from transformers import pipeline
import re


class PandasCodeGenerator:

    def __init__(self):

        # Better reasoning model for data/code
        self.generator = pipeline(
            "text-generation",
            model="Qwen/Qwen2.5-Coder-3B-Instruct",
            max_new_tokens=200,
            temperature=0.1,
            do_sample=False,
            device=-1 # Force to CPU
        )

    def generate_code(self, schema, question):

        prompt = f"""
You are a senior Python data analyst. Your task is to write a single line of Python pandas code to calculate the answer to a user's question.

Dataset columns:
{schema}

A pandas dataframe named `df` is already loaded.

Write Python pandas code to answer the following question.
If the question implies a derived metric (e.g., 'profit', 'loss', 'revenue', 'discount'), infer the calculation based on common business logic and available columns. For example, if 'profit' is asked and 'Weekly_Sales' and 'Fuel_Price' are available, assume profit might be related to their difference.

Question:
{question}

STRICT RULES:
- Return ONLY a single line of Python code that assigns the final calculated value to a variable named `result`.
- Use pandas operations only.
- Do NOT explain anything.
- Do NOT print anything.
- Ensure the code is syntactically correct and directly executable.
- Example: `result = df['Weekly_Sales'].sum()`
"""

        output = self.generator(prompt)[0]["generated_text"]

        code = self._clean_generated_code(output)

        return code


    def _clean_generated_code(self, code):

        # remove tokenizer artifacts
        code = code.replace("Ġ", "").replace("Ċ", "")
        code = "".join(ch for ch in code if ord(ch) < 128)

        extracted_code = ""

        # extract python blocks
        if "```python" in code:
            parts = code.split("```python")
            for part in parts[1:]:
                if "```" in part:
                    extracted_code += part.split("```")[0] + "\n"

        elif "```" in code:
            parts = code.split("```")
            for i in range(1, len(parts), 2):
                extracted_code += parts[i] + "\n"

        else:
            extracted_code = code

        code = extracted_code.strip()

        # remove hallucinated text
        garbage_prefix = [
            "You are",
            "Dataset columns",
            "Question",
            "STRICT RULES",
            "Rules",
            "-"
        ]

        lines = code.split("\n")
        cleaned = []

        for line in lines:

            stripped = line.strip()

            if not stripped:
                continue

            skip = False
            for g in garbage_prefix:
                if stripped.startswith(g):
                    skip = True
                    break

            if skip:
                continue

            cleaned.append(stripped)

        code = "\n".join(cleaned)

        # remove dangerous imports
        blocked = [
            "import os",
            "import sys",
            "subprocess",
            "eval(",
            "exec("
        ]

        safe_lines = []

        for line in code.split("\n"):

            block = False

            for b in blocked:
                if b in line:
                    block = True
                    break

            if not block:
                safe_lines.append(line)

        code = "\n".join(safe_lines)

        # fix duplicated result tokens
        code = re.sub(r"\)\s*result$", ")", code)
        code = re.sub(r"(result\s*=.*)\s+result", r"\1", code)

        # ensure result exists
        if "result" not in code:

            lines = code.split("\n")

            if lines:
                last_line = lines[-1]

                if last_line and not last_line.startswith("result"):
                    code += f"\nresult = {last_line}"

        # remove lone result tokens
        final_lines = []

        for line in code.split("\n"):

            if line.strip() == "result":
                continue

            final_lines.append(line)

        code = "\n".join(final_lines)

        # collapse blank lines
        code = "\n".join([l for l in code.split("\n") if l.strip()])

        return code.strip()