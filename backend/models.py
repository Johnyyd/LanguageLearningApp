from sqlalchemy import Column, Integer, String, Float, Text, DateTime, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import datetime
from config import settings

Base = declarative_base()
engine = create_engine(settings.DATABASE_URL, connect_args={"check_same_thread": False} if "sqlite" in settings.DATABASE_URL else {})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True)
    email = Column(String(100), unique=True, index=True)
    hashed_password = Column(String(200))
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class EssaySubmission(Base):
    __tablename__ = "essay_submissions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    prompt_id = Column(String(50))
    essay_text = Column(Text)
    overall_band = Column(Float)
    json_report = Column(Text) # Stored JSON response from Gemini
    submitted_at = Column(DateTime, default=datetime.datetime.utcnow)

class ChatHistory(Base):
    __tablename__ = "chat_history"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    message = Column(Text)
    reply = Column(Text)
    emotion = Column(String(50))
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

def init_db():
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ [Models] Database schema verified.")
    except Exception as e:
        print(f"⚠️ [Models] Could not connect to database during startup ({e}). Continuing in Fallback/Demo mode.")
