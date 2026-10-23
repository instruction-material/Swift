"""Verify the included networking app roles using Swift 6 and owned loopback HTTP."""
import argparse
import datetime
import hashlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import platform
import shutil
import signal
import subprocess
import tempfile
import threading
import time

ROOT = Path(__file__).resolve().parent
APP_FILES = ("APIReferenceApp.swift", "ContentView.swift", "ReferenceClient.swift", "ReferenceStore.swift")


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def run(command, timeout, events):
    event = dict(parentTaskId="swift-reference-network-contracts", parentPid=os.getpid(),
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


class Fixture(BaseHTTPRequestHandler):
    def do_GET(self):
        cases = {
            "/posts": (200, b'[{"id":42,"title":"Local fixture entry","body":"Owned HTTP fixture."}]'),
            "/unavailable": (503, b"[]"),
            "/malformed": (200, b"not JSON"),
            "/empty": (200, b"[]"),
        }
        status, body = cases.get(self.path, (404, b"[]"))
        if self.headers.get("Accept") != "application/json":
            status, body = 400, b"[]"
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *_args):
        pass


def main():
    def stop(signum, _frame):
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--proof", type=Path)
    parser.add_argument("--ios", action="store_true", help="Also typecheck the included app roles against the installed iOS SDK")
    args = parser.parse_args()
    if args.proof:
        assert not args.proof.exists(), "Use a new proof path to preserve prior attempts"
        args.proof.parent.mkdir(parents=True, exist_ok=True)
    roles = [role for role in ("starter", "solution") if (ROOT / role).is_dir()]
    assert roles, "Include a starter or solution app folder"
    for role in roles:
        missing = [name for name in APP_FILES if not (ROOT / role / name).is_file()]
        assert not missing, "Missing Swift app files for " + role + ": " + ", ".join(missing)
    events = []
    result = dict(at=now(), accepted=False, externalRequests=0, sourceRoles=roles)
    inputs = sorted([*(path for role in roles for path in (ROOT / role).glob("*.swift")),
                     ROOT / "tests/ReferenceContracts.swift", Path(__file__).resolve()])
    result["sourceHashes"] = {
        str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in inputs
    }
    server = None
    thread = None
    try:
        if platform.system() == "Darwin":
            deadline = time.monotonic() + 300
            result["entryLoadSamples"] = []
            while True:
                load = os.getloadavg()[0]
                result["entryLoadSamples"].append(dict(at=now(), load=load))
                if load <= 8:
                    break
                assert time.monotonic() < deadline, "Mac load must settle below8 before starting this verification job"
                time.sleep(10)
        if len(roles) == 2:
            for name in ["ReferenceClient.swift", "ReferenceStore.swift"]:
                assert (ROOT / "starter" / name).read_bytes() == (ROOT / "solution" / name).read_bytes()
        compiler = shutil.which("swiftc")
        assert compiler, "Install the course's Swift 6/Xcode toolchain first"
        result["compiler"] = run([compiler, "--version"], 30, events).decode().strip()
        with tempfile.TemporaryDirectory(prefix="swift-reference-contracts-") as temporary:
            work = Path(temporary)
            (work / ".metadata_never_index").touch()
            binary = work / "contracts"
            run([compiler, "-swift-version", "6", "-parse-as-library",
                 "-module-cache-path", str(work / "module-cache"),
                 str(ROOT / roles[0] / "ReferenceClient.swift"),
                 str(ROOT / roles[0] / "ReferenceStore.swift"),
                 str(ROOT / "tests/ReferenceContracts.swift"), "-o", str(binary)], 180, events)
            server = ThreadingHTTPServer(("127.0.0.1", 0), Fixture)
            server.daemon_threads = True
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            output = run([str(binary), "http://127.0.0.1:" + str(server.server_port)], 60, events)
            contracts = json.loads(output)
            assert contracts["accepted"] and contracts["passed"] == len(contracts["checks"]) >= 25
            result.update({key: value for key, value in contracts.items() if key != "accepted"})
            result["contractsAccepted"] = True
            if args.ios:
                assert platform.system() == "Darwin", "The iOS checks require an installed Xcode SDK"
                sdk = run(["/usr/bin/xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"], 30, events).decode().strip()
                target = platform.machine() + "-apple-ios17.0-simulator"
                for role in roles:
                    sources = sorted(str(p) for p in (ROOT / role).glob("*.swift"))
                    run(["/usr/bin/xcrun", "swiftc", "-typecheck", "-parse-as-library", "-swift-version", "6",
                         "-sdk", sdk, "-target", target, "-module-cache-path", str(work / "ios-module-cache"),
                         *sources], 180, events)
                result.update(iosSDK=sdk, iosTarget=target, iosRolesTypechecked=roles,
                              iosSimulatorExecutionVerified=False)
            assert all(hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest
                       for name, digest in result["sourceHashes"].items()), "Source changed during verification"
            result["accepted"] = True
    finally:
        if server:
            server.shutdown()
            server.server_close()
        if thread:
            thread.join(timeout=5)
            assert not thread.is_alive()
        result.update(finishedAt=now(), ownedServerClosed=True, processes=events)
        if args.proof:
            args.proof.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({key: value for key, value in result.items() if key != "processes"}, indent=2))


if __name__ == "__main__":
    main()
