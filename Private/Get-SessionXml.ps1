<#
.SYNOPSIS
    Reads url, site and user fields from the Tableu session xml file, accepts path as input, defaults to local appdata\tableau\tabcmd\tabcmd-session.xml
.NOTES
    Ori Besser
#>
function Get-SessionXml
{
    [CmdletBinding()]
    param
    (
        # Path to tabcmd-session.xml
        [string]$Path = (Join-Path $env:LOCALAPPDATA 'Tableau\Tabcmd\tabcmd-session.xml'),
        # Tableau server session timeout in minutes (default is 240)
        [int]$SessionTimeout = 240
    )

    $ErrorActionPreference = 'Stop'
    try
    {
        [xml]$xml = Get-Content $Path
        [datetime]$sessionTime = $xml.session.'updated-at'
        if ($sessionTime -gt (Get-Date).AddMinutes(-$SessionTimeout - 1))
        {
            Write-Verbose "$(Get-Date) [Get-SessionXml]  $Path session time is within the session timeout - $SessionTimeout minutes"
            @{
                'Url' = $xml.session.'base-url'
                'Site' = $xml.session.'site-namespace'
                'User' = $xml.session.username
            }
        }
        else
        {
            Write-Verbose "$(Get-Date) [Get-SessionXml]  $Path session time is past the session timeout - $SessionTimeout minutes, a new session is required"
            return
        }
    }
    catch
    {
        Write-Verbose "$(Get-Date) [Get-SessionXml]  Error getting $Path content: $($_.Exception.Message)"
        return
    }
}