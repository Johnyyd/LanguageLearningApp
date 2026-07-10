# =====================================================================
# 🎙️ Voice Service (Style-Bert-VITS2 / GPT-SoVITS Integration & Viseme Pipeline)
# =====================================================================

import io
import re
import httpx
import logging
from typing import List, Dict, Any, Optional
from config import settings

logger = logging.getLogger(__name__)

def _generate_synthetic_audio(duration_sec: float, sample_rate: int = 24000) -> bytes:
    """
    Generates acoustic speech-like harmonic waveform (24kHz WAV) in memory for fallback audio streaming.
    """
    try:
        import numpy as np
        import scipy.io.wavfile as wavfile
        t = np.linspace(0, duration_sec, int(sample_rate * duration_sec), endpoint=False)
        freq = 220.0 + 30.0 * np.sin(2 * np.pi * 3.0 * t)
        signal = 0.3 * np.sin(2 * np.pi * freq * t)
        signal += 0.15 * np.sin(2 * np.pi * (freq * 2) * t)
        signal += 0.08 * np.sin(2 * np.pi * (freq * 3) * t)
        
        fade_len = int(sample_rate * 0.05)
        if len(signal) > fade_len * 2:
            signal[:fade_len] *= np.linspace(0, 1, fade_len)
            signal[-fade_len:] *= np.linspace(1, 0, fade_len)
            
        audio_int16 = np.int16(signal * 32767)
        buf = io.BytesIO()
        wavfile.write(buf, sample_rate, audio_int16)
        buf.seek(0)
        return buf.read()
    except Exception as e:
        logger.warning(f"⚠️ Could not generate harmonic audio ({e}). Returning minimal WAV header.")
        # Minimal 44-byte silent WAV header if numpy/scipy unavailable
        return b'RIFF$\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00\x80\xbb\x00\x00\x00w\x01\x00\x02\x00\x10\x00data\x00\x00\x00\x00'

def _generate_fallback_visemes(text: str, duration_sec: float) -> List[Dict[str, Any]]:
    """
    Generates fallback VRM/VTuber lip-sync visemes from text when Voice Engine microservice is offline.
    Maps hiragana/katakana/romaji vowels to VRM blendshapes: mouth_a, mouth_i, mouth_u, mouth_e, mouth_o.
    """
    clean_text = re.sub(r'[^\w\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]', '', text)
    if not clean_text:
        clean_text = "aiueo"
    
    char_count = len(clean_text)
    time_per_char = duration_sec / max(char_count, 1)
    
    visemes = []
    current_time = 0.0
    
    vowel_map = {
        'a': 'mouth_a', 'あ': 'mouth_a', 'か': 'mouth_a', 'さ': 'mouth_a', 'た': 'mouth_a', 'な': 'mouth_a', 'は': 'mouth_a', 'ま': 'mouth_a', 'や': 'mouth_a', 'ら': 'mouth_a', 'わ': 'mouth_a',
        'ア': 'mouth_a', 'カ': 'mouth_a', 'サ': 'mouth_a', 'タ': 'mouth_a', 'ナ': 'mouth_a', 'ハ': 'mouth_a', 'マ': 'mouth_a', 'ヤ': 'mouth_a', 'ラ': 'mouth_a', 'ワ': 'mouth_a',
        'i': 'mouth_i', 'い': 'mouth_i', 'き': 'mouth_i', 'し': 'mouth_i', 'ち': 'mouth_i', 'に': 'mouth_i', 'ひ': 'mouth_i', 'み': 'mouth_i', 'り': 'mouth_i',
        'イ': 'mouth_i', 'キ': 'mouth_i', 'シ': 'mouth_i', 'チ': 'mouth_i', 'ニ': 'mouth_i', 'ヒ': 'mouth_i', 'ミ': 'mouth_i', 'リ': 'mouth_i',
        'u': 'mouth_u', 'う': 'mouth_u', 'く': 'mouth_u', 'す': 'mouth_u', 'つ': 'mouth_u', 'ぬ': 'mouth_u', 'ふ': 'mouth_u', 'む': 'mouth_u', 'ゆ': 'mouth_u', 'る': 'mouth_u', 'ん': 'mouth_u',
        'ウ': 'mouth_u', 'ク': 'mouth_u', 'ス': 'mouth_u', 'ツ': 'mouth_u', 'ヌ': 'mouth_u', 'フ': 'mouth_u', 'ム': 'mouth_u', 'ユ': 'mouth_u', 'ル': 'mouth_u', 'ン': 'mouth_u',
        'e': 'mouth_e', 'え': 'mouth_e', 'け': 'mouth_e', 'せ': 'mouth_e', 'て': 'mouth_e', 'ね': 'mouth_e', 'へ': 'mouth_e', 'め': 'mouth_e', 'れ': 'mouth_e',
        'エ': 'mouth_e', 'ケ': 'mouth_e', 'セ': 'mouth_e', 'テ': 'mouth_e', 'ネ': 'mouth_e', 'ヘ': 'mouth_e', 'メ': 'mouth_e', 'レ': 'mouth_e',
        'o': 'mouth_o', 'お': 'mouth_o', 'こ': 'mouth_o', 'そ': 'mouth_o', 'と': 'mouth_o', 'の': 'mouth_o', 'ほ': 'mouth_o', 'も': 'mouth_o', 'よ': 'mouth_o', 'ろ': 'mouth_o', 'を': 'mouth_o',
        'オ': 'mouth_o', 'コ': 'mouth_o', 'ソ': 'mouth_o', 'ト': 'mouth_o', 'ノ': 'mouth_o', 'ホ': 'mouth_o', 'モ': 'mouth_o', 'ヨ': 'mouth_o', 'ロ': 'mouth_o', 'ヲ': 'mouth_o',
    }
    
    for i, char in enumerate(clean_text):
        viseme_name = vowel_map.get(char.lower(), "mouth_a")
        visemes.append({
            "time": round(current_time, 3),
            "viseme": viseme_name,
            "value": 0.85 if i % 2 == 0 else 0.65
        })
        current_time += time_per_char
        
        if i < char_count - 1 and time_per_char > 0.15:
            visemes.append({
                "time": round(current_time - (time_per_char * 0.2), 3),
                "viseme": "mouth_close",
                "value": 0.0
            })
            
    visemes.append({
        "time": round(duration_sec, 3),
        "viseme": "mouth_close",
        "value": 0.0
    })
    return visemes

