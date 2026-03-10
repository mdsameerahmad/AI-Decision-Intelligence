import pandas as pd
import os


class DataService:

    def load_dataset(self, file_path: str):

        if file_path.endswith(".csv"):
            df = pd.read_csv(file_path)

        elif file_path.endswith(".xlsx"):
            df = pd.read_excel(file_path)

        else:
            raise ValueError("Unsupported file format")

        return df


    def dataset_summary(self, df: pd.DataFrame):

        summary = {
            "rows": df.shape[0],
            "columns": df.shape[1],
            "column_names": list(df.columns),
            "missing_values": df.isnull().sum().to_dict()
        }

        return summary


    def preprocess_data(self, df: pd.DataFrame):

        df = df.dropna()

        return df