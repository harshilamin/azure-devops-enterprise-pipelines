[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Organization,
    [Parameter(Mandatory)] [string] $Project
)

$ErrorActionPreference = 'Stop'
$names = @(
    'pipeline-demo-dev',
    'pipeline-demo-qa',
    'pipeline-demo-prod',
    'infrastructure-dev',
    'infrastructure-qa',
    'infrastructure-prod'
)

foreach ($name in $names) {
    $existing = az devops invoke `
        --organization $Organization `
        --area distributedtask `
        --resource environments `
        --route-parameters project=$Project `
        --query-parameters name=$name `
        --query 'value[0].id' `
        --output tsv

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to query Azure DevOps Environment: $name"
    }

    if (-not [string]::IsNullOrWhiteSpace($existing)) {
        Write-Host "Environment exists: $name ($existing)"
        continue
    }

    $body = @{
        name = $name
        description = 'Managed deployment boundary'
    } | ConvertTo-Json -Compress

    $temp = New-TemporaryFile
    try {
        [System.IO.File]::WriteAllText(
            $temp.FullName,
            $body,
            [System.Text.UTF8Encoding]::new($false)
        )
        az devops invoke `
            --organization $Organization `
            --area distributedtask `
            --resource environments `
            --route-parameters project=$Project `
            --http-method POST `
            --in-file $temp.FullName | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create Azure DevOps Environment: $name"
        }
        Write-Host "Created environment: $name"
    }
    finally {
        Remove-Item $temp -Force -ErrorAction SilentlyContinue
    }
}
