from sqlalchemy.orm import Session

from app.database import models


# ---------- USER OPERATIONS ----------

def create_user(db: Session, email: str, password_hash: str):

    user = models.User(
        email=email,
        password_hash=password_hash
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


def get_user_by_email(db: Session, email: str):

    return db.query(models.User).filter(
        models.User.email == email
    ).first()


# ---------- DATASET OPERATIONS ----------

def create_dataset(db: Session, file_name: str, file_path: str, user_id: int):

    dataset = models.Dataset(
        file_name=file_name,
        file_path=file_path,
        user_id=user_id
    )

    db.add(dataset)
    db.commit()
    db.refresh(dataset)

    return dataset


def get_user_datasets(db: Session, user_id: int):

    return db.query(models.Dataset).filter(
        models.Dataset.user_id == user_id
    ).all()


# ---------- CHAT HISTORY ----------

def save_chat(db: Session, user_id: int, query: str, response: str):

    chat = models.ChatHistory(
        user_id=user_id,
        query=query,
        response=response
    )

    db.add(chat)
    db.commit()

    return chat


def get_chat_history(db: Session, user_id: int):

    return db.query(models.ChatHistory).filter(
        models.ChatHistory.user_id == user_id
    ).all()