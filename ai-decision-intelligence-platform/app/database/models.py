from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database.mongodb import Base


class User(Base):

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    email = Column(String, unique=True, index=True)

    password_hash = Column(String)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    datasets = relationship("Dataset", back_populates="owner")

    chats = relationship("ChatHistory", back_populates="user")


class Dataset(Base):

    __tablename__ = "datasets"

    id = Column(Integer, primary_key=True, index=True)

    file_name = Column(String)

    file_path = Column(String)

    user_id = Column(Integer, ForeignKey("users.id"))

    uploaded_at = Column(DateTime(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="datasets")


class ChatHistory(Base):

    __tablename__ = "chat_history"

    id = Column(Integer, primary_key=True)

    user_id = Column(Integer, ForeignKey("users.id"))

    query = Column(String)

    response = Column(String)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="chats")