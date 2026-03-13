from fastapi import APIRouter, Depends, Body
from app.llm.langchain_pipeline import LangChainPipeline
import re
from app.core.security import get_current_user

router = APIRouter(prefix="/action-plan", tags=["AI Planner"])

# Initialize the pipeline
planner_pipeline = LangChainPipeline()


@router.post("/generate")
def generate_action_plan(
    problem: str = Body(..., embed=True),
    user: dict = Depends(get_current_user)
):
    """
    Generate 10 highly detailed business strategies based on the user's problem.
    """
    response = planner_pipeline.generate_action_plan(problem)
    
    # Split the response by double newlines to get individual strategy blocks
    # as instructed in the new prompt.
    raw_strategies = response.split('\n\n')

    cleaned_strategies = []
    for item in raw_strategies:
        cleaned = item.strip()
        if cleaned:
            # Clean up any residual markdown symbols or prefixes if LLM still includes them
            # Remove "Strategy #N:", "N:", etc.
            cleaned = re.sub(r'^(Strategy\s*#?\s*\d+:?|#+\s*|\d+[\.:]\s*|-\s*)', '', cleaned, flags=re.IGNORECASE)
            
            # Clean up internal double spaces but keep structure
            cleaned = re.sub(r'\s{2,}', ' ', cleaned).strip()
            
            if cleaned:
                cleaned_strategies.append(cleaned)

    # Fallback if splitting by double newlines failed or produced nothing
    if not cleaned_strategies and response.strip():
        # Just clean the whole response if it's one block
        cleaned = response.strip()
        cleaned = re.sub(r'^(Strategy\s*#?\s*\d+:?|#+\s*|\d+[\.:]\s*|-\s*)', '', cleaned, flags=re.IGNORECASE)
        cleaned_strategies = [cleaned]

    return {
        "problem": problem,
        "recommended_tasks": cleaned_strategies
    }