
FROM python:3.10-slim-bullseye

# Set working directory
WORKDIR /code

# Prevent Python from writing .pyc files and buffering stdout
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies (for any Python packages)
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download Parrot model to avoid downloading at runtime
RUN python -c "from transformers import AutoModelForSeq2SeqLM, AutoTokenizer; \
    AutoModelForSeq2SeqLM.from_pretrained('prithivida/parrot_paraphraser_on_T5').save_pretrained('/code/parrot_model'); \
    AutoTokenizer.from_pretrained('prithivida/parrot_paraphraser_on_T5').save_pretrained('/code/parrot_model')"

# Copy application code
COPY . .

# Environment variable for model path
ENV PARROT_MODEL_PATH=/code/parrot_model

# Expose API port
EXPOSE 8000

# Start FastAPI using uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
