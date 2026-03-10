from app.ai.models.local_llm import LocalLLM


class LangChainPipeline:

    def __init__(self):

        self.llm = LocalLLM()

    def answer_question(self, context: str, question: str):
        prompt = f"<s>[INST] You are a helpful assistant. Based on the following context, answer the question concisely.\nContext: {context}\nQuestion: {question} [/INST]"
        response = self.llm.generate(prompt)
        return response


    def generate_action_plan(self, insight: str):
        prompt = f"<s>[INST] You are a business strategist. Based on the following insight, generate a numbered list of detailed, actionable items for a business strategy.\nInsight: {insight}\nAction Plan: [/INST]"
        response = self.llm.generate(prompt)
        return response

    def generate_suggested_questions(self, dataset_schema: list):
        schema_str = ", ".join(dataset_schema)
        prompt = f"""<s>[INST] You are an AI data analyst. Based on the following dataset columns, suggest 3 insightful questions for analysis.
Dataset Columns: {schema_str}
Provide ONLY the questions, one per line, no numbering. [/INST]"""
        response = self.llm.generate(prompt)
        # Parse the response into a list of questions
        questions = [q.strip() for q in response.split('\n') if q.strip()]
        return questions