import logfire
from dotenv import load_dotenv
from langfuse import get_client
from pydantic_ai import Agent, RunContext

load_dotenv()

logfire.configure(scrubbing=False)


# Load environment variables
load_dotenv()

# Initialize Langfuse client
langfuse = get_client()

# Verify Langfuse connection
if langfuse.auth_check():
    print("Langfuse client is authenticated and ready!")
else:
    print("Authentication failed. Please check your credentials and host.")

# Initialize Pydantic AI instrumentation
Agent.instrument_all()