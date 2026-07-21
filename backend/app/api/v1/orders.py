import random
import string
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.models.order import Order, OrderItem
from app.models.user import User
from app.schemas.order import OrderCreate, OrderOut
from app.api.v1.auth import get_current_user

router = APIRouter()

def generate_order_code() -> str:
    digits = ''.join(random.choices(string.digits, k=6))
    return f"FOOD-{digits}"

@router.post("", response_model=OrderOut, status_code=status.HTTP_201_CREATED)
def create_order(
    order_in: OrderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    code = generate_order_code()
    new_order = Order(
        order_code=code,
        user_id=current_user.id,
        total_price=order_in.total_price,
        payment_method=order_in.payment_method,
        shipping_address=order_in.shipping_address,
        note=order_in.note,
        status="Đang chuẩn bị"
    )
    db.add(new_order)
    db.commit()
    db.refresh(new_order)

    for item in order_in.items:
        order_item = OrderItem(
            order_id=new_order.id,
            food_name=item.food_name,
            food_image=item.food_image,
            price=item.price,
            quantity=item.quantity
        )
        db.add(order_item)

    db.commit()
    db.refresh(new_order)
    return new_order

from datetime import datetime

def update_order_status_by_time(order: Order, db: Session) -> Order:
    if not order.created_at:
        return order
    
    elapsed_seconds = (datetime.utcnow() - order.created_at).total_seconds()
    
    new_status = order.status
    if elapsed_seconds < 15:
        new_status = "Đang chuẩn bị"
    elif elapsed_seconds < 45:
        new_status = "Đang giao"
    else:
        new_status = "Đã giao"
        
    if new_status != order.status:
        order.status = new_status
        db.commit()
        db.refresh(order)
        
    return order

@router.get("", response_model=List[OrderOut])
def get_user_orders(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    orders = db.query(Order).filter(Order.user_id == current_user.id).order_by(Order.created_at.desc()).all()
    for o in orders:
        update_order_status_by_time(o, db)
    return orders

@router.get("/{order_id}", response_model=OrderOut)
def get_order_detail(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    order = db.query(Order).filter(Order.id == order_id, Order.user_id == current_user.id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Không tìm thấy đơn hàng!"
        )
    return update_order_status_by_time(order, db)

