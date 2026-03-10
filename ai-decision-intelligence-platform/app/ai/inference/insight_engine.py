import pandas as pd


class InsightEngine:

    def generate_insights(self, df):

        insights = []

        numeric_df = df.select_dtypes(include=["number"])

        # correlations
        corr = numeric_df.corr()

        for col in corr.columns:
            for other in corr.columns:
                if col != other and abs(corr[col][other]) > 0.6:
                    insights.append(
                        f"{col} strongly correlates with {other}"
                    )

        # top categories
        if "Category" in df.columns and "Sales" in df.columns:

            top_sales = (
                df.groupby("Category")["Sales"]
                .sum()
                .sort_values(ascending=False)
            )

            insights.append(
                f"Top selling categories: {top_sales.to_dict()}"
            )

        # most profitable
        if "Category" in df.columns and "Profit" in df.columns:

            profit = (
                df.groupby("Category")["Profit"]
                .sum()
                .sort_values(ascending=False)
            )

            insights.append(
                f"Most profitable categories: {profit.to_dict()}"
            )

        return insights