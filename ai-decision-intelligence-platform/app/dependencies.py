from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from app.config import settings


# Create SQLAlchemy engine
engine = create_engine(settings.DATABASE_URL, pool_pre_ping=True)

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