from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class PaymentCreateRequest(BaseModel):
    order_id: int
    payment_method: str # 'COD', 'BANK', 'MOMO'
    amount: int

class PaymentVerifyRequest(BaseModel):
    transaction_code: str
    order_id: int

class PaymentTransactionOut(BaseModel):
    id: int
    order_id: int
    user_id: int
    amount: int
    payment_method: str
    transaction_code: str
    status: str
    qr_url: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
