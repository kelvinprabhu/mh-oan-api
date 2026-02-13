import logfire
from dotenv import load_dotenv
from pydantic_ai import Agent, RunContext

load_dotenv()

logfire.configure(scrubbing=False)

Agent.instrument_all()