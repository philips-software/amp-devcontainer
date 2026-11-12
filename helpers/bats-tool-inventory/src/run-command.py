"""Run a Linux smoke command without exposing Bats descriptors to its children."""

import ctypes
import math
import os
from pathlib import Path
import select
import signal
import subprocess
import sys
import time


OUTPUT_LIMIT = 16384
KILL_AFTER = 5


def children():
    return Path(f"/proc/self/task/{os.getpid()}/children").read_text().split()


def cleanup():
    # As a subreaper we adopt orphaned descendants, even those using setsid().
    # Repeatedly terminate and reap direct children as their parents disappear.
    deadline = time.monotonic() + KILL_AFTER
    while True:
        try:
            while os.waitpid(-1, os.WNOHANG)[0]:
                pass
        except ChildProcessError:
            return
        now = time.monotonic()
        for pid in children():
            try:
                os.kill(int(pid), signal.SIGTERM if now < deadline else signal.SIGKILL)
            except ProcessLookupError:
                pass
        if now >= deadline + 1:
            raise RuntimeError("could not reap smoke command descendants after SIGKILL")
        time.sleep(0.01)


def interrupted(signum, _frame):
    raise SystemExit(128 + signum)


def main():
    seconds = float(sys.argv[1])
    if not math.isfinite(seconds) or seconds <= 0:
        raise ValueError("timeout must be a positive, finite number of seconds")

    # PR_SET_CHILD_SUBREAPER: do not delegate orphan reaping to the container's PID 1.
    libc = ctypes.CDLL(None, use_errno=True)
    if libc.prctl(36, 1, 0, 0, 0) != 0:
        raise OSError(ctypes.get_errno(), "cannot enable child subreaper")
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGINT, interrupted)

    captured = bytearray()
    truncated = False
    timed_out = False
    deadline = time.monotonic() + seconds
    process = None
    try:
        process = subprocess.Popen(
            sys.argv[2:],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            close_fds=True,
            start_new_session=True,
        )
        eof = False
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                timed_out = True
                break
            if not eof and select.select([process.stdout], [], [], min(0.05, remaining))[0]:
                chunk = os.read(process.stdout.fileno(), 65536)
                eof = not chunk
                available = OUTPUT_LIMIT - len(captured)
                captured.extend(chunk[:available])
                truncated |= len(chunk) > available
            elif eof:
                time.sleep(min(0.01, remaining))
            if process.poll() is not None and eof:
                break
        status = 124 if timed_out else process.returncode
        if status < 0:
            status = 128 - status
    except OSError as error:
        print(f"cannot start smoke command: {error}")
        status = 127 if isinstance(error, FileNotFoundError) else 126
    finally:
        if process is not None:
            process.stdout.close()
        cleanup()
        if process is not None:
            process.wait()

    # Escape XML-forbidden control bytes (including NUL) before Bats sees them.
    text = captured.decode("utf-8", errors="replace")
    text = "".join(
        char if char in "\t\n\r" or (ord(char) >= 32 and ord(char) not in (0xFFFE, 0xFFFF))
        else f"\\x{ord(char):02x}"
        for char in text
    )
    if text:
        print(text)
    if truncated:
        print(f"[output truncated after {OUTPUT_LIMIT} bytes]")
    if timed_out:
        print(f"[timed out after {seconds:g}s; termination grace {KILL_AFTER}s; exit code 124]")
    return status


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, RuntimeError, OSError) as error:
        print(f"smoke command supervisor failed: {error}", file=sys.stderr)
        sys.exit(125)
