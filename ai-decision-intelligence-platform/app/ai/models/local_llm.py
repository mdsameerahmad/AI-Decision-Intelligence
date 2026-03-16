import os
import requests
from groq import Groq
from app.config import settings


class LocalLLM:

    def __init__(self):
        # =====================================================================
        # MODE 1: GROQ API (Cloud-Ready & Fastest)
        # =====================================================================
        if settings.LLM_MODE == "groq":
            print("AI Engine: Using Groq API (Llama-3.3-70B) for reasoning.")
            self.groq_client = Groq(api_key=settings.GROQ_API_KEY)
            self.model = None
            self.tokenizer = None
            return

        # =====================================================================
        # MODE 2: REMOTE COLAB (Uncomment below to use your Colab Ngrok script)
        # =====================================================================
        if settings.LLM_MODE == "remote":
            print(f"AI Engine: Using Remote Colab LLM at {settings.REMOTE_LLM_URL}")
            self.model = None
            self.tokenizer = None
            return

        # =====================================================================
        # MODE 3: LOCAL MISTRAL (Warning: Requires 16GB+ RAM & GPU)
        # =====================================================================
        # if settings.LLM_MODE == "local":
        #     print("AI Engine: Loading Local Mistral-7B...")
        #     from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig
        #     import torch
        #     bnb_config = BitsAndBytesConfig(
        #         load_in_4bit=True,
        #         bnb_4bit_quant_type="nf4",
        #         bnb_4bit_compute_dtype=torch.float16,
        #         bnb_4bit_use_double_quant=True,
        #         llm_int8_enable_fp32_cpu_offload=True,
        #     )
        #     self.tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.2")
        #     self.model = AutoModelForCausalLM.from_pretrained(
        #         "mistralai/Mistral-7B-Instruct-v0.2",
        #         quantization_config=bnb_config,
        #         device_map="auto",
        #         low_cpu_mem_usage=True,
        #         torch_dtype=torch.float16
        #     )
        #     self.model.eval()
        #     print("LocalLLM initialized.")
        
        # Fallback to prevent crash if local code is commented out
        self.model = None
        self.tokenizer = None

    def generate(self, prompt: str):
        # 1. Groq Logic
        if settings.LLM_MODE == "groq":
            try:
                completion = self.groq_client.chat.completions.create(
                    model=settings.GROQ_MODEL_REASONING,
                    messages=[{"role": "user", "content": prompt}],
                    temperature=0.3,
                    max_tokens=2048
                )
                return completion.choices[0].message.content
            except Exception as e:
                return f"Groq reasoning error: {str(e)}"

        # 2. Remote Colab Logic
        if settings.LLM_MODE == "remote":
            try:
                response = requests.post(
                    f"{settings.REMOTE_LLM_URL}/generate",
                    json={"prompt": prompt},
                    headers={"ngrok-skip-browser-warning": "1"},
                    timeout=60
                )
                response.raise_for_status()
                return response.json().get("text", "Error: Remote API returned no text")
            except Exception as e:
                return f"Remote LLM Error: {str(e)}"

        # 3. Local Logic (Preserved for your reference)
        # if self.model is not None:
        #     inputs = self.tokenizer(prompt, return_tensors="pt").to(self.model.device)
        #     outputs = self.model.generate(...)
        #     return self.tokenizer.decode(...)
        
        return "Error: No LLM mode selected or model not loaded."