import pandas as pd

from app.ai.query_engine.pandas_code_generator import PandasCodeGenerator
from app.ai.query_engine.code_executor import execute_generated_code
from app.ai.models.local_llm import LocalLLM


class ChatPipeline:

    def __init__(self):

        self.code_generator = PandasCodeGenerator()
        self.interpreter = LocalLLM()

    def load_dataset(self, file_path):

        try:
            return pd.read_csv(file_path, encoding="utf-8")
        except:
            return pd.read_csv(file_path, encoding="latin1")

    def extract_schema(self, df):

        schema = {}

        for col in df.columns:
            schema[col] = str(df[col].dtype)

        return schema

    def _parse_llm_output(self, text):
        # We look for "Answer:" as the definitive start of the actual content
        if "Answer:" in text:
            return text.split("Answer:")[-1].strip()
        
        # Fallback to the instruction phrases if "Answer:" is missing
        instruction_phrases = [
            "Use appropriate emojis in your response to make it more engaging (e.g., 📊 for stats, ✅ for success, ⚠️ for warnings).",
            "Based on this result, provide a clear, concise natural language answer to the user."
        ]
        
        for phrase in instruction_phrases:
            if phrase in text:
                return text.split(phrase)[-1].strip()
                
        return text

    def answer_question(self, file_path, question):

        df = self.load_dataset(file_path)

        schema = self.extract_schema(df)

        code = self.code_generator.generate_code(schema, question)

        result = execute_generated_code(code, df)

        interpretation_prompt = f"""
You are a data analyst. A user asked: "{question}"
The data analysis result is: {result}

Based on this result, provide a clear, concise natural language answer to the user.
Use appropriate emojis in your response to make it more engaging (e.g., 📊 for stats, ✅ for success, ⚠️ for warnings).

Answer:"""
        raw_answer = self.interpreter.generate(interpretation_prompt)
        
        # Parse the raw output to get the clean answer
        clean_answer = self._parse_llm_output(raw_answer)

        return {
            "generated_code": code,
            "result": result,
            "answer": clean_answer
        }
