import hashlib
from fastapi import APIRouter, Depends
from fastapi.responses import Response
from pydantic import BaseModel
from sqlalchemy.orm import Session
from models import ChatHistory, SessionLocal
from services.gemini_service import chat_with_3d_tutor
from services.cache_service import cache_service
from services.voice_service import synthesize_voice_and_visemes, get_audio_stream

router = APIRouter(prefix="/api/v1/chat", tags=["3D AI Tutor Chat"])

class ChatRequest(BaseModel):
    message: str
    module_context: str = "japanese_n5"
    user_id: int = 1
    speaker_id: str = "sensei_va_01"
    enable_voice_cloning: bool = True

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/ask")
def ask_tutor(request: ChatRequest, db: Session = Depends(get_db)):
    msg_hash = hashlib.md5(f"{request.module_context}:{request.message.strip().lower()}:{request.speaker_id}".encode('utf-8')).hexdigest()
    cache_key = f"chat:qa:v7:{msg_hash}"
    cached_res = cache_service.get(cache_key)
    if cached_res:
        print(f"🎯 [Redis Hit] Returning cached chat response for {request.message[:20]}...")
        return cached_res

    res = chat_with_3d_tutor(request.message, request.module_context)
    reply_text = res.get("reply_text", "")
    emotion = res.get("avatar_emotion", "happy")
    
    # Generate Voice & Viseme timestamps for 3D VTuber Lip-sync
    voice_data = {}
    if request.enable_voice_cloning:
        voice_data = synthesize_voice_and_visemes(
            text=reply_text,
            speaker_id=request.speaker_id,
            emotion=emotion
        )
    
    # Save log
    try:
        log = ChatHistory(
            user_id=request.user_id,
            message=request.message,
            reply=reply_text,
            emotion=emotion
        )
        db.add(log)
        db.commit()
    except Exception as e:
        print(f"Warning: Could not save chat log: {e}")
        
    response_payload = {
        "status": "success",
        "reply_text": reply_text,
        "avatar_emotion": emotion,
        "speech_audio_url": voice_data.get("audio_stream_url"),
        "visemes": voice_data.get("visemes", []),
        "duration_seconds": voice_data.get("duration_seconds", 3.0),
        "voice_actor_id": voice_data.get("speaker_id", request.speaker_id),
        "suggested_questions": res.get("suggested_questions", []),
        "cached": False
    }
    
    # Cache response for 30 minutes (1800s)
    cache_service.set(cache_key, response_payload, ttl=1800)
    
    return response_payload

@router.get("/audio")
def stream_tutor_audio(text: str, speaker_id: str = "sensei_va_01", speed: float = 1.0):
    """
    Streams synthesized audio for Anime VA voice cloning.
    """
    audio_bytes = get_audio_stream(text=text, speaker_id=speaker_id, speed=speed)
    media_type = "audio/wav"
    if audio_bytes and (audio_bytes.startswith(b'\xff\xf3') or audio_bytes.startswith(b'\xff\xfb') or audio_bytes.startswith(b'ID3')):
        media_type = "audio/mpeg"
    return Response(content=audio_bytes, media_type=media_type)

@router.delete("/clear-cache")
@router.post("/clear-cache")
def clear_chat_cache():
    cache_service.flush_all()
    return {"status": "success", "message": "All chat cache flushed successfully."}


