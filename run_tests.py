#!/usr/bin/env python3
"""
Custom Test Runner and Report Generator for SDET Robot Framework Automation Suite.

Provides convenient flags for test filtering, browser selection, parallel runs,
and executive test execution reporting.
"""

import sys
import os
import argparse
import subprocess
import time

# Ensure UTF-8 output encoding across all operating systems
if sys.stdout.encoding and sys.stdout.encoding.lower() != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
        sys.stderr.reconfigure(encoding='utf-8', errors='replace')
    except Exception:
        pass


def main():
    parser = argparse.ArgumentParser(description="SDET Robot Framework Test Runner")
    parser.add_argument("-t", "--tags", help="Filter tests by tag expression (e.g. smoke, visual, self_healing)")
    parser.add_argument("-s", "--suite", help="Execute specific test suite file name or pattern")
    parser.add_argument("-b", "--browser", default="headlesschrome", help="Browser to execute against (default: headlesschrome)")
    parser.add_argument("-o", "--outputdir", default="reports", help="Directory for test logs and reports")
    parser.add_argument("--variable", "-v", action="append", default=[], help="Pass custom Robot Framework variables (KEY:VALUE)")

    args = parser.parse_args()

    project_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(project_dir, args.outputdir)
    tests_dir = os.path.join(project_dir, "tests")

    os.makedirs(output_dir, exist_ok=True)

    cmd = [
        sys.executable,
        "-m", "robot",
        "--outputdir", output_dir,
        "--variable", f"BROWSER:{args.browser}",
        "--loglevel", "INFO",
        "--timestampoutputs",
        "--reportbackground", "white:white:white"
    ]

    for var in args.variable:
        cmd.extend(["--variable", var])

    if args.tags:
        cmd.extend(["--include", args.tags])

    if args.suite:
        suite_path = os.path.join(tests_dir, args.suite)
        if not suite_path.endswith(".robot"):
            suite_path += ".robot"
        cmd.append(suite_path)
    else:
        cmd.append(tests_dir)

    print("=" * 70)
    print("🚀  SDET AUTOMATION TEST SUITE RUNNER")
    print(f"📁 Target Tests: {args.suite or 'All Suites in /tests'}")
    print(f"🏷️  Tag Filter:  {args.tags or 'None (All tests)'}")
    print(f"🌐 Browser:     {args.browser}")
    print(f"📊 Output Dir:  {output_dir}")
    print("=" * 70)

    start_time = time.time()
    result = subprocess.run(cmd)
    duration = round(time.time() - start_time, 2)

    # Maintain canonical report.html and log.html alongside timestamped historical files
    import shutil
    import glob

    canonical_report = os.path.join(output_dir, "report.html")
    canonical_log = os.path.join(output_dir, "log.html")

    report_files = [f for f in glob.glob(os.path.join(output_dir, "report-*.html"))]
    log_files = [f for f in glob.glob(os.path.join(output_dir, "log-*.html"))]

    if report_files:
        latest_report = max(report_files, key=os.path.getmtime)
        try:
            shutil.copy2(latest_report, canonical_report)
        except Exception:
            pass

    if log_files:
        latest_log = max(log_files, key=os.path.getmtime)
        try:
            shutil.copy2(latest_log, canonical_log)
        except Exception:
            pass

    print("=" * 70)
    print(f"⏱️  Execution completed in {duration} seconds.")
    print(f"📄 Report HTML: {canonical_report}")
    print(f"📑 Log HTML:    {canonical_log}")
    print("=" * 70)

    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
