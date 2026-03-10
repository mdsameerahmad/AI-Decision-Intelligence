from app.llm.langchain_pipeline import LangChainPipeline


class DecisionAgent:

    def __init__(self):

        self.pipeline = LangChainPipeline()

    def run(self, insight: str):

        response = self.pipeline.generate_action_plan(insight)

        return response