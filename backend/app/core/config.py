import os

class Settings:
    PROJECT_NAME: str = "Food App Backend"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Cấu hình JWT
    SECRET_KEY: str = "your-super-secret-key-change-this-in-production-123456"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 ngày
    
    # Cấu hình Cơ sở dữ liệu SQLite
    DATABASE_URL: str = "sqlite:///./food_app.db"

settings = Settings()
