from fastapi import APIRouter, HTTPException, Depends, Body
import pandas as pd
from app.core.security import get_current_user

router = APIRouter(prefix="/forecast", tags=["Forecast"])


@router.post("/predict")
def forecast(
    file_path: str = Body(..., embed=True),
    column: str = Body(..., embed=True),
    user: dict = Depends(get_current_user)
):
    try:
        df = pd.read_csv(file_path)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail=f"File not found at {file_path}")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error reading CSV file: {e}")

    # Normalize the column name for flexible input
    normalized_column = column.replace(" ", "_").lower()

    # Find the actual column name in a case-insensitive manner
    actual_column = None
    for col_name in df.columns:
        if col_name.replace(" ", "_").lower() == normalized_column:
            actual_column = col_name
            break

    if actual_column is None:
        raise HTTPException(status_code=400, detail=f"Column '{column}' (normalized to '{normalized_column}') not found in the dataset. Available columns: {', '.join(df.columns)}")

    series = df[actual_column]

    # placeholder until PyTorch model
    prediction = series.tail(5).mean()

    return {
        "column": actual_column,
        "forecast": prediction
    }