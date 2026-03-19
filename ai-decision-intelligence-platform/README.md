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

## 🔮 Hybrid LLM Strategy: Multi-Switch AI Engines

The platform is designed with a flexible **Hybrid LLM Strategy**, allowing you to seamlessly switch between different AI providers or local models based on your needs for development, performance, and resource management. This is controlled by the `LLM_MODE` setting in your `app/config.py` file.

### **1. AI Model Mapping**
The platform intelligently leverages different models for specific tasks:

| Feature | Model / Engine Used | Role |
| :--- | :--- | :--- |
| **Data Summary** | **Pandas & NumPy** | Statistical profiling and null value detection. |
| **Correlation Matrix** | **Pandas (Pearson)** | Calculating relationships between numeric variables. |
| **Suggested Questions** | **Mistral-7B-Instruct-v0.2** (or Groq) | Analyzes column names to suggest analytical queries. |
| **Chat Code Generation** | **Qwen2.5-Coder-3B** (or Groq) | Converts natural language questions into Pandas code. |
| **Chat Interpretation** | **Mistral-7B-Instruct-v0.2** (or Groq) | Explains the results of the executed code to the user. |
| **Trend Prediction** | **Pandas (Rolling Mean)** | Statistical forecasting of future numeric values. |
| **Strategy Planner** | **Mistral-7B-Instruct-v0.2** (or Groq) | Generates business action plans based on data insights. |

### **2. How to Switch LLM Modes**

The `LLM_MODE` variable in `app/config.py` (or your `.env` file) is the central switch.

#### **Mode 1: `LLM_MODE: "groq"` (Recommended for Cloud/Mobile)**
*   **Description**: Utilizes the Groq API for all LLM-related tasks, offering extremely fast inference for models like Llama 3. This is ideal for high-performance, scalable cloud deployments.
*   **Configuration**:
    *   Set `LLM_MODE: str = "groq"` in `app/config.py` or your `.env` file.
    *   Ensure `GROQ_API_KEY` is set in your `.env` file.
    *   `GROQ_MODEL_REASONING` and `GROQ_MODEL_CODE` specify the Groq-hosted models for reasoning and code generation tasks.
*   **Pros**: High speed, excellent scalability, offloads computational resources.
*   **Cons**: Requires an active internet connection, Groq API key, and incurs API usage costs.

#### **Mode 2: `LLM_MODE: "remote"` (Colab/Ngrok Model Endpoint)**
*   **Description**: Connects to a remotely hosted LLM, typically running on platforms like Google Colab and exposed via a tunneling service (e.g., `ngrok`). This allows leveraging powerful models or specific hardware configurations not available locally.
*   **Configuration**:
    *   Set `LLM_MODE: str = "remote"` in `app/config.py` or your `.env` file.
    *   Ensure your remote LLM server (e.g., Colab script) is running and exposed via `ngrok`.
    *   Update `REMOTE_LLM_URL` in `app/config.py` or your `.env` file with the public `ngrok` URL.
*   **Pros**: Access to powerful models/hardware without local setup.
*   **Cons**: Relies on remote server/tunneling service stability, `ngrok` URLs may change frequently (free tier), performance can be affected by network latency.

#### **Mode 3: `LLM_MODE: "local"` (Local Machine Inference)**
*   **Description**: Loads and runs LLM models (Mistral-7B, Qwen-Coder) directly on your local machine. Suitable for development, privacy-sensitive applications, or offline use.
*   **Configuration**:
    *   Set `LLM_MODE: str = "local"` in `app/config.py` or your `.env` file.
    *   **Uncomment** the "Mode 3" sections in `app/ai/models/local_llm.py` and `app/ai/query_engine/pandas_code_generator.py` to enable local model loading.
    *   *Note: Requires significant local resources (e.g., 16GB+ RAM and a CUDA-capable GPU for optimal performance).*
*   **Pros**: No internet connection required for inference, full control over models, no API costs.
*   **Cons**: High resource consumption, potentially slower inference speeds compared to optimized cloud APIs, more complex local setup.

---

