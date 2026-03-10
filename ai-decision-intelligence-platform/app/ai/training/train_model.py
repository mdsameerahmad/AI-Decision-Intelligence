from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
import joblib


class ModelTrainer:

    def train_regression_model(self, df, target_column):

        X = df.drop(columns=[target_column])
        y = df[target_column]

        X_train, X_test, y_train, y_test = train_test_split(
            X,
            y,
            test_size=0.2
        )

        model = RandomForestRegressor()

        model.fit(X_train, y_train)

        joblib.dump(model, "app/ai/models/predictor.pkl")

        return {
            "message": "Model trained successfully"
        }