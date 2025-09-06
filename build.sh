#!/bin/bash
set -e

echo "Starting build process..."

# Build frontend if Node.js is available
if command -v npm &> /dev/null; then
    echo "Building frontend with npm..."
    cd frontend
    npm ci --silent --production
    npm run build
    cd ..
    echo "Frontend build completed"
else
    echo "Warning: npm not found, skipping frontend build"
fi

echo "Build process completed successfully"
