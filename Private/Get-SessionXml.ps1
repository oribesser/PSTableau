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
        [string]$Path = (Join-Path $env:LOCALAPPDATA 'Tableau\Tabcmd\tabcmd-session.xml')
    )

    if ([xml]$xml = Get-Content $Path -ErrorAction SilentlyContinue)
    {
        @{
            'Url' = $xml.session.'base-url'
            'Site' = $xml.session.'site-namespace'
            'User' = $xml.session.username
        }
    }
    else
    {
        return
    }
}
