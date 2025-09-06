#!/usr/bin/env python3
"""
Python-based build script for Azure deployment
This handles the frontend build process as part of the Python deployment
"""
import os
import subprocess
import sys
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def run_command(cmd, cwd=None):
    """Run a shell command and return success status"""
    try:
        logger.info(f"Running: {cmd}")
        result = subprocess.run(cmd, shell=True, cwd=cwd, check=True, 
                              capture_output=True, text=True)
        logger.info(f"Command succeeded: {result.stdout}")
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed: {e}")
        logger.error(f"Error output: {e.stderr}")
        return False

def build_frontend():
    """Build the frontend using Node.js if available"""
    frontend_dir = "frontend"
    
    if not os.path.exists(frontend_dir):
        logger.info("No frontend directory found, skipping frontend build")
        return True
    
    if not os.path.exists(os.path.join(frontend_dir, "package.json")):
        logger.info("No package.json found, skipping frontend build")
        return True
    
    logger.info("Building frontend...")
    
    # Check if npm is available
    if not run_command("which npm"):
        logger.warning("npm not found, attempting to install Node.js...")
        
        # Try to install Node.js using the system package manager
        if run_command("curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"):
            run_command("sudo apt-get install -y nodejs")
        else:
            logger.error("Failed to install Node.js")
            return False
    
    # Install dependencies
    if not run_command("npm ci --only=production", cwd=frontend_dir):
        logger.error("Failed to install frontend dependencies")
        return False
    
    # Build the frontend
    if not run_command("npm run build", cwd=frontend_dir):
        logger.error("Failed to build frontend")
        return False
    
    logger.info("Frontend build completed successfully")
    return True

def main():
    """Main build function"""
    logger.info("Starting Python-based build process...")
    
    # Build frontend
    if not build_frontend():
        logger.error("Frontend build failed")
        sys.exit(1)
    
    logger.info("Build process completed successfully")

if __name__ == "__main__":
    main()
