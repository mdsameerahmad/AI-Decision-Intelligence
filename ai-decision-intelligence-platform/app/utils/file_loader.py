import pandas as pd
import os


class FileLoader:

    @staticmethod
    def load_file(file_path: str):

        if not os.path.exists(file_path):
            raise FileNotFoundError("Dataset file not found")

        if file_path.endswith(".csv"):
            df = pd.read_csv(file_path)

        elif file_path.endswith(".xlsx") or file_path.endswith(".xls"):
            df = pd.read_excel(file_path)

        else:
            raise ValueError("Unsupported file format")

        return df


    @staticmethod
    def get_file_info(df):

        return {
            "rows": df.shape[0],
            "columns": df.shape[1],
            "column_names": list(df.columns)
        }