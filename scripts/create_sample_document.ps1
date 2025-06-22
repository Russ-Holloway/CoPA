# Create Sample Document for Policing Assistant Search
# This script uploads a sample police procedures document to the storage container

param(
    [Parameter(Mandatory = $true)]
    [string]$storageAccountName,
    
    [Parameter(Mandatory = $true)]
    [string]$storageAccountKey,
    
    [Parameter(Mandatory = $true)]
    [string]$containerName
)

Write-Output "=== Creating Sample Document ==="
Write-Output "Storage Account: $storageAccountName"
Write-Output "Container: $containerName"
Write-Output ""

try {
    # Create sample content
    $sampleContent = @"
# Police Investigation Procedures

## General Guidelines
- Follow all departmental protocols
- Document all evidence thoroughly
- Maintain chain of custody
- Interview witnesses promptly
- Collaborate with other agencies when appropriate

### Emergency Response
- Assess scene safety first
- Request backup when needed
- Provide medical aid if qualified
- Secure the scene

### Investigation Best Practices
- Preserve crime scene integrity
- Collect and catalog evidence systematically
- Interview witnesses separately
- Maintain detailed case notes
- Follow proper evidence chain of custody
- Coordinate with forensic teams when necessary

### Community Policing
- Build positive relationships with community members
- Engage in proactive problem-solving
- Participate in community outreach programs
- Maintain professional demeanor at all times

### Report Writing
- Use clear, concise language
- Include all relevant facts
- Maintain objectivity
- Follow department formatting standards
- Submit reports in a timely manner

This document serves as a sample for the Policing Assistant search functionality.
"@

    Write-Output "Creating temporary file with sample content..."
    
    # Create temporary file
    $tempFile = [System.IO.Path]::GetTempFileName()
    $sampleContent | Out-File -FilePath $tempFile -Encoding UTF8
    
    Write-Output "Connecting to storage account..."
    
    # Create storage context
    $ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
    
    Write-Output "Uploading sample document to container..."
    
    # Upload the file to blob storage
    $blob = Set-AzStorageBlobContent -File $tempFile -Container $containerName -Blob 'sample-police-procedures.txt' -Context $ctx -Force
    
    Write-Output "Cleaning up temporary file..."
    
    # Clean up temporary file
    Remove-Item $tempFile -Force
    
    Write-Output "✅ Sample document created successfully!"
    Write-Output "Blob name: sample-police-procedures.txt"
    Write-Output "Blob URI: $($blob.ICloudBlob.StorageUri.PrimaryUri)"
    Write-Output ""
    
    # Verify the upload
    Write-Output "Verifying upload..."
    $uploadedBlob = Get-AzStorageBlob -Container $containerName -Blob 'sample-police-procedures.txt' -Context $ctx
    Write-Output "✅ Verification successful - Blob size: $($uploadedBlob.Length) bytes"
    
    Write-Output ""
    Write-Output "🎉 Sample document setup completed successfully!"
    
}
catch {
    Write-Output "❌ Error creating sample document: $($_.Exception.Message)"
    Write-Output "Stack trace: $($_.ScriptStackTrace)"
    
    # Clean up temp file if it exists
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
    
    # Don't fail the entire deployment for sample document issues
    Write-Output "Sample document creation failed, but this is not critical for the main deployment."
    Write-Output "You can upload documents manually to the storage container after deployment."
}

Write-Output "Sample document script completed."
