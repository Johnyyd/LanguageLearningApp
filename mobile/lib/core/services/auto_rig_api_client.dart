import 'dart:convert' show base64Encode;
import 'dart:io' show File;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

/// Dịch vụ kết nối tới API Auto-Rigging & Skinning Gateway Service trên FastAPI Backend (`/api/v1/autorig/process-json`)
class AutoRigApiClient {
    final ApiClient _apiClient = ApiClient();

    /// Gửi file mô hình 3D thô (.glb, .obj, .vrm) lên máy chủ AI để tự động gắn bộ xương 22 khớp Humanoid
    /// và tính toán trọng số da LBS Skinning cho Unity Mecanim Retargeting.
    Future<Map<String, dynamic>> uploadAndAutoRigModel({
        File? file,
        Uint8List? bytes,
        required String filename,
        bool autoRetarget = true,
        void Function(int sent, int total)? onSendProgress,
    }) async {
        final bool isVrm = filename.toLowerCase().endsWith('.vrm');

        try {
            debugPrint("🟢 [AutoRigApiClient] Đang gửi '$filename' lên AI Server để tự động gắn xương...");
            MultipartFile multipartFile;
            if (!kIsWeb && file != null && file.path.isNotEmpty) {
                multipartFile = await MultipartFile.fromFile(file.path, filename: filename);
            } else if (bytes != null) {
                multipartFile = MultipartFile.fromBytes(bytes, filename: filename);
            } else {
                throw Exception("Dữ liệu file không hợp lệ");
            }

            final formData = FormData.fromMap({
                'file': multipartFile,
                'auto_retarget': autoRetarget.toString(),
            });

            final response = await _apiClient.dio.post(
                '/autorig/process-json',
                data: formData,
                onSendProgress: onSendProgress,
                options: Options(
                    receiveTimeout: const Duration(seconds: 90),
                    sendTimeout: const Duration(seconds: 60),
                ),
            );

            if (response.statusCode == 200 && response.data != null) {
                final data = response.data as Map<String, dynamic>;
                debugPrint("✅ [AutoRigApiClient] Auto-Rigging thành công! Khớp: ${data['metadata']?['skeleton']?['joints_count'] ?? 22}");
                return data;
            } else {
                throw DioException(
                    requestOptions: response.requestOptions,
                    message: "Phản hồi máy chủ không hợp lệ: ${response.statusCode}",
                );
            }
        } catch (e) {
            debugPrint("⚠️ [AutoRigApiClient] Không thể kết nối hoặc xử lý qua AI Server ($e). Chuyển sang nạp cục bộ (Fallback).");
            
            // Xử lý nạp cục bộ (Local Fallback) khi server chưa bật để không bao giờ làm crash ứng dụng
            try {
                Uint8List rawBytes;
                if (!kIsWeb && file != null && file.path.isNotEmpty) {
                    rawBytes = await file.readAsBytes();
                } else if (bytes != null) {
                    rawBytes = bytes;
                } else {
                    throw Exception("Không có bytes cục bộ");
                }

                final base64String = base64Encode(rawBytes);
                final mime = isVrm ? "application/octet-stream" : "model/gltf-binary";
                final dataUri = "data:$mime;base64,$base64String";

                return {
                    "status": "fallback",
                    "message": "Máy chủ Auto-Rigging chưa phản hồi (offline). Đã nạp trực tiếp file cục bộ.",
                    "data_uri": dataUri,
                    "metadata": {
                        "filename": filename,
                        "format": isVrm ? "vrm" : "glb",
                        "workflow": isVrm ? "vrm_standard" : "local_fallback_glb",
                        "skeleton": {
                            "joints_count": isVrm ? 22 : 0,
                            "root_joint": isVrm ? "root" : "unrigged_mesh",
                        },
                        "retargeting": {
                            "ready_for_unity": isVrm,
                            "mecanim_avatar_type": isVrm ? "Humanoid" : "None",
                        },
                        "facial_rigging": {
                            "supported": true,
                            "jaw_bone": "head",
                            "visemes": [
                                {"code": "mouth_a", "target": "Viseme_A", "fallback_jaw_angle": 15.0},
                                {"code": "mouth_i", "target": "Viseme_I", "fallback_jaw_angle": 6.0},
                                {"code": "mouth_u", "target": "Viseme_U", "fallback_jaw_angle": 10.0},
                                {"code": "mouth_e", "target": "Viseme_E", "fallback_jaw_angle": 8.0},
                                {"code": "mouth_o", "target": "Viseme_O", "fallback_jaw_angle": 12.0},
                            ],
                        }
                    }
                };
            } catch (fallbackError) {
                return {
                    "status": "error",
                    "message": "Lỗi khi đọc file 3D cục bộ: $fallbackError",
                };
            }
        }
    }
}
