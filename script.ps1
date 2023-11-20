# Parameters
param (
    [Parameter()]
    [string]$hostname,
    [Parameter()]
    [string]$login,
    [Parameter()]
    [string]$password,
    [Parameter()]
    [string]$path,
    [Parameter()]
    [string]$destination
)

try {
    # Checks the Posh-SSH module, if not found then installs it
    if (-not (Get-Module Posh-SSH -ListAvailable)) {
        Write-Host "Posh-SSH not found, installing NuGet package provider and Posh-SSH module"
        Install-PackageProvider NuGet -Force
        Install-Module Posh-SSH -Confirm:$False -Force
    }

    if (Test-Connection -TargetName $hostname -IPv4 -Count 1 -Quiet) {

        # Imports the module
        Import-Module Posh-SSH

        # Converting [string] to [securestring]
        $passwordSec = $password | ConvertTo-SecureString -AsPlainText -Force

        # Checking the $FilePath
        if (Test-Path -path $path) {
            # Creates a credential
            $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $login,$passwordSec
            # Creates a session
            $session = New-SFTPSession -ComputerName $hostname -Credential $credential -AcceptKey
            # Copies the source item to the destination
            Set-SFTPItem -Session $session.SessionID -Destination $destination -Path $path -verbose -Force
        } else {
            Write-Host "$path not found"
        }

    } else {
        Write-Host "$hostname not available"
    }
}
catch {
    Write-Host "An error occurred that could not be resolved"
}