import pandas as pd


class DataProcessor:

    def load_dataset(self, file_path):

        try:
            df = pd.read_csv(file_path)
        except:
            df = pd.read_csv(file_path, encoding="latin1")

        return df


    def clean_data(self, df):

        df = df.drop_duplicates()
        df = df.fillna(0)

        return df


    def get_numeric_features(self, df):

        numeric_df = df.select_dtypes(include=["int64", "float64"])

        return numeric_df