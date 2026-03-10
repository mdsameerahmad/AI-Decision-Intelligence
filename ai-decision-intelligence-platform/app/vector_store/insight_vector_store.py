from sentence_transformers import SentenceTransformer
import faiss
import numpy as np


class InsightVectorStore:

    def __init__(self):

        self.model = SentenceTransformer("all-MiniLM-L6-v2")

        self.index = None
        self.insights = []

    def build_index(self, insights):

        embeddings = self.model.encode(insights)

        dimension = embeddings.shape[1]

        self.index = faiss.IndexFlatL2(dimension)

        self.index.add(np.array(embeddings))

        self.insights = insights

    def search(self, question, k=3):

        query_embedding = self.model.encode([question])

        distances, indices = self.index.search(
            np.array(query_embedding), k
        )

        results = [self.insights[i] for i in indices[0]]

        return results