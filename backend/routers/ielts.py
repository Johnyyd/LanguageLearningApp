import json
import hashlib
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from models import EssaySubmission, SessionLocal
from services.gemini_service import evaluate_ielts_essay
from services.cache_service import cache_service

router = APIRouter(prefix="/api/v1/ielts", tags=["IELTS Writing AI Coach"])

class IeltsEvalRequest(BaseModel):
    prompt_id: str
    input_type: str = "text"
    essay_text: str
    user_id: int = 1

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/evaluate")
def evaluate_essay(request: IeltsEvalRequest, db: Session = Depends(get_db)):
    if len(request.essay_text.strip()) < 10:
        raise HTTPException(status_code=400, detail="Essay text is too short for evaluation.")
        
    # Check Redis cache for identical essay evaluation
    text_hash = hashlib.md5(request.essay_text.strip().encode('utf-8')).hexdigest()
    cache_key = f"ielts:eval:{request.prompt_id}:{text_hash}"
    cached_report = cache_service.get(cache_key)
    if cached_report:
        print(f"🎯 [Redis Hit] Returning cached IELTS evaluation for {text_hash}")
        return {"status": "success", "report": cached_report, "cached": True}

    report = evaluate_ielts_essay(request.essay_text, request.prompt_id)
    
    # Save submission to database
    try:
        sub = EssaySubmission(
            user_id=request.user_id,
            prompt_id=request.prompt_id,
            essay_text=request.essay_text,
            overall_band=report.get("overall_band", 6.0),
            json_report=json.dumps(report, ensure_ascii=False)
        )
        db.add(sub)
        db.commit()
    except Exception as e:
        print(f"Warning: Could not save submission to DB: {e}")
        
    # Store in cache for 7 days (604800s)
    cache_service.set(cache_key, report, ttl=604800)
    
    return {
        "status": "success",
        "report": report
    }

@router.get("/prompts")
def get_ielts_prompts():
    cache_key = "ielts:prompts:list"
    cached_prompts = cache_service.get(cache_key)
    if cached_prompts:
        return cached_prompts

    prompts = [
        {
            "id": "task1_bar_chart_01",
            "title": "Car Ownership Trends (2000-2020)",
            "chart_type": "Bar Chart",
            "description": "The chart below shows the number of cars per 1000 people in three European countries from 2000 to 2020. Summarise the information by selecting and reporting the main features, and make comparisons where relevant.",
            "sample_image": "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=600"
        },
        {
            "id": "task1_line_graph_01",
            "title": "Global Energy Consumption (1980-2030)",
            "chart_type": "Line Graph",
            "description": "The line graph illustrates the consumption of four different sources of energy worldwide between 1980 and projected figures for 2030.",
            "sample_image": "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600"
        },
        {
            "id": "task1_pie_chart_01",
            "title": "Household Expenditure Distribution",
            "chart_type": "Pie Chart",
            "description": "The pie charts compare average household expenditure in a European country in 1990 and 2015 across five key categories.",
            "sample_image": "https://images.unsplash.com/photo-1543286386-2e659306cd6c?w=600"
        }
    ]
    cache_service.set(cache_key, prompts, ttl=86400) # Lưu cache 24h
    return prompts
