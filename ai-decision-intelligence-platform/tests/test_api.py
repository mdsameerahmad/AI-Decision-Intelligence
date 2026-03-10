import sys
import os

# Add project root to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_root_endpoint():

    response = client.get("/")

    assert response.status_code == 200

    assert "message" in response.json()


def test_health_check():

    response = client.get("/health")

    assert response.status_code == 200

    assert response.json()["status"] == "ok"