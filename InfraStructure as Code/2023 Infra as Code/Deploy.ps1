param(
    [boolean] $login  =  $false,
    [string] $tenant,
    [string] $sub,
    [boolean] $Plan = $true,
    [boolean] $Apply = $false
)
if ($login) {
    Connect-AzAccount -Tenant $tenant

    Set-AzContext -Tenant $tenant -Subscription $sub

    az login --tenant $tenant

}

if ($Plan) {
    terraform.exe plan
}

if ($Apply) {
    terraform.exe apply
}

if ($Apply -and $Plan){
    Write-Host 'Please make up your mind!' -ForegroundColor Blue
}