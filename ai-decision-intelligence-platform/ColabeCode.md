# ==========================================
# 1. INSTALL DEPENDENCIES
# ==========================================
!pip install -q transformers bitsandbytes accelerate pyngrok fastapi uvicorn nest-asyncio

import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig, pipeline
import nest_asyncio
from fastapi import FastAPI
from pyngrok import ngrok
import uvicorn
from pydantic import BaseModel
import re

# ==========================================
# 2. LOAD MODELS (Mistral & Qwen)
# ==========================================
print("Loading Mistral-7B (Reasoning)...")
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True, 
    bnb_4bit_compute_dtype=torch.float16
)
m_tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.2")
m_model = AutoModelForCausalLM.from_pretrained(
    "mistralai/Mistral-7B-Instruct-v0.2", 
    quantization_config=bnb_config, 
    device_map="auto"
)

print("Loading Qwen-Coder (Code Gen)...")
q_tokenizer = pipeline(
    "text-generation", 
    model="Qwen/Qwen2.5-Coder-3B-Instruct", 
    device_map="auto", 
    torch_dtype=torch.float16
)

# ==========================================
# 3. INITIALIZE FASTAPI & HELPERS
# ==========================================
app = FastAPI()

class PromptRequest(BaseModel):
    prompt: str

class CodeRequest(BaseModel):
    schema: dict
    question: str

def _clean_generated_code(code):
    """Robust cleaning logic for generated Pandas code"""
    code = code.replace("Ġ", "").replace("Ċ", "")
    code = "".join(ch for ch in code if ord(ch) < 128)
    
    lines = code.split('\n')
    # Priority 1: Find 'result =' line
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("result ="):
            return re.sub(r'```.*', '', stripped).split('#')[0].strip()
    
    # Priority 2: Fallback to markdown block extraction
    if "```python" in code:
        code = code.split("```python")[1].split("```")[0]
    elif "```" in code:
        code = code.split("```")[1].split("```")[0]
        
    return code.strip()

# ==========================================
# 4. API ENDPOINTS
# ==========================================

@app.post("/generate")
async def generate(data: PromptRequest):
    """Handles Suggested Questions, Strategies, and Chat Interpretation"""
    inputs = m_tokenizer(data.prompt, return_tensors="pt").to("cuda")
    outputs = m_model.generate(**inputs, max_new_tokens=4000)
    full_text = m_tokenizer.decode(outputs[0], skip_special_tokens=True)

    # Clean the response: 
    # 1. Strip system prompt
    clean_text = full_text.split("[/INST]")[-1].strip() if "[/INST]" in full_text else full_text
    
    # 2. Strip specific data analysis instructions
    instruction_phrase = "Based on this result, provide a clear, concise natural language answer to the user."
    if instruction_phrase in clean_text:
        clean_text = clean_text.split(instruction_phrase)[-1].strip()
    
    # Remove leading colons/junk
    clean_text = re.sub(r'^[:\s\-\n]+', '', clean_text)
    
    return {"text": clean_text}

@app.post("/generate_code")
async def generate_code(data: CodeRequest):
    """Handles Natural Language to Pandas code generation"""
    prompt = f"Dataset columns: {data.schema}\nQuestion: {data.question}\nWrite one line of pandas code: result = "
    output = q_tokenizer(prompt, max_new_tokens=100)[0]['generated_text']
    
    # Extract logic after the prompt
    code_raw = output.split("result =")[-1].strip()
    cleaned_code = _clean_generated_code("result = " + code_raw)
    
    print(f"--- DEBUG: Generated Code: {cleaned_code} ---")
    return {"code": cleaned_code}

# ==========================================
# 5. START SERVER WITH NGROK
# ==========================================
NGROK_AUTH_TOKEN = "3AlQIxGK2hAfFJR8iR0Nsa49FjZ_3DUTmYmr5vMumJhCZRRAx" 
ngrok.set_auth_token(NGROK_AUTH_TOKEN)
nest_asyncio.apply()
ngrok.kill()
public_url = ngrok.connect(8000)

print(f"\n🚀 AI BACKEND IS LIVE!")
print(f"🔗 PUBLIC URL: {public_url}")
print(f"👉 Update your Flutter settings with this URL.")

config = uvicorn.Config(app, host="0.0.0.0", port=8000, loop="asyncio")
server = uvicorn.Server(config)
await server.serve()