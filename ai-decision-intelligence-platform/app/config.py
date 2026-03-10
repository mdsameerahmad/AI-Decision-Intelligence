from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):

    APP_NAME: str = "AI Decision Intelligence Platform"

    DATABASE_URL: str

    SECRET_KEY: str

    ALGORITHM: str = "HS256"

    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    DATASET_STORAGE_PATH: str = "app/storage/datasets"

    # Hybrid Deployment Settings: Switch between local and remote LLM (e.g., Colab)
    # LLM_MODE: 'local' (runs on machine) or 'remote' (calls Colab/API)
    LLM_MODE: str = "local" 
    REMOTE_LLM_URL: str = "" # Your Colab Ngrok URL (e.g., https://xyz.ngrok-free.app)

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )


settings = Settings()