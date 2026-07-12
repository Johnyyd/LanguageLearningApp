import sys
import os
from datetime import date, timedelta
from models import init_db, SessionLocal, User
from routers.auth import get_password_hash, verify_password, get_effective_streak

def test_auth_and_streak():
    init_db()
    
    # 1. Test password hashing & verification
    raw_pass = "SecurePass123!"
    hashed = get_password_hash(raw_pass)
    assert verify_password(raw_pass, hashed) == True, "Hash verification failed for correct password"
    assert verify_password("WrongPass", hashed) == False, "Hash verification succeeded for wrong password!"
    print("[OK] Password hashing (PBKDF2-SHA256) & verify passed.")

    # 2. Test streak logic
    today = date.today()
    today_str = today.strftime("%Y-%m-%d")
    yesterday_str = (today - timedelta(days=1)).strftime("%Y-%m-%d")
    two_days_ago_str = (today - timedelta(days=2)).strftime("%Y-%m-%d")

    user_active_today = User(username="u1", streak_count=5, last_activity_date=today_str)
    assert get_effective_streak(user_active_today, today_str) == 5, "Should return 5 if active today"

    user_active_yesterday = User(username="u2", streak_count=5, last_activity_date=yesterday_str)
    assert get_effective_streak(user_active_yesterday, today_str) == 5, "Should return 5 if active yesterday (pending study today)"

    user_missed_day = User(username="u3", streak_count=5, last_activity_date=two_days_ago_str)
    assert get_effective_streak(user_missed_day, today_str) == 0, "Should return 0 (lost streak) if missed >1 day!"

    print("[OK] Real-date streak calculation & loss logic verified!")

if __name__ == "__main__":
    test_auth_and_streak()
