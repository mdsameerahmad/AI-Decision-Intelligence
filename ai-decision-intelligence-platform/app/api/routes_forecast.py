from fastapi import APIRouter, HTTPException, Depends, Body
import pandas as pd
from app.core.security import get_current_user
from app.services.llm_service import LLMService
from app.utils.data_utils import load_dataframe

router = APIRouter(prefix="/forecast", tags=["Forecast"])
llm_service = LLMService()


@router.post("/predict")
def forecast(
    file_path: str = Body(..., embed=True),
    column: str = Body(..., embed=True),
    user: dict = Depends(get_current_user)
):
    try:
        df = load_dataframe(file_path)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail=f"File not found at {file_path}")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error reading file: {e}")

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

    # Calculate basic stats for context
    last_value = series.iloc[-1]
    avg_value = series.mean()
    trend_prediction = series.tail(5).mean()
    
    # Generate detailed explanation using LLM
    context = f"Column: {actual_column}. Last value: {last_value}. Overall average: {avg_value}. Recent 5-period average (simple forecast): {trend_prediction}."
    prompt = f"Based on the following data points for the column '{actual_column}', provide a brief, professional forecast explanation (2-3 sentences) with relevant emojis. Explain what the forecasted value of {trend_prediction:.2f} means in the context of recent trends. Data Context: {context}"
    
    explanation = llm_service.llm.generate(prompt)

    return {
        "column": actual_column,
        "forecast": trend_prediction,
        "explanation": explanation
    }