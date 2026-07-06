# 🎙️ Hướng Dẫn Tự Train Giọng VA Thực Tế Với Mã Nguồn Mở (GPT-SoVITS / Style-Bert-VITS2)

Tài liệu này hướng dẫn chi tiết từ A-Z cách sử dụng các dự án mã nguồn mở hàng đầu thế giới hiện nay để tự huấn luyện (train) mô hình AI Voice Cloning với giọng thật của các diễn viên lồng tiếng (Voice Actor - VA) ngoài đời: **Kana Hanazawa (Sakura)**, **Yuki Kaji (Kenji)**, **Rie Takahashi (Aoi)**, và **Haruka Tomatsu (Zero Two)**.

---

## 🏆 Lựa Chọn Mã Nguồn Mở: GPT-SoVITS (Khuyên dùng số 1)

**GPT-SoVITS** (phát triển bởi RVC-Boss) hiện là hệ thống AI Voice Cloning Few-shot mạnh mẽ nhất hiện nay:
- **Chỉ cần 1 phút audio** giọng thật là có thể clone được giọng nói với chất lượng phòng thu.
- **Chỉ cần 5 - 10 phút audio** để model học trọn vẹn ngữ điệu, cảm xúc (vui, buồn, giận dữ, ngượng ngùng) của các VA Nhật Bản.
- **Tích hợp sẵn bộ công cụ WebUI 100% không cần code:** Tự động lọc tạp âm, tự động tách lời hát/nhạc nền (UVR5), tự động cắt câu (Audio Slicing), và tự động gán nhãn văn bản (Whisper ASR).

---

## 📋 Bước 1: Cài Đặt GPT-SoVITS Trên Máy (Linux / Windows)

### 1. Yêu cầu cấu hình máy:
- **GPU:** NVIDIA RTX 3060 / 3070 / 3080 / 4060 / 4070 / 4090 (tối thiểu 6GB VRAM, khuyến nghị 8GB - 12GB VRAM).
- **RAM:** Tối thiểu 16GB.
- **Ổ cứng:** Trống ít nhất 15GB SSD.

### 2. Tải và cài đặt:
Mở terminal trên máy Linux của bạn và chạy các lệnh sau:
```bash
# 1. Clone kho lưu trữ chính thức của GPT-SoVITS
git clone https://github.com/RVC-Boss/GPT-SoVITS.git
cd GPT-SoVITS

# 2. Tạo môi trường ảo Conda hoặc Python venv (Python 3.9 - 3.11)
conda create -n GPTSoVits python=3.10 -y
conda activate GPTSoVits

# 3. Cài đặt các thư viện cần thiết và PyTorch với hỗ trợ CUDA (GPU)
pip install -r requirements.txt
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

---

## 🎧 Bước 2: Chuẩn Bị Dữ Liệu Âm Thanh (Dataset Preparation)

Để train giọng Kana Hanazawa (hay các VA khác), bạn cần thu thập nguồn âm thanh:
1. **Tìm nguồn Audio:** Tải 1 - 2 video phỏng vấn, Radio Show hoặc clip tổng hợp giọng nói anime của Kana Hanazawa từ YouTube ở chất lượng 1080p/4K (để âm thanh đạt 48kHz chất lượng tốt nhất).
2. **Khởi chạy WebUI xử lý dữ liệu:**
   ```bash
   python webui.py
   ```
   Trình duyệt sẽ tự động mở giao diện WebUI tại `http://localhost:9874`.
3. **Thực hiện quy trình làm sạch trên WebUI (Tab 0 - Tiền xử lý audio):**
   - **Bước 2.1 (Vocal Separation - UVR5):** Chọn audio tải về -> Nhấn **Start Vocal Separation** để tách toàn bộ nhạc nền và tạp âm, chỉ giữ lại giọng nói sạch của Kana Hanazawa.
   - **Bước 2.2 (Audio Slicing):** Cắt file audio dài thành các câu ngắn từ 2 - 10 giây.
   - **Bước 2.3 (ASR - Tự động nhận dạng lời nói):** Chọn model ASR là `Faster-Whisper (JA)` để AI tự động nghe và chuyển từng câu nói tiếng Nhật thành văn bản text khớp 100% với audio.

---

## 🚀 Bước 3: Train Mô Hình (Huấn Luyện AI)

Trở lại giao diện WebUI, chuyển sang **Tab 1 - Fine-tuning (Huấn luyện)**:

1. **Train SoVITS (Mô hình âm học - Acoustic Model):**
   - Đặt tên model: `Kana_Hanazawa_Sakura`.
   - Batch size: 4 (hoặc 8 nếu VRAM 12GB+).
   - Total Epochs: `8` (chỉ mất khoảng 5 - 10 phút trên GPU RTX).
   - Nhấn **Start SoVITS Training**.

2. **Train GPT (Mô hình ngữ điệu & Nhịp điệu - Prosody Model):**
   - Total Epochs: `15`.
   - Nhấn **Start GPT Training** (mất khoảng 3 - 5 phút).

🎉 *Hoàn thành! Bạn đã sở hữu 2 file trọng số model:*
- `SoVITS_weights/Kana_Hanazawa_Sakura.pth`
- `GPT_weights/Kana_Hanazawa_Sakura.ckpt`

---

## 🔌 Bước 4: Khởi Chạy Server API & Kết Nối Với Ứng Dụng Language Learning App

GPT-SoVITS tích hợp sẵn một máy chủ API inference tối ưu hóa độ trễ thấp (< 300ms).

### 1. Khởi chạy máy chủ API local của GPT-SoVITS:
Trong thư mục `GPT-SoVITS`, mở terminal chạy lệnh:
```bash
python api_v2.py --port 9880
```
*(Server AI sẽ lắng nghe tại `http://localhost:9880`)*.

### 2. Cấu hình vào hệ thống Backend của bạn:
Mở file `.env` ở thư mục `backend/` của dự án **LanguageLearningApp** và điền URL của server GPT-SoVITS vừa chạy:
```bash
VITS_URL="http://localhost:9880"
```

### 3. Nguyên lý hoạt động tự động trong Codebase:
Hệ thống `voice_service.py` và `voice_engine/main.py` của chúng ta đã được nâng cấp sẵn Tier 1 tự động tương thích với chuẩn API của GPT-SoVITS.
Khi người dùng bấm vào nhân vật Sakura (`sensei_va_01`), ứng dụng sẽ gửi yêu cầu trực tiếp đến máy chủ AI local trên cổng 9880:
`GET http://localhost:9880/?text=Konnichiwa...&text_lang=ja`

máy chủ AI sẽ sử dụng chính mô hình bạn đã train để sinh ra luồng WAV binary mang chất giọng thực tế 100% của Kana Hanazawa và trả về cho ứng dụng phát tức thì!
