#!/usr/bin/env python3
"""
Oryx build hook - ensures Python-only detection
"""
import os
import sys

def main():
    print("Python build hook executed successfully")
    print(f"Python version: {sys.version}")
    print(f"Working directory: {os.getcwd()}")
    
    # Verify static directory exists
    if os.path.exists('static'):
        print("✅ Static frontend directory found")
    else:
        print("❌ Static frontend directory not found")
        
    return 0

if __name__ == "__main__":
    sys.exit(main())
