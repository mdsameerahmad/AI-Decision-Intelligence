import pandas as pd


class DataPreprocessor:

    @staticmethod
    def remove_missing(df: pd.DataFrame):

        return df.dropna()


    @staticmethod
    def fill_missing(df: pd.DataFrame):

        for col in df.columns:
            if df[col].dtype in ["float64", "int64"]:
                df[col].fillna(df[col].mean(), inplace=True)
            else:
                df[col].fillna("Unknown", inplace=True)

        return df


    @staticmethod
    def normalize_numeric(df: pd.DataFrame):

        numeric_cols = df.select_dtypes(include=["float64", "int64"]).columns

        for col in numeric_cols:
            df[col] = (df[col] - df[col].mean()) / df[col].std()

        return df


    @staticmethod
    def select_numeric(df: pd.DataFrame):

        return df.select_dtypes(include=["float64", "int64"])