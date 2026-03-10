from app.ai.models.local_llm import LocalLLM


class AIPipeline:

    def __init__(self):

        self.llm = LocalLLM()

    def answer_question(self, insights, question):

        context = "\n".join(insights)

        prompt = f"""
Dataset Insights:

{context}

Question:
{question}

Provide a clear data analysis answer.
"""

        return self.llm.generate(prompt)