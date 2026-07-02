@echo off
REM =====================================================================
REM 🚀 Backend Environment One-Click Bootstrap Script (Windows)
REM =====================================================================

echo 🟢 [Step 1/4] Checking Python environment...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Python could not be found. Please install Python 3.10+ and add it to PATH.
    exit /b 1
)

echo 🟢 [Step 2/4] Setting up Python virtual environment (.venv)...
if not exist ".venv" (
    python -m venv .venv
    echo ✅ Virtual environment created at backend\.venv
) else (
    echo ℹ️ Virtual environment already exists.
)

REM Activate venv
call .venv\Scripts\activate.bat

echo 🟢 [Step 3/4] Installing / Updating Python dependencies...
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
if errorlevel 1 (
    echo ❌ Error occurred while installing dependencies.
    exit /b 1
)
echo ✅ All dependencies installed successfully.

echo 🟢 [Step 4/4] Configuring environment variables (.env)...
if not exist ".env" (
    if exist ".env.example" (
        copy .env.example .env >nul
        echo ✅ Created .env from .env.example template.
    ) else (
        echo ⚠️ Warning: .env.example not found.
    )
) else (
    echo ℹ️ .env file already exists.
)

echo.
echo 🎉 BACKEND ENVIRONMENT READY!
echo 👉 To start coding and running the local server:
echo    1. Activate virtual environment: .venv\Scripts\activate
echo    2. Start Uvicorn dev server:    uvicorn main:app --host 0.0.0.0 --port 1112 --reload
echo    OR use Docker Compose:          docker-compose up --build -d
echo.
pause
