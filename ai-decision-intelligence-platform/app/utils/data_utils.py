import pandas as pd
import numpy as np
from fastapi import HTTPException
import io
import requests

def load_dataframe(file_path: str) -> pd.DataFrame:
    """
    Universal loader for CSV and Excel files.
    """
    try:
        if file_path.endswith('.csv'):
            try:
                return pd.read_csv(file_path, encoding="utf-8")
            except UnicodeDecodeError:
                return pd.read_csv(file_path, encoding="latin1")
        elif file_path.endswith(('.xls', '.xlsx')):
            return pd.read_excel(file_path)
        else:
            # Try CSV by default if no extension
            return pd.read_csv(file_path)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail=f"File not found at {file_path}")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error loading data file: {str(e)}")

def import_from_google_sheet(sheet_url: str) -> pd.DataFrame:
    """
    Imports a public Google Sheet as a DataFrame.
    Supports standard URLs, /edit URLs, and gid specification.
    """
    try:
        # Standardize the URL for export
        if "docs.google.com/spreadsheets/d/" in sheet_url:
            # Extract the spreadsheet ID
            parts = sheet_url.split("/")
            sheet_id = parts[parts.index("d") + 1]
            
            # Extract GID if present
            gid = "0"
            if "gid=" in sheet_url:
                gid = sheet_url.split("gid=")[1].split("&")[0]
            
            export_url = f"https://docs.google.com/spreadsheets/d/{sheet_id}/export?format=csv&gid={gid}"
        else:
            export_url = sheet_url

        response = requests.get(export_url)
        response.raise_for_status()
        
        # Verify content is actually CSV
        content_type = response.headers.get('Content-Type', '').lower()
        if 'text/html' in content_type:
             raise Exception("The URL provided seems to be private or not a spreadsheet. Please ensure the sheet is 'Public' or 'Anyone with the link can view'.")
        
        return pd.read_csv(io.BytesIO(response.content))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to import Google Sheet: {str(e)}")
