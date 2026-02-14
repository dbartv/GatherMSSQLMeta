#==================================================================================================
#Define Log file variables.
#==================================================================================================
#Get the script name, remove .ps1 extention
$ScriptName = ($MyInvocation.MyCommand.Name.Split("."))[0]
$ScriptLoc  = $MyInvocation.MyCommand.Path
$ScriptLoc  = $ScriptLoc.Replace($MyInvocation.MyCommand.ToString(), "") #remove the script name from the file path
#==================================================================================================
#Create the log file.
#Write-Output "Create the log file."
#==================================================================================================
if (($LogFile -eq "") -or ($null -eq $LogFile))
{
  $LogFile = ((Split-Path $ScriptLoc -Parent) + "\Log\" + $ScriptName + "\" + (Get-Date -Format yyyy-MM-dd-HH-mm-ss-ffff) + ".Log")
}
$StartTime = Get-Date
if ((Test-Path $LogFile) -eq $true)
{
  Clear-Content $LogFile
  Add-Content $LogFile "$StartTime`t`t=================================================================================================="
  Add-Content $LogFile ("$StartTime`t`t" + $MyInvocation.MyCommand.Path)
  Add-Content $LogFile "$StartTime`t`t=================================================================================================="
  Add-Content $LogFile ("`t`t`t`t'$LogFile' already exists, additionally logging will be added.")
}
else
{
  try
  {
    New-Item $LogFile -type file -Force -ErrorAction Stop | out-null
    Add-Content $LogFile "$StartTime`t`t=================================================================================================="
    Add-Content $LogFile ("$StartTime`t`t" + $MyInvocation.MyCommand.Path)
    Add-Content $LogFile "$StartTime`t`t=================================================================================================="
    Add-Content $LogFile "$StartTime`t`t'$LogFile' is created."
  }
  catch
  {
    Write-Error ("Error: " + ($PsItem.Exception))
    Exit 
  }
}
#================================================================================================== 
#Get variables from the xml file.
#==================================================================================================
try
{
  $XmlLocation    = ".\Variables.xml"
  [xml]$Variables = Get-Content $XmlLocation -ErrorAction Stop
  $MetaServerName = $Variables.General.MetaServerName #Name of the where the metadata will be stored
  $MetaDb         = $Variables.General.MetaDb #Name of the database where the data will be stored 
  $ModuleInfo     = $Variables.General.ModuleInfo
}
catch 
{
  throw ("Error: " + ($PsItem.Exception))
}
#==================================================================================================
#Define extra variables.
#Write-Output "Define extra variables."
#==================================================================================================
$TargetFolder = 'c:\temp\Dataminds\'
#==================================================================================================
#Add the module files to an arraylist.
#==================================================================================================
$Modules = New-Object System.Collections.ArrayList
foreach ($item in $ModuleInfo.ModuleFile)
{
  try 
  {
    [void]$Modules.Add("$($ScriptLoc)$($item)")
  }
  catch 
  {
    throw ("Error: " + ($PsItem.Exception))
    Write-TerminatingError -FileName $LogFile -Message ("Error: " + ($PsItem.Exception))
  }
}
#==================================================================================================
#Import-Module module(s).
#==================================================================================================
foreach($Module in $Modules)
{
  try
  {
    Import-Module -Name $Module -Force -ErrorAction Stop 
    Write-Log -FileName $LogFile -Message "The module $Module is imported."
  }
  catch
  {
    Write-TerminatingError -FileName $LogFile -ErrorObject $_
  }
}
#==================================================================================================
#Check if the folder exists.
Write-Log -FileName $LogFile -Message "Check if the folder exists."
#==================================================================================================
try 
{
  $Return = Test-Path $TargetFolder
  if($Return -eq $true)
  {
    Write-Log -FileName $LogFile -Message "Folder $TargetFolder exists."
  }
  elseif($Return -eq $false)
  {
    Write-Log -FileName $LogFile -Message "Folder $TargetFolder should be created."
  }
  else 
  {
    Write-LogicalError "$Return is an unexpected value for this variable. A boolean type was expected."
  }
}
catch 
{
  Write-TerminatingError -FileName $LogFile -ErrorObject $_
}
#==================================================================================================
#If needed create the folder.
Write-Log -FileName $LogFile -Message "If needed create the folder."
#==================================================================================================
if($Return -eq $false)
{
  try 
  {
    New-Item -Path $TargetFolder -ItemType Directory -ErrorAction Stop
    Write-Log -FileName $LogFile -Message "Folder $TargetFolder is created."
  }
  catch 
  {
    Write-TerminatingError -FileName $LogFile -ErrorObject $_
  }
}
#==================================================================================================
#Create the file.
Write-Log -FileName $LogFile -Message "If needed create the folder."
#==================================================================================================
if($Return -eq $false)
{
  try 
  {
    New-Item -Path $TargetFolder -ItemType Directory -ErrorAction Stop
    Write-Log -FileName $LogFile -Message "Folder $TargetFolder is created."
  }
  catch 
  {
    Write-TerminatingError -FileName $LogFile -ErrorObject $_
  }
}