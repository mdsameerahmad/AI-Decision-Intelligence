from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig
import torch
import os
import requests
from app.config import settings


class LocalLLM:

    def __init__(self):

        # Hybrid Deployment: If mode is remote, skip heavy model loading to save Railway resources
        if settings.LLM_MODE == "remote":
            print(f"Hybrid Mode: Using Remote LLM at {settings.REMOTE_LLM_URL}")
            self.model = None
            self.tokenizer = None
            return

        print("Initializing LocalLLM with Mistral-7B-Instruct-v0.2...")
        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.float16,
            bnb_4bit_use_double_quant=True,
            llm_int8_enable_fp32_cpu_offload=True,
        )
        self.tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.2")
        self.model = AutoModelForCausalLM.from_pretrained(
            "mistralai/Mistral-7B-Instruct-v0.2",
            quantization_config=bnb_config,
            device_map="auto",
            low_cpu_mem_usage=True,
            torch_dtype=torch.float16
        )
        self.model.eval()
        print("LocalLLM initialized.")

    def generate(self, prompt: str):

        # Hybrid Deployment: Forward request to Colab API
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

        inputs = self.tokenizer(prompt, return_tensors="pt").to(self.model.device)
        outputs = self.model.generate(
            **inputs,
            max_new_tokens=4000,
            do_sample=True,
            temperature=0.7,
            top_p=0.9,
            pad_token_id=self.tokenizer.eos_token_id
        )
        generated_text = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        if prompt in generated_text:
            return generated_text.split(prompt)[-1].strip()
        return generated_text.strip()