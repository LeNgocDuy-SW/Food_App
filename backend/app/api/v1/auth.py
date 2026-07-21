import random
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
import jwt

from sqlalchemy import func, Column, Integer, String, Boolean, DateTime
from app.core.database import get_db
from app.models.user import User
from app.schemas.user import (
    UserCreate,
    UserLogin,
    UserOut,
    Token,
    ForgotPasswordRequest,
    VerifyOTPRequest,
    ResetPasswordRequest,
)
from app.core.security import get_password_hash, verify_password, create_access_token
from app.core.config import settings

router = APIRouter()
security = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    token = credentials.credentials
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token không hợp lệ",
            )
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token không hợp lệ hoặc đã hết hạn",
        )

    user = db.query(User).filter(User.id == int(user_id)).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Không tìm thấy người dùng",
        )
    return user


@router.post(
    "/signup", response_model=UserOut, status_code=status.HTTP_201_CREATED
)
def signup(user_in: UserCreate, db: Session = Depends(get_db)):
    clean_email = user_in.email.strip().lower()
    existing_user = db.query(User).filter(func.lower(User.email) == clean_email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email này đã được sử dụng!",
        )
    hashed_pwd = get_password_hash(user_in.password.strip())
    new_user = User(
        full_name=user_in.full_name.strip(),
        email=clean_email,
        hashed_password=hashed_pwd,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@router.post("/login", response_model=Token)
def login(user_in: UserLogin, db: Session = Depends(get_db)):
    clean_email = user_in.email.strip().lower()
    clean_pwd = user_in.password.strip()
    print(f"\n[LOGIN] Email: '{clean_email}' | Password: '{clean_pwd}'")

    user = db.query(User).filter(func.lower(User.email) == clean_email).first()
    if not user:
        print(f"[LOGIN FAILED] Không tìm thấy user với email/SĐT '{clean_email}'")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email hoặc mật khẩu không chính xác",
        )

    is_correct = verify_password(clean_pwd, user.hashed_password)
    print(f"[LOGIN] Check password result: {is_correct}")

    if not is_correct:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email hoặc mật khẩu không chính xác",
        )
    access_token = create_access_token(data={"sub": str(user.id)})
    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=UserOut)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.post("/forgot-password")
def forgot_password(req: ForgotPasswordRequest, db: Session = Depends(get_db)):
    clean_target = req.phone_or_email.strip().lower()
    print(f"\n[FORGOT PASSWORD] Target: '{clean_target}'")
    user = db.query(User).filter(func.lower(User.email) == clean_target).first()
    if not user:
        print(f"[FORGOT FAILED] Không tìm thấy user '{clean_target}'")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Tài khoản với email/số điện thoại này không tồn tại!",
        )

    # Tạo mã OTP 4 số ngẫu nhiên
    otp_code = str(random.randint(1000, 9999))
    user.reset_otp = otp_code
    user.reset_otp_expires = datetime.now(timezone.utc) + timedelta(minutes=10)
    db.commit()

    print(f"[FORGOT SUCCESS] Mã OTP tạo ra: '{otp_code}' cho User ID: {user.id}")

    return {
        "success": True,
        "message": f"Mã xác nhận OTP đã được gửi tới {req.phone_or_email}",
        "otp_code": otp_code,
    }


@router.post("/verify-otp")
def verify_otp(req: VerifyOTPRequest, db: Session = Depends(get_db)):
    clean_target = req.phone_or_email.strip().lower()
    clean_otp = req.otp_code.strip()
    print(f"\n[VERIFY OTP] Target: '{clean_target}' | OTP: '{clean_otp}'")

    user = db.query(User).filter(func.lower(User.email) == clean_target).first()
    if not user or not user.reset_otp or user.reset_otp != clean_otp:
        print(f"[VERIFY FAILED] OTP không khớp hoặc User không tồn tại. DB OTP: '{user.reset_otp if user else None}'")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Mã OTP không chính xác!",
        )

    if user.reset_otp_expires:
        expires = user.reset_otp_expires
        if expires.tzinfo is None:
            expires = expires.replace(tzinfo=timezone.utc)
        if datetime.now(timezone.utc) > expires:
            print("[VERIFY FAILED] Mã OTP đã hết hạn")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Mã OTP đã hết hạn, vui lòng xin lại mã mới!",
            )

    print("[VERIFY SUCCESS] Xác thực OTP hợp lệ")
    return {"success": True, "message": "Xác thực mã OTP thành công!"}


@router.post("/reset-password")
def reset_password(req: ResetPasswordRequest, db: Session = Depends(get_db)):
    clean_target = req.phone_or_email.strip().lower()
    clean_otp = req.otp_code.strip()
    clean_new_pwd = req.new_password.strip()
    print(f"\n[RESET PASSWORD] Target: '{clean_target}' | OTP: '{clean_otp}' | New Pass: '{clean_new_pwd}'")

    user = db.query(User).filter(func.lower(User.email) == clean_target).first()
    if not user or not user.reset_otp or user.reset_otp != clean_otp:
        print(f"[RESET FAILED] Không tìm thấy user hoặc OTP không đúng. DB OTP: '{user.reset_otp if user else None}'")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Mã xác thực không hợp lệ!",
        )

    if user.reset_otp_expires:
        expires = user.reset_otp_expires
        if expires.tzinfo is None:
            expires = expires.replace(tzinfo=timezone.utc)
        if datetime.now(timezone.utc) > expires:
            print("[RESET FAILED] Mã OTP đã hết hạn")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Mã OTP đã hết hạn, vui lòng xin lại mã mới!",
            )

    user.hashed_password = get_password_hash(clean_new_pwd)
    user.reset_otp = None
    user.reset_otp_expires = None
    db.commit()

    print(f"[RESET SUCCESS] Đã lưu hashed_password mới thành công cho User ID {user.id} ({user.email})")

    return {
        "success": True,
        "message": "Đổi mật khẩu thành công! Vui lòng đăng nhập lại.",
    }