#==================================================================================================
#Function: Write to a log file.
#================================================================================================== 
function Write-Log
{
  [CmdletBinding()]
  Param
  (
    #LogfileName"
    [Parameter(Mandatory=$true)] [string]$FileName,      
    #Log message
    [Parameter(Mandatory=$true)] [string]$Message
  )
  try
  {
    $Date = Get-Date -format "dd/MM/yyyy HH:mm:ss"
    Add-Content -Path $FileName "$Date`t`t$Message"
  }
  catch
  {
    throw
  }
}
#==================================================================================================
#function: Write a terminating logical error message to the log file.
#==================================================================================================
function Write-LogicalError
{
  [CmdletBinding()]
  Param
  (
    #LogfileName"
    [Parameter(Mandatory=$true)] [string]$FileName,      
    #Log message
    [Parameter(Mandatory=$true)] [string]$Message
  )
  try
  {
    $Locations = (Get-PSCallStack).Location | Where-Object {$PsItem -ne '<No file>'}
    $Date      = Get-Date -format "dd/MM/yyyy HH:mm:ss"
    foreach ($Location in $Locations)
    {
      $Date = Get-Date -format "dd/MM/yyyy HH:mm:ss"
      Add-Content -Path $FileName "$Date`t`t$Location"
    }
    Add-Content -Path $FileName "$Date`t`t$Message"
    Exit
  }
  catch
  {
    throw
  }
}
#==================================================================================================
#function: Write a non terminating error message to the log file.
#================================================================================================== 
function Write-NonTerminatingError
{
  [CmdletBinding()]
  Param
  (
    #LogfileName"
    [Parameter(Mandatory=$true)] [string]$FileName,      
    #Object that contains the error
    [Parameter(Mandatory=$true)] [System.Object]$ErrorObject
  )
  try
  {
    $Date = Get-Date -format "dd/MM/yyyy HH:mm:ss"
    Add-Content -Path $FileName "$Date`t`t$Message"
    Add-Content -Path $FileName -Value ($ErrorObject | Format-List -Force | Out-String)  
  }
  catch
  {
    throw
  }
}
#==================================================================================================
#function: Write a terminating error message to the log file.
#================================================================================================== 
function Write-TerminatingError
{
  [CmdletBinding()]
  Param
  (
    #LogfileName"
    [Parameter(Mandatory=$true)] [string]$FileName,      
    #Object that contains the error
    [Parameter(Mandatory=$true)] [System.Object]$ErrorObject
  )
  try
  {
    $Date = Get-Date -format "dd/MM/yyyy HH:mm:ss"
    Add-Content -Path $FileName -Value "$date"
    Add-Content -Path $FileName -Value ($ErrorObject | Format-List -Force | Out-String)
    Exit
  }
  catch
  {
    throw
  }
}
<#
catch {
  Write-TerminatingError -FileName $LogFile -Message $_
}
#>