def synthesize_voice_and_visemes(
    text: str,
    speaker_id: str = "sensei_va_01",
    emotion: str = "talking",
    speed: float = 1.0
) -> Dict[str, Any]:
    """
    Calls the Voice Engine microservice to synthesize speech and get visemes.
    Falls back to intelligent local simulation if microservice is unreachable.
    """
    voice_url = getattr(settings, "VOICE_ENGINE_URL", "http://localhost:1114")
    endpoint = f"{voice_url}/synthesize"
    
    payload = {
        "text": text,
        "speaker_id": speaker_id,
        "emotion": emotion,
        "speed": speed
    }
    
    import urllib.parse
    encoded_text = urllib.parse.quote(text)
    
    try:
        logger.info(f"🎙️ [VoiceService] Calling Voice Engine at {endpoint} for speaker '{speaker_id}'...")
        with httpx.Client(timeout=4.0) as client:
            resp = client.post(endpoint, json=payload)
            if resp.status_code == 200:
                data = resp.json()
                logger.info("✅ [VoiceService] Successfully retrieved visemes and metadata from Voice Engine.")
                return {
                    "status": "success",
                    "speaker_id": data.get("speaker", speaker_id),
                    "emotion": data.get("emotion", emotion),
                    "duration_seconds": data.get("duration_seconds", 3.0),
                    "visemes": data.get("visemes", []),
                    "audio_stream_url": f"/api/v1/chat/audio?text={encoded_text}&speaker_id={speaker_id}&speed={speed}"
                }
            else:
                logger.warning(f"⚠️ Voice Engine returned status {resp.status_code}: {resp.text}. Using fallback.")
    except Exception as e:
        logger.warning(f"⚠️ Voice Engine unreachable ({e}). Using simulated fallback visemes.")
        
    # Fallback simulation
    text_len = max(len(text), 1)
    duration_sec = max((text_len / 4.0) / max(speed, 0.5), 1.5)
    visemes = _generate_fallback_visemes(text, duration_sec)
    
    return {
        "status": "success_fallback",
        "speaker_id": speaker_id,
        "emotion": emotion,
        "duration_seconds": round(duration_sec, 2),
        "visemes": visemes,
        "audio_stream_url": f"/api/v1/chat/audio?text={encoded_text}&speaker_id={speaker_id}&speed={speed}"
    }

