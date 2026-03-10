import pandas as pd
from sklearn.ensemble import IsolationForest


class AnomalyDetector:

    def __init__(self, contamination=0.05):
        self.model = IsolationForest(
            contamination=contamination,
            random_state=42
        )

    def detect(self, df: pd.DataFrame):

        numeric_df = df.select_dtypes(include=["float64", "int64"])

        if numeric_df.empty:
            raise ValueError("Dataset has no numeric columns for anomaly detection")

        predictions = self.model.fit_predict(numeric_df)

        df["anomaly"] = predictions

        anomalies = df[df["anomaly"] == -1]

        return {
            "total_rows": len(df),
            "anomaly_count": len(anomalies),
            "anomalies": anomalies.to_dict(orient="records")
        }