"""Exercise complete, isolated source-role ZIPs without the other app role."""
import argparse
import datetime
import hashlib
import io
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
APP_FILES = ("PersistentTrackerApp.swift", "ContentView.swift", "TrackerRecord.swift", "TrackerPersistence.swift")
SUPPORT_FILES = ("README.md", "verify-persistence.py", "tests/PersistenceContracts.swift",
                 "Package.swift", "tests/PersistenceTests.swift")
# Version/SDK90 + compile180 + models120 + eight process phases480 + iOS180 + SwiftTesting300 + cleanup60.
VERIFIER_TIMEOUT_SECONDS = 1440


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def execute(command, cwd, events):
    event = dict(parentTaskId="swiftdata-tracker-single-role-export-contracts", parentPid=os.getpid(),
                 cwd=str(cwd), command=command, startTime=now(), timeoutSeconds=VERIFIER_TIMEOUT_SECONDS)
    child = subprocess.Popen(command, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                             start_new_session=True)
    event["pid"] = child.pid
    events.append(dict(event, event="start"))
    cleanup = "owned process exited and reaped"
    stdout, stderr = b"", b""
    try:
        stdout, stderr = child.communicate(timeout=VERIFIER_TIMEOUT_SECONDS)
    except BaseException:
        if child.poll() is None:
            os.killpg(child.pid, signal.SIGTERM)
            try:
                stdout, stderr = child.communicate(timeout=10)
            except subprocess.TimeoutExpired:
                os.killpg(child.pid, signal.SIGKILL)
                stdout, stderr = child.communicate()
        cleanup = "owned process group terminated and reaped"
        raise
    finally:
        events.append(dict(event, event="end", endTime=now(), exitCode=child.returncode,
                           childProcessGroupCleanup=cleanup,
                           stdout=stdout.decode(errors="replace"), stderr=stderr.decode(errors="replace")))
    return child.returncode, stdout, stderr


def role_zip(role):
    names = [*(role + "/" + name for name in APP_FILES), *SUPPORT_FILES]
    raw = io.BytesIO()
    with zipfile.ZipFile(raw, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for name in names:
            archive.writestr(name, (ROOT / name).read_bytes())
    return raw.getvalue(), {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest() for name in names}


def main():
    def stop(signum, _frame):
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ios", action="store_true")
    parser.add_argument("--proof", type=Path)
    args = parser.parse_args()
    if args.proof:
        assert not args.proof.exists(), "Use a fresh proof path"
        args.proof.parent.mkdir(parents=True, exist_ok=True)
    archive_dir = args.proof.parent / (args.proof.stem + "-archives") if args.proof else None
    if archive_dir:
        archive_dir.mkdir(exist_ok=False)
    events, checks, failures = [], [], []
    result = dict(at=now(), accepted=False, checks=checks, processes=events)
    try:
        with tempfile.TemporaryDirectory(prefix="swift-single-role-exports-") as directory:
            temporary = Path(directory)
            (temporary / ".metadata_never_index").touch()
            for role in ("starter", "solution"):
                work = temporary / role
                work.mkdir()
                raw, hashes = role_zip(role)
                if archive_dir:
                    (archive_dir / (role + ".zip")).write_bytes(raw)
                with zipfile.ZipFile(io.BytesIO(raw)) as archive:
                    assert len(archive.infolist()) == 9
                    archive.extractall(work)
                assert not (work / ("solution" if role == "starter" else "starter")).exists()
                assert all(hashlib.sha256((work / name).read_bytes()).hexdigest() == digest for name, digest in hashes.items())
                proof = temporary / (role + "-proof.json")
                command = [sys.executable, str(work / "verify-persistence.py"), "--proof", str(proof)]
                if args.ios:
                    command.append("--ios")
                code, stdout, stderr = execute(command, work, events)
                check = dict(name=role + " standalone ZIP", role=role, exitCode=code,
                             archiveSha256=hashlib.sha256(raw).hexdigest(), sourceHashes=hashes)
                checks.append(check)
                if code != 0:
                    failures.append(role + ": " + stderr.decode(errors="replace"))
                    check["passed"] = False
                    continue
                evidence = json.loads(proof.read_text())
                assert evidence["accepted"] and len(evidence["roleContracts"]) == 1
                assert evidence["roleContracts"][0]["passed"] == 28
                assert evidence["sourceRoles"] == [role]
                assert evidence["externalRequests"] == 0
                assert len(evidence["roleContracts"][0]["processRelaunchPhases"]) == 8
                assert evidence["swiftTesting"]["passed"] == 5 and evidence["swiftTesting"]["role"] == role
                if args.ios:
                    assert evidence["iosRolesTypechecked"] == [role]
                check.update(passed=True, contractProof=evidence)
            incomplete = temporary / "incomplete"
            incomplete.mkdir()
            raw, _ = role_zip("starter")
            with zipfile.ZipFile(io.BytesIO(raw)) as archive:
                archive.extractall(incomplete)
            (incomplete / "starter/PersistentTrackerApp.swift").unlink()
            code, _, stderr = execute([sys.executable, str(incomplete / "verify-persistence.py")], incomplete, events)
            passed = code != 0 and "Incomplete app role" in stderr.decode(errors="replace")
            checks.append(dict(name="incomplete app role is rejected", exitCode=code, passed=passed))
            if not passed:
                failures.append("An incomplete app role was not rejected with its missing source files")
            full = temporary / "mismatched-full-pack"
            full.mkdir()
            for role in ("starter", "solution"):
                raw, _ = role_zip(role)
                with zipfile.ZipFile(io.BytesIO(raw)) as archive:
                    archive.extractall(full)
            client = full / "starter/TrackerRecord.swift"
            client.write_bytes(client.read_bytes() + b"\n// Different model revision\n")
            proof = temporary / "mismatched-proof.json"
            code, _, stderr = execute([sys.executable, str(full / "verify-persistence.py"), "--proof", str(proof)], full, events)
            evidence = json.loads(proof.read_text()) if proof.exists() else {}
            passed = code != 0 and "Shared TrackerRecord.swift must match between roles" in stderr.decode(errors="replace") and not evidence.get("processes") and not evidence.get("accepted")
            checks.append(dict(name="full-pack model parity is preserved", exitCode=code, passed=passed))
            if not passed:
                failures.append("A mismatched full pack was not rejected before compiler startup")
            result["accepted"] = not failures and len(checks) == 4
            result["failures"] = failures
    finally:
        result["finishedAt"] = now()
        if args.proof:
            args.proof.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({key: value for key, value in result.items() if key != "processes"}, indent=2))
    if not result["accepted"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
