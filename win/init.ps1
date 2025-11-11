
# Safely get execution policy listing
$INIT_EXECUTION_POLICY = Get-ExecutionPolicy -list

# Set execution policy for current user to bypass only for this script
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass

$DownloadPath = "~\Downloads"
$Vagrant_Base_URL = "https://releases.hashicorp.com/vagrant/"

function APICall {
    param (
        [string]$url
    )
    $response = Invoke-WebRequest -Uri $url
    if ($response.StatusCode -eq "200" ) {
        return $response
    }else {
        return $null
    }
}

$Vagrant_Base_URL_Response = APICall -url $Vagrant_Base_URL



$Newest_Vagrant_Version = ($Vagrant_Base_URL_Response.ParsedHtml.getElementsByTagName('a') | Select-Object nameprop)[1].nameprop

$Vagrant_Filename = (-join("vagrant_",$Newest_Vagrant_Version,"_windows_amd64.msi"))

$ProgressPreference = 'SilentlyContinue' # Allows a faster download speed.
Invoke-WebRequest -Uri (-join($Vagrant_Base_URL,$Newest_Vagrant_Version,"/",$Vagrant_Filename)) -outfile "$DownloadPath\$Vagrant_Filename"
# As needed, check download status:  $Vagrant_Download_Status = $?

$Vagrant_File_Hash = (Get-FileHash "$DownloadPath\$Vagrant_Filename").Hash

$Vagrant_File_Hash_Filename = (-join("vagrant_",$Newest_Vagrant_Version,"_SHA256SUMS"))

Invoke-WebRequest -Uri (-join($Vagrant_Base_URL,$Newest_Vagrant_Version,"\",$Vagrant_File_Hash_Filename)) -outfile "$DownloadPath\$Vagrant_File_Hash_Filename"
# As needed, check download status: $Vagrant_File_Hash_Download_Status = $?

if (Select-String -Path $DownloadPath\$Vagrant_File_Hash_Filename -Pattern $Vagrant_File_Hash){ Write-Host "File signature for $Vagrant_Filename verified."}

# Install Vagrant
msiexec /qn /i $Vagrant_Filename /passive /norestart VAGRANTAPPDIR=C:\HashiCorp\Vagrant\

# Install (and / or upgrade) Virtualbox 
winget install Oracle.VirtualBox --silent

# Set execution policy back to original
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $INIT_EXECUTION_POLICY.ExecutionPolicy[3]