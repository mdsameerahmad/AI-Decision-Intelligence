from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):

    APP_NAME: str = "AI Decision Intelligence Platform"

    DATABASE_URL: str

    SECRET_KEY: str

    ALGORITHM: str = "HS256"

    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    DATASET_STORAGE_PATH: str = "app/storage/datasets"


    model_config = SettingsConfigDict(
        env_file=".env"
    )


settings = Settings()