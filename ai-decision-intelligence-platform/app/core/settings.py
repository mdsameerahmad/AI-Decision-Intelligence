import os
from pydantic_settings import BaseSettings, SettingsConfigDict

# Get the absolute path to the .env file in the project root
# settings.py is in app/core/, so we go up two levels
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ENV_FILE = os.path.join(BASE_DIR, ".env")

class Settings(BaseSettings):

    APP_NAME: str
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    DATASET_STORAGE_PATH: str = "app/storage/datasets"

    model_config = SettingsConfigDict(env_file=ENV_FILE)


settings = Settings()