from langchain_core.prompts import PromptTemplate


DATA_ANALYSIS_PROMPT = PromptTemplate(
    input_variables=["context", "question"],
    template="""
You are an AI data analyst.

Context from dataset insights:
{context}

User Question:
{question}

Provide a clear explanation based on the dataset insights.
Explain the possible causes and patterns.
Use appropriate emojis in your response to make it more engaging.

Answer:"""
)


ACTION_PLAN_PROMPT = PromptTemplate(
    input_variables=["insight"],
    template="""
You are an AI project manager.

Based on the following insight:

{insight}

Generate a list of actionable steps a team should take to resolve or improve the situation.
Provide the output as a list of tasks, starting each task with an appropriate emoji.

Answer:"""
)