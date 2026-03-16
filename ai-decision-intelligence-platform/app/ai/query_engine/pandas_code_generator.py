import re
import requests
from groq import Groq
from app.config import settings


class PandasCodeGenerator:

    def __init__(self):
        # =====================================================================
        # MODE 1: GROQ API (Recommended)
        # =====================================================================
        if settings.LLM_MODE == "groq":
            print("Code Engine: Using Groq API for Pandas generation.")
            self.groq_client = Groq(api_key=settings.GROQ_API_KEY)
            self.generator = None
            return

        # =====================================================================
        # MODE 2: REMOTE COLAB
        # =====================================================================
        if settings.LLM_MODE == "remote":
            print("Code Engine: Using Remote Colab for Pandas generation.")
            self.generator = None
            return

        # =====================================================================
        # MODE 3: LOCAL QWEN (Commented out for reference)
        # =====================================================================
        # if settings.LLM_MODE == "local":
        #     print("Code Engine: Loading Local Qwen-Coder-3B...")
        #     from transformers import pipeline
        #     self.generator = pipeline(
        #         "text-generation",
        #         model="Qwen/Qwen2.5-Coder-3B-Instruct",
        #         max_new_tokens=200,
        #         temperature=0.1,
        #         do_sample=False,
        #         device=-1 # Force to CPU
        #     )
        
        self.generator = None

    def generate_code(self, schema, question):

        prompt = f"""
You are a senior Python data analyst. Your task is to write a single line of Python pandas code to calculate the answer to a user's question.

Dataset columns:
{schema}

A pandas dataframe named `df` is already loaded.
The pandas library is available as `pd`.

Write Python pandas code to answer the following question.
Question:
{question}

STRICT RULES:
- Return ONLY a single line of Python code that assigns the final calculated value to a variable named `result`.
- Example: `result = df['Weekly_Sales'].sum()`
"""

        # 1. Groq Logic
        if settings.LLM_MODE == "groq":
            try:
                completion = self.groq_client.chat.completions.create(
                    model=settings.GROQ_MODEL_CODE,
                    messages=[{"role": "user", "content": prompt}],
                    temperature=0.1
                )
                code_raw = completion.choices[0].message.content
                return self._clean_generated_code(code_raw)
            except Exception as e:
                return f"# Groq Code Gen Error: {str(e)}"

        # 2. Remote Logic
        if settings.LLM_MODE == "remote":
            try:
                response = requests.post(
                    f"{settings.REMOTE_LLM_URL}/generate_code",
                    json={"schema": schema, "question": question},
                    headers={"ngrok-skip-browser-warning": "1"},
                    timeout=60
                )
                response.raise_for_status()
                code = response.json().get("code", "# Error: No code returned")
                return self._clean_generated_code(code)
            except Exception as e:
                return f"# Remote Code Gen Error: {str(e)}"

        # 3. Local Logic (Reference)
        # if self.generator is not None:
        #     output = self.generator(prompt)[0]["generated_text"]
        #     return self._clean_generated_code(output)

        return "# Error: No Code Engine mode selected."


    def _clean_generated_code(self, code):
        # Remove tokenizer artifacts and non-ASCII characters
        code = code.replace("Ġ", "").replace("Ċ", "")
        code = "".join(ch for ch in code if ord(ch) < 128)

        # Split the code into lines
        lines = code.split('\n')
        
        # Look for the first line that starts with "result ="
        for line in lines:
            stripped_line = line.strip()
            if stripped_line.startswith("result ="):
                # Remove any trailing markdown fences (```) or comments (#) from this line
                cleaned_line = re.sub(r'```.*', '', stripped_line).strip()
                cleaned_line = re.sub(r'#.*', '', cleaned_line).strip()
                return cleaned_line
        
        # If no line starting with "result =" is found, try to extract from code blocks
        # This is a fallback for cases where the LLM might wrap the code differently
        extracted_code_block = ""
        if "```python" in code:
            parts = code.split("```python")
            for part in parts[1:]:
                if "```" in part:
                    extracted_code_block += part.split("```")[0] + "\n"
        elif "```" in code:
            parts = code.split("```")
            for i in range(1, len(parts), 2):
                extracted_code_block += parts[i] + "\n"
        
        # If a code block was extracted, process it
        if extracted_code_block:
            block_lines = extracted_code_block.strip().split('\n')
            for line in block_lines:
                stripped_line = line.strip()
                if stripped_line.startswith("result ="):
                    # Clean the line from the block
                    cleaned_line = re.sub(r'```.*', '', stripped_line).strip()
                    cleaned_line = re.sub(r'#.*', '', cleaned_line).strip()
                    return cleaned_line
            # If "result =" not found in block, return the whole block after stripping
            return extracted_code_block.strip()
        
        # If no "result =" line and no code block, return the original code after basic cleaning
        # and removing any trailing markdown fences or comments
        cleaned_code = re.sub(r'```.*', '', code).strip()
        cleaned_code = re.sub(r'#.*', '', cleaned_code).strip()
        return cleaned_code