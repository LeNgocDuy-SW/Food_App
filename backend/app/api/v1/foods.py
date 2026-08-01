import uuid
import shutil
import os
from fastapi import APIRouter, Depends, HTTPException, Query, status, File, UploadFile, Request
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional

from app.core.database import get_db
from app.models.food import Food
from app.schemas.food import FoodOut, FoodCreate

router = APIRouter()

@router.post("/upload-image")
async def upload_food_image(request: Request, file: UploadFile = File(...)):
    if not os.path.exists("uploads"):
        os.makedirs("uploads")
    
    file_ext = os.path.splitext(file.filename or "image.png")[1]
    if not file_ext:
        file_ext = ".png"
    filename = f"{uuid.uuid4().hex}{file_ext}"
    file_path = os.path.join("uploads", filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    base_url = str(request.base_url).rstrip("/")
    image_url = f"{base_url}/static/{filename}"
    return {"image_url": image_url, "filename": filename}


@router.get("", response_model=List[FoodOut])
def get_foods(
    category: Optional[str] = None,
    search: Optional[str] = None,
    is_popular: Optional[bool] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Food)
    if category and category.lower() != "all" and category.lower() != "tất cả":
        query = query.filter(func.lower(Food.category) == category.lower())
    if search:
        search_fmt = f"%{search.strip()}%"
        query = query.filter(Food.name.ilike(search_fmt))
    if is_popular is not None:
        query = query.filter(Food.is_popular == is_popular)
    
    return query.all()

@router.get("/categories", response_model=List[str])
def get_categories(db: Session = Depends(get_db)):
    categories = db.query(Food.category).distinct().all()
    result = ["All"] + [c[0] for c in categories if c[0]]
    return result

@router.get("/{food_id}", response_model=FoodOut)
def get_food_detail(food_id: int, db: Session = Depends(get_db)):
    food = db.query(Food).filter(Food.id == food_id).first()
    if not food:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Không tìm thấy món ăn này!"
        )
    return food

@router.post("", response_model=FoodOut, status_code=status.HTTP_201_CREATED)
def create_food(food_in: FoodCreate, db: Session = Depends(get_db)):
    new_food = Food(**food_in.model_dump())
    db.add(new_food)
    db.commit()
    db.refresh(new_food)
    return new_food

