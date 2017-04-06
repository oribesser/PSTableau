$userContext = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.split('\')[1]
Write-Verbose "$(Get-Date) [Module]          Running username is $userContext"
Write-Verbose "$(Get-Date) [Module]          Importing module private data"
$sessionConfig = @{}
function GETPD {$MyInvocation.MyCommand.Module.PrivateData}
$tabCmd = (GETPD).TabCmd
$sessionConfig.Url = (GETPD).TabUrl
$sessionConfig.Site = (GETPD).TabSite
$sessionConfig.User = (GETPD).TabUser
Write-Verbose "$(Get-Date) [Module]          Module private data: $($sessionConfig | Out-String)"
Write-Verbose "$(Get-Date) [Module]          Initializing variables"
$cred = Import-Clixml "$PSScriptRoot\Credential\$($sessionConfig.User).xml"
$tabPass =  $cred.GetNetworkCredential().Password
$outFileStd = Join-Path $env:TEMP outputStandard.txt
$outFileErr = Join-Path $env:TEMP outputError.txt

Write-Verbose "$(Get-Date) [Module]          Importing functions"
$public  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1)
$private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1)

foreach ($import in @($Public + $Private))
{
    try
    {
        . $import.fullname
    }
    catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
Export-ModuleMember -Function $public.Basename
Write-Verbose "$(Get-Date) [Module]          Functions imported"
