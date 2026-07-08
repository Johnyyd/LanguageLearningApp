#!/usr/bin/env bash
# ==============================================================================
# run_zero_two_service.sh
# Automated Launch Script for Zero Two 1-on-1 AI Voice Conversation Pipeline
# ==============================================================================
# 1. Launches GPT-SoVITS API Server (api_v2.py) on port 9880
# 2. Launches LanguageLearningApp Voice Engine Microservice on port 8001
# 3. Manages background processes with clean shutdown on exit (Ctrl+C)
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}[================================================================]${NC}"
echo -e "${BLUE}[*] Starting Zero Two 1-on-1 Voice Conversation Microservices...${NC}"
echo -e "${BLUE}[================================================================]${NC}"

# 1. Configuration & Directories
GPT_SOVITS_DIR="${GPT_SOVITS_DIR:-/home/tringuyen/AI_Voice_Workspace/GPT-SoVITS}"
VOICE_ENGINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_BIN="/home/tringuyen/miniconda3/envs/GPTSoVits/bin/python"

if [ ! -f "$PYTHON_BIN" ]; then
    PYTHON_BIN=$(command -v python3 || command -v python)
fi

if [ ! -d "$GPT_SOVITS_DIR" ]; then
    echo -e "${RED}[!] Error: GPT-SoVITS directory not found at $GPT_SOVITS_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Using Python: $PYTHON_BIN${NC}"
echo -e "${GREEN}[+] GPT-SoVITS Workspace: $GPT_SOVITS_DIR${NC}"
echo -e "${GREEN}[+] Voice Engine Directory: $VOICE_ENGINE_DIR${NC}"

# 2. Trap SIGINT and SIGTERM to cleanly kill child processes
cleanup() {
    echo ""
    echo -e "${YELLOW}[!] Shutting down Zero Two Voice Services...${NC}"
    if [ -n "$GPT_SOVITS_PID" ] && kill -0 "$GPT_SOVITS_PID" 2>/dev/null; then
        kill "$GPT_SOVITS_PID" 2>/dev/null || true
        echo -e "${GREEN}[✔] Stopped GPT-SoVITS API Server (PID: $GPT_SOVITS_PID)${NC}"
    fi
    exit 0
}
trap cleanup SIGINT SIGTERM

# 3. Check and clean existing processes on ports 9880 and 8001
if command -v lsof &>/dev/null; then
    STALE_9880=$(lsof -ti:9880 2>/dev/null || true)
    if [ -n "$STALE_9880" ]; then
        echo -e "${YELLOW}[i] Port 9880 is in use (PID: $STALE_9880). Stopping previous instance...${NC}"
        kill -9 $STALE_9880 2>/dev/null || true
    fi
    STALE_8001=$(lsof -ti:8001 2>/dev/null || true)
    if [ -n "$STALE_8001" ]; then
        echo -e "${YELLOW}[i] Port 8001 is in use (PID: $STALE_8001). Stopping previous instance...${NC}"
        kill -9 $STALE_8001 2>/dev/null || true
    fi
fi

# 4. Launch GPT-SoVITS API Server (api_v2.py) in the background
echo -e "${CYAN}[1/2] Launching GPT-SoVITS API Server (http://127.0.0.1:9880)...${NC}"
cd "$GPT_SOVITS_DIR"
"$PYTHON_BIN" api_v2.py -a 127.0.0.1 -p 9880 &
GPT_SOVITS_PID=$!

echo -e "${GREEN}[+] GPT-SoVITS API Server running in background with PID: $GPT_SOVITS_PID${NC}"
echo -e "${YELLOW}[i] Waiting 3 seconds for API Server initialization...${NC}"
sleep 3

# 5. Launch LanguageLearningApp Voice Engine Microservice
echo -e "${CYAN}[2/2] Launching LanguageLearningApp Voice Engine Microservice (http://0.0.0.0:8001)...${NC}"
cd "$VOICE_ENGINE_DIR"
export VITS_URL="http://127.0.0.1:9880"

echo -e "${GREEN}[================================================================]${NC}"
echo -e "${GREEN}[✔] Zero Two Voice Engine is Ready!${NC}"
echo -e "  - GPT-SoVITS TTS API:     http://127.0.0.1:9880"
       - Voice Engine Endpoint:  http://127.0.0.1:8001/synthesize"
echo -e "  - Health Check:           http://127.0.0.1:8001/health"
echo -e "${GREEN}[================================================================]${NC}"
echo -e "${YELLOW}[i] Press Ctrl+C to stop both services cleanly.${NC}"

"$PYTHON_BIN" -m uvicorn main:app --host 0.0.0.0 --port 8001
