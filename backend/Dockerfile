# Use official lightweight Python image
FROM python:3.11-slim

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=barbuddy_api.settings \
    PORT=8080

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y gdal-bin libgdal-dev libgeos-dev gcc python3-dev build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set GDAL/GEOS paths
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so
ENV GEOS_LIBRARY_PATH=/usr/lib/libgeos_c.so

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt && pip install gunicorn

# Copy the entire backend code into the container
COPY . /app

# Make sure entrypoint is executable
RUN chmod +x /app/entrypoint.sh

# Create and switch to non-root user
RUN adduser --disabled-password appuser
RUN chown -R appuser:appuser /app
USER appuser

# Run app
ENTRYPOINT ["/app/entrypoint.sh"]
