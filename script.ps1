# Checks the Posh-SSH module, if not found then installs it
if(-not (Get-Module Posh-SSH -ListAvailable))
{
    Install-PackageProvider NuGet -Force
    Install-Module Posh-SSH -Confirm:$False -Force
}

# Imports the module
Import-Module Posh-SSH

# Variables for the script
$server = $args[0]
$username = $args[1]
$password = $args[2] | ConvertTo-SecureString -AsPlainText -Force
$FilePath = $args[3]
$SFTPPath = $args[4]

# Creates a credential
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password

# Creates a session
$session = New-SFTPSession -ComputerName $server -Credential $credential -AcceptKey

# Copies the source item to the destination
Set-SFTPItem -Session $session.SessionID -Destination $SFTPPath -Path $FilePath -verbose -Force