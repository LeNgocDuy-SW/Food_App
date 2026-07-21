from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.database import engine, Base, SessionLocal
import app.models.user
import app.models.food
import app.models.order
import app.models.payment
from app.models.food import Food

from app.api.v1.auth import router as auth_router
from app.api.v1.foods import router as foods_router
from app.api.v1.orders import router as orders_router
from app.api.v1.users import router as users_router
from app.api.v1.payments import router as payments_router

Base.metadata.create_all(bind=engine)

# Tự động nâng cấp SQLite schema nếu thiếu các cột mới
with engine.connect() as conn:
    result = conn.execute(text("PRAGMA table_info(users)")).fetchall()
    columns = [row[1] for row in result]
    if "reset_otp" not in columns:
        conn.execute(text("ALTER TABLE users ADD COLUMN reset_otp VARCHAR(10)"))
    if "reset_otp_expires" not in columns:
        conn.execute(text("ALTER TABLE users ADD COLUMN reset_otp_expires DATETIME"))
    
    order_result = conn.execute(text("PRAGMA table_info(orders)")).fetchall()
    order_columns = [row[1] for row in order_result]
    if "is_paid" not in order_columns:
        conn.execute(text("ALTER TABLE orders ADD COLUMN is_paid BOOLEAN DEFAULT 0"))
    if "payment_code" not in order_columns:
        conn.execute(text("ALTER TABLE orders ADD COLUMN payment_code VARCHAR(100)"))

    conn.commit()

# Tự động nạp dữ liệu món ăn mẫu nếu DB chưa có
def seed_foods():
    db: Session = SessionLocal()
    try:
        if db.query(Food).count() == 0:
            sample_foods = [
                Food(
                    name="Phở Bò Đặc Biệt",
                    price="55.000đ",
                    price_num=55000.0,
                    duration="10-15 phút",
                    calories="350 KCal",
                    rating="4.8",
                    image="assets/image/pho_ga.png",
                    description="Phở bò truyền thống với nước dùng thanh ngọt nấu từ xương bò trong 12 tiếng.",
                    category="Phở & Nước",
                    is_popular=True,
                    is_discount=False,
                ),
                Food(
                    name="Bánh Mì Thịt Nướng",
                    price="25.000đ",
                    price_num=25000.0,
                    duration="5 phút",
                    calories="280 KCal",
                    rating="4.6",
                    image="assets/image/hamberger.png",
                    description="Bánh mì giòn rụm kết hợp với thịt heo nướng sốt đặc biệt và rau dưa tươi.",
                    category="Bánh Mì & Burger",
                    is_popular=True,
                    is_discount=True,
                ),
                Food(
                    name="Bún Chả Hà Nội",
                    price="45.000đ",
                    price_num=45000.0,
                    duration="15 phút",
                    calories="410 KCal",
                    rating="4.9",
                    image="assets/image/pho_ga.png",
                    description="Thịt nướng than hoa thơm nức, ăn kèm bún tươi, rau sống và nước chấm chua ngọt.",
                    category="Phở & Nước",
                    is_popular=True,
                    is_discount=False,
                ),
                Food(
                    name="Burger Bò Phô Mai",
                    price="69.000đ",
                    price_num=69000.0,
                    duration="10 phút",
                    calories="520 KCal",
                    rating="4.7",
                    image="assets/image/hamberger.png",
                    description="Burger bò Úc nướng mềm thơm ngậy với 2 lát phô Mai Cheddar tan chảy.",
                    category="Bánh Mì & Burger",
                    is_popular=False,
                    is_discount=True,
                ),
            ]
            db.add_all(sample_foods)
            db.commit()
            print("[SEED] Đã khởi tạo dữ liệu món ăn mẫu vào DB thành công!")
    finally:
        db.close()

seed_foods()

app = FastAPI(
    title="Food App API",
    description="Backend API cho ứng dụng Food App",
    version="1.0.0"
)

# Thêm CORS Middleware để Flutter App (Web/Android/iOS) có thể gọi API không bị chặn
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://.*",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(foods_router, prefix="/api/v1/foods", tags=["Foods"])
app.include_router(orders_router, prefix="/api/v1/orders", tags=["Orders"])
app.include_router(users_router, prefix="/api/v1/users", tags=["Users"])
app.include_router(payments_router, prefix="/api/v1/payments", tags=["Payments"])

@app.get("/")
def read_root():
    return {"message": "Chào mừng đến với Backend Food App!"}


