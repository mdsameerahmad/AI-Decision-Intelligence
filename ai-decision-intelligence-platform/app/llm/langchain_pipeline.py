from app.ai.models.local_llm import LocalLLM


class LangChainPipeline:

    def __init__(self):

        self.llm = LocalLLM()

    def answer_question(self, context: str, question: str):
        prompt = f"<s>[INST] You are a helpful assistant. Based on the following context, answer the question concisely and use appropriate emojis to make it engaging.\nContext: {context}\nQuestion: {question} [/INST] Answer:"
        response = self.llm.generate(prompt)
        
        if "Answer:" in response:
            return response.split("Answer:")[-1].strip()
            
        return response


    def generate_action_plan(self, insight: str):
        prompt = f"""<s>[INST] You are a senior business consultant and strategist. Based on the following problem/insight, provide exactly 10 highly detailed, in-depth business strategies.

Problem/Insight: {insight}

For each of the 10 strategies, provide:
1. A clear Title.
2. A detailed implementation plan (3-4 sentences).
3. The expected business impact.

IMPORTANT FORMATTING RULES:
- Do NOT use prefixes like "Strategy #1:", "1:", or "Strategy:".
- Do NOT use markdown symbols like #, *, or dashes (-).
- Start each strategy with an appropriate emoji related to the content (e.g., 📈 for growth, 💰 for pricing, 🤝 for loyalty).
- Provide ONLY the 10 strategies, separated by two newlines. [/INST]"""
        response = self.llm.generate(prompt)
        return response

    def generate_suggested_questions(self, dataset_schema: list):
        schema_str = ", ".join(dataset_schema)
        prompt = f"""<s>[INST] You are an AI data analyst. Based on the following dataset columns, suggest 3 insightful questions for analysis.
Dataset Columns: {schema_str}
Provide ONLY the questions, one per line, no numbering. Each question should start with an appropriate emoji. [/INST]"""
        response = self.llm.generate(prompt)
        # Parse the response into a list of questions
        questions = [q.strip() for q in response.split('\n') if q.strip()]
        return questions