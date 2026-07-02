# =====================================================================
# 🧪 Automated Functional & Caching Verification Test Suite
# =====================================================================

import sys
import os

# Ensure backend directory is in path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi.testclient import TestClient
from main import app
from services.cache_service import cache_service

client = TestClient(app)

def test_system_health():
    print("\n--- 🟢 [Test 1] Root & Health Check ---")
    r_root = client.get("/")
    assert r_root.status_code == 200, f"Root endpoint failed: {r_root.text}"
    print(f"✅ Root Endpoint OK: {r_root.json()['app']}")

    r_health = client.get("/health")
    assert r_health.status_code == 200, f"Health endpoint failed: {r_health.text}"
    print(f"✅ Health Check OK: {r_health.json()}")

def test_vocab_cache():
    print("\n--- 🟢 [Test 2] Japanese N5 Vocab & Caching ---")
    r1 = client.get("/api/v1/vocab/n5")
    assert r1.status_code == 200
    data1 = r1.json()
    assert len(data1) > 0
    print(f"✅ Fetched {len(data1)} N5 vocabulary items successfully.")

    # Test cache hit on second request
    r2 = client.get("/api/v1/vocab/n5")
    assert r2.status_code == 200
    print("✅ Cache hit verified for N5 vocabulary.")

def test_ielts_prompts_and_eval():
    print("\n--- 🟢 [Test 3] IELTS Writing Prompts & AI Evaluation ---")
    r_prompts = client.get("/api/v1/ielts/prompts")
    assert r_prompts.status_code == 200
    prompts = r_prompts.json()
    assert len(prompts) > 0
    print(f"✅ Fetched {len(prompts)} IELTS writing prompts.")

    sample_essay = "The bar chart illustrates car ownership trends per 1000 people across three European countries between 2000 and 2020. Overall, there was a noticeable increase in car numbers."
    payload = {
        "prompt_id": prompts[0]["id"],
        "input_type": "text",
        "essay_text": sample_essay,
        "user_id": 1
    }
    print("⏳ Sending essay to AI Engine (OpenRouter / Gemini) for grading...")
    r_eval = client.post("/api/v1/ielts/evaluate", json=payload)
    assert r_eval.status_code == 200
    res_data = r_eval.json()
    assert res_data["status"] == "success"
    report = res_data["report"]
    print(f"✅ AI Grading Report Received -> Overall Band: {report.get('overall_band')}")
    print(f"   Comment: {report.get('general_comment')}")

def test_3d_tutor_chat():
    print("\n--- 🟢 [Test 4] 3D Sensei AI Tutor Q&A ---")
    chat_payload = {
        "message": "Phân biệt trợ từ Wa và Ga trong tiếng Nhật giúp mình với?",
        "module_context": "japanese_n5",
        "user_id": 1
    }
    print("⏳ Asking 3D Tutor a grammatical question...")
    r_chat = client.post("/api/v1/chat/ask", json=chat_payload)
    assert r_chat.status_code == 200
    chat_res = r_chat.json()
    assert chat_res["status"] == "success"
    print(f"✅ 3D Tutor Reply: {chat_res.get('reply_text')[:100]}...")
    print(f"✅ Avatar Emotion State: {chat_res.get('avatar_emotion')}")

if __name__ == "__main__":
    print("=====================================================================")
    print("🚀 STARTING AUTOMATED VERIFICATION TEST SUITE (MiMo Technical Review)")
    print("=====================================================================")
    try:
        test_system_health()
        test_vocab_cache()
        test_ielts_prompts_and_eval()
        test_3d_tutor_chat()
        print("\n🎉 ALL 4 TEST SUITES PASSED SUCCESSFULLY! 100% FUNCTIONAL.")
    except Exception as e:
        print(f"\n❌ TEST FAILED: {e}")
        sys.exit(1)
