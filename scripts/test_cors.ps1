param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,
    
    [Parameter(Mandatory=$true)]
    [string]$BlobName
)

$testUrl = "https://$StorageAccountName.blob.core.windows.net/$ContainerName/$BlobName"
Write-Host "Testing CORS configuration for: $testUrl"

# Create a temporary HTML file to test CORS
$tempHtmlPath = [System.IO.Path]::GetTempFileName() + ".html"
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>CORS Test</title>
    <script>
        function testCORS() {
            const url = '$testUrl';
            fetch(url)
                .then(response => {
                    if (response.ok) {
                        document.getElementById('result').innerHTML = 
                            '<span style="color:green">SUCCESS: CORS is properly configured. The deploy to Azure button should work.</span>';
                        return response.text();
                    }
                    throw new Error('Network response was not ok.');
                })
                .then(data => {
                    console.log('Response data:', data);
                    document.getElementById('data').textContent = data.substring(0, 200) + '...';
                })
                .catch(error => {
                    document.getElementById('result').innerHTML = 
                        '<span style="color:red">ERROR: CORS is not properly configured. ' + error.message + '</span>';
                });
        }
    </script>
</head>
<body onload="testCORS()">
    <h1>Testing CORS for Azure Blob Storage</h1>
    <p>URL being tested: <code>$testUrl</code></p>
    <div id="result">Testing...</div>
    <h3>Response Preview:</h3>
    <pre id="data"></pre>
</body>
</html>
"@

$html | Out-File -FilePath $tempHtmlPath -Encoding utf8

# Open the HTML file in the default browser
Write-Host "Opening CORS test page in your browser..."
Start-Process $tempHtmlPath

Write-Host "The test page has been opened in your browser."
Write-Host "If the test is successful, you'll see a green success message."
Write-Host "If it fails, you'll see a red error message indicating a CORS configuration issue."
