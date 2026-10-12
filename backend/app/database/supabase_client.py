import os
from pathlib import Path

from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv(Path(__file__).resolve().parents[2] / '.env')

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    raise RuntimeError(
        "SUPABASE_URL ou SUPABASE_KEY não configurados."
    )

supabase: Client = create_client(
    SUPABASE_URL,
    SUPABASE_KEY
)
