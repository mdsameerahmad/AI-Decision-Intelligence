from app.ai.models.local_llm import LocalLLM


class LLMService:

    def __init__(self):

        self.llm = LocalLLM()

    def generate_answer(self, question: str, context: str):

        prompt = f"""
You are a data analyst.

Dataset information:
{context}

Question:
{question}

Provide a clear answer based on the dataset.
"""

        response = self.llm.generate(prompt)

        return response