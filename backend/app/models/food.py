from sqlalchemy import Column, Integer, String, Float, Boolean, Text
from app.core.database import Base

class Food(Base):
    __tablename__ = "foods"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), nullable=False, index=True)
    price = Column(String(50), nullable=False)
    price_num = Column(Float, nullable=False, default=0.0) # Dùng cho sắp xếp & tính toán
    duration = Column(String(50), nullable=True)
    calories = Column(String(50), nullable=True)
    rating = Column(String(10), nullable=True, default="4.8")
    image = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String(100), nullable=False, default="Popular", index=True)
    is_popular = Column(Boolean, default=True)
    is_discount = Column(Boolean, default=False)
