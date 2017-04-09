# PSTableau
A PowerShell module for Tableau. Currently a wrapper to tabcmd

This module is a wrapper to Tableau tabcmd.exe command line tool.
Its purpose is to provide an easy and consistent way to run it with PowerShell for better automation:
  * Handles tabcmd session state by reading its tabcmd-sesion.xml file and creating a new session only when necessary
  * Redirects tabcmd standard and error outputs to the appropriate PowerShell streams.
  

