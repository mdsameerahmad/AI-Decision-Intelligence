import pandas as pd

def execute_generated_code(code, df):

    local_env = {"df": df, "pd": pd}

    try:
        exec(code, {}, local_env)
        return local_env.get("result")

    except Exception as e:
        return f"Error executing generated code: {str(e)}"