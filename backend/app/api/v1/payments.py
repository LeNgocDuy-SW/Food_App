import random
import string
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.core.database import get_db
from app.models.payment import PaymentTransaction
from app.models.order import Order
from app.models.user import User
from app.schemas.payment import (
    PaymentCreateRequest,
    PaymentVerifyRequest,
    PaymentTransactionOut
)
from app.api.v1.auth import get_current_user

router = APIRouter()

def generate_tx_code() -> str:
    digits = ''.join(random.choices(string.digits, k=6))
    return f"PAY-{digits}"

@router.post("/create-qr", response_model=PaymentTransactionOut, status_code=status.HTTP_201_CREATED)
def create_payment_qr(
    payment_in: PaymentCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    order = db.query(Order).filter(Order.id == payment_in.order_id, Order.user_id == current_user.id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Không tìm thấy đơn hàng!"
        )

    tx_code = generate_tx_code()
    qr_url = None

    # Sinh mã VietQR thực tế hoặc mã MoMo cho chuyển khoản
    if payment_in.payment_method.upper() == 'BANK':
        qr_url = f"https://img.vietqr.io/image/MB-0339582134-compact2.png?amount={payment_in.amount}&addInfo=DUFOOD%20{order.order_code}&accountName=LE%20NGOC%20DUY"
    elif payment_in.payment_method.upper() == 'MOMO':
        qr_url = f"https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=momo://pay?amount={payment_in.amount}%26note=DUFOOD%20{order.order_code}"
    
    status_str = "SUCCESS" if payment_in.payment_method.upper() == 'COD' else "PENDING"

    tx = PaymentTransaction(
        order_id=order.id,
        user_id=current_user.id,
        amount=payment_in.amount,
        payment_method=payment_in.payment_method,
        transaction_code=tx_code,
        status=status_str,
        qr_url=qr_url
    )
    db.add(tx)

    if payment_in.payment_method.upper() == 'COD':
        order.payment_code = tx_code
        order.is_paid = False

    db.commit()
    db.refresh(tx)
    return tx

@router.post("/confirm", response_model=PaymentTransactionOut)
def confirm_payment(
    verify_in: PaymentVerifyRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    tx = db.query(PaymentTransaction).filter(
        PaymentTransaction.transaction_code == verify_in.transaction_code,
        PaymentTransaction.user_id == current_user.id
    ).first()

    if not tx:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Không tìm thấy giao dịch thanh toán!"
        )

    tx.status = "SUCCESS"
    order = db.query(Order).filter(Order.id == verify_in.order_id).first()
    if order:
        order.is_paid = True
        order.payment_code = tx.transaction_code

    db.commit()
    db.refresh(tx)
    return tx

@router.get("/{order_id}", response_model=Optional[PaymentTransactionOut])
def get_payment_status(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    tx = db.query(PaymentTransaction).filter(
        PaymentTransaction.order_id == order_id,
        PaymentTransaction.user_id == current_user.id
    ).order_by(PaymentTransaction.created_at.desc()).first()
    return tx
