from pydantic import BaseModel
from datetime import datetime
from typing import Optional

# 1. Schema dữ liệu gửi lên khi ĐĂNG KÝ
class UserCreate(BaseModel):
    full_name: str
    email: str # Đổi EmailStr -> str để nhận cả số điện thoại lẫn email
    password: str

# 2. Schema dữ liệu gửi lên khi ĐĂNG NHẬP
class UserLogin(BaseModel):
    email: str # Đổi EmailStr -> str
    password: str

# 3. Schema dữ liệu User trả về cho Client
class UserOut(BaseModel):
    id: int
    full_name: str
    email: str
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

# 4. Schema Token trả về khi Đăng nhập thành công
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

# 5. Schemas cho Quên mật khẩu & OTP
class ForgotPasswordRequest(BaseModel):
    phone_or_email: str

class VerifyOTPRequest(BaseModel):
    phone_or_email: str
    otp_code: str

class ResetPasswordRequest(BaseModel):
    phone_or_email: str
    otp_code: str
    new_password: str

# 6. Schema Cập nhật thông tin Hồ sơ
class UserUpdateProfile(BaseModel):
    full_name: Optional[str] = None
    email: Optional[str] = None


