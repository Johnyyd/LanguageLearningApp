@echo off
REM =====================================================================
REM 🧪 Automated Test Runner Script (Windows VirtualEnv Auto-Activation)
REM =====================================================================

cd /d "%~dp0"

echo 🟢 [Step 1/3] Checking Python virtual environment...
if not exist ".venv" (
    echo ⚠️ Virtual environment not found. Initializing via setup_env.bat...
    call setup_env.bat
)

echo 🟢 [Step 2/3] Activating virtual environment (.venv)...
call .venv\Scripts\activate.bat

echo 🟢 [Step 3/3] Executing MiMo automated test suite...
python test_all_features.py
pause
