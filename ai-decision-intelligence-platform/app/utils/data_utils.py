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
    Supports standard URLs, /edit URLs, and direct export URLs.
    """
    try:
        export_url = sheet_url

        # If it's a standard Google Sheets URL, construct the export URL
        if "docs.google.com/spreadsheets/d/" in sheet_url:
            # Extract the spreadsheet ID
            parts = sheet_url.split("/")
            sheet_id = parts[parts.index("d") + 1]
            
            # Extract GID if present
            gid = "0"
            if "gid=" in sheet_url:
                gid_part = sheet_url.split("gid=")[1]
                gid = gid_part.split("&")[0] if "&" in gid_part else gid_part
            
            export_url = f"https://docs.google.com/spreadsheets/d/{sheet_id}/export?format=csv&gid={gid}"
        elif "googlusercontent.com/export" in sheet_url:
            # If it's already a direct export URL, ensure it's CSV and has gid
            if "format=csv" not in sheet_url:
                export_url += "&format=csv"
            if "gid=" not in sheet_url:
                export_url += "&gid=0" # Default to first sheet if not specified
        
        response = requests.get(export_url)
        response.raise_for_status()
        
        # Verify content is actually CSV
        content_type = response.headers.get('Content-Type', '').lower()
        if 'text/html' in content_type or 'application/json' in content_type:
             raise Exception("The URL provided seems to be private, not a spreadsheet, or returned HTML/JSON instead of CSV. Please ensure the sheet is 'Public' or 'Anyone with the link can view' and the URL is correct.")
        
        return pd.read_csv(io.BytesIO(response.content))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to import Google Sheet: {str(e)}")
