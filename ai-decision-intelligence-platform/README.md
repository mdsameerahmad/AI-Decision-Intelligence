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

### **2. Detailed Model Specifications**
- **Mistral-7B-Instruct-v0.2 (4-bit Quantized)**:
    - **Optimization**: Uses `bitsandbytes` for 4-bit precision, reducing memory usage while maintaining high reasoning quality.
    - **Hardware**: Optimized for NVIDIA T4 (Colab) and consumer GPUs using `float16`.
- **Qwen2.5-Coder-3B**:
    - **Optimization**: Lightweight and extremely accurate for generating Python/Pandas syntax.
    - **Role**: Ensures that the code generated during "Chat" is syntactically perfect.

---

## 🛣 API Routes

### **Authentication (`/auth`)**
- `POST /signup`: Register a new user.
- `POST /login`: Authenticate and receive a JWT token.

### **Dataset Management (`/dataset`)**
- `POST /upload`: Securely upload CSV files (restricted to authenticated users).
- `GET /list`: Retrieve a list of your personal uploaded datasets.

### **Data Analysis (`/analysis`)**
- `POST /summary`: Detailed descriptive statistics (mean, std, min, max, etc.).
- `POST /correlation`: Generate a correlation matrix for numeric columns.
- `POST /suggested-questions`: AI-generated list of insights to explore.

### **Intelligent Chat (`/chat`)**
- `POST /ask`: Ask any question about your data. The system generates code, executes it, and provides a natural language answer.

### **Forecasting & Strategy (`/forecast` & `/action-plan`)**
- `POST /predict`: Predict future trends for a specific numeric column.
- `POST /generate`: Generate a 3-5 step actionable strategy based on data insights.

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

