from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.security import get_current_user
from app.dependencies import get_db
from app.database import crud, models
from app.schemas.dataset_schema import BulkDeleteRequest
import pandas as pd
import os
import uuid
import io # Import io module

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

    # Read all bytes once to avoid stream exhaustion
    raw_data = await file.read()

    # Save uploaded file
    with open(file_path, "wb") as buffer:
        buffer.write(raw_data)

    # Save record to DB
    crud.create_dataset(
        db=db,
        file_name=file.filename,
        file_path=file_path,
        user_id=db_user.id
    )

    # Read CSV safely (handle encoding issues and common delimiters)
    df = None
    
    # Try common encodings and delimiters
    encodings = ["utf-8", "latin1"]
    delimiters = [",", ";", "\t"] # Comma, semicolon, tab
    
    last_exception = None
    for encoding in encodings:
        for delimiter in delimiters:
            try:
                # Use io.BytesIO to read from bytes in pandas
                df = pd.read_csv(io.BytesIO(raw_data), encoding=encoding, delimiter=delimiter)
                # Ensure it actually parsed columns (if only 1 column, it might be the wrong delimiter)
                if df.shape[1] > 1:
                    break
            except Exception as e:
                # Store the error for debugging if all attempts fail
                last_exception = e
        if df is not None and df.shape[1] > 1:
            break
            
    # Fallback if no delimiter produced multiple columns, try first successful one
    if df is None or df.shape[1] <= 1:
        # One last try with default comma if everything failed or produced 1 col
        try:
            df = pd.read_csv(io.BytesIO(raw_data), encoding="utf-8")
        except:
            pass

    if df is None:
        raise HTTPException(
            status_code=400,
            detail=f"Could not parse CSV file. Last error: {last_exception}"
        )

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


@router.delete("/delete/{dataset_id}")
def delete_dataset(
    dataset_id: int,
    user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Get user from DB
    db_user = db.query(models.User).filter(models.User.email == user.get("sub")).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # Get dataset from DB
    dataset = crud.get_dataset(db, dataset_id)
    if not dataset:
        raise HTTPException(status_code=404, detail="Dataset not found")

    # Verify ownership
    if dataset.user_id != db_user.id:
        raise HTTPException(status_code=403, detail="You do not have permission to delete this dataset")

    # Delete physical file if it exists
    if os.path.exists(dataset.file_path):
        try:
            os.remove(dataset.file_path)
        except Exception as e:
            # We still want to remove from DB even if file deletion fails (maybe file was already gone)
            print(f"Error deleting file: {e}")

    # Delete from DB
    crud.delete_dataset(db, dataset_id)

    return {"message": "Dataset deleted successfully"}


@router.post("/delete-multiple")
def delete_multiple_datasets(
    request: BulkDeleteRequest,
    user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Get user from DB
    db_user = db.query(models.User).filter(models.User.email == user.get("sub")).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # Get datasets from DB
    datasets = crud.get_datasets_by_ids(db, request.dataset_ids)
    if not datasets:
        raise HTTPException(status_code=404, detail="No datasets found for the given IDs")

    # Verify ownership for ALL datasets
    for dataset in datasets:
        if dataset.user_id != db_user.id:
            raise HTTPException(status_code=403, detail=f"You do not have permission to delete dataset: {dataset.file_name}")

    # Delete physical files
    deleted_files = 0
    for dataset in datasets:
        if os.path.exists(dataset.file_path):
            try:
                os.remove(dataset.file_path)
                deleted_files += 1
            except Exception as e:
                print(f"Error deleting file {dataset.file_path}: {e}")

    # Delete from DB
    crud.delete_datasets(db, request.dataset_ids)

    return {
        "message": f"Successfully deleted {len(datasets)} datasets and {deleted_files} physical files"
    }