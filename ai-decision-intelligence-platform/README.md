//Create Virtual Environment
python -m venv venv
//Activate Virtual Environment
source venv/Scripts/activate

//Run the Application
uvicorn app.main:app --reload
