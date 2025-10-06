# Base image
FROM python:3.10-slim-bullseye

# Install git (required for installing from GitHub)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /code

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the pre-downloaded Parrot model
COPY parrot_model /code/parrot_model

# Copy app code
COPY app.py /code/app.py

# Expose port for Render
ENV PORT 10000
EXPOSE 10000

# Start FastAPI with Render's PORT
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port $PORT"]

