from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from app.core.database import Base

class PaymentTransaction(Base):
    __tablename__ = "payment_transactions"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    amount = Column(Integer, nullable=False)
    payment_method = Column(String(50), nullable=False) # 'COD', 'BANK', 'MOMO'
    transaction_code = Column(String(100), unique=True, index=True, nullable=False)
    status = Column(String(50), nullable=False, default="SUCCESS") # 'SUCCESS', 'PENDING', 'FAILED'
    qr_url = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    order = relationship("Order")
    user = relationship("User")
