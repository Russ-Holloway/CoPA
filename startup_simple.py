#!/usr/bin/env python3
"""
Simple startup script for Azure App Service
This assumes the frontend is pre-built and included in the static/ directory
"""
import os
import sys

def main():
    """Simple startup - just start gunicorn"""
    print("🚀 Starting CoPPA application...")
    
    # Check if static directory exists (pre-built frontend)
    if not os.path.exists('static'):
        print("❌ Static directory not found. Frontend must be pre-built.")
        print("Run 'cd frontend && npm install && npm run build' locally and commit the static/ directory")
        sys.exit(1)
    
    print("✅ Static frontend found")
    print("✅ Starting application with gunicorn...")
    
    # Start gunicorn (this will be handled by Azure App Service)
    os.system("python -m gunicorn app:app")

if __name__ == "__main__":
    main()
