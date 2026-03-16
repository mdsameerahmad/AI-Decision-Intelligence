from fastapi import APIRouter, Depends, HTTPException, Body
from app.core.security import get_current_user
from app.utils.data_utils import load_dataframe
import pandas as pd
import numpy as np
from app.ai.models.local_llm import LocalLLM
from app.llm.langchain_pipeline import LangChainPipeline

router = APIRouter(prefix="/analysis", tags=["Analysis"])

# Initialize LLM and LangChainPipeline for suggested questions
# This will load the models once when the application starts
langchain_pipeline_for_suggestions = LangChainPipeline()


@router.post("/summary")
def dataset_summary(
    file_path: str = Body(..., embed=True),
    user: dict = Depends(get_current_user)
):
    """
    Generate dataset summary statistics including descriptive statistics for columns.
    """

    try:
        df = load_dataframe(file_path)

    except FileNotFoundError:
        raise HTTPException(status_code=404, detail=f"File not found at {file_path}")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error reading file: {e}")

    # Generate descriptive statistics for all columns
    descriptive_stats_df = df.describe(include='all')

    # Replace NaN values with None for JSON compliance
    # We use .where(pd.notnull(descriptive_stats_df), None) to handle all types properly
    descriptive_stats_df = descriptive_stats_df.replace({np.nan: None})
    
    # Reorient to be by column for easier frontend parsing
    descriptive_stats = descriptive_stats_df.to_dict(orient='dict')
    
    # Final cleanup of the dictionary to ensure JSON compliance
    def clean_dict(d):
        if not isinstance(d, dict):
            return d
        return {k: (None if isinstance(v, float) and (np.isnan(v) or np.isinf(v)) else clean_dict(v)) for k, v in d.items()}

    descriptive_stats = clean_dict(descriptive_stats)

    return {
        "user": user.get("sub"),
        "rows": df.shape[0],
        "columns": df.shape[1],
        "column_names": list(df.columns),
        "missing_values": df.isnull().sum().to_dict(),
        "descriptive_statistics": descriptive_stats # Add the new detailed stats
    }


@router.post("/correlation")
def dataset_correlation(
    file_path: str = Body(..., embed=True),
    user: dict = Depends(get_current_user)
):
    """
    Generate correlation matrix
    """

    try:
        df = load_dataframe(file_path)

        correlation = df.corr(numeric_only=True)
        # Handle NaN values in correlation matrix for JSON compliance
        correlation = correlation.replace({np.nan: None})

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    return {
        "user": user.get("sub"),
        "correlation_matrix": correlation.to_dict()
    }


@router.post("/suggested-questions")
def get_suggested_questions(
    file_path: str = Body(..., embed=True),
    user: dict = Depends(get_current_user)
):
    """
    Generate suggested questions based on the dataset schema.
    """
    try:
        # handle encoding issues
        try:
            df = pd.read_csv(file_path, encoding="utf-8")
        except UnicodeDecodeError:
            df = pd.read_csv(file_path, encoding="latin1")

    except FileNotFoundError:
        raise HTTPException(status_code=404, detail=f"File not found at {file_path}")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error reading CSV file: {e}")

    dataset_schema = df.columns.tolist()
    suggested_questions = langchain_pipeline_for_suggestions.generate_suggested_questions(dataset_schema)

    return {
        "user": user.get("sub"),
        "suggested_questions": suggested_questions
    }