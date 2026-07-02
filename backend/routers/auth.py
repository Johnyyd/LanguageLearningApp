from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from jose import jwt
from models import User, SessionLocal
from config import settings

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])

class UserRegister(BaseModel):
    username: str
    email: str
    password: str

class UserLogin(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    username: str
    user_id: int

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=7)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

@router.post("/register", response_model=TokenResponse)
def register(user: UserRegister, db: Session = Depends(get_db)):
    existing = db.query(User).filter((User.username == user.username) | (User.email == user.email)).first()
    if existing:
        raise HTTPException(status_code=400, detail="Username or email already registered")
    
    new_user = User(username=user.username, email=user.email, hashed_password=user.password) # In prod use bcrypt hash
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    token = create_access_token({"sub": str(new_user.id), "username": new_user.username})
    return {"access_token": token, "token_type": "bearer", "username": new_user.username, "user_id": new_user.id}

@router.post("/login", response_model=TokenResponse)
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == user.username).first()
    if not db_user or db_user.hashed_password != user.password:
        # Fallback for portfolio demo if user logs in with demo credentials
        if user.username == "demo_student" and user.password == "123456":
            token = create_access_token({"sub": "1", "username": "demo_student"})
            return {"access_token": token, "token_type": "bearer", "username": "demo_student", "user_id": 1}
        raise HTTPException(status_code=401, detail="Invalid username or password")
        
    token = create_access_token({"sub": str(db_user.id), "username": db_user.username})
    return {"access_token": token, "token_type": "bearer", "username": db_user.username, "user_id": db_user.id}
