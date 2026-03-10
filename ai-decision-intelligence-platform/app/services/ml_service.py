from sklearn.ensemble import IsolationForest, RandomForestRegressor
from sklearn.cluster import KMeans
import pandas as pd


class MLService:

    def anomaly_detection(self, df: pd.DataFrame):

        numeric_df = df.select_dtypes(include=["float64", "int64"])

        model = IsolationForest()

        preds = model.fit_predict(numeric_df)

        df["anomaly"] = preds

        return df


    def clustering(self, df: pd.DataFrame, n_clusters=3):

        numeric_df = df.select_dtypes(include=["float64", "int64"])

        model = KMeans(n_clusters=n_clusters)

        clusters = model.fit_predict(numeric_df)

        df["cluster"] = clusters

        return df


    def feature_importance(self, df: pd.DataFrame, target_column: str):

        X = df.drop(columns=[target_column])

        y = df[target_column]

        model = RandomForestRegressor()

        model.fit(X, y)

        importance = dict(zip(X.columns, model.feature_importances_))

        return importance