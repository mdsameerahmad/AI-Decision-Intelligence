import joblib


class Predictor:

    def __init__(self):

        self.model = joblib.load(
            "app/ai/models/predictor.pkl"
        )


    def predict(self, data):

        prediction = self.model.predict(data)

        return prediction.tolist()