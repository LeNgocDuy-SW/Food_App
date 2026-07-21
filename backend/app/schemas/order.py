from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class OrderItemCreate(BaseModel):
    food_name: str
    food_image: str
    price: str
    quantity: int = 1

class OrderItemOut(OrderItemCreate):
    id: int

    class Config:
        from_attributes = True

class OrderCreate(BaseModel):
    total_price: int
    payment_method: str = "Tiền mặt"
    shipping_address: Optional[str] = "123 Đường Nguyễn Huệ, Q.1, TP.HCM"
    note: Optional[str] = None
    items: List[OrderItemCreate]

class OrderOut(BaseModel):
    id: int
    order_code: str
    user_id: int
    total_price: int
    payment_method: str
    status: str
    shipping_address: Optional[str]
    note: Optional[str]
    is_paid: bool = False
    payment_code: Optional[str] = None
    created_at: datetime
    items: List[OrderItemOut]

    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.strftime("%Y-%m-%dT%H:%M:%SZ") if v else None
        }

