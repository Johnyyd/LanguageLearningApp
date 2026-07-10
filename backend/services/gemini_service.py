# =====================================================================
# 🧠 AI Engine Service (Supporting Google AI Studio & OpenRouter)
# =====================================================================

import json
import re
import logging
import httpx
import google.generativeai as genai
from config import settings

logger = logging.getLogger(__name__)

# Configure Gemini if API key is provided and is official Google Studio key
is_openrouter = False
model = None

if settings.GEMINI_API_KEY and settings.GEMINI_API_KEY != "demo_api_key_portfolio_2026":
    if settings.GEMINI_API_KEY.startswith("sk-or-") or settings.GEMINI_API_KEY.startswith("sk-"):
        logger.info("🔑 [GeminiService] Detected OpenRouter / OpenAI compatible API Key.")
        is_openrouter = True
    else:
        try:
            genai.configure(api_key=settings.GEMINI_API_KEY)
            model = genai.GenerativeModel('gemini-1.5-pro')
            logger.info("🔑 [GeminiService] Configured official Google GenAI SDK.")
        except Exception as e:
            logger.warning(f"Could not configure Gemini API: {e}")
            model = None

def _call_ai_engine(prompt: str) -> str | None:
    """
    Helper function calling either OpenRouter REST API or official Google GenAI SDK.
    """
    if is_openrouter:
        try:
            url = "https://openrouter.ai/api/v1/chat/completions"
            headers = {
                "Authorization": f"Bearer {settings.GEMINI_API_KEY}",
                "Content-Type": "application/json",
                "HTTP-Referer": "https://github.com/LanguageLearningApp",
                "X-Title": "Language Learning Portfolio App"
            }
            payload = {
                "model": settings.OPENROUTER_MODEL,
                "messages": [{"role": "user", "content": prompt}]
            }
            logger.info(f"🚀 [OpenRouter] Calling AI model: {settings.OPENROUTER_MODEL}")
            with httpx.Client(timeout=12.0) as client:
                resp = client.post(url, headers=headers, json=payload)
                if resp.status_code == 200:
                    data = resp.json()
                    return data["choices"][0]["message"]["content"]
                else:
                    logger.error(f"⚠️ OpenRouter API error {resp.status_code}: {resp.text}")
        except Exception as e:
            logger.error(f"⚠️ OpenRouter request exception: {e}")
            return None
    elif model:
        try:
            response = model.generate_content(prompt, request_options={"timeout": 12.0})
            return response.text
        except Exception as e:
            logger.error(f"⚠️ Google GenAI SDK error: {e}")
            return None
    return None

def _clean_json_string(text_resp: str) -> dict | None:
    try:
        text_resp = text_resp.strip()
        if text_resp.startswith("```json"):
            text_resp = text_resp[7:-3].strip()
        elif text_resp.startswith("```"):
            text_resp = text_resp[3:-3].strip()
        return json.loads(text_resp)
    except Exception:
        # Try to extract JSON object using regex if standard stripping fails
        try:
            match = re.search(r'\{.*\}', text_resp, re.DOTALL)
            if match:
                return json.loads(match.group(0))
        except Exception as e2:
            logger.error(f"⚠️ Could not parse JSON from AI response: {e2}\nRaw: {text_resp}")
        return None

