import faiss
import numpy as np
import os
import pickle


class FAISSVectorStore:

    def __init__(self, dimension=384, index_path="app/vector_store/faiss_index"):
        """
        dimension: size of embedding vectors
        index_path: location to save/load FAISS index
        """
        self.dimension = dimension
        self.index_path = index_path

        self.index = faiss.IndexFlatL2(self.dimension)
        self.metadata = []

        if os.path.exists(self.index_path):
            self.load_index()


    def add_vectors(self, vectors, metadata_list):
        """
        Add embeddings and corresponding metadata
        vectors: list of embedding vectors
        metadata_list: associated info (text, insight, dataset id)
        """

        vectors = np.array(vectors).astype("float32")

        self.index.add(vectors)

        self.metadata.extend(metadata_list)


    def search(self, query_vector, k=3):
        """
        Find k nearest neighbors for a query vector
        """

        query_vector = np.array([query_vector]).astype("float32")

        distances, indices = self.index.search(query_vector, k)

        results = []

        for idx in indices[0]:
            if idx < len(self.metadata):
                results.append(self.metadata[idx])

        return results


    def save_index(self):
        """
        Save FAISS index and metadata to disk
        """

        faiss.write_index(self.index, self.index_path)

        meta_path = self.index_path + "_meta.pkl"

        with open(meta_path, "wb") as f:
            pickle.dump(self.metadata, f)


    def load_index(self):
        """
        Load FAISS index and metadata
        """

        self.index = faiss.read_index(self.index_path)

        meta_path = self.index_path + "_meta.pkl"

        if os.path.exists(meta_path):

            with open(meta_path, "rb") as f:
                self.metadata = pickle.load(f)