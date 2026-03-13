from pydantic import BaseModel
from datetime import datetime


class DatasetCreate(BaseModel):

    file_name: str
    file_path: str
    user_id: int


class DatasetResponse(BaseModel):

    id: int
    file_name: str
    file_path: str
    user_id: int
    uploaded_at: datetime

    class Config:
        from_attributes = True


class BulkDeleteRequest(BaseModel):
    dataset_ids: list[int]