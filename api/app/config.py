import os

class Config:
    DEBUG = False
    SECRET_KEY = os.getenv("SECRET_KEY", "default_secret_key")
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL", "mysql+mysqlconnector://user:password@localhost:3306/database_name")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    FLASK_RUN_HOST = os.getenv("API_HOST", "0.0.0.0")
    FLASK_RUN_PORT = int(os.getenv("API_PORT", 5000))