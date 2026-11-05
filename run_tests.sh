#!/usr/bin/env bash
# SDET Technical Exercise - Linux/macOS Execution Script

set -e
echo "[INFO] Running SDET Automation Test Suite..."
python3 run_tests.py "$@"
