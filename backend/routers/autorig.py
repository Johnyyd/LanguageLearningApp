import base64
import json
from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Response
from fastapi.responses import JSONResponse
from services.autorig_service import auto_rig_service

router = APIRouter(
    prefix="/api/v1/autorig",
    tags=["Auto-Rigging & Skinning Gateway (3D VTuber)"]
)

@router.get("/status", summary="Kiểm tra trạng thái máy chủ AI Auto-Rigging & Skinning Gateway")
def get_autorig_status():
    """
    Trả về thông số kỹ thuật của engine Auto-Rigging (RigNet / Geodesic Voxel Binding),
    danh sách 22 khớp xương chuẩn Humanoid hỗ trợ, và công thức tính toán trọng số da.
    """
    return auto_rig_service.get_status()

@router.post("/process", summary="Tải lên lưới 3D thô (.glb/.obj/.vrm) và trả về file nhị phân đã gắn xương chuẩn Humanoid")
async def process_autorig_binary(
    file: UploadFile = File(..., description="File mô hình 3D thô (.glb, .vrm, .obj, .gltf)"),
    auto_retarget: bool = Form(True, description="Tự động cấu hình sẵn cho Unity Mecanim Retargeting")
):
    """
    Nhận file mô hình thô từ người dùng, thực thi pipeline:
    1. Chuẩn hóa kích thước về chiều cao 1.6m và đặt tâm về (0,0,0).
    2. Dựng bộ xương Humanoid 22 khớp.
    3. Tính toán trọng số da Linear Blend Skinning (LBS).
    4. Trả về nhị phân GLB/VRM đã rig kèm header siêu dữ liệu `X-Autorig-Metadata`.
    """
    try:
        file_bytes = await file.read()
        processed_bytes, metadata = await auto_rig_service.process_raw_mesh(
            file_bytes=file_bytes,
            filename=file.filename or "custom_avatar.glb",
            auto_retarget=auto_retarget
        )

        # Chuẩn bị Header siêu dữ liệu
        metadata_header = json.dumps(metadata)
        headers = {
            "Content-Disposition": f'attachment; filename="rigged_{file.filename or "avatar.glb"}"',
            "X-Autorig-Status": "success",
            "X-Autorig-Metadata": metadata_header
        }

        mime_type = "model/gltf-binary"
        if (file.filename and file.filename.lower().endswith(".vrm")) or metadata["format"] == "vrm":
            mime_type = "application/octet-stream"

        return Response(
            content=processed_bytes,
            media_type=mime_type,
            headers=headers
        )
    except ValueError as err:
        raise HTTPException(status_code=400, detail=str(err))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống Auto-Rigging: {str(e)}")

@router.post("/process-json", summary="Tải lên file 3D thô và nhận JSON phản hồi (chứa Base64 Data URI & metadata chi tiết)")
async def process_autorig_json(
    file: UploadFile = File(..., description="File mô hình 3D thô (.glb, .vrm, .obj, .gltf)"),
    auto_retarget: bool = Form(True, description="Tự động cấu hình cho Unity Mecanim Retargeting")
):
    """
    Tương tự `/process` nhưng trả về gói JSON chứa cả Data URI Base64 lẫn toàn bộ cấu trúc
    22 khớp xương, trọng số da mẫu, và siêu dữ liệu chuẩn hóa để dễ dàng gỡ lỗi trên Client/Web.
    """
    try:
        file_bytes = await file.read()
        processed_bytes, metadata = await auto_rig_service.process_raw_mesh(
            file_bytes=file_bytes,
            filename=file.filename or "custom_avatar.glb",
            auto_retarget=auto_retarget
        )

        base64_str = base64.b64encode(processed_bytes).decode('utf-8')
        mime_type = "model/gltf-binary"
        if (file.filename and file.filename.lower().endswith(".vrm")) or metadata["format"] == "vrm":
            mime_type = "application/octet-stream"

        data_uri = f"data:{mime_type};base64,{base64_str}"

        return JSONResponse(content={
            "status": "success",
            "message": "Đã tự động chuẩn hóa lưới, gắn bộ xương 22 khớp và tính toán trọng số da LBS thành công!",
            "data_uri": data_uri,
            "metadata": metadata
        })
    except ValueError as err:
        raise HTTPException(status_code=400, detail=str(err))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống Auto-Rigging: {str(e)}")
