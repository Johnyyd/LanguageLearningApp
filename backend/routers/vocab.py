from fastapi import APIRouter, Query
from services.cache_service import cache_service

router = APIRouter(prefix="/api/v1/vocab", tags=["Japanese N5 Vocabulary SRS"])

@router.get("/n5")
def get_n5_vocabulary(lesson: int = Query(1, description="Lesson number from 1 to 5")):
    """
    Returns core N5 vocabulary categorized by lessons with SRS parameters.
    Uses Redis cache to speed up response times.
    """
    if lesson < 1 or lesson > 5:
        lesson = 1

    cache_key = f"vocab:n5:lesson:{lesson}"
    cached_data = cache_service.get(cache_key)
    if cached_data:
        return cached_data

    lessons_data = {
        1: [
            {"id": "jap_101", "character": "あ", "romaji": "a", "type": "Hiragana", "meaning": "Chữ A (Hiragana nguyên âm)", "example": "あさ (Asa - Buổi sáng)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_102", "character": "い", "romaji": "i", "type": "Hiragana", "meaning": "Chữ I (Hiragana nguyên âm)", "example": "いえ (Ie - Ngôi nhà)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_103", "character": "う", "romaji": "u", "type": "Hiragana", "meaning": "Chữ U (Hiragana nguyên âm)", "example": "うみ (Umi - Biển cả)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_104", "character": "え", "romaji": "e", "type": "Hiragana", "meaning": "Chữ E (Hiragana nguyên âm)", "example": "えき (Eki - Nhà ga)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_105", "character": "お", "romaji": "o", "type": "Hiragana", "meaning": "Chữ O (Hiragana nguyên âm)", "example": "おちゃ (Ocha - Trà xanh)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_106", "character": "か", "romaji": "ka", "type": "Hiragana", "meaning": "Chữ KA (Hàng K)", "example": "かさ (Kasa - Cái ô/dù)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_107", "character": "き", "romaji": "ki", "type": "Hiragana", "meaning": "Chữ KI (Hàng K)", "example": "きもの (Kimono - Áo truyền thống)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
        ],
        2: [
            {"id": "jap_201", "character": "ア", "romaji": "a", "type": "Katakana", "meaning": "Chữ A (Katakana từ mượn)", "example": "アイス (Aisu - Kem)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_202", "character": "イ", "romaji": "i", "type": "Katakana", "meaning": "Chữ I (Katakana từ mượn)", "example": "インク (Inku - Mực in)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_203", "character": "カメラ", "romaji": "kamera", "type": "Katakana", "meaning": "Máy ảnh (Camera)", "example": "デジタルカメラ (Máy ảnh kỹ thuật số)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_204", "character": "ホテル", "romaji": "hoteru", "type": "Katakana", "meaning": "Khách sạn (Hotel)", "example": "きれいなホテル (Khách sạn sạch đẹp)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_205", "character": "テレビ", "romaji": "terebi", "type": "Katakana", "meaning": "Tivi, truyền hình (TV)", "example": "テレビをみる (Xem tivi)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_206", "character": "ラジオ", "romaji": "rajio", "type": "Katakana", "meaning": "Đài phát thanh (Radio)", "example": "ラジオをきく (Nghe đài)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_207", "character": "パン", "romaji": "pan", "type": "Katakana", "meaning": "Bánh mì (Bread)", "example": "おいしいパン (Bánh mì ngon)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
        ],
        3: [
            {"id": "jap_301", "character": "日", "romaji": "Nichi / Hi", "type": "Kanji", "meaning": "Nhật (Mặt trời, Ngày)", "example": "日本 (Nihon - Nhật Bản)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_302", "character": "月", "romaji": "Getu / Tsuki", "type": "Kanji", "meaning": "Nguyệt (Mặt trăng, Tháng)", "example": "月曜日 (Getsuyoubi - Thứ Hai)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_303", "character": "火", "romaji": "Ka / Hi", "type": "Kanji", "meaning": "Hỏa (Lửa)", "example": "火曜日 (Kayoubi - Thứ Ba)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_304", "character": "水", "romaji": "Sui / Mizu", "type": "Kanji", "meaning": "Thủy (Nước)", "example": "水曜日 (Suiyoubi - Thứ Tư)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_305", "character": "木", "romaji": "Moku / Ki", "type": "Kanji", "meaning": "Mộc (Cây cối)", "example": "木曜日 (Mokuyoubi - Thứ Năm)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_306", "character": "金", "romaji": "Kin / Kane", "type": "Kanji", "meaning": "Kim (Vàng, Tiền)", "example": "金曜日 (Kinyoubi - Thứ Sáu)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_307", "character": "土", "romaji": "Do / Tsuchi", "type": "Kanji", "meaning": "Thổ (Đất)", "example": "土曜日 (Doyoubi - Thứ Bảy)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
        ],
        4: [
            {"id": "jap_401", "character": "人", "romaji": "Jin / Hito", "type": "Kanji", "meaning": "Nhân (Con người)", "example": "日本人 (Nihonjin - Người Nhật)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_402", "character": "父", "romaji": "Fu / Chichi", "type": "Kanji", "meaning": "Phụ (Cha, Bố)", "example": "お父さん (Otousan - Bố người khác)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_403", "character": "母", "romaji": "Bo / Haha", "type": "Kanji", "meaning": "Mẫu (Mẹ)", "example": "お母さん (Okaasan - Mẹ người khác)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_404", "character": "子", "romaji": "Shi / Ko", "type": "Kanji", "meaning": "Tử (Con cái, Trẻ em)", "example": "子供 (Kodomo - Trẻ em)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_405", "character": "男", "romaji": "Dan / Otoko", "type": "Kanji", "meaning": "Nam (Đàn ông, Con trai)", "example": "男の人 (Otoko no hito - Người đàn ông)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_406", "character": "女", "romaji": "Jo / Onna", "type": "Kanji", "meaning": "Nữ (Phụ nữ, Con gái)", "example": "女の人 (Onna no hito - Người phụ nữ)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_407", "character": "友", "romaji": "Yuu / Tomo", "type": "Kanji", "meaning": "Hữu (Bạn bè)", "example": "友達 (Tomodachi - Bạn bè)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
        ],
        5: [
            {"id": "jap_501", "character": "本", "romaji": "Hon / Moto", "type": "Kanji", "meaning": "Bản (Sách, Gốc rễ)", "example": "本を読む (Hon wo yomu - Đọc sách)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_502", "character": "学", "romaji": "Gaku / Mana(bu)", "type": "Kanji", "meaning": "Học (Học tập)", "example": "大学 (Daigaku - Trường đại học)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_503", "character": "校", "romaji": "Kou", "type": "Kanji", "meaning": "Hiệu (Trường học)", "example": "学校 (Gakkou - Trường học)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_504", "character": "生", "romaji": "Sei / I(kiru)", "type": "Kanji", "meaning": "Sinh (Sống, Sinh viên)", "example": "先生 (Sensei - Giáo viên)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_505", "character": "食べる", "romaji": "Ta(beru)", "type": "Động từ", "meaning": "Thực (Ăn, Thưởng thức)", "example": "ごはんを食べる (Ăn cơm)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_506", "character": "飲む", "romaji": "No(mu)", "type": "Động từ", "meaning": "Ẩm (Uống nước)", "example": "水を飲む (Uống nước)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
            {"id": "jap_507", "character": "見る", "romaji": "Mi(ru)", "type": "Động từ", "meaning": "Kiến (Nhìn, Xem)", "example": "映画を見る (Xem phim)", "stroke_order_url": "", "srs_interval": 1, "srs_repetition": 0, "srs_efactor": 2.5},
        ]
    }

    vocab_list = lessons_data.get(lesson, lessons_data[1])
    cache_service.set(cache_key, vocab_list, ttl=86400) # Lưu cache 24h
    return vocab_list
