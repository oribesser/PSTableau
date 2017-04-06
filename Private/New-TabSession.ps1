<#
.SYNOPSIS
    Starts a new tabcmd session with parameters from the sessionConfig variable (initialized on module load).
.NOTES
    Ori Besser
#>
function New-TabSession
{
    [CmdletBinding()]
    param 
    (
        [string]$TabUrl = $sessionConfig.Url,
        [string]$TabSite = $sessionConfig.Site,
        [string]$TabUser = $sessionConfig.User,
        [string]$TabPass = $tabPass
    )
    
    $defaultArgs = '--no-certcheck --no-prompt --no-proxy'
    if ($TabSite -eq '')
    {
        $TabSite = '""'
    }
    Write-Verbose "$(Get-Date) [New-TabSession]  running tabcmd login to $TabUrl site $TabSite with the user $TabUser"
    $runArgs = "login -s $TabUrl -t $TabSite -u $TabUser -p $TabPass $defaultArgs"
    $login = Start-Process -FilePath $tabCmd -ArgumentList $runArgs -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outFileStd -RedirectStandardError $outFileErr
    $outStd = Get-Content $outFileStd
    $outErr = Get-Content $outFileErr
    $out = $outStd + $outErr
    if ($login.ExitCode -eq 0)
    {
        Write-Verbose "$(Get-Date) [New-TabSession]  Login command exited with success, output: $out. Logged in as $TabUser to $TabUrl site $TabSite"
        Write-Output $out
    }
    else 
    {
        Write-Verbose "$(Get-Date) [Invoke-TabCmd]   Login command exited with error, output: $out"
        Write-Error "Failed to login as $TabUser `n$outErr" -ErrorAction Stop
    }
}