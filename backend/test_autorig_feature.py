import json
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_autorig_status():
    """Kiểm tra API lấy trạng thái hệ thống Auto-Rigging"""
    response = client.get("/api/v1/autorig/status")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert data["humanoid_joints_supported"] == 22
    assert ".glb" in data["supported_formats"]
    assert ".vrm" in data["supported_formats"]
    print("✅ test_autorig_status passed.")

def test_autorig_process_binary_glb():
    """Kiểm tra tải lên file .glb thô và nhận về binary đã rig cùng metadata headers"""
    # Tạo payload giả lập glTF nhị phân
    dummy_glb = b'glTF\x02\x00\x00\x00' + b'\x00' * 1024
    files = {"file": ("my_raw_character.glb", dummy_glb, "model/gltf-binary")}
    data = {"auto_retarget": "true"}

    response = client.post("/api/v1/autorig/process", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "model/gltf-binary"
    assert "X-Autorig-Metadata" in response.headers

    metadata = json.loads(response.headers["X-Autorig-Metadata"])
    assert metadata["status"] == "success"
    assert metadata["format"] == "glb"
    assert metadata["skeleton"]["joints_count"] == 22
    assert metadata["retargeting"]["ready_for_unity"] is True
    print("✅ test_autorig_process_binary_glb passed.")

def test_autorig_process_json_vrm():
    """Kiểm tra tải lên file .vrm và nhận về JSON chứa Data URI & siêu dữ liệu"""
    dummy_vrm = b'glTF\x02\x00\x00\x00' + b'\x01' * 2048
    files = {"file": ("anime_tutor.vrm", dummy_vrm, "application/octet-stream")}
    data = {"auto_retarget": "true"}

    response = client.post("/api/v1/autorig/process-json", files=files, data=data)
    assert response.status_code == 200
    json_data = response.json()
    assert json_data["status"] == "success"
    assert json_data["data_uri"].startswith("data:application/octet-stream;base64,")
    assert json_data["metadata"]["workflow"] == "vrm_standard"
    assert json_data["metadata"]["skinning"]["max_influences_per_vertex"] == 4
    print("✅ test_autorig_process_json_vrm passed.")

def test_autorig_invalid_file():
    """Kiểm tra xử lý lỗi khi file upload quá nhỏ hoặc hỏng"""
    tiny_bad_file = b'tiny'
    files = {"file": ("corrupted.glb", tiny_bad_file, "model/gltf-binary")}

    response = client.post("/api/v1/autorig/process", files=files)
    assert response.status_code == 400
    assert "File quá nhỏ hoặc bị hỏng dữ liệu nhị phân" in response.json()["detail"]
    print("✅ test_autorig_invalid_file passed.")

if __name__ == "__main__":
    print("🚀 Bắt đầu kiểm định hệ thống Backend AI Auto-Rigging & Skinning Gateway...")
    test_autorig_status()
    test_autorig_process_binary_glb()
    test_autorig_process_json_vrm()
    test_autorig_invalid_file()
    print("🎉 Toàn bộ kiểm định Auto-Rigging Backend thành công 100%!")
