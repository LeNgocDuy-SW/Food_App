from pydantic import BaseModel
from datetime import datetime

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
