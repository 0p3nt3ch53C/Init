
# Safely get execution policy listing
$INIT_EXECUTION_POLICY = Get-ExecutionPolicy -list

# Set execution policy for current user to bypass only for this script
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass

# Install VSCode Extension via PowerShell
code --install-extension ms-vscode.powershell
code --install-extension ms-python.python
code --install-extension ms-python.debugpy
code --install-extension ms-python.vscode-python-envs
code --install-extension ms-python.vscode-pylance
# Mobile Development
code --install-extension dart-code.dart-code
code --install-extension dart-code.flutter
code --install-extension google.geminicodeassist

$DownloadPath = "~\Downloads"
$Vagrant_Base_URL = "https://releases.hashicorp.com/vagrant/"

function CheckAPIStatusCode {
    param (
        [string]$statuscode
    )
    if ($response.StatusCode -eq "200" ) {
        return $response
    } else {
        return $null
    }
}

function APICall {
    param (
        [string]$url,
        [string]$filepath = $false
    )
    if ($filepath -ne $false) {
        $response = Invoke-WebRequest -Uri $url -outfile $filepath
    } else {
        $response = Invoke-WebRequest -Uri $url
    }
    return CheckAPIStatusCode -response $response
}

$Vagrant_Base_URL_Response = APICall -url $Vagrant_Base_URL

$Newest_Vagrant_Version = ($Vagrant_Base_URL_Response.ParsedHtml.getElementsByTagName('a') | Select-Object nameprop)[1].nameprop

$Vagrant_Filename = (-join("vagrant_",$Newest_Vagrant_Version,"_windows_amd64.msi"))

$ProgressPreference = 'SilentlyContinue' # Allows a faster download speed.
$Vagrant_Installer_URL_Response = APICall -url (-join($Vagrant_Base_URL,$Newest_Vagrant_Version,"/",$Vagrant_Filename)) -filepath "$DownloadPath\$Vagrant_Filename"

$Vagrant_File_Hash = (Get-FileHash "$DownloadPath\$Vagrant_Filename").Hash

$Vagrant_File_Hash_Filename = (-join("vagrant_",$Newest_Vagrant_Version,"_SHA256SUMS"))

# Update to use APICall Function
$Vagrant_Hash_From_Source_URL_Response = APICall -url (-join($Vagrant_Base_URL,$Newest_Vagrant_Version,"\",$Vagrant_File_Hash_Filename)) -filepath "$DownloadPath\$Vagrant_File_Hash_Filename"

if (Select-String -Path $DownloadPath\$Vagrant_File_Hash_Filename -Pattern $Vagrant_File_Hash){ Write-Host "File signature for $Vagrant_Filename verified."}

# Install Vagrant
msiexec /qn /i $Vagrant_Filename /passive /norestart VAGRANTAPPDIR=C:\HashiCorp\Vagrant\

# Install (and / or upgrade) Virtualbox 
winget install Oracle.VirtualBox --silent

# Set execution policy back to original
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $INIT_EXECUTION_POLICY.ExecutionPolicy[3]