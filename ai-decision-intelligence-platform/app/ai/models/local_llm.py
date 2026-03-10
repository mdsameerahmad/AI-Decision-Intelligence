from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig
import torch
import os


class LocalLLM:

    def __init__(self):
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
        inputs = self.tokenizer(prompt, return_tensors="pt").to(self.model.device)
        outputs = self.model.generate(
            **inputs,
            max_new_tokens=500,
            do_sample=True,
            temperature=0.7,
            top_p=0.9,
            pad_token_id=self.tokenizer.eos_token_id
        )
        generated_text = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        if prompt in generated_text:
            return generated_text.split(prompt)[-1].strip()
        return generated_text.strip()