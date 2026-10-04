#!/usr/bin/env bash
# setup.sh — create or rebuild the project's virtual environment
set -euo pipefail

rm -rf .venv
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt

echo "Done. Activate with: source .venv/bin/activate"
