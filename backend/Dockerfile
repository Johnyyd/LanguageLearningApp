FROM python:3.11-slim

WORKDIR /app

# Install system dependencies for SQL Server (FreeTDS, unixODBC) and building wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    freetds-dev \
    freetds-bin \
    unixodbc-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY . .

# Expose port
EXPOSE 1112

# Run FastAPI server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "1112", "--reload"]
