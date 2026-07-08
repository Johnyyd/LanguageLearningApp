#!/usr/bin/env bash
# ==============================================================================
# setup_gpt_sovits.sh
# Automated Setup & Pretrained Model Downloader for GPT-SoVITS Voice Engine
# ==============================================================================
# This script downloads the required pretrained models for GPT-SoVITS
# (BERT feature extraction, HuBERT speech SSL, SoVITS-G/D acoustics & prosody)
# from HuggingFace without relying on monolithic, prone-to-corruption zip files.
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}[*] Starting GPT-SoVITS Pretrained Model Setup...${NC}"

# Define workspace and target directories
GPT_SOVITS_DIR="${GPT_SOVITS_DIR:-/home/tringuyen/AI_Voice_Workspace/GPT-SoVITS}"
TARGET_PRETRAINED_DIR="$GPT_SOVITS_DIR/GPT_SoVITS"

if [ ! -d "$GPT_SOVITS_DIR" ]; then
    echo -e "${RED}[!] Error: GPT-SoVITS directory not found at $GPT_SOVITS_DIR${NC}"
    echo -e "${YELLOW}[i] Please ensure GPT-SoVITS is installed or set GPT_SOVITS_DIR environment variable.${NC}"
    exit 1
fi

# Locate huggingface-cli / hf in Conda environment or PATH
HF_CLI=""
if [ -f "/home/tringuyen/miniconda3/envs/GPTSoVits/bin/huggingface-cli" ]; then
    HF_CLI="/home/tringuyen/miniconda3/envs/GPTSoVits/bin/huggingface-cli"
elif command -v huggingface-cli &>/dev/null; then
    HF_CLI=$(command -v huggingface-cli)
else
    echo -e "${RED}[!] Error: huggingface-cli not found.${NC}"
    echo -e "${YELLOW}[i] Installing huggingface_hub in the current environment...${NC}"
    pip install -q huggingface_hub
    HF_CLI="huggingface-cli"
fi

echo -e "${GREEN}[+] Using HuggingFace CLI: $HF_CLI${NC}"

# Clean up corrupted or incomplete zip archives to reclaim disk space
if [ -f "$GPT_SOVITS_DIR/pretrained_models.zip" ]; then
    echo -e "${YELLOW}[i] Removing incomplete/corrupted pretrained_models.zip (~2.8GB wasted space)...${NC}"
    rm -f "$GPT_SOVITS_DIR/pretrained_models.zip"
fi

echo -e "${BLUE}[*] Downloading Core Pretrained Models into $TARGET_PRETRAINED_DIR/pretrained_models ...${NC}"
echo -e "${YELLOW}[i] Downloading BERT (chinese-roberta-wwm-ext-large), SSL (chinese-hubert-base), and SoVITS weights...${NC}"

# Download all pretrained_models folder contents from HuggingFace repository
$HF_CLI download XXXXRT/GPT-SoVITS-Pretrained \
    --include "pretrained_models/*" \
    --local-dir "$TARGET_PRETRAINED_DIR" \
    --local-dir-use-symlinks False

echo -e "${GREEN}[+] Successfully downloaded Core Pretrained Models!${NC}"

# Ensure UVR5 vocal separation weights exist
UVR5_DIR="$GPT_SOVITS_DIR/tools/uvr5/uvr5_weights"
if [ ! -d "$UVR5_DIR" ] || [ -z "$(ls -A "$UVR5_DIR" 2>/dev/null | grep -v '.gitignore')" ]; then
    echo -e "${BLUE}[*] Checking UVR5 Vocal Separation weights...${NC}"
    mkdir -p "$GPT_SOVITS_DIR/tools/uvr5"
    if [ ! -f "$GPT_SOVITS_DIR/tools/uvr5/uvr5_weights.zip" ]; then
        echo -e "${YELLOW}[i] Downloading uvr5_weights.zip...${NC}"
        $HF_CLI download XXXXRT/GPT-SoVITS-Pretrained uvr5_weights.zip --local-dir "$GPT_SOVITS_DIR/tools/uvr5" --local-dir-use-symlinks False
    fi
    if [ -f "$GPT_SOVITS_DIR/tools/uvr5/uvr5_weights.zip" ]; then
        echo -e "${YELLOW}[i] Extracting uvr5_weights.zip...${NC}"
        unzip -q -o "$GPT_SOVITS_DIR/tools/uvr5/uvr5_weights.zip" -d "$GPT_SOVITS_DIR/tools/uvr5/"
        rm -f "$GPT_SOVITS_DIR/tools/uvr5/uvr5_weights.zip"
        echo -e "${GREEN}[+] UVR5 models installed successfully.${NC}"
    fi
fi

echo -e "${GREEN}[================================================================]${NC}"
echo -e "${GREEN}[✔] All GPT-SoVITS Pretrained Models are ready for Voice Cloning!${NC}"
echo -e "${GREEN}[================================================================]${NC}"
echo -e "${BLUE}Model paths configured:${NC}"
echo -e "  - BERT Model:  $TARGET_PRETRAINED_DIR/pretrained_models/chinese-roberta-wwm-ext-large"
echo -e "  - SSL Model:   $TARGET_PRETRAINED_DIR/pretrained_models/chinese-hubert-base"
echo -e "  - SoVITS-G/D:  $TARGET_PRETRAINED_DIR/pretrained_models/"
echo ""
