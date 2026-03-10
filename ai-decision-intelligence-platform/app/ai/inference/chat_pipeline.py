import pandas as pd

from app.ai.query_engine.pandas_code_generator import PandasCodeGenerator
from app.ai.query_engine.code_executor import execute_generated_code


class ChatPipeline:

    def __init__(self):

        self.code_generator = PandasCodeGenerator()

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

    def answer_question(self, file_path, question):

        df = self.load_dataset(file_path)

        schema = self.extract_schema(df)

        code = self.code_generator.generate_code(schema, question)

        result = execute_generated_code(code, df)

        return {
            "generated_code": code,
            "result": result
        }