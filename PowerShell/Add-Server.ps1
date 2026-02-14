#================================================================================================== 
#Import Server info
#==================================================================================================
function Import-Server
{
  try 
  {
    $Query = "SELECT 
              [s_id]
            FROM 
              [dbo].[servers]
            WHERE 
              [name] = '$ServerName'"
    $Result = (Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop).s_id
    #Only insert if not already present, otherwise return the server id.
    if($null -eq $Result) 
    {
      $Query  = "INSERT INTO [dbo].[servers]
                 ([name]) VALUES ('$ServerName')
                 SELECT SCOPE_IDENTITY() AS [s_id];"
      $Result = (Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop).s_id
    } 
  }
  catch 
  {
    Write-TerminatingError -FileName $LogFile -ErrorObject $_
  }
  Return $Result
}
#================================================================================================== 
#Import Instance info
#==================================================================================================
function Import-Instance
{
  try
  {
    $Query = "SELECT 
                [s_id]
              FROM
                [dbo].[instances]
              WHERE 
                [s_id] = $Sid AND
                [name] = '$InstanceName'"
    $Result = (Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop).s_id
    #Only insert if not already present.
    if($null -eq $Result)
    {
      $Query = "INSERT INTO [dbo].[instances]
                  ([s_id],[name])
                VALUES 
                  ($Sid,'$InstanceName')"
      Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
    }
  }
  catch
  {
    Write-Error ($Global:Error[0] | Format-List -Force | Out-String)	
  }
}
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
#Get the script start time.
#==================================================================================================
$StartDate = Get-Date
#================================================================================================== 
#Get variables from the xml file.
#==================================================================================================
try
{
  $XmlLocation    = ".\Variables.xml"
  [xml]$Variables = Get-Content $XmlLocation -ErrorAction Stop
  $MetaServerName = $Variables.General.MetaServerName #Name of the where the metadata will be stored
  $MetaDb         = $Variables.General.MetaDb #Name of the database where the data will be stored 
  $Delimiter      = $Variables.General.CsvDelimiter #delimiter used in the csv file 
  $ModuleInfo     = $Variables.General.ModuleInfo
}
catch 
{
  throw ("Error: " + ($PsItem.Exception))
}
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
#Read the csv file.
Write-Log -FileName $LogFile -Message "Read the csv file."
#==================================================================================================
try 
{
  $Servers = Import-Csv -Path (".\servers.txt") -Delimiter $Delimiter -Header ServerName, InName
}
catch 
{
  Write-TerminatingError -FileName $LogFile -ErrorObject $_
}
#================================================================================================== 
#Add data to [dbo].[servers].
Write-Log -FileName $LogFile -Message "Add server info."
#==================================================================================================
foreach ($Server in $Servers)
{
  $ServerName   = $Server.ServerName
  $InstanceName = $Server.InName
  Write-Log -FileName $LogFile -Message "Import server $ServerName."
  $Sid = Import-Server
  Write-Log -FileName $LogFile -Message "$Sid is the id of imported server $ServerName."
  Write-Log -FileName $LogFile -Message "Import instance info for $ServerName."
  Import-Instance
  Write-Log -FileName $LogFile -Message "Instance info is imported for $ServerName."
}
#================================================================================================== 
#End of script.
Write-Log -FileName $LogFile -Message "End of script."
#==================================================================================================
$EndDate = Get-Date
New-TimeSpan -Start $StartDate -End $EndDate