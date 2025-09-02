#!/bin/bash
set -e

echo "🚀 Starting CoPPA application..."
echo "================================="

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if we're in Azure App Service and if this is first startup
if [ -n "$WEBSITE_HOSTNAME" ] && [ ! -f "/home/setup_completed.flag" ]; then
    log "🔧 First-time setup in Azure App Service: $WEBSITE_HOSTNAME"
    
    # Set up search components if they don't exist
    log "🔍 Verifying search components setup..."
    if [ -f "backend/search_setup.py" ]; then
        python backend/search_setup.py --verify-and-create || log "⚠️  Search setup had issues, but continuing..."
    fi
    
    # Upload sample documents if storage is empty
    log "📄 Checking for sample documents..."
    if [ -d "data/" ] && [ -n "$SETUP_STORAGE_ACCOUNT_NAME" ] && [ -n "$SETUP_STORAGE_ACCOUNT_KEY" ]; then
        python -c "
import os
from azure.storage.blob import BlobServiceClient
from azure.core.exceptions import ResourceNotFoundError

try:
    # Connect to storage
    blob_service = BlobServiceClient(
        account_url=f'https://{os.environ[\"SETUP_STORAGE_ACCOUNT_NAME\"]}.blob.core.windows.net',
        credential=os.environ['SETUP_STORAGE_ACCOUNT_KEY']
    )
    
    container_name = os.environ.get('AZURE_STORAGE_CONTAINER_NAME', 'docs')
    container_client = blob_service.get_container_client(container_name)
    
    # Check if container has any blobs
    blobs = list(container_client.list_blobs())
    if len(blobs) == 0:
        print('📤 Uploading sample documents...')
        
        # Upload sample documents from data folder
        import glob
        for file_path in glob.glob('data/*'):
            if os.path.isfile(file_path):
                file_name = os.path.basename(file_path)
                with open(file_path, 'rb') as data:
                    container_client.upload_blob(name=file_name, data=data, overwrite=True)
                    print(f'   ✅ Uploaded: {file_name}')
        
        print('📄 Sample documents uploaded successfully!')
    else:
        print(f'📄 Found {len(blobs)} existing documents in storage.')
        
except Exception as e:
    print(f'❌ Error with document upload: {str(e)}')
    print('   Documents can be uploaded manually later.')
" || log "⚠️  Document upload had issues, but continuing..."
    
    fi
    
    # Create a flag file to indicate setup is complete
    echo "$(date)" > /home/setup_completed.flag
    log "✅ First-time setup completed!"
fi

# Build frontend if needed
if [ ! -d "static" ]; then
    log "🏗️  Building frontend..."
    cd frontend
    npm install --silent
    npm run build
    cd ..
fi

# Start the application with gunicorn
log "🚀 Starting backend with gunicorn..."
python -m gunicorn app:app
