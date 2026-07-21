from pydantic import BaseModel
from typing import Optional

class FoodBase(BaseModel):
    name: str
    price: str
    price_num: float
    duration: Optional[str] = "10-15 phút"
    calories: Optional[str] = "350 KCal"
    rating: Optional[str] = "4.8"
    image: str
    description: Optional[str] = None
    category: str = "Popular"
    is_popular: bool = True
    is_discount: bool = False

class FoodCreate(FoodBase):
    pass

class FoodOut(FoodBase):
    id: int

    class Config:
        from_attributes = True
