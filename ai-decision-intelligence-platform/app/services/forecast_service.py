import torch
import torch.nn as nn
import numpy as np


class LSTMModel(nn.Module):

    def __init__(self, input_size=1, hidden_size=32, num_layers=1):

        super(LSTMModel, self).__init__()

        self.lstm = nn.LSTM(input_size, hidden_size, num_layers)

        self.fc = nn.Linear(hidden_size, 1)


    def forward(self, x):

        out, _ = self.lstm(x)

        out = self.fc(out[-1])

        return out


class ForecastService:

    def simple_forecast(self, series):

        values = np.array(series)

        prediction = np.mean(values[-5:])

        return prediction