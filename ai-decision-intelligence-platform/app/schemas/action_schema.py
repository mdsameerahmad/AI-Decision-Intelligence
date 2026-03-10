from pydantic import BaseModel
from typing import List


class ActionPlanRequest(BaseModel):

    problem: str


class ActionPlanResponse(BaseModel):

    problem: str
    recommended_tasks: List[str]