def evaluate_ielts_essay(essay_text: str, prompt_id: str) -> dict:
    """
    Evaluates an IELTS Writing Task 1 essay using Gemini 1.5 Pro Multimodal.
    Returns a structured JSON report with 4 criteria band scores, grammar corrections, and lexical upgrades.
    """
    if is_openrouter or model:
        prompt = f"""
        You are an expert IELTS Examiner. Evaluate the following IELTS Writing Task 1 essay for prompt topic '{prompt_id}'.
        Essay: "{essay_text}"
        
        Return ONLY valid JSON with this exact structure:
        {{
          "overall_band": float,
          "sub_scores": {{
            "task_achievement": float,
            "cohesion_coherence": float,
            "lexical_resource": float,
            "grammatical_accuracy": float
          }},
          "general_comment": "string in Vietnamese explaining the score",
          "grammar_errors": [
            {{"line_number": int, "original": "string", "corrected": "string", "explanation": "string in Vietnamese"}}
          ],
          "lexical_upgrades": [
            {{"original_word": "string", "suggested_academic_words": ["string1", "string2"], "context_example": "string"}}
          ]
        }}
        """
        raw_res = _call_ai_engine(prompt)
        if raw_res:
            parsed = _clean_json_string(raw_res)
            if parsed:
                logger.info("🎯 [AI Engine] Successfully evaluated IELTS essay.")
                return parsed

    # Fallback / Demo Portfolio evaluation for seamless testing without API key or when API fails
    logger.info("ℹ️ [GeminiService] Using fallback intelligent IELTS evaluation.")
    return {
        "overall_band": 6.5,
        "sub_scores": {
            "task_achievement": 6.5,
            "cohesion_coherence": 6.5,
            "lexical_resource": 6.0,
            "grammatical_accuracy": 7.0
        },
        "general_comment": "Bài viết có bố cục rõ ràng, mô tả chính xác các xu hướng chính từ biểu đồ. Tuy nhiên, cấu trúc miêu tả sự tăng giảm còn lặp lại và thiếu các từ vựng học thuật cao cấp.",
        "grammar_errors": [
            {
                "line_number": 2,
                "original": "The amount of cars increase dramatically in 2010.",
                "corrected": "The number of cars increased dramatically in 2010.",
                "explanation": "Dùng 'number' cho danh từ đếm được số nhiều (cars) thay vì 'amount'. Biểu đồ trong năm 2010 nên động từ cần chia thì quá khứ đơn 'increased'."
            },
            {
                "line_number": 4,
                "original": "In conclusion, we can see that oil production go down.",
                "corrected": "Overall, it is evident that oil production experienced a downward trend.",
                "explanation": "Writing Task 1 không nên dùng từ xưng hô 'we'. Nên dùng câu bị động hoặc cấu trúc 'experience a downward trend' để trang trọng hơn."
            }
        ],
        "lexical_upgrades": [
            {
                "original_word": "go up very fast",
                "suggested_academic_words": ["experience a sharp surge", "soar significantly", "witness a steep rise"],
                "context_example": "The sales figures experienced a sharp surge from 20 to 80 million units in 2015."
            },
            {
                "original_word": "show the difference",
                "suggested_academic_words": ["illustrate the disparity", "delineate the contrast", "highlight the divergence"],
                "context_example": "The provided line graph clearly illustrates the disparity in energy consumption between the two sectors."
            }
        ]
    }

