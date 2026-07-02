#!/usr/bin/env bash
# =====================================================================
# 🚀 Backend Environment One-Click Bootstrap Script (Linux / macOS)
# =====================================================================

set -e

echo "🟢 [Step 1/4] Checking Python environment..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: python3 could not be found. Please install Python 3.10+."
    exit 1
fi

echo "🟢 [Step 2/4] Setting up Python virtual environment (.venv)..."
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "✅ Virtual environment created at backend/.venv"
else
    echo "ℹ️ Virtual environment already exists."
fi

# Activate venv
source .venv/bin/activate

echo "🟢 [Step 3/4] Installing / Updating Python dependencies inside .venv..."
./.venv/bin/pip install --upgrade pip setuptools wheel
./.venv/bin/pip install -r requirements.txt
echo "✅ All dependencies installed successfully inside VirtualEnv."

echo "🟢 [Step 4/4] Configuring environment variables (.env)..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✅ Created .env from .env.example template."
    else
        echo "⚠️ Warning: .env.example not found."
    fi
else
    echo "ℹ️ .env file already exists."
fi

echo ""
echo "🎉 BACKEND ENVIRONMENT READY!"
echo "👉 To start coding and running the local server:"
echo "   1. Activate virtual environment: source .venv/bin/activate"
echo "   2. Start Uvicorn dev server:    uvicorn main:app --host 0.0.0.0 --port 1112 --reload"
echo "   OR use Docker Compose:          docker-compose up --build -d"
echo ""