def _synthesize_cloned_voice(text: str, speaker_id: str = "sensei_va_01", speed: float = 1.0) -> bytes:
    """
    Synthesizes AI Voice Cloned speech audio (WAV/MP3 bytes) for Anime characters.
    Does NOT use simple pitch/speed shifting. Uses model-based voice synthesis:
    1. Style-Bert-VITS2 / GPT-SoVITS microservice endpoint (VITS_URL / SOVITS_URL)
    2. ElevenLabs API voice cloning (ELEVENLABS_API_KEY)
    3. Neural AI Voice Speech Synthesis (Edge-TTS / Online Neural Speech Engine)
    """
    import os, urllib.parse
    
    # Tier 1: Style-Bert-VITS2 / GPT-SoVITS Custom Voice Cloning Server (Default 9880 from AI_Voice_Workspace)
    vits_url = os.environ.get("VITS_URL") or os.environ.get("SOVITS_URL") or os.environ.get("VOICE_CLONE_URL") or "http://127.0.0.1:9880"
    if vits_url:
        try:
            with httpx.Client(timeout=10.0) as client:
                res = client.get(f"{vits_url.rstrip('/')}/tts", params={
                    "text": text, "text_lang": "vi" if any(c in text.lower() for c in "àáảãạèéẻẽẹìíỉĩịòóỏõọùúủũụăâđêôơư") else "ja"
                })
                if res.status_code == 200 and len(res.content) > 100:
                    return res.content
        except Exception:
            pass
        try:
            with httpx.Client(timeout=6.0) as client:
                res = client.post(f"{vits_url.rstrip('/')}/synthesize", json={
                    "text": text, "speaker_id": speaker_id, "speed": speed
                })
                if res.status_code == 200 and len(res.content) > 100:
                    return res.content
        except Exception:
            pass
        try:
            with httpx.Client(timeout=8.0) as client:
                res = client.get(f"{vits_url.rstrip('/')}/", params={
                    "text": text, "text_lang": "ja" if "sensei" in speaker_id else "vi"
                })
                if res.status_code == 200 and len(res.content) > 100:
                    return res.content
        except Exception:
            pass
        try:
            model_map = {"sensei_va_01": 0, "sensei_va_02": 1, "sensei_va_03": 2, "sensei_va_04": 3}
            with httpx.Client(timeout=8.0) as client:
                res = client.get(f"{vits_url.rstrip('/')}/voice", params={
                    "text": text, "model_id": model_map.get(speaker_id, 0), "speaker_id": 0, "speed": speed
                })
                if res.status_code == 200 and len(res.content) > 100:
                    return res.content
        except Exception as e:
            logger.warning(f"⚠️ Custom VITS/SoVITS voice clone server unreachable: {e}")

    # Tier 2: ElevenLabs API Voice Cloning
    eleven_key = os.environ.get("ELEVENLABS_API_KEY")
    if eleven_key:
        voice_id_map = {
            "sensei_va_01": os.environ.get("VOICE_ID_SAKURA", "EXAVITQu4vr4xnSDxMaL"),
            "sensei_va_02": os.environ.get("VOICE_ID_KENJI", "ErXwobaYiN019PkySvjV"),
            "sensei_va_03": os.environ.get("VOICE_ID_AOI", "MF3mGyEYCl7XYWbV9V6O"),
            "sensei_va_04": os.environ.get("VOICE_ID_ZEROTWO", "TX3LPaxmSGnfKAjCFHIx"),
        }
        target_voice_id = voice_id_map.get(speaker_id, "EXAVITQu4vr4xnSDxMaL")
        try:
            url = f"https://api.elevenlabs.io/v1/text-to-speech/{target_voice_id}"
            headers = {"Accept": "audio/mpeg", "Content-Type": "application/json", "xi-api-key": eleven_key}
            payload = {"text": text, "model_id": "eleven_multilingual_v2", "voice_settings": {"stability": 0.5, "similarity_boost": 0.8}}
            with httpx.Client(timeout=8.0) as client:
                res = client.post(url, json=payload, headers=headers)
                if res.status_code == 200 and len(res.content) > 100:
                    return res.content
        except Exception as e:
            logger.warning(f"⚠️ ElevenLabs voice cloning API failed: {e}")

    # Tier 2.5: HuggingFace Public Anime VITS Spaces via gradio_client (Free Anime Voice Synthesis)
    try:
        from gradio_client import Client
        hf_char_map = {
            "sensei_va_01": "Silence Suzuka", # Giọng nữ dịu dàng (phong cách Kana Hanazawa)
            "sensei_va_02": "Gold Ship",      # Giọng nam/năng động (phong cách Yuki Kaji)
            "sensei_va_03": "Haru Urara",     # Giọng loli nhí nhảnh (phong cách Rie Takahashi)
            "sensei_va_04": "Mejiro McQueen", # Giọng trưởng thành quyến rũ (phong cách Haruka Tomatsu)
        }
        char_name = hf_char_map.get(speaker_id, "Silence Suzuka")
        client = Client("Plachta/VITS-Umamusume-voice-synthesizer")
        result = client.predict(
            text,
            char_name,
            "Japanese",
            speed,
            api_name="/predict"
        )
        if result and isinstance(result, str) and os.path.exists(result):
            with open(result, "rb") as f:
                audio_bytes = f.read()
            if len(audio_bytes) > 100:
                return audio_bytes
    except Exception as e:
        logger.debug(f"HuggingFace Gradio VITS API fallback bypassed: {e}")

    # Tier 3: Neural AI Anime Voices via edge-tts (if installed in environment)
    try:
        import edge_tts
        import asyncio
        
        is_vi = any(c in text.lower() for c in "àáảãạèéẻẽẹìíỉĩịòóỏõọùúủũụăâđêôơư")
        if is_vi:
            vi_map = {
                "sensei_va_01": "vi-VN-HoaiMyNeural",
                "sensei_va_02": "vi-VN-NamMinhNeural",
                "sensei_va_03": "vi-VN-HoaiMyNeural",
                "sensei_va_04": "vi-VN-HoaiMyNeural",
            }
            voice_name = vi_map.get(speaker_id, "vi-VN-HoaiMyNeural")
        else:
            ja_map = {
                "sensei_va_01": "ja-JP-NanamiNeural",
                "sensei_va_02": "ja-JP-KeitaNeural",
                "sensei_va_03": "ja-JP-MayuNeural",
                "sensei_va_04": "ja-JP-ShioriNeural",
            }
            voice_name = ja_map.get(speaker_id, "ja-JP-NanamiNeural")
            
        async def _run_edge():
            communicate = edge_tts.Communicate(text, voice_name)
            audio_data = b""
            async for chunk in communicate.stream():
                if chunk["type"] == "audio":
                    audio_data += chunk["data"]
            return audio_data
            
        try:
            loop = asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
        if loop.is_running():
            import concurrent.futures
            with concurrent.futures.ThreadPoolExecutor() as pool:
                audio_bytes = pool.submit(lambda: asyncio.run(_run_edge())).result()
        else:
            audio_bytes = loop.run_until_complete(_run_edge())
            
        if audio_bytes and len(audio_bytes) > 100:
            return audio_bytes
    except Exception as e:
        logger.debug(f"edge_tts not available or failed: {e}")

    # Tier 4: Online Speech API Stream (High quality human speech fallback)
    try:
        target_lang = "vi" if any(c in text.lower() for c in "àáảãạèéẻẽẹìíỉĩịòóỏõọùúủũụăâđêôơư") else "ja"
        url = f"https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q={urllib.parse.quote(text)}&tl={target_lang}"
        with httpx.Client(timeout=5.0) as client:
            res = client.get(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
            if res.status_code == 200 and len(res.content) > 100:
                return res.content
    except Exception as e:
        logger.debug(f"Online TTS stream failed: {e}")

    # Tier 5: Fallback harmonic acoustic wave if all network audio fails
    text_len = max(len(text), 1)
    duration_sec = max((text_len / 4.0) / max(speed, 0.5), 1.5)
    return _generate_synthetic_audio(duration_sec)

def get_audio_stream(text: str, speaker_id: str = "sensei_va_01", speed: float = 1.0) -> bytes:
    """
    Retrieves synthetic speech audio stream from Voice Engine or generates AI cloned voice.
    """
    voice_url = getattr(settings, "VOICE_ENGINE_URL", "http://localhost:1114")
    endpoint = f"{voice_url}/synthesize/audio"
    
    payload = {
        "text": text,
        "speaker_id": speaker_id,
        "speed": speed
    }
    
    try:
        with httpx.Client(timeout=4.0) as client:
            resp = client.post(endpoint, json=payload)
            if resp.status_code == 200 and len(resp.content) > 100:
                return resp.content
    except Exception as e:
        logger.warning(f"⚠️ Voice Engine audio stream unreachable ({e}). Using AI voice cloning generator.")
        
    return _synthesize_cloned_voice(text, speaker_id, speed)

