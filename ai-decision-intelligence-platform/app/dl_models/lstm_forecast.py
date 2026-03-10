import torch
import torch.nn as nn
import numpy as np


class LSTMForecastModel(nn.Module):

    def __init__(self, input_size=1, hidden_size=64, num_layers=2):

        super(LSTMForecastModel, self).__init__()

        self.hidden_size = hidden_size
        self.num_layers = num_layers

        self.lstm = nn.LSTM(
            input_size,
            hidden_size,
            num_layers,
            batch_first=True
        )

        self.fc = nn.Linear(hidden_size, 1)

    def forward(self, x):

        h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size)
        c0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size)

        out, _ = self.lstm(x, (h0, c0))

        out = self.fc(out[:, -1, :])

        return out


class LSTMForecastService:

    def create_sequences(self, data, seq_length):

        sequences = []
        targets = []

        for i in range(len(data) - seq_length):

            seq = data[i:i + seq_length]
            target = data[i + seq_length]

            sequences.append(seq)
            targets.append(target)

        return np.array(sequences), np.array(targets)


    def train_model(self, data, seq_length=10, epochs=20):

        data = np.array(data).astype(np.float32)

        X, y = self.create_sequences(data, seq_length)

        X = torch.tensor(X).unsqueeze(-1)
        y = torch.tensor(y).unsqueeze(-1)

        model = LSTMForecastModel()

        criterion = nn.MSELoss()

        optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

        for epoch in range(epochs):

            outputs = model(X)

            loss = criterion(outputs, y)

            optimizer.zero_grad()

            loss.backward()

            optimizer.step()

        return model


    def predict_next(self, model, data, seq_length=10):

        data = np.array(data).astype(np.float32)

        seq = data[-seq_length:]

        seq = torch.tensor(seq).unsqueeze(0).unsqueeze(-1)

        prediction = model(seq)

        return prediction.item()