from pydantic import BaseModel


class QueryRequest(BaseModel):

    dataset_id: int
    question: str


class QueryResponse(BaseModel):

    question: str
    answer: str