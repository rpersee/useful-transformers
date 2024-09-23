FROM python:3.9-slim AS builder

WORKDIR /build

# Install system build dependencies
RUN apt-get update && apt-get install -y build-essential

# Install Python build dependencies
RUN pip install pybind11[global]

# Copy application code
COPY . .

# Build project's wheels
RUN pip wheel --no-cache-dir --wheel-dir=/wheels -e .


FROM python:3.9-slim

WORKDIR /app

# Install required libraries
RUN apt-get update && apt-get install -y libgomp1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install the application
RUN --mount=type=bind,from=builder,source=/wheels,target=/wheels \
    pip install --no-cache-dir --no-index --find-links=/wheels useful_transformers

# Set the application as the entrypoint
ENTRYPOINT ["taskset", "-c", "4-7", "python", "-m", "useful_transformers.transcribe_wav"]
