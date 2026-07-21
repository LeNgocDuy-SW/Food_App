from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from app.core.database import Base

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    order_code = Column(String(50), unique=True, index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    total_price = Column(Integer, nullable=False)
    payment_method = Column(String(50), nullable=False, default="Tiền mặt")
    status = Column(String(50), nullable=False, default="Đang chuẩn bị")
    shipping_address = Column(String(255), nullable=True)
    note = Column(String(255), nullable=True)
    is_paid = Column(Boolean, default=False, nullable=False)
    payment_code = Column(String(100), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Quan hệ tới người dùng và danh sách sản phẩm trong đơn
    user = relationship("User")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    food_name = Column(String(150), nullable=False)
    food_image = Column(String(255), nullable=False)
    price = Column(String(50), nullable=False)
    quantity = Column(Integer, nullable=False, default=1)

    order = relationship("Order", back_populates="items")
