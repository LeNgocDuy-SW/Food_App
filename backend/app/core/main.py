from fastapi import FastAPI 
from app.models.user import Base # Import cái Base từ Model của bạn
# Câu lệnh ma thuật: Tự động quét các class Model và tạo bảng trong MySQL nếu chưa có
Base.metadata.create_all(bind=engine)
app = FastAPI()
# Giả lập dữ liệu món ăn Việt Nam từ file JSON trước đó của bạn
fake_food_db = [
    {
        "id": 1,
        "name": "Phở Bò Đặc Biệt",
        "price": "55.000đ",
        "duration": "10-15 phút",
        "calories": "350 KCal",
        "description": "Phở bò truyền thống với nước dùng thanh ngọt..."
    },
    {
        "id": 2,
        "name": "Bánh Mì Thịt Nướng",
        "price": "25.000đ",
        "duration": "5 phút",
        "calories": "280 KCal",
        "description": "Bánh mì giòn rụm kết hợp với thịt heo nướng..."
    }
]
@app.get("/api/foods")
def get_all_foods():
    return fake_food_db
