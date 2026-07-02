from fastapi import APIRouter
from services.cache_service import cache_service

router = APIRouter(prefix="/api/v1/vocab", tags=["Japanese N5 Vocabulary SRS"])

@router.get("/n5")
def get_n5_vocabulary():
    """
    Returns core N5 Hiragana, Katakana, and Kanji vocabulary with SRS parameters.
    Uses Redis cache to speed up response times.
    """
    cache_key = "vocab:n5:list"
    cached_data = cache_service.get(cache_key)
    if cached_data:
        return cached_data

    vocab_list = [
        {
            "id": "jap_001",
            "character": "あ",
            "romaji": "a",
            "type": "Hiragana",
            "meaning": "Chữ A (Hiragana nguyên âm đầu tiên)",
            "example": "あさ (Asa - Buổi sáng)",
            "stroke_order_url": "https://media.giphy.com/media/l41lO3nrycM9U1Gxy/giphy.gif",
            "srs_interval": 1,
            "srs_repetition": 0,
            "srs_efactor": 2.5
        },
        {
            "id": "jap_002",
            "character": "い",
            "romaji": "i",
            "type": "Hiragana",
            "meaning": "Chữ I (Hiragana nguyên âm thứ hai)",
            "example": "いえ (Ie - Ngôi nhà)",
            "stroke_order_url": "",
            "srs_interval": 1,
            "srs_repetition": 0,
            "srs_efactor": 2.5
        },
        {
            "id": "jap_003",
            "character": "ア",
            "romaji": "a",
            "type": "Katakana",
            "meaning": "Chữ A (Katakana dùng cho từ mượn)",
            "example": "アイス (Aisu - Kem)",
            "stroke_order_url": "",
            "srs_interval": 1,
            "srs_repetition": 0,
            "srs_efactor": 2.5
        },
        {
            "id": "jap_004",
            "character": "日",
            "romaji": "Nichi / Hi",
            "type": "Kanji",
            "meaning": "Nhật (Mặt trời, Ngày)",
            "example": "日本 (Nihon - Nhật Bản)",
            "stroke_order_url": "",
            "srs_interval": 1,
            "srs_repetition": 0,
            "srs_efactor": 2.5
        },
        {
            "id": "jap_005",
            "character": "本",
            "romaji": "Hon / Moto",
            "type": "Kanji",
            "meaning": "Bản (Sách, Gốc rễ)",
            "example": "本 (Hon - Quyển sách)",
            "stroke_order_url": "",
            "srs_interval": 1,
            "srs_repetition": 0,
            "srs_efactor": 2.5
        },
        {
            "id": "jap_006",
            "character": "学",
            "romaji": "Gaku / Mana(bu)",
            "type": "Kanji",
            "meaning": "Học (Học tập)",
            "example": "学生 (Gakusei - Học sinh, Sinh viên)",
            "stroke_order_url": "",
            "srs_interval": 1,
            "srs_repetition": 0,
            "srs_efactor": 2.5
        }
    ]
    cache_service.set(cache_key, vocab_list, ttl=86400) # Lưu cache 24h
    return vocab_list
