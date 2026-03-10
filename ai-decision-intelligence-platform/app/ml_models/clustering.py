import pandas as pd
from sklearn.cluster import KMeans


class ClusteringModel:

    def __init__(self, n_clusters=3):
        self.n_clusters = n_clusters
        self.model = KMeans(
            n_clusters=n_clusters,
            random_state=42
        )

    def cluster(self, df: pd.DataFrame):

        numeric_df = df.select_dtypes(include=["float64", "int64"])

        if numeric_df.empty:
            raise ValueError("Dataset has no numeric columns for clustering")

        clusters = self.model.fit_predict(numeric_df)

        df["cluster"] = clusters

        return {
            "clusters": df["cluster"].value_counts().to_dict(),
            "clustered_data": df.to_dict(orient="records")
        }