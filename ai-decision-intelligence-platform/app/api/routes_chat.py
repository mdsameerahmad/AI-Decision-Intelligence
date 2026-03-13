from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from app.core.security import get_current_user
from app.dependencies import get_db
from app.database import crud, models
from app.ai.inference.chat_pipeline import ChatPipeline


router = APIRouter(prefix="/chat", tags=["Chat"])

pipeline = ChatPipeline()


@router.post("/ask")
def ask_question(
    file_path: str = Body(..., embed=True),
    question: str = Body(..., embed=True),
    user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):

    # Get user from DB
    db_user = db.query(models.User).filter(models.User.email == user.get("sub")).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    response = pipeline.answer_question(file_path, question)

    # Save to database
    crud.save_chat(
        db=db,
        user_id=db_user.id,
        query=question,
        response=response["answer"]
    )

    return {
        "user": user.get("sub"),
        "question": question,
        "generated_code": response["generated_code"],
        "answer": response["answer"]
    }


@router.get("/history")
def get_history(
    user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_user = db.query(models.User).filter(models.User.email == user.get("sub")).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    history = crud.get_chat_history(db, db_user.id)
    return {
        "history": [
            {
                "id": h.id,
                "query": h.query,
                "response": h.response,
                "created_at": h.created_at
            } for h in history
        ]
    }