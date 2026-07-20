from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.auth import router as auth_router
# 1. Import engine, Base và các Models
from app.core.database import engine, Base
import app.models.user  # Đảm bảo model được nạp
Base.metadata.create_all(bind=engine)
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
app.include_router(
    auth_router,
    prefix="/api/v1/auth",
    tags=["Authentication"]
)

# Giả lập dữ liệu món ăn Việt Nam
fake_food_db = [
    {
        "id": 1,
        "name": "Phở Bò Đặc Biệt",
        "price": "55.000đ",
        "duration": "10-15 phút",
        "calories": "350 KCal",
        "rating": "4.8",
        "image": "assets/image/pho_ga.png",
        "description": "Phở bò truyền thống với nước dùng thanh ngọt nấu từ xương bò trong 12 tiếng."
    },
    {
        "id": 2,
        "name": "Bánh Mì Thịt Nướng",
        "price": "25.000đ",
        "duration": "5 phút",
        "calories": "280 KCal",
        "rating": "4.6",
        "image": "assets/image/hamberger.png",
        "description": "Bánh mì giòn rụm kết hợp với thịt heo nướng sốt đặc biệt và rau dưa tươi."
    }
]



@app.get("/")
def read_root():
    return {"message": "Chào mừng đến với Backend Food App của tôi!"}
@app.get("/api/food")
def get_all_foods():
    return {"status": "success", "data": fake_food_db}
