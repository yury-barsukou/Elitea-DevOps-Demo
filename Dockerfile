# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Install necessary dependencies

# Install the necessary Python dependencies
#COPY requirements.txt .
#RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container
COPY . .

# Set the environment variables
ENV APP_NAME=my-app
ENV IMAGE_TAG=latest

# Run the app (or replace with your app's startup command)
#CMD ["python", "app.py"]
