"""Compile and verify the included in-memory tracker roles using Swift 6."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import signal
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent
APP_FILES = ("SimpleTrackerApp.swift", "ContentView.swift", "TrackerItem.swift", "TrackerStore.swift")


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def run(command, timeout, events):
    event = dict(parentTaskId="swift-tracker-contracts", parentPid=os.getpid(),
                 cwd=str(ROOT), command=command, startTime=now(), timeoutSeconds=timeout,
                 hostLoadAtStart=os.getloadavg()[0])
    child = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE, start_new_session=True)
    event["pid"] = child.pid
    events.append(dict(event, event="start"))
    cleanup = "owned process exited and reaped"
    stdout, stderr = b"", b""
    try:
        stdout, stderr = child.communicate(timeout=timeout)
    except BaseException:
        if child.poll() is None:
            os.killpg(child.pid, signal.SIGTERM)
            try:
                stdout, stderr = child.communicate(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(child.pid, signal.SIGKILL)
                stdout, stderr = child.communicate()
        cleanup = "owned process group terminated and reaped"
        raise
    finally:
        events.append(dict(event, event="end", endTime=now(), exitCode=child.returncode,
                           childProcessGroupCleanup=cleanup,
                           stdout=stdout.decode(errors="replace"), stderr=stderr.decode(errors="replace")))
    if child.returncode:
        raise RuntimeError(stderr.decode(errors="replace") or stdout.decode(errors="replace"))
    return stdout


def main():
    def stop(signum, _frame):
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--proof", type=Path)
    parser.add_argument("--ios", action="store_true", help="Also typecheck the complete roles with the installed iOS SDK")
    args = parser.parse_args()
    if args.proof:
        assert not args.proof.exists(), "Use a new proof path to preserve prior attempts"
        args.proof.parent.mkdir(parents=True, exist_ok=True)
    roles = [role for role in ("starter", "solution") if (ROOT / role).is_dir()]
    assert roles, "Include a starter or solution app folder"
    for role in roles:
        assert {p.name for p in (ROOT / role).glob("*.swift")} == set(APP_FILES), "Incomplete app role: " + role
    if len(roles) == 2:
        for name in ("TrackerItem.swift", "TrackerStore.swift"):
            assert (ROOT / "starter" / name).read_bytes() == (ROOT / "solution" / name).read_bytes(), "Shared " + name + " must match between roles"
    inputs = [Path(__file__).resolve(), ROOT / "tests/TrackerContracts.swift"]
    inputs += [ROOT / role / name for role in roles for name in APP_FILES]
    hashes = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs}
    events = []
    result = dict(at=now(), accepted=False, externalRequests=0, sourceRoles=roles, sourceHashes=hashes, roleContracts=[])
    try:
        compiler = shutil.which("swiftc")
        assert compiler, "Install the course's Swift 6/Xcode toolchain first"
        result["compiler"] = run([compiler, "--version"], 30, events).decode().strip()
        if args.ios:
            assert platform.system() == "Darwin", "iOS typechecking requires an installed Xcode SDK"
            sdk = run(["/usr/bin/xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"], 30, events).decode().strip()
            target = platform.machine() + "-apple-ios17.0-simulator"
        with tempfile.TemporaryDirectory(prefix="swift-tracker-contracts-") as temporary:
            work = Path(temporary)
            (work / ".metadata_never_index").touch()
            for role in roles:
                binary = work / (role + "-contracts")
                run([compiler, "-swift-version", "6", "-parse-as-library", "-module-cache-path", str(work / "module-cache"),
                     str(ROOT / role / "TrackerItem.swift"), str(ROOT / role / "TrackerStore.swift"),
                     str(ROOT / "tests/TrackerContracts.swift"), "-o", str(binary)], 180, events)
                contracts = json.loads(run([str(binary)], 30, events))
                assert contracts["accepted"] and contracts["passed"] == len(contracts["checks"]) >= 29
                result["roleContracts"].append(dict(role=role, **contracts))
                if args.ios:
                    run(["/usr/bin/xcrun", "swiftc", "-typecheck", "-parse-as-library", "-swift-version", "6", "-sdk", sdk,
                         "-target", target, "-module-cache-path", str(work / "ios-module-cache"),
                         *(str(ROOT / role / name) for name in APP_FILES)], 180, events)
            if args.ios:
                result.update(iosSDK=sdk, iosTarget=target, iosRolesTypechecked=roles, iosSimulatorExecutionVerified=False)
        assert all(hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest for name, digest in hashes.items()), "Source changed during verification"
        result["accepted"] = True
    finally:
        result.update(finishedAt=now(), processes=events)
        if args.proof:
            args.proof.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({key: value for key, value in result.items() if key != "processes"}, indent=2))


if __name__ == "__main__":
    main()
