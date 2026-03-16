# AI-Driven Decision Intelligence Platform

An advanced AI platform designed to transform raw data (CSV) into actionable business intelligence using Large Language Models (LLM), Machine Learning, and Automated Data Analysis.

## 🚀 Key Features

- **Automated Data Profiling**: Instant summary statistics and missing value detection.
- **AI Suggested Questions**: LLM-driven discovery of potential insights based on your data schema.
- **Intelligent Data Chat**: Natural language interface to query datasets using generated Pandas code.
- **Correlation Analysis**: Identify hidden relationships between variables with dynamic heatmaps.
- **Strategy Planner**: Generate detailed, actionable business tasks based on data-driven insights.
- **Trend Prediction**: Forecast future values using statistical and ML-based models.
- **User Authentication**: Secure JWT-based access control with personal dataset and chat history.

---

## 🏗 Project Structure

```text
app/
├── ai/
│   ├── models/           # Mistral-7B-Instruct-v0.2 (4-bit quantized)
│   ├── query_engine/     # Pandas code generation and execution
│   └── inference/        # Chat and insight pipelines
├── api/                  # FastAPI routes (Auth, Dataset, Analysis, Chat, Forecast)
├── core/                 # Security (JWT), Settings, and Config
├── database/             # SQLAlchemy Models and CRUD operations (SQLite/PostgreSQL)
├── llm/                  # LangChain integration and LCEL pipelines
├── storage/              # Local file storage for uploaded CSVs
└── main.py               # Application entry point
```

---

## 🧠 Model Architecture & Feature Mapping

The platform uses a hybrid approach, combining high-performance Python libraries with state-of-the-art Large Language Models.

### **1. AI Model Mapping**
| Feature | Model / Engine Used | Role |
| :--- | :--- | :--- |
| **Data Summary** | **Pandas & NumPy** | Statistical profiling and null value detection. |
| **Correlation Matrix** | **Pandas (Pearson)** | Calculating relationships between numeric variables. |
| **Suggested Questions** | **Mistral-7B-Instruct-v0.2** | Analyzes column names to suggest analytical queries. |
| **Chat Code Generation** | **Qwen2.5-Coder-3B** | Converts natural language questions into Pandas code. |
| **Chat Interpretation** | **Mistral-7B-Instruct-v0.2** | Explains the results of the executed code to the user. |
| **Trend Prediction** | **Pandas (Rolling Mean)** | Statistical forecasting of future numeric values. |
| **Strategy Planner** | **Mistral-7B-Instruct-v0.2** | Generates business action plans based on data insights. |

---

## 🛣 Detailed API Documentation

All routes (except `/auth/signup` and `/auth/login`) require a **JWT Bearer Token** in the header:
`Authorization: Bearer <your_token>`

### **1. Authentication (`/auth`)**

