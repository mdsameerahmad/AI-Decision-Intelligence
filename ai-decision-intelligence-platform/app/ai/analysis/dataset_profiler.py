import pandas as pd


class DatasetProfiler:

    def profile(self, df: pd.DataFrame):

        profile = {}

        profile["columns"] = df.columns.tolist()

        profile["types"] = df.dtypes.astype(str).to_dict()

        profile["summary"] = df.describe(include="all").to_string()

        profile["missing_values"] = df.isnull().sum().to_dict()

        return profile