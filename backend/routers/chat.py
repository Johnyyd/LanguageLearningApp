import hashlib
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from models import ChatHistory, SessionLocal
from services.gemini_service import chat_with_3d_tutor
from services.cache_service import cache_service

router = APIRouter(prefix="/api/v1/chat", tags=["3D AI Tutor Chat"])

class ChatRequest(BaseModel):
    message: str
    module_context: str = "japanese_n5"
    user_id: int = 1

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/ask")
def ask_tutor(request: ChatRequest, db: Session = Depends(get_db)):
    msg_hash = hashlib.md5(f"{request.module_context}:{request.message.strip().lower()}".encode('utf-8')).hexdigest()
    cache_key = f"chat:qa:{msg_hash}"
    cached_res = cache_service.get(cache_key)
    if cached_res:
        print(f"🎯 [Redis Hit] Returning cached chat response for {request.message[:20]}...")
        return cached_res

    res = chat_with_3d_tutor(request.message, request.module_context)
    
    # Save log
    try:
        log = ChatHistory(
            user_id=request.user_id,
            message=request.message,
            reply=res.get("reply_text", ""),
            emotion=res.get("avatar_emotion", "idle")
        )
        db.add(log)
        db.commit()
    except Exception as e:
        print(f"Warning: Could not save chat log: {e}")
        
    response_payload = {
        "status": "success",
        "reply_text": res.get("reply_text"),
        "avatar_emotion": res.get("avatar_emotion", "happy"),
        "speech_audio_url": None, # In prod, return TTS audio stream URL
        "suggested_questions": res.get("suggested_questions", []),
        "cached": False
    }
    
    # Cache response for 30 minutes (1800s)
    cache_service.set(cache_key, response_payload, ttl=1800)
    
    return response_payload
