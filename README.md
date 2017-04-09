# PSTableau
A PowerShell module for Tableau. Currently a wrapper to tabcmd

This module is a wrapper to Tableau tabcmd.exe command line tool.
Its purpose is to provide an easy, secure and consistent way to run it with PowerShell for better automation:
  * Handles tabcmd session state by reading its tabcmd-sesion.xml file and creating a new session only when necessary.
  * Uses a pre-encrypted user credential to generate the PSCredential object and pass it to tabcmd.
  * Redirects tabcmd standard and error outputs to the appropriate PowerShell streams.

## How to use

The module requires the following to be prepared before use:
  * Generate a credential file, it must be generated in the context of the same user and the same computer that will run the PowerShell commands:
```powershell
Get-Credetntial | Export-CliXml \modulepath\Credential\username.xml
```
  * In the module manifest's PrivateData section, set the values for:
    * tabcmd.exe path.
    * Tableau server URL.
    * An optional default Site to log on to.
    * A username to authenticate with.

```powershell
PrivateData = @{

  PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

    TabUrl = 'https://tableauserver' # The tableau server URL.
    TabSite = '' # Leave it like this to default to the default site.
    TabCmd = 'C:\Program Files\Tableau\Tableau Server\10.1\bin\tabcmd.exe' # Path to tabcmd.exe.
    TabUser = 'username' # The username to authenticate with, must be the same as the username.xml that was pre-created.

} # End of PrivateData hashtable
```


## Examples
Invoke tabcmd.exe with the refreshextracts command and with multiple arguments.
Enclose the whole argument line with ''. Enclose tabcmd item names with "".
```powershell
Invoke-TabCmd -Command refreshextracts -Argumets '--workbook "A Workbook Name" --datasource "datasource" --synchronous'
```
Invoke tabcmd.exe with the get command
```powershell
Invoke-TabCmd -Command get -Arguments '"/workbooks/workbook.twb" -f "\\server\share\workbook.twbx"'
```



*I assume that ultimately, the right way to do all of this would be to use the REST API. Meanwhile, this one does the job.*
