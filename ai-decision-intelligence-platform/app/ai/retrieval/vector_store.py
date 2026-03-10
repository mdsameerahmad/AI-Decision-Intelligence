import faiss
import numpy as np
from sentence_transformers import SentenceTransformer


class VectorStore:

    def __init__(self):

        self.model = SentenceTransformer("all-MiniLM-L6-v2", device="cpu")

        self.index = None
        self.documents = []

    def build(self, texts):

        embeddings = self.model.encode(texts)

        dimension = embeddings.shape[1]

        self.index = faiss.IndexFlatL2(dimension)

        self.index.add(np.array(embeddings))

        self.documents = texts

    def search(self, query, k=3):

        query_embedding = self.model.encode([query])

        distances, indices = self.index.search(
            np.array(query_embedding), k
        )

        results = []

        for i in indices[0]:
            results.append(self.documents[i])

        return results