# Use Python slim image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy requirements and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the converter script
COPY main.py .

# Create a folder for input/output (mapped from host)
RUN mkdir -p data/output

# Default command
CMD ["python", "main.py"]