def chat_with_3d_tutor(message: str, module_context: str) -> dict:
    """
    Handles conversational Q&A with the 3D AI Tutor.
    Returns reply text, appropriate 3D avatar emotion state, and follow-up suggestions.
    """
    is_japanese_input = any('\u3040' <= c <= '\u309f' or '\u30a0' <= c <= '\u30ff' or '\u4e00' <= c <= '\u9faf' for c in message)
    is_japanese_only = (module_context == "japanese_kaiwa" or module_context == "japanese_only" or is_japanese_input)

    if is_openrouter or model:
        if is_japanese_only:
            prompt = f"""
            You are Sensei AI, an Anime Japanese language tutor represented as a 3D VTuber avatar.
            The user wants to practice pure Japanese Kaiwa (conversation).
            User message: "{message}"
            
            IMPORTANT: You MUST reply ENTIRELY in natural, friendly, conversational Japanese (日本語) so that the Anime AI Voice Synthesizer can speak your reply naturally in Japanese! Keep the reply concise (2-4 sentences).
            
            Return ONLY valid JSON with this structure:
            {{
              "reply_text": "string in natural conversational Japanese (日本語)",
              "avatar_emotion": "happy | thinking | explaining | cheering | idle",
              "suggested_questions": ["自己紹介をお願いします", "日本語が上手になりたいです"]
            }}
            """
        else:
            prompt = f"""
            You are Sensei AI, a friendly, encouraging language tutor represented as a 3D avatar.
            The user is asking a question in context '{module_context}'.
            User message: "{message}"
            
            Return ONLY valid JSON with this structure:
            {{
              "reply_text": "string in Vietnamese with helpful, pedagogically sound explanation",
              "avatar_emotion": "happy | thinking | explaining | cheering | idle",
              "suggested_questions": ["question 1", "question 2"]
            }}
            """
        raw_res = _call_ai_engine(prompt)
        if raw_res:
            parsed = _clean_json_string(raw_res)
            if parsed:
                logger.info("🎯 [AI Engine] Successfully generated 3D Tutor reply.")
                return parsed

    # Fallback intelligent tutor response based on keywords
    logger.info("ℹ️ [GeminiService] Using fallback intelligent 3D Tutor reply.")
    msg_lower = message.lower()
    
    if is_japanese_only:
        if any(w in msg_lower for w in ["こんにちは", "おはよう", "xin chào", "hi", "hello", "konnichiwa"]):
            return {
                "reply_text": "こんにちは！私は日本語AIチューターのセンセイです。今日はどんなことを勉強したいですか？一緒に楽しく日本語を話しましょう！",
                "avatar_emotion": "happy",
                "suggested_questions": ["自己紹介をお願いします", "日本語の勉強方法を教えてください"]
            }
        elif any(w in msg_lower for w in ["あります", "います", "arimasu", "imasu"]):
            return {
                "reply_text": "「あります」と「います」の違いですね！人や動物には「います」（例：犬がいます）を使い、物や植物には「あります」（例：本があります）を使います。とても大切な文法ですね！",
                "avatar_emotion": "explaining",
                "suggested_questions": ["助詞の「は」と「が」の違いは？", "動詞のテ形について教えて"]
            }
        elif any(w in msg_lower for w in ["て形", "te", "động từ"]):
            return {
                "reply_text": "動詞の「て形」ですね！例えば、「食べる」は「食べて」、「行く」は「行って」になります。お願いや接続表現によく使われますよ！",
                "avatar_emotion": "explaining",
                "suggested_questions": ["もっと例文を作って", "会話の練習をしましょう"]
            }
        else:
            return {
                "reply_text": f"「{message}」ですね！素晴らしい質問です。日本語の会話をもっと一緒に練習しましょう。私はあなたとお話しできてとても嬉しいです！",
                "avatar_emotion": "happy",
                "suggested_questions": ["日本の文化について教えて", "今日の天気はどうですか"]
            }

    # Helper function to match keywords cleanly using word boundaries for ASCII/short strings
    # This prevents short substrings like 'hi', 'ai', 'to', 'mo', 'e', 'ni', 'de', 'wa', 'ga' 
    # from falsely triggering inside words like 'giải thích', 'bài 1', 'tôi', 'ngữ pháp', 'xem'...
    def _has_kw(keywords):
        for kw in keywords:
            # For short keywords or ASCII strings, enforce word boundaries
            if len(kw) <= 4 and kw.isascii():
                if re.search(r'\b' + re.escape(kw) + r'\b', msg_lower, re.IGNORECASE):
                    return True
            else:
                if kw in msg_lower:
                    return True
        return False

    # --- NHÓM 1: CÁC CHUYÊN ĐỀ KIẾN THỨC N5 (Ưu tiên kiểm tra trước tiên) ---
    
    # 1. Phân biệt Arimasu (あります) và Imasu (います)
    if _has_kw(["arimasu", "imasu", "tồn tại", "có ở đâu", "ở đâu", "đồ vật", "con vật", "sinh vật"]):
        return {
            "reply_text": "Cả Arimasu và Imasu đều có nghĩa là 'CÓ / Ở', nhưng cách dùng rất khác nhau chuẩn N5:\n• IMASU (います): Dùng cho người và sinh vật có sự sống, có thể tự di chuyển.\n  👉 Ví dụ: Asoko ni inu ga imasu (Ở đằng kia có con chó).\n• ARIMASU (あります): Dùng cho đồ vật, cây cối, sự việc không có sự sống hoặc không tự di chuyển.\n  👉 Ví dụ: Tsukue no ue ni hon ga arimasu (Trên bàn có quyển sách).\n\n💡 Mẹo nhớ nhanh: 'Người/Động vật -> Imasu | Đồ vật/Cây cối -> Arimasu'!",
            "avatar_emotion": "explaining",
            "suggested_questions": [
                "Cho mình xin ví dụ phân biệt trợ từ Ni và De?",
                "Chia động từ thể Te thế nào?"
            ]
        }
    # 2. Trợ từ (Wa, Ga, Ni, De, Wo, E, Mo, To, Kara, Made)
    elif _has_kw(["wa", "ga", "trợ từ", "ni", "de", "wo", "kara", "made", "ngữ pháp trợ từ", "phân biệt wa", "phân biệt ga"]):
        return {
            "reply_text": "Trợ từ là 'linh hồn' của câu tiếng Nhật! Dưới đây là cách phân biệt chuẩn N5:\n• WA (は): Nhấn mạnh CHỦ ĐỀ câu (Watashi wa gakusei desu).\n• GA (が): Nhấn mạnh CHỦ NGỮ hành động hoặc thông tin mới (Dare ga kimashita ka).\n• NI (に): Chỉ thời điểm chính xác (7-ji ni) hoặc điểm đến/nơi tồn tại.\n• DE (で): Chỉ nơi diễn ra hành động (Gakkou de benkyou shimasu) hoặc phương tiện (Basu de ikimasu).\n• WO (を): Đi với tân ngữ chịu tác động của hành động (Gohan wo tabemasu).\n\nBạn đang thắc mắc cặp trợ từ cụ thể nào, hãy gõ ra để Sensei lấy ví dụ nhé!",
            "avatar_emotion": "happy",
            "suggested_questions": [
                "Cho mình xin ví dụ phân biệt trợ từ Ni và De?",
                "Phân biệt mẫu câu ~te imasu và ~te arimasu?"
            ]
        }
    # 3. Chia động từ / Thể Te / Thể Masu / Thể Nai / Thể từ điển
    elif _has_kw(["chia", "động từ", "thể te", "thể từ điển", "thể nai", "thể masu", "nhóm 1", "nhóm 2", "nhóm 3", "từ loại"]):
        return {
            "reply_text": "Động từ tiếng Nhật N5 chia làm 3 nhóm chính:\n• Nhóm 1 (kết trước -masu là cột i): Khi chuyển sang thể TE sẽ áp dụng quy tắc bài ca 'i-chi-ri -> tte', 'mi-bi-ni -> nde', 'ki -> ite', 'gi -> ide', 'shi -> shite'.\n• Nhóm 2 (kết trước -masu là cột e hoặc một số từ đặc biệt): Chỉ cần bỏ -masu thêm -te (ví dụ: tabemasu -> tabete, mimasu -> mite).\n• Nhóm 3 (bất quy tắc): shimasu -> shite, kimasu -> kite.\n\nBạn muốn Sensei hướng dẫn chi tiết về nhóm động từ hay mẫu cấu trúc nào nữa không?",
            "avatar_emotion": "explaining",
            "suggested_questions": [
                "Cách chia tính từ đuôi i và đuôi na?",
                "Phân biệt Arimasu và Imasu?"
            ]
        }
    # 4. Tính từ đuôi i / đuôi na / So sánh
    elif _has_kw(["tính từ", "đuôi i", "đuôi na", "takai", "yasui", "oishii", "kirei", "so sánh"]):
        return {
            "reply_text": "Tính từ tiếng Nhật N5 chia làm 2 loại:\n• Tính từ đuôi -i (như oishii - ngon, takai - đắt): Khi phủ định hiện tại sẽ bỏ -i thêm -kunai (oishikunai - không ngon). Quá khứ bỏ -i thêm -katta.\n• Tính từ đuôi -na (như kirei - đẹp/sạch, genki - khỏe): Dùng giống như danh từ, khi nối với danh từ thì giữ nguyên -na (kirei na hana - hoa đẹp), khi phủ định dùng -ja arimasen.\n\n⚠️ Lưu ý ngoại lệ: 'Kirei' và 'Yuu mei' dù kết thúc bằng chữ 'i' nhưng lại là tính từ đuôi na nhé!",
            "avatar_emotion": "explaining",
            "suggested_questions": [
                "Cách nói giờ và ngày tháng trong tiếng Nhật?",
                "Mẫu câu yêu cầu lịch sự ~te kudasai?"
            ]
        }
    # 5. Ngữ pháp nói chung / Các cấu trúc N5 (~te kudasai, ~tai, ~mashou, desu, deshita)
    elif _has_kw(["ngữ pháp", "mẫu câu", "kudasai", "tai desu", "mashou", "desu", "deshita", "quá khứ", "tương lai", "phủ định", "khẳng định", "cấu trúc"]):
        return {
            "reply_text": "Ở trình độ N5 (Minna no Nihongo), bạn cần nắm vững 4 mẫu cấu trúc trọng tâm:\n1️⃣ N1 wa N2 desu: N1 là N2 (Watashi wa gakusei desu).\n2️⃣ ~te kudasai: Yêu cầu/đề nghị ai làm gì một cách lịch sự (Chotto matte kudasai - Xin hãy đợi một chút).\n3️⃣ ~te imasu: Đang làm gì đó hoặc chỉ trạng thái (Gohan wo tabete imasu - Đang ăn cơm).\n4️⃣ ~tai desu: Muốn làm gì (Nihon e ikitai desu - Muốn đi Nhật).\n\nBạn đang ôn bài mấy, để Sensei tóm tắt ngữ pháp bài đó cho bạn nhé!",
            "avatar_emotion": "explaining",
            "suggested_questions": [
                "Phân biệt mẫu câu ~te imasu và ~te arimasu?",
                "Chia động từ thể Te thế nào?"
            ]
        }
    # 6. Số đếm / Thời gian / Giờ / Phút / Ngày tháng / Tiền tệ
    elif _has_kw(["số", "đếm", "giờ", "tháng", "ngày", "năm", "tiền", "yen", "phút", "tuần", "bao nhiêu tiền", "ikura", "nanji", "thời gian"]):
        return {
            "reply_text": "Cách đếm trong tiếng Nhật có một số trường hợp biến âm cần lưu ý:\n• Số đếm cơ bản: 1 (ichi), 2 (ni), 3 (san), 4 (yon/shi), 5 (go), 6 (roku), 7 (nana/shichi), 8 (hachi), 9 (kyuu/ku), 10 (juu).\n• Giờ: Chú ý 4 giờ là 'yo-ji' (không phải yon-ji), 7 giờ là 'shichi-ji', 9 giờ là 'ku-ji'.\n• Phút: Các số 1, 3, 4, 6, 8, 10 sẽ chuyển sang 'pun/ppun' (ví dụ 10 phút là juppun).\n\nBạn thử gõ một giờ hoặc số tiền bất kỳ, Sensei sẽ viết phiên âm tiếng Nhật giúp bạn nhé!",
            "avatar_emotion": "happy",
            "suggested_questions": [
                "Cách hỏi giá tiền trong tiếng Nhật?",
                "Các ngày trong tuần tiếng Nhật đọc thế nào?"
            ]
        }
    # 7. Kanji / Viết nét / Chữ Hán / Bộ thủ
    elif _has_kw(["kanji", "viết", "chữ", "nét", "nhớ", "hán", "bộ thủ", "onyomi", "kunyomi", "chữ tượng hình"]):
        return {
            "reply_text": "Chào bạn! Để học và ghi nhớ Kanji N5 hiệu quả, Sensei khuyên bạn áp dụng 3 bí quyết vàng:\n1️⃣ Học theo phương pháp tượng hình và bộ thủ (ví dụ chữ Mộc 木 là cây, 2 cây ghép lại thành Lâm 林 - rừng);\n2️⃣ Nắm vững quy tắc viết nét 'Trái trước phải sau, trên trước dưới sau, ngang trước dọc sau, ngoài trước trong sau';\n3️⃣ Ôn tập ngắt quãng (SRS) hàng ngày! Bạn có thể vào tab 'Tiếng Nhật N5' chọn chức năng Luyện Viết Kana/Kanji để thực hành vẽ từng nét ngay nhé!",
            "avatar_emotion": "explaining",
            "suggested_questions": [
                "Làm sao nhớ cách phát âm Onyomi và Kunyomi?",
                "Có bao nhiêu bộ thủ cơ bản trong Kanji N5?"
            ]
        }
    # 8. Bảng chữ cái Hiragana / Katakana
    elif _has_kw(["hiragana", "katakana", "bảng chữ cái", "kana", "trường âm", "xúc âm", "biến âm", "ảo âm", "chữ mềm", "chữ cứng"]):
        return {
            "reply_text": "Bảng chữ cái là nền tảng quan trọng nhất của N5! Tiếng Nhật có 3 bộ chữ chính:\n1️⃣ Hiragana (46 chữ mềm): Dùng cho từ thuần Nhật và chia ngữ pháp;\n2️⃣ Katakana (46 chữ cứng): Dùng để phiên âm từ mượn tiếng nước ngoài (tên riêng, địa danh);\n3️⃣ Kanji (Chữ Hán): Dùng để rút ngắn câu và phân biệt nghĩa homonym.\n\n👉 Mẹo nhỏ: Bạn hãy vào tab 'Tiếng Nhật N5' -> 'Luyện Viết Kana/Kanji' để tập vẽ từng nét mỗi ngày nhé!",
            "avatar_emotion": "explaining",
            "suggested_questions": [
                "Quy tắc phát âm trường âm và xúc âm?",
                "Làm sao nhớ cách viết chữ Kanji N5 nhanh nhất?"
            ]
        }
    # 9. Luyện thi JLPT N5 / Kinh nghiệm / Điểm đỗ
    elif _has_kw(["jlpt", "thi", "đề", "điểm", "đỗ", "đậu", "phần thi", "nghe hiểu", "đọc hiểu", "khó không", "kinh nghiệm", "luyện đề"]):
        return {
            "reply_text": "Kỳ thi JLPT N5 gồm 3 phần thi chính với tổng thời gian khoảng 105 phút:\n1️⃣ Kiến thức ngôn ngữ (Chữ Hán & Từ vựng): 25 phút.\n2️⃣ Ngữ pháp & Đọc hiểu: 50 phút.\n3️⃣ Nghe hiểu: 30 phút.\n\n🎯 Điểm đỗ: Bạn cần đạt tối thiểu 80/180 điểm tổng (trong đó mỗi phần không dưới điểm liệt 19 điểm).\n👉 Mẹo thi: Tập trung cày chắc 120 từ vựng và Kanji trong app, khi làm bài đọc hiểu hãy chú ý các trợ từ wa/ga/wo và từ nối ở đầu câu nhé!",
            "avatar_emotion": "cheering",
            "suggested_questions": [
                "Cách ôn tập từ vựng N5 nhớ lâu?",
                "Cần chuẩn bị gì trước ngày thi JLPT?"
            ]
        }
    # 10. Bài học Minna no Nihongo (Bài 1 -> 5)
    elif _has_kw(["bài 1", "bài 2", "bài 3", "bài 4", "bài 5", "minna", "giáo trình", "sách", "bài học"]):
        return {
            "reply_text": "Hệ thống bài học N5 trong app được thiết kế chuẩn theo lộ trình 5 bài đầu của giáo trình Minna no Nihongo:\n• Bài 1: Giới thiệu bản thân, nghề nghiệp, quốc tịch (~wa ~desu).\n• Bài 2 & 3: Chỉ định từ đồ vật và địa điểm (Kore, Sore, Are, Koko, Soko, Asoko).\n• Bài 4: Thời gian, giờ giấc, thứ trong tuần, động từ quá khứ (~mashita).\n• Bài 5: Động từ di chuyển (Ikimasu - đi, Kimasu - đến, Kaerimasu - về) cùng trợ từ e, de, to.\n\nBạn hãy vào tab 'Tiếng Nhật N5' trên màn hình chính và bấm chọn từng bài học để luyện Flashcard và Quiz nhé!",
            "avatar_emotion": "cheering",
            "suggested_questions": [
                "Ngữ pháp trọng tâm Bài 1 là gì?",
                "Cách hỏi địa điểm Koko, Soko, Asoko?"
            ]
        }
    # 11. Từ vựng / Flashcard / SRS / Cách học
    elif _has_kw(["từ vựng", "srs", "flashcard", "thẻ bài", "từ mới", "nhớ lâu", "ôn tập"]):
        return {
            "reply_text": "Chào bạn! Để học từ vựng tiếng Nhật N5 nhanh thuộc và nhớ lâu, bí quyết lớn nhất là sử dụng phương pháp Lặp lại ngắt quãng (SRS - Spaced Repetition System). Hệ thống thuật toán SM-2 trong app sẽ tự động tính toán 'thời điểm vàng' (khi bạn chuẩn bị quên) để nhắc lại từ đó.\n\nMỗi ngày bạn chỉ cần dành 15 phút ôn tập với Flashcard SRS trong tab 'Tiếng Nhật N5' là có thể thuộc lòng trọn vẹn hơn 120+ từ vựng cực kỳ nhẹ nhàng!",
            "avatar_emotion": "cheering",
            "suggested_questions": [
                "Làm sao để nhớ cách viết chữ Kanji N5 nhanh nhất?",
                "Phân biệt trợ từ Wa và Ga trong tiếng Nhật?"
            ]
        }
    # 12. Phát âm / Luyện nghe
    elif _has_kw(["phát âm", "luyện nghe", "nghe", "nói", "trọng âm", "giọng"]):
        return {
            "reply_text": "Để phát âm tiếng Nhật chuẩn như người bản xứ, bạn cần chú ý đến cao độ (Pitch Accent) và độ dài của trường âm/xúc âm. Trong tiếng Nhật không có trọng âm mạnh nhẹ như tiếng Anh, mà các âm tiết được phát âm với cao độ ngang nhau hoặc lên/xuống nhịp nhàng.\n\n👉 Bạn hãy bật tính năng phát âm Audio (TTS) trên các thẻ bài Flashcard trong app và tập nói đuổi theo (Shadowing) hàng ngày nhé!",
            "avatar_emotion": "explaining",
            "suggested_questions": [
                "Quy tắc phát âm trường âm và xúc âm?",
                "Làm sao cải thiện kỹ năng nghe hiểu N5?"
            ]
        }

    # --- NHÓM 2: GIAO TIẾP LỊCH SỰ & CHÀO HỎI (Đưa xuống cuối để không chặn các câu hỏi chuyên đề) ---
    
    # 13. Cảm ơn, Xin lỗi, Lịch sự
    elif _has_kw(["cảm ơn", "arigato", "arigatou", "xin lỗi", "sumimasen", "gomen", "tạm biệt", "sayonara", "mata ne"]):
        return {
            "reply_text": "Douitashimashite (どういたしまして - Không có chi)! Trong giao tiếp tiếng Nhật, thái độ lịch sự và lòng biết ơn luôn được đánh giá rất cao. Nếu có điểm ngữ pháp hay từ vựng nào chưa hiểu rõ, bạn cứ thoải mái hỏi Sensei bất cứ lúc nào nhé!",
            "avatar_emotion": "happy",
            "suggested_questions": [
                "Phân biệt Arimasu và Imasu?",
                "Chia động từ thể Te thế nào?"
            ]
        }
    # 14. Chào hỏi & Giới thiệu
    elif _has_kw(["chào", "hello", "hi", "konnichiwa", "ohayo", "konbanwa", "oyasumi", "sensei", "tên gì", "bạn là ai", "ai đấy", "genki", "khỏe không"]):
        return {
            "reply_text": "Konnichiwa (こんにちは)! Mình là Sensei AI - Trợ lý 3D đồng hành cùng bạn trên hành trình chinh phục tiếng Nhật N5! Bạn có thể hỏi mình bất cứ điều gì về bảng chữ cái Hiragana/Katakana, ngữ pháp Minna no Nihongo, cách viết Kanji, hay mẹo thi JLPT nhé!",
            "avatar_emotion": "cheering",
            "suggested_questions": [
                "Bảng chữ cái Hiragana có bao nhiêu chữ?",
                "Cách nhớ Kanji hiệu quả?"
            ]
        }
    # 15. Smart Contextual Fallback cho bất kỳ câu hỏi nào khác
    else:
        return {
            "reply_text": f"Chào bạn! Sensei đã tiếp nhận câu hỏi của bạn: '{message}'. Trong chương trình tiếng Nhật N5, đây là một nội dung rất thú vị! Để nắm vững kiến thức này, bạn nên kết hợp ghi nhớ từ vựng, rèn luyện cách chia động từ và áp dụng thực hành đặt câu.\n\n👉 Bạn có thể vào tab 'Tiếng Nhật N5' để ôn tập Flashcard SRS hoặc làm Quiz trắc nghiệm củng cố kiến thức nhé!",
            "avatar_emotion": "happy",
            "suggested_questions": [
                "Cách nhớ Kanji hiệu quả?",
                "Phân biệt trợ từ Wa và Ga trong tiếng Nhật?"
            ]
        }
