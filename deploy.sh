#!/bin/bash

# Exit on any failure
set -e

echo "Running custom deployment script..."

# Install Node.js dependencies and build frontend
echo "Installing Node.js dependencies and building frontend..."
cd frontend
npm install --silent
npm run build
cd ..

echo "Frontend build completed successfully"
