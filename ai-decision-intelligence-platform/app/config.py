import os
from pydantic_settings import BaseSettings, SettingsConfigDict

# Get the absolute path to the .env file in the project root
# config.py is in app/, so we go up one level
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENV_FILE = os.path.join(BASE_DIR, ".env")

class Settings(BaseSettings):

    APP_NAME: str = "AI Decision Intelligence Platform"

    DATABASE_URL: str

    SECRET_KEY: str

    ALGORITHM: str = "HS256"

    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    DATASET_STORAGE_PATH: str = "app/storage/datasets"

    # =========================================================================
    # HYBRID LLM SETTINGS
    # =========================================================================
    # Choose between:
    # 1. 'groq'   - Fast, accurate reasoning via Groq API (Recommended for Cloud/Mobile)
    # 2. 'remote' - Uses temporary Colab/Ngrok model endpoint
    # 3. 'local'  - Runs heavy Mistral/Qwen models directly on your RAM/GPU
    LLM_MODE: str = "groq" 

    # --- Mode 1: Groq API Settings ---
    GROQ_API_KEY: str
    GROQ_MODEL_REASONING: str = "llama-3.3-70b-versatile"
    GROQ_MODEL_CODE: str = "llama-3.3-70b-versatile"

    # --- Mode 2: Remote/Colab Settings ---
    REMOTE_LLM_URL: str = "" # e.g., https://xyz.ngrok-free.app

    model_config = SettingsConfigDict(
        env_file=ENV_FILE,
        env_file_encoding="utf-8",
        extra="ignore"
    )


settings = Settings()