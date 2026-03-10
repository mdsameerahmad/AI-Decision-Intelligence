import pandas as pd


class PandasQueryEngine:

    def execute(self, df: pd.DataFrame, question: str):

        q = question.lower()

        if "average sales" in q:
            return df["Sales"].mean()

        if "average profit" in q:
            return df["Profit"].mean()

        if "top category" in q or "highest sales category" in q:

            result = (
                df.groupby("Category")["Sales"]
                .sum()
                .sort_values(ascending=False)
                .head(5)
            )

            return result.to_dict()

        if "list product" in q:

            return df["Product Name"].unique().tolist()

        return None