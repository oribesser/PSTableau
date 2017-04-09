<#
.SYNOPSIS
    A wrapper to tabcmd.exe - Tableau CLI
.DESCRIPTION
    A wrapper to tabcmd.exe. It builds the arguments from sessionConfig (initialized on module load) and from the $Arguments parameter.
    It uses Start-Process to invoke tabcmd.exe. Standard error and standard output from tabcmd.exe are transferred to the equivalent PowerShell streams.
    It checks for an existing session state (see Get-SessionXml) and compares it to the session config (the session config is initialized on module load).
    If the session state is different from the session config, it starts a new session, if they are the same it just invokes the command and the session is resumed.
    Enclose the whole argument line with ''. Enclose tabcmd item names with "".
.EXAMPLE
    PS C:\> Invoke-TabCmd -Command refreshextracts -Argumets '--workbook "A Workbook Name" --datasource "datasource" --synchronous'
    Invokes tabcmd.exe with the refreshextracts command and with multiple arguments.
.NOTES
    Ori Besser
#>
function Invoke-TabCmd
{
    [CmdletBinding()]
    param
    (
        # The base tabcmd command, such as 'get' or 'refreshextracts' (can be obtained from 'tabcmd.exe help commands')
        [string]$Command,
        # Arguments of the base command (see 'tabcmd.exe help <a command>'). Enclose items with spaces with "".
        [string]$Arguments,
        # The tableau site. If not stated, the default site is used
        [string]$Site
    )

    if ($Site)
    {
        Write-Verbose "$(Get-Date) [Invoke-TabCmd]   Site parameter is used, updating sessionConfig.Site to $Site"
        $sessionConfig.Site = $Site
    }
    else
    {
        $sessionConfig.Site = ''
    }

    if ($sessionState = Get-SessionXml)
    {
        if (Compare-ObjectProperty $sessionConfig $sessionState)
        {
            Write-Verbose "$(Get-Date) [Invoke-TabCmd]   tabcmd-session.xml values: $($sessionState | Out-String) are different from the sessionConfig values: $($sessionConfig | Out-String) Starting a new session"
            New-TabSession
        }
    }
    else
    {
        Write-Verbose "$(Get-Date) [Invoke-TabCmd]   No tabcmd-session.xml was found, Starting a new session"
        New-TabSession
    }

    $defaultArgs = '--no-certcheck --no-prompt --no-proxy'
    $runArgs = "$($Command.Trim()) $($Arguments.Trim()) $defaultArgs"
    Write-Verbose "$(Get-Date) [Invoke-TabCmd]   Invoking $tabcmd $runArgs"
    $run = Start-Process -FilePath $tabCmd -ArgumentList $runArgs -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outFileStd -RedirectStandardError $outFileErr
    $outStd = Get-Content $outFileStd
    $outErr = Get-Content $outFileErr
    $out = $outStd + $outErr
    if ($run.ExitCode -eq 0)
    {
        Write-Verbose "$(Get-Date) [Invoke-TabCmd]   Command exited with success, output: $out"
        Write-Output $out
    }
    else
    {
        if ($outErr -match 'Cannot sign in')
        {
            Write-Verbose "$(Get-Date) [Invoke-TabCmd]   Not logged in, reconnecting"
            New-TabSession
            Write-Verbose "$(Get-Date) [Invoke-TabCmd]   Invoking $tabcmd $runArgs"
            $run = Start-Process -FilePath $tabCmd -ArgumentList $runArgs -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outFileStd -RedirectStandardError $outFileErr
            $outStd = Get-Content $outFileStd
            $outErr = Get-Content $outFileErr
            $out = $outStd + $outErr
            if ($run.ExitCode -eq 0)
            {
                Write-Verbose "$(Get-Date) [Invoke-TabCmd]   Command exited with success after reconnecting, output: $out"
                Write-Output $out
            }
            else
            {
                Write-Verbose "$(Get-Date) [Invoke-TabCmd]   Command exited with error after reconnecting, output: $out"
                Write-Error "Failed to run tabcmd $Command with the argument $Arguments after reconnecting `n$outErr" -ErrorAction Stop
            }
        }
        else
        {
            Write-Verbose "$(Get-Date) [Invoke-TabCmd]   Command exited with error, output: $out"
            Write-Error "Failed to run tabcmd $Command with the argument $Arguments `n$outErr" -ErrorAction Stop
        }
    }
}