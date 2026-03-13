from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from app.config import settings


import os

# Create SQLAlchemy engine with error handling and prefix correction
db_url = settings.DATABASE_URL.strip() if settings.DATABASE_URL else None

if not db_url:
    print("CRITICAL ERROR: DATABASE_URL is not set in environment variables.")
    # Fallback for build phase or early startup
    db_url = "sqlite:///./temp.db" 

# Clean up common copy-paste artifacts like dashes or quotes
db_url = db_url.lstrip("- ").strip("'\"")

# Ensure the prefix is correct for SQLAlchemy 1.4+ (postgres:// -> postgresql://)
if db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql+psycopg2://", 1)
elif db_url.startswith("postgresql://"):
    db_url = db_url.replace("postgresql://", "postgresql+psycopg2://", 1)

engine = create_engine(db_url, pool_pre_ping=True)

# Session factory
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)


def get_db() -> Session:
    """
    Dependency that provides a database session
    and closes it after request finishes.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()