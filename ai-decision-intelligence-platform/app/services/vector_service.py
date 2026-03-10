import faiss
import numpy as np


class VectorService:

    def __init__(self):

        self.dimension = 384

        self.index = faiss.IndexFlatL2(self.dimension)

        self.data = []


    def add_vector(self, vector, metadata):

        vec = np.array([vector]).astype("float32")

        self.index.add(vec)

        self.data.append(metadata)


    def search(self, vector, k=3):

        vec = np.array([vector]).astype("float32")

        distances, indices = self.index.search(vec, k)

        results = []

        for i in indices[0]:
            if i < len(self.data):
                results.append(self.data[i])

        return results