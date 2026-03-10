import pandas as pd


class VisualizationService:

    @staticmethod
    def column_distribution(df: pd.DataFrame, column: str):

        values = df[column].value_counts()

        return {
            "labels": values.index.tolist(),
            "values": values.tolist()
        }


    @staticmethod
    def correlation_matrix(df: pd.DataFrame):

        corr = df.corr(numeric_only=True)

        return corr.to_dict()


    @staticmethod
    def time_series(df: pd.DataFrame, column: str):

        return {
            "index": df.index.tolist(),
            "values": df[column].tolist()
        }