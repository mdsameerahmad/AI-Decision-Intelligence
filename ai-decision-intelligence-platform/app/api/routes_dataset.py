from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.security import get_current_user
from app.dependencies import get_db
from app.database import crud, models
import pandas as pd
import os
import uuid

router = APIRouter(prefix="/dataset", tags=["Dataset"])

DATASET_DIR = "app/storage/datasets"

os.makedirs(DATASET_DIR, exist_ok=True)


@router.post("/upload")
async def upload_dataset(
    file: UploadFile = File(...),
    user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):

    # Only allow CSV files
    if not file.filename.endswith(".csv"):
        raise HTTPException(
            status_code=400,
            detail="Only CSV files are allowed"
        )

    # Get user from DB to get the ID
    db_user = db.query(models.User).filter(models.User.email == user.get("sub")).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    file_id = str(uuid.uuid4())
    file_path = f"{DATASET_DIR}/{file_id}_{file.filename}"

    # Save uploaded file
    with open(file_path, "wb") as buffer:
        buffer.write(await file.read())

    # Save record to DB
    crud.create_dataset(
        db=db,
        file_name=file.filename,
        file_path=file_path,
        user_id=db_user.id
    )

    # Read CSV safely (handle encoding issues)
    try:
        df = pd.read_csv(file_path, encoding="utf-8")
    except UnicodeDecodeError:
        df = pd.read_csv(file_path, encoding="latin1")

    return {
        "message": "Dataset uploaded successfully",
        "uploaded_by": user.get("sub"),
        "file_path": file_path,
        "rows": df.shape[0],
        "columns": df.shape[1]
    }


@router.get("/list")
def list_datasets(
    user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Get user from DB
    db_user = db.query(models.User).filter(models.User.email == user.get("sub")).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # Get datasets from DB instead of listing directory
    datasets = crud.get_user_datasets(db, db_user.id)

    return {
        "user": user.get("sub"),
        "datasets": [
            {
                "id": d.id,
                "file_name": d.file_name,
                "file_path": d.file_path,
                "uploaded_at": d.uploaded_at
            } for d in datasets
        ]
    }