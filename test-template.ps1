param(
    [string]$TemplateFile = "infrastructure/deployment.json",
    [string]$Location = "eastus"
)

# Set the subscription context
# Uncomment and set your subscription ID if needed
# Select-AzSubscription -SubscriptionId "your-subscription-id"

# Create a temporary resource group for validation
$validationRgName = "validation-test-rg-$(Get-Random)"
New-AzResourceGroup -Name $validationRgName -Location $Location -Force

try {
    Write-Host "Validating ARM template: $TemplateFile" -ForegroundColor Cyan
    
    $templateContent = Get-Content -Path $TemplateFile -Raw
    
    # Test the template against the API
    $validation = Test-AzResourceGroupDeployment `
        -ResourceGroupName $validationRgName `
        -TemplateFile $TemplateFile `
        -HostingPlanName "test-hosting-plan" `
        -WebsiteName "test-web-app" `
        -ApplicationInsightsName "test-app-insights" `
        -WhatIf
    
    if ($validation) {
        Write-Host "Template validation failed with the following errors:" -ForegroundColor Red
        $validation | Format-List
    }
    else {
        Write-Host "Template validation successful!" -ForegroundColor Green
    }
}
catch {
    Write-Host "Error during validation: $_" -ForegroundColor Red
    $_.Exception.Message
}
finally {
    # Clean up the temporary resource group
    Remove-AzResourceGroup -Name $validationRgName -Force -AsJob | Out-Null
    Write-Host "Cleanup initiated for resource group: $validationRgName" -ForegroundColor Yellow
}
