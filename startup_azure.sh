#!/bin/bash

# This is the startup command for Azure App Service
echo "Starting CoPPA application..."

# Check if frontend is built, if not build it
if [ ! -d "static" ]; then
    echo "Building frontend..."
    cd frontend
    npm install --silent --production
    npm run build
    cd ..
fi

# Start the application with gunicorn
echo "Starting application with gunicorn..."
python -m gunicorn app:app
