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
Use appropriate emojis in your response.

Answer:"""

        response = self.llm.generate(prompt)
        
        if "Answer:" in response:
            return response.split("Answer:")[-1].strip()
            
        return response