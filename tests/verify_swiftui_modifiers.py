"""Typecheck reference app roles and reject modifiers that wrap their own view."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import signal
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
CASES = [
    ("SAD2-Media-Gallery-App", "ArtworkCard", "padding", "        .padding(14)", "        padding(14)"),
    ("SAD3-Multi-Tab-Hobby-App", "ActivityDetailView", "foregroundStyle", "                .foregroundStyle(.blue)", "            foregroundStyle(.blue)"),
    ("SAD-Swift-UI-Shapes-Studio", "ContentView", "overlay",
     "                                    .overlay(\n"
     "                                        Text(\"AD4\")\n"
     "                                            .font(.headline.weight(.semibold))\n"
     "                                    )",
     "                                overlay(\n"
     "                                    Text(\"AD4\")\n"
     "                                        .font(.headline.weight(.semibold))\n"
     "                                )"),
]

def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()

def implicit_self_calls(ast, view, modifier):
    return [line.strip() for line in ast.splitlines()
            if "declref_expr" in line and re.search(r"View extension\." + re.escape(modifier) + r"(?:\s|\()", line)
            and re.search(r"Self -> " + re.escape(view) + r"(?:\s|\))", line)]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--proof", type=Path, required=True)
    args = parser.parse_args()
    assert platform.system() == "Darwin", "An installed Xcode iOS SDK is required"
    proof_path = args.proof.resolve()
    proof_path.parent.mkdir(parents=True, exist_ok=True)
    logs = proof_path.parent / "swiftui-modifier-logs"
    logs.mkdir(exist_ok=True)
    processes = []
    record = dict(startedAt=now(), accepted=False, positiveRoles=[], negativeControls=[], welcomeRoles=[],
                  processes=processes, nativeUIExecutionVerified=False)
    task = "swiftui-modifier-contracts-" + os.environ.get("GITHUB_RUN_ID", str(os.getpid()))

    def save():
        proof_path.write_text(json.dumps(record, indent=2) + "\n")

    def stop(signum, _frame):
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)

    def run(label, command):
        child = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE, start_new_session=True)
        event = dict(parentTaskId=task, parentPid=os.getpid(), cwd=str(ROOT),
                     pid=child.pid, command=command, startTime=now(), timeoutSeconds=240)
        processes.append(dict(event, event="start"))
        save()
        stdout, stderr = b"", b""
        cleanup = "owned process exited and reaped"
        try:
            stdout, stderr = child.communicate(timeout=240)
        except BaseException:
            if child.poll() is None:
                os.killpg(child.pid, signal.SIGTERM)
                try:
                    stdout, stderr = child.communicate(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(child.pid, signal.SIGKILL)
                    stdout, stderr = child.communicate()
            cleanup = "owned child process group terminated and reaped"
            raise
        finally:
            (logs / (label + ".stdout.txt")).write_bytes(stdout)
            (logs / (label + ".stderr.txt")).write_bytes(stderr)
            processes.append(dict(event, event="end", endTime=now(), exitCode=child.returncode,
                                  stdoutSHA256=hashlib.sha256(stdout).hexdigest(),
                                  stderrSHA256=hashlib.sha256(stderr).hexdigest(),
                                  childProcessGroupCleanup=cleanup))
            save()
        assert child.returncode == 0, (label, stderr.decode(errors="replace")[-4000:])
        return stdout, stderr

    sdk = run("sdk-path", ["/usr/bin/xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"])[0].decode().strip()
    record.update(sdk=sdk, swiftVersion=run("swift-version", ["/usr/bin/xcrun", "swiftc", "--version"])[0].decode().strip(),
                  xcodeVersion=run("xcode-version", ["/usr/bin/xcrun", "xcodebuild", "-version"])[0].decode().strip())
    arch = platform.machine()
    assert arch in ["arm64", "x86_64"]
    work = Path(tempfile.mkdtemp(prefix="swiftui-modifiers-", dir=proof_path.parent))
    (work / ".metadata_never_index").touch()

    def check(pack, role, view, modifier, sources, negative):
        label = pack + "-" + role + ("-negative" if negative else "")
        command = ["/usr/bin/xcrun", "swiftc", "-dump-ast", "-parse-as-library", "-swift-version", "6",
                   "-sdk", sdk, "-target", arch + "-apple-ios17.0-simulator",
                   "-module-cache-path", str(work / "module-cache"), *map(str, sources)]
        stdout, stderr = run(label, command)
        # Supported Swift releases have emitted typed ASTs on either stream.
        ast = stdout.decode(errors="replace") + stderr.decode(errors="replace")
        assert "(source_file" in ast and "(struct_decl" in ast, label
        matches = implicit_self_calls(ast, view, modifier)
        assert bool(matches) == negative, (label, matches[:2])
        row = dict(pack=pack, role=role, actualIOSSDKTyped=True,
                   sourceHashes={source.name: hashlib.sha256(source.read_bytes()).hexdigest() for source in sources},
                   implicitSelfModifierExpressions=len(matches),
                   astSHA256=hashlib.sha256(ast.encode()).hexdigest(),
                   evidence=matches[:1], accepted=not matches, rejected=bool(matches))
        record["negativeControls" if negative else "positiveRoles"].append(row)
        save()

    try:
        for pack, view, modifier, fixed, broken in CASES:
            for role in ["starter", "solution"]:
                sources = sorted((ROOT / pack / role).glob("*.swift"))
                assert len(sources) == 2
                check(pack, role, view, modifier, sources, False)
            isolated = work / pack
            isolated.mkdir()
            sources = []
            for source in sorted((ROOT / pack / "solution").glob("*.swift")):
                raw = source.read_bytes()
                if source.name == "ContentView.swift":
                    newline = b"\r\n" if b"\r\n" in raw else b"\n"
                    fixed_bytes = fixed.encode().replace(b"\n", newline)
                    broken_bytes = broken.encode().replace(b"\n", newline)
                    assert raw.count(fixed_bytes) == 1
                    raw = raw.replace(fixed_bytes, broken_bytes, 1)
                destination = isolated / source.name
                destination.write_bytes(raw)
                sources.append(destination)
            check(pack, "solution", view, modifier, sources, True)
        for role in ["starter", "solution"]:
            sources = sorted((ROOT / "SAD1-Welcome-Profile-App" / role).glob("*.swift"))
            assert len(sources) == 2
            run("welcome-" + role, ["/usr/bin/xcrun", "swiftc", "-typecheck", "-parse-as-library", "-swift-version", "6",
                "-sdk", sdk, "-target", arch + "-apple-ios17.0-simulator",
                "-module-cache-path", str(work / "module-cache"), *map(str, sources)])
            record["welcomeRoles"].append(dict(role=role, actualIOSSDKTyped=True,
                sourceHashes={source.name: hashlib.sha256(source.read_bytes()).hexdigest() for source in sources}))
            save()
        record.update(accepted=len(record["positiveRoles"]) == len(CASES) * 2 and len(record["negativeControls"]) == len(CASES) and len(record["welcomeRoles"]) == 2,
                      scope="Actual SDK-typed view composition with all original missing-dot faults rejected. Native app rendering remains a separate check.")
    finally:
        shutil.rmtree(work)
        record.update(endedAt=now(), ownedTemporarySourceRemoved=not work.exists())
        save()
    assert record["accepted"]
    print(json.dumps({k: v for k, v in record.items() if k != "processes"}, indent=2))

if __name__ == "__main__":
    main()
