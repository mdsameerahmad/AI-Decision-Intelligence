from fastapi import APIRouter, Depends, HTTPException
from app.core.security import get_current_user
import pandas as pd
import numpy as np
from app.ai.models.local_llm import LocalLLM
from app.llm.langchain_pipeline import LangChainPipeline

router = APIRouter(prefix="/analysis", tags=["Analysis"])

# Initialize LLM and LangChainPipeline for suggested questions
# This will load the models once when the application starts
llm_instance_for_suggestions = LocalLLM()
langchain_pipeline_for_suggestions = LangChainPipeline(llm_instance_for_suggestions)


@router.post("/summary")
def dataset_summary(
    file_path: str,
    user: dict = Depends(get_current_user)
):
    """
    Generate dataset summary statistics including descriptive statistics for columns.
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

    # Generate descriptive statistics for all columns
    descriptive_stats_df = df.describe(include='all')

    # Replace NaN values with None for JSON compliance
    descriptive_stats_df = descriptive_stats_df.fillna(value=None)

    descriptive_stats = descriptive_stats_df.to_dict(orient='index')

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
    file_path: str,
    user: dict = Depends(get_current_user)
):
    """
    Generate correlation matrix
    """

    try:
        try:
            df = pd.read_csv(file_path, encoding="utf-8")
        except UnicodeDecodeError:
            df = pd.read_csv(file_path, encoding="latin1")

        correlation = df.corr(numeric_only=True)

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    return {
        "user": user.get("sub"),
        "correlation_matrix": correlation.to_dict()
    }


@router.post("/suggested-questions")
def get_suggested_questions(
    file_path: str,
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