#### **POST `/auth/signup`**
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "strongpassword"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "message": "User created successfully"
  }
  ```

#### **POST `/auth/login`**
- **Request (Form Data)**: `username=email&password=password`
- **Response (200 OK)**:
  ```json
  {
    "access_token": "eyJhbG...",
    "token_type": "bearer"
  }
  ```

---

### **2. Dataset Management (`/dataset`)**

#### **POST `/dataset/upload`**
- **Request (Multipart/Form-Data)**: `file=@yourdata.csv`
- **Response (200 OK)**:
  ```json
  {
    "message": "Dataset uploaded successfully",
    "uploaded_by": "user@example.com",
    "file_path": "app/storage/datasets/uuid_yourdata.csv",
    "rows": 1000,
    "columns": 15
  }
  ```

#### **GET `/dataset/list`**
- **Response (200 OK)**:
  ```json
  {
    "user": "user@example.com",
    "datasets": [
      {
        "id": 1,
        "file_name": "sales_data.csv",
        "file_path": "app/storage/datasets/uuid_sales_data.csv",
        "uploaded_at": "2024-03-21T10:00:00"
      }
    ]
  }
  ```

---

### **3. Data Analysis (`/analysis`)**

#### **POST `/analysis/summary`**
- **Request Body**:
  ```json
  {
    "file_path": "app/storage/datasets/uuid_sales_data.csv"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "user": "user@example.com",
    "rows": 1000,
    "columns": 15,
    "column_names": ["date", "sales", "category"],
    "missing_values": { "date": 0, "sales": 5 },
    "descriptive_statistics": {
      "sales": { "count": 995, "mean": 150.5, "std": 45.2, "min": 10, "max": 500 }
    }
  }
  ```

#### **POST `/analysis/correlation`**
- **Request Body**:
  ```json
  {
    "file_path": "app/storage/datasets/uuid_sales_data.csv"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "user": "user@example.com",
    "correlation_matrix": {
      "sales": { "sales": 1.0, "profit": 0.85 },
      "profit": { "sales": 0.85, "profit": 1.0 }
    }
  }
  ```

#### **POST `/analysis/suggested-questions`**
- **Request Body**:
  ```json
  {
    "file_path": "app/storage/datasets/uuid_sales_data.csv"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "user": "user@example.com",
    "suggested_questions": [
      "What is the total sales for the last quarter?",
      "Which product category has the highest profit margin?"
    ]
  }
  ```

---

### **4. Intelligent Chat (`/chat`)**

#### **POST `/chat/ask`**
- **Request Body**:
  ```json
  {
    "file_path": "app/storage/datasets/uuid_sales_data.csv",
    "question": "Show me total sales by category"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "user": "user@example.com",
    "question": "Show me total sales by category",
    "generated_code": "df.groupby('category')['sales'].sum()",
    "answer": "The total sales by category are: Electronics: $50,000, Clothing: $30,000..."
  }
  ```

#### **GET `/chat/history`**
- **Response (200 OK)**:
  ```json
  {
    "history": [
      {
        "id": 1,
        "query": "Show me total sales by category",
        "response": "The total sales by category are...",
        "created_at": "2024-03-21T11:00:00"
      }
    ]
  }
  ```

---

### **5. Forecasting & Strategy (`/forecast` & `/action-plan`)**

#### **POST `/forecast/predict`**
- **Request Body**:
  ```json
  {
    "file_path": "app/storage/datasets/uuid_sales_data.csv",
    "column": "sales"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "column": "sales",
    "forecast": 155.2
  }
  ```

#### **POST `/action-plan/generate`**
- **Request Body**:
  ```json
  {
    "problem": "Sales are declining in the Electronics category"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "problem": "Sales are declining in the Electronics category",
    "recommended_tasks": [
      "Strategy #1 Analyze customer feedback to identify quality issues.",
      "Strategy #2 Launch a targeted promotional campaign for best-sellers.",
      "Strategy #3 Review pricing strategy compared to competitors."
    ]
  }
  ```

---

## 🛠 Installation & Setup

1. **Create Virtual Environment**
   ```bash
   python -m venv venv
   source venv/Scripts/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the Application**
   ```bash
   uvicorn app.main:app --reload
   ```

---

## 🔮 Future-Proofing: How to Switch AI Engines

The platform is designed with a **Hybrid LLM Strategy**, allowing you to switch between different AI providers or local models easily.

### **How to Use This in the Future**
If you ever want to switch back to your Colab model or Local model:

- **To use Groq (Current Default)**:
  - Ensure `LLM_MODE: str = "groq"` in [config.py](file:///d:/Project%20WOrk/ai_analyser/ai-decision-intelligence-platform/app/config.py).
  - This provides the fastest and most accurate reasoning for cloud deployment.

- **To use Colab (Remote Mode)**:
  - Change `LLM_MODE: str = "remote"` in [config.py](file:///d:/Project%20WOrk/ai_analyser/ai-decision-intelligence-platform/app/config.py).
  - Ensure your Colab script is running and update `REMOTE_LLM_URL` with your new Ngrok address.

- **To use Local (No Internet Mode)**:
  - Change `LLM_MODE: str = "local"` in [config.py](file:///d:/Project%20WOrk/ai_analyser/ai-decision-intelligence-platform/app/config.py).
  - **Uncomment** the "Mode 3" sections in [local_llm.py](file:///d:/Project%20WOrk/ai_analyser/ai-decision-intelligence-platform/app/ai/models/local_llm.py) and [pandas_code_generator.py](file:///d:/Project%20WOrk/ai_analyser/ai-decision-intelligence-platform/app/ai/query_engine/pandas_code_generator.py).
  - *Note: Requires 16GB+ RAM and a CUDA-capable GPU.*

---

