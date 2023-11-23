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
    [string]$destination,
    [Parameter()]
    [string]$log
)

try {
    # Checks the Posh-SSH module, if not found then installs it
    if (-not (Get-Module Posh-SSH -ListAvailable)) {
        $currentDateTime = Get-Date
        $currentDateTimeString = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $logPath -Value "$currentDateTimeString : Posh-SSH not found, installing NuGet package provider and Posh-SSH module"
        Install-PackageProvider NuGet -Force
        Install-Module Posh-SSH -Confirm:$False -Force
    }

    # If -log is not empty then uses it as the $logName
    $scriptDirectory = $PSScriptRoot
    if ($log -eq "") {
        $logName = "log.txt"
    }
    else {
        $logName = $log
    }
    $logPath = Join-Path -Path $scriptDirectory -ChildPath $fileName

    # Creates $logPath file, if not found
    if (Test-Path -path $logPath) {
        $currentDateTime = Get-Date
        $currentDateTimeString = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $logPath -Value "$currentDateTimeString : $logName found"
    } else {
        $currentDateTime = Get-Date
        $currentDateTimeString = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss")
        Out-File -FilePath $filePath -InputObject "$currentDateTimeString : $fileName created"
    }

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
        $currentDateTime = Get-Date
        $currentDateTimeString = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $logPath -Value "$currentDateTimeString : $path put in $destination"
    } else {
        $currentDateTime = Get-Date
        $currentDateTimeString = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $logPath -Value "$currentDateTimeString : $path not found"
    }
}
catch {
    $currentDateTime = Get-Date
    $currentDateTimeString = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logPath -Value "$currentDateTimeString : An error occurred that could not be resolved"
}