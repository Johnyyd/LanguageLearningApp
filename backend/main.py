from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import settings
from models import init_db
from routers import auth, ielts, chat, vocab, exercises

app = FastAPI(
    title=settings.APP_NAME,
    description="Backend AI Gateway & Data Server for Language Learning App (Flutter + Gemini 1.5 Pro + 3D Avatar)",
    version="1.0.0"
)

# Configure CORS for Flutter client communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Database on startup
@app.on_event("startup")
def on_startup():
    init_db()
    print(f"✅ {settings.APP_NAME} initialized successfully.")

# Include routers
app.include_router(auth.router)
app.include_router(ielts.router)
app.include_router(chat.router)
app.include_router(vocab.router)
app.include_router(exercises.router)

@app.get("/")
def root():
    return {
        "app": settings.APP_NAME,
        "status": "online",
        "docs_url": "/docs",
        "version": "1.0.0",
        "team_coordination": "Antigravity SDD - OpenCode, Hermes, MiMo"
    }

@app.get("/health")
def health_check():
    return {"status": "healthy", "ai_engine": "Gemini 1.5 Pro Ready"}
