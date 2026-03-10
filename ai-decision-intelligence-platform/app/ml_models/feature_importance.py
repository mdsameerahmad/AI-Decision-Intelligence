import pandas as pd
from sklearn.ensemble import RandomForestRegressor


class FeatureImportanceModel:

    def __init__(self):
        self.model = RandomForestRegressor(
            n_estimators=100,
            random_state=42
        )

    def calculate_importance(self, df: pd.DataFrame, target_column: str):

        if target_column not in df.columns:
            raise ValueError("Target column not found in dataset")

        X = df.drop(columns=[target_column])
        y = df[target_column]

        numeric_X = X.select_dtypes(include=["float64", "int64"])

        self.model.fit(numeric_X, y)

        importance = dict(
            zip(numeric_X.columns, self.model.feature_importances_)
        )

        return {
            "target": target_column,
            "feature_importance": importance
        }