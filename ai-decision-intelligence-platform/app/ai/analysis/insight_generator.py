import pandas as pd


class InsightGenerator:

    def generate(self, df: pd.DataFrame):

        insights = []

        numeric_df = df.select_dtypes(include=["number"])

        if not numeric_df.empty:

            corr = numeric_df.corr()

            for col in corr.columns:
                for other in corr.columns:

                    if col != other and abs(corr[col][other]) > 0.6:

                        insights.append(
                            f"{col} strongly correlates with {other}"
                        )

        if "Sales" in df.columns:
            insights.append(
                f"Average sales value is {df['Sales'].mean():.2f}"
            )

        if "Profit" in df.columns:
            insights.append(
                f"Average profit value is {df['Profit'].mean():.2f}"
            )

        if "Category" in df.columns and "Sales" in df.columns:

            top_sales = (
                df.groupby("Category")["Sales"]
                .sum()
                .sort_values(ascending=False)
                .head(3)
            )

            insights.append(
                f"Top selling categories: {top_sales.to_dict()}"
            )

        return insights