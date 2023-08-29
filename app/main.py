from fastapi import FastAPI
from dotenv import load_dotenv
from pathlib import Path
from router import hello
import sys
import os

os.environ["TZ"] = "UTC"

env_path = Path('.') / '.env'
load_dotenv(dotenv_path=env_path, override=True)
app_version = str(os.getenv('BUILD_VERSION', "0.0.1"))
api = FastAPI(
    title="Hello",
    description="Hello service.",
    version=app_version,
)

api.include_router(hello.router)
