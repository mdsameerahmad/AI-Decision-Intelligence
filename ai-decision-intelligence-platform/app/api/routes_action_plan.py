from fastapi import APIRouter

router = APIRouter(prefix="/action-plan", tags=["AI Planner"])


@router.post("/generate")
def generate_action_plan(problem: str):

    tasks = [
        "Analyze root cause of the issue",
        "Improve product experience",
        "Launch targeted marketing campaign",
        "Measure impact using analytics"
    ]

    return {
        "problem": problem,
        "recommended_tasks": tasks
    }