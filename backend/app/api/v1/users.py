from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.database import get_db
from app.models.user import User
from app.schemas.user import UserOut, UserUpdateProfile
from app.api.v1.auth import get_current_user

router = APIRouter()

@router.put("/me", response_model=UserOut)
def update_profile(
    profile_in: UserUpdateProfile,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if profile_in.full_name is not None and profile_in.full_name.strip():
        current_user.full_name = profile_in.full_name.strip()
    
    if profile_in.email is not None and profile_in.email.strip():
        new_email = profile_in.email.strip().lower()
        if not current_user.email or new_email != current_user.email.lower():
            existing = db.query(User).filter(func.lower(User.email) == new_email).first()
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email hoặc Số điện thoại này đã được sử dụng!"
                )
            current_user.email = new_email

    db.commit()
    db.refresh(current_user)
    return current_user
