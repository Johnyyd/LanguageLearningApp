import os
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseModel):
    APP_NAME: str = "Language Learning & IELTS AI Gateway"
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "demo_api_key_portfolio_2026")
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "super_secret_portfolio_key_2026")
    JWT_ALGORITHM: str = "HS256"
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./app.db")
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:1113/0")
    CACHE_TTL_SECONDS: int = int(os.getenv("CACHE_TTL_SECONDS", "3600"))
    OPENROUTER_MODEL: str = os.getenv("OPENROUTER_MODEL", "google/gemma-4-31b-it:free")

settings = Settings()
