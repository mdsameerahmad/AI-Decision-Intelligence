import pandas as pd


class DataQueryEngine:

    def run_query(self, df: pd.DataFrame, question: str):

        q = question.lower()

        # average sales
        if "average" in q and "sales" in q:
            return f"Average sales value is {df['Sales'].mean():.2f}"

        # average profit
        if "average" in q and "profit" in q:
            return f"Average profit per order is {df['Profit'].mean():.2f}"

        # list products
        if "product" in q and ("list" in q or "name" in q):
            products = df["Product Name"].unique().tolist()
            return products[:50]

        # top selling categories
        if "top" in q and "category" in q:
            result = (
                df.groupby("Category")["Sales"]
                .sum()
                .sort_values(ascending=False)
            )
            return result.head(5).to_dict()

        # most profitable category
        if "profit" in q and "category" in q:
            result = (
                df.groupby("Category")["Profit"]
                .sum()
                .sort_values(ascending=False)
            )
            return result.head(5).to_dict()

        # region sales
        if "region" in q and "sales" in q:
            result = (
                df.groupby("Region")["Sales"]
                .sum()
                .sort_values(ascending=False)
            )
            return result.to_dict()

        return "Sorry, I couldn't compute the answer from the dataset."