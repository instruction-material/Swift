"""Verify SwiftData CRUD, isolated containers, failure rollback and process relaunch."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import platform
import signal
import subprocess
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent
APP_FILES = ("PersistentTrackerApp.swift", "ContentView.swift", "TrackerRecord.swift", "TrackerPersistence.swift")


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def run(command, timeout, events):
    event = dict(parentTaskId="swiftdata-tracker-contracts", parentPid=os.getpid(),
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


def decode(output):
    return json.loads(output.decode().strip().splitlines()[-1])


def main():
    def stop(signum, _frame):
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--proof", type=Path)
    parser.add_argument("--ios", action="store_true", help="Also typecheck the complete iOS roles")
    args = parser.parse_args()
    assert platform.system() == "Darwin", "SwiftData verification requires macOS 14 or later with Xcode installed"
    if args.proof:
        assert not args.proof.exists(), "Use a new proof path to preserve previous attempts"
        args.proof.parent.mkdir(parents=True, exist_ok=True)
    roles = [role for role in ("starter", "solution") if (ROOT / role).is_dir()]
    assert roles, "Include a starter or solution app folder"
    for role in roles:
        assert {p.name for p in (ROOT / role).glob("*.swift")} == set(APP_FILES), "Incomplete app role: " + role
    if len(roles) == 2:
        for name in ("TrackerRecord.swift", "TrackerPersistence.swift"):
            assert (ROOT / "starter" / name).read_bytes() == (ROOT / "solution" / name).read_bytes(), "Shared " + name + " must match between roles"
    inputs = [Path(__file__).resolve(), ROOT / "tests/PersistenceContracts.swift",
              ROOT / "Package.swift", ROOT / "tests/PersistenceTests.swift"]
    inputs += [ROOT / role / name for role in roles for name in APP_FILES]
    hashes = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs}
    events = []
    result = dict(at=now(), accepted=False, externalRequests=0, sourceRoles=roles, sourceHashes=hashes, roleContracts=[])
    try:
        result["compiler"] = run(["/usr/bin/xcrun", "swiftc", "--version"], 30, events).decode().strip()
        mac_sdk = run(["/usr/bin/xcrun", "--sdk", "macosx", "--show-sdk-path"], 30, events).decode().strip()
        if args.ios:
            ios_sdk = run(["/usr/bin/xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"], 30, events).decode().strip()
        with tempfile.TemporaryDirectory(prefix="swiftdata-tracker-contracts-") as temporary:
            work = Path(temporary)
            (work / ".metadata_never_index").touch()
            for role in roles:
                binary = work / (role + "-contracts")
                run(["/usr/bin/xcrun", "swiftc", "-swift-version", "6", "-parse-as-library", "-sdk", mac_sdk,
                     "-target", platform.machine() + "-apple-macos14.0", "-module-cache-path", str(work / "module-cache"),
                     str(ROOT / role / "TrackerRecord.swift"), str(ROOT / role / "TrackerPersistence.swift"),
                     str(ROOT / "tests/PersistenceContracts.swift"), "-o", str(binary)], 180, events)
                contracts = decode(run([str(binary)], 120, events))
                assert contracts["accepted"] and contracts["passed"] == len(contracts["checks"]) >= 28
                store = work / (role + ".store")
                phases = []
                identity = None
                for phase in ["write", "read", "edit", "read-edited", "read-only", "read-edited", "delete", "read-empty"]:
                    command = [str(binary), phase, str(store)]
                    if identity:
                        command.append(identity)
                    outcome = decode(run(command, 60, events))
                    assert outcome["accepted"] and outcome["phase"] == phase
                    if phase == "write":
                        identity = outcome["id"]
                    phases.append(outcome)
                result["roleContracts"].append(dict(role=role, **contracts, processRelaunchPhases=phases))
                if args.ios:
                    run(["/usr/bin/xcrun", "swiftc", "-typecheck", "-parse-as-library", "-swift-version", "6", "-sdk", ios_sdk,
                         "-target", platform.machine() + "-apple-ios17.0-simulator", "-module-cache-path", str(work / "ios-module-cache"),
                         *(str(ROOT / role / name) for name in APP_FILES)], 180, events)
            xml = work / "swift-testing.xml"
            run(["/usr/bin/xcrun", "swift", "test", "--package-path", str(ROOT),
                 "--scratch-path", str(work / "swift-testing-build"), "--cache-path", str(work / "swiftpm-cache"),
                 "--manifest-cache", "local", "--jobs", "1", "--disable-index-store",
                 "--disable-xctest", "--enable-swift-testing", "--xunit-output", str(xml)], 300, events)
            tree = ET.parse(xml)
            cases = tree.findall(".//testcase")
            assert len(cases) == 5
            assert not tree.findall(".//failure") and not tree.findall(".//error") and not tree.findall(".//skipped")
            assert all(int(suite.get(key, "0")) == 0 for suite in tree.iter("testsuite") for key in ("failures", "errors", "skipped"))
            result["swiftTesting"] = dict(passed=5, failed=0, skipped=0,
                role="solution" if "solution" in roles else "starter",
                cases=[case.get("name") for case in cases], xunitXML=xml.read_text(),
                xunitSha256=hashlib.sha256(xml.read_bytes()).hexdigest())
            if args.ios:
                result.update(iosSDK=ios_sdk, iosRolesTypechecked=roles, iosSimulatorExecutionVerified=False)
        assert all(hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest for name, digest in hashes.items()), "Source changed during verification"
        result["accepted"] = True
    finally:
        result.update(finishedAt=now(), processes=events)
        if args.proof:
            args.proof.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({key: value for key, value in result.items() if key != "processes"}, indent=2))


if __name__ == "__main__":
    main()
