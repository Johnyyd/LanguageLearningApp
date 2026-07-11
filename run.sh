#!/bin/bash
# 1. Cập nhật container backend để nhận đúng biến môi trường ZEROTWO_REF_WAV và code mới
cd /home/tringuyen/Documents/GitHub/LanguageLearningApp/backend
docker compose up -d --force-recreate ai-gateway voice-engine

# 2. Khởi chạy GPT-SoVITS API Server (lắng nghe 0.0.0.0:9880)
cd /home/tringuyen/AI_Voice_Workspace
./start_api.sh
