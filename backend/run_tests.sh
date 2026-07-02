#!/usr/bin/env bash
# =====================================================================
# 🧪 Automated Test Runner Script (With VirtualEnv Auto-Activation)
# =====================================================================

set -e

# Change directory to backend script location
cd "$(dirname "$0")"

echo "🟢 [Step 1/3] Checking Python virtual environment..."
if [ ! -d ".venv" ]; then
    echo "⚠️ Virtual environment not found. Initializing via setup_env.sh..."
    bash setup_env.sh
fi

echo "🟢 [Step 2/2] Executing MiMo automated test suite via VirtualEnv..."
./.venv/bin/python3 test_all_features.py
