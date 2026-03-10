from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings

from app.api.routes_auth import router as auth_router
from app.api.routes_dataset import router as dataset_router
from app.api.routes_analysis import router as analysis_router
from app.api.routes_chat import router as chat_router
from app.api.routes_forecast import router as forecast_router
from app.api.routes_action_plan import router as action_router

from app.database.mongodb import engine
from app.database.models import Base


# Create FastAPI app FIRST
app = FastAPI(
    title=settings.APP_NAME
)


# Hybrid Deployment: Enable CORS for local Flutter frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allow all origins for testing; restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Create tables
Base.metadata.create_all(bind=engine)


# Include routers
app.include_router(auth_router)
app.include_router(dataset_router)
app.include_router(analysis_router)
app.include_router(chat_router)
app.include_router(forecast_router)
app.include_router(action_router)


@app.get("/")
def root():
    return {"message": "AI Decision Intelligence Platform running"}


@app.get("/health")
def health():
    return {"status": "ok"}