from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from datetime import datetime, date, timedelta
from jose import jwt
import hashlib
import hmac
import os
from typing import Optional
from models import User, SessionLocal
from config import settings

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])

class UserRegister(BaseModel):
    username: str
    email: str
    password: str
    full_name: Optional[str] = None

class UserLogin(BaseModel):
    username: str
    password: str

class ActivityRequest(BaseModel):
    username: Optional[str] = None
    activity_date: Optional[str] = None

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    username: str
    user_id: int
    streak_count: int
    last_activity_date: Optional[str]
    effective_streak: int

class UserInfoResponse(BaseModel):
    user_id: int
    username: str
    email: str
    full_name: Optional[str]
    streak_count: int
    last_activity_date: Optional[str]
    effective_streak: int

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_password_hash(password: str) -> str:
    salt = os.urandom(16).hex()
    hashed = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), bytes.fromhex(salt), 100000).hex()
    return f"pbkdf2_sha256$100000${salt}${hashed}"

def verify_password(plain_password: str, hashed_password: str) -> bool:
    if not hashed_password:
        return False
    if "$" not in hashed_password:
        return plain_password == hashed_password
    try:
        parts = hashed_password.split("$")
        if len(parts) == 4 and parts[0] == "pbkdf2_sha256":
            iterations = int(parts[1])
            salt = bytes.fromhex(parts[2])
            expected_hash = parts[3]
            computed_hash = hashlib.pbkdf2_hmac('sha256', plain_password.encode('utf-8'), salt, iterations).hex()
            return hmac.compare_digest(computed_hash, expected_hash)
    except Exception:
        return False
    return False

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=7)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

def get_effective_streak(user: User, today_str: str) -> int:
    if not user.last_activity_date or (user.streak_count or 0) <= 0:
        return 0
    try:
        today = datetime.strptime(today_str, "%Y-%m-%d").date()
        last_date = datetime.strptime(user.last_activity_date, "%Y-%m-%d").date()
        diff = (today - last_date).days
        if diff == 0 or diff == 1:
            return user.streak_count or 0
        return 0
    except Exception:
        return 0

@router.post("/register", response_model=TokenResponse)
def register(user: UserRegister, db: Session = Depends(get_db)):
    existing = db.query(User).filter((User.username == user.username) | (User.email == user.email)).first()
    if existing:
        raise HTTPException(status_code=400, detail="Tên đăng nhập hoặc email đã tồn tại")
    
    hashed = get_password_hash(user.password)
    today_str = date.today().strftime("%Y-%m-%d")
    new_user = User(
        username=user.username,
        email=user.email,
        hashed_password=hashed,
        full_name=user.full_name or user.username,
        streak_count=1,
        last_activity_date=today_str
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    token = create_access_token({"sub": str(new_user.id), "username": new_user.username})
    return {
        "access_token": token,
        "token_type": "bearer",
        "username": new_user.username,
        "user_id": new_user.id,
        "streak_count": new_user.streak_count,
        "last_activity_date": new_user.last_activity_date,
        "effective_streak": 1
    }

@router.post("/login", response_model=TokenResponse)
def login(user: UserLogin, db: Session = Depends(get_db)):
    try:
        db_user = db.query(User).filter(
            (User.username == user.username) | (User.email == user.username)
        ).first()
    except Exception:
        db.rollback()
        db_user = db.query(User).filter(User.username == user.username).first()
    
    if not db_user or not verify_password(user.password, db_user.hashed_password or ""):
        raise HTTPException(status_code=401, detail="Tên đăng nhập hoặc mật khẩu không chính xác")
        
    today_str = date.today().strftime("%Y-%m-%d")
    effective_streak = get_effective_streak(db_user, today_str)
    
    token = create_access_token({"sub": str(db_user.id), "username": db_user.username})
    return {
        "access_token": token,
        "token_type": "bearer",
        "username": db_user.username,
        "user_id": db_user.id,
        "streak_count": db_user.streak_count or 0,
        "last_activity_date": db_user.last_activity_date,
        "effective_streak": effective_streak
    }

@router.post("/activity", response_model=UserInfoResponse)
def record_activity(req: ActivityRequest, db: Session = Depends(get_db)):
    if not req.username:
        raise HTTPException(status_code=400, detail="Thiếu thông tin username")
    db_user = db.query(User).filter(User.username == req.username).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng")
        
    today_str = req.activity_date or date.today().strftime("%Y-%m-%d")
    today = datetime.strptime(today_str, "%Y-%m-%d").date()
    
    current_streak = db_user.streak_count or 0
    last_date_str = db_user.last_activity_date
    
    if not last_date_str:
        db_user.streak_count = 1
        db_user.last_activity_date = today_str
    else:
        try:
            last_date = datetime.strptime(last_date_str, "%Y-%m-%d").date()
            diff = (today - last_date).days
            if diff == 0:
                # Hôm nay đã học -> giữ nguyên streak (tối thiểu 1)
                db_user.streak_count = max(current_streak, 1)
            elif diff == 1:
                # Hôm qua học -> hôm nay học -> tăng streak!
                db_user.streak_count = current_streak + 1
                db_user.last_activity_date = today_str
            elif diff > 1:
                # Qua >1 ngày không học -> mất streak, tính lại 1
                db_user.streak_count = 1
                db_user.last_activity_date = today_str
        except Exception:
            db_user.streak_count = 1
            db_user.last_activity_date = today_str

    db.commit()
    db.refresh(db_user)
    
    return {
        "user_id": db_user.id,
        "username": db_user.username,
        "email": db_user.email,
        "full_name": db_user.full_name,
        "streak_count": db_user.streak_count or 0,
        "last_activity_date": db_user.last_activity_date,
        "effective_streak": db_user.streak_count or 0
    }

@router.get("/user/{username}", response_model=UserInfoResponse)
def get_user_info(username: str, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == username).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng")
    today_str = date.today().strftime("%Y-%m-%d")
    eff = get_effective_streak(db_user, today_str)
    return {
        "user_id": db_user.id,
        "username": db_user.username,
        "email": db_user.email,
        "full_name": db_user.full_name,
        "streak_count": db_user.streak_count or 0,
        "last_activity_date": db_user.last_activity_date,
        "effective_streak": eff
    }
