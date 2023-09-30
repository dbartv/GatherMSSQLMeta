#================================================================================================== 
#Import Server info
#==================================================================================================
Function Import-Server
{
  try 
  {
    $Query = "SELECT 
              [s_id]
            FROM 
              [dbo].[servers]
            WHERE 
              [name] = '$ServerName'"
    $Result = (Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop).s_id
    If($null -eq $Result)
    {
      $Query  = "INSERT INTO [dbo].[servers]
                 ([name])
                 VALUES 
                 ('$ServerName')
                SELECT SCOPE_IDENTITY() AS [s_id];"
      $Result = (Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop).s_id
    } 
  }
  catch 
  {
    Write-Error ($Global:Error[0] | Format-List -Force | Out-String)	
  }
  Return $Result
}
#================================================================================================== 
#Import Instance info
#==================================================================================================
Function Import-Instance
{
  Try
  {
    $Query = "SELECT 
                [s_id]
              FROM
                [dbo].[instances]
              WHERE 
                [s_id] = $Sid AND
                [name] = '$InstanceName'"
    $Result = (Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop).s_id
    If($null -eq $Result)
    {
      $Query = "INSERT INTO [dbo].[instances]
              ([s_id],[name])
              VALUES 
              ($Sid,'$InstanceName')"
      Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
    }
  }
  Catch
  {
    Write-Error ($Global:Error[0] | Format-List -Force | Out-String)	
  }
}
#==================================================================================================
#Get the script start time.
#==================================================================================================
$StartDate = Get-Date
#==================================================================================================
#Set PSDefaultParameterValues
#==================================================================================================
#SQLServer module 22.0.0 introduced a breaking change regarding certificates.
try
{
  $SQLModule = Get-InstalledModule -Name SqlServer -ErrorAction Stop
  $SQLModuleVersion = $SQLModule.Version
  $SqlModuleKey = 'Invoke-SQLCmd:TrustServerCertificate'
  Write-Output "The version number of the SQL module is '$SqlModuleVersion'."
  if($SQLModuleVersion -ge [System.version]'22.0.0')
  {
    #If there's already an entry for 'Invoke-SQLCmd:TrustServerCertificate' set it to true (again)
    if($PSDefaultParameterValues.ContainsKey($SqlModuleKey) -eq $true)
    {
      $PSDefaultParameterValues[$SqlModuleKey]= $true
      Write-Output "The value for $SqlModuleKey is set to 'true'."
    }
    #If there isn't an entry for 'Invoke-SQLCmd:TrustServerCertificate', add one
    else 
    {
      $PSDefaultParameterValues.Add($SqlModuleKey,$True)
      Write-Output "The key $SqlModuleKeyvalue is added with key value:'true'."
    }
  }
  #if the module version is lower then 22, check if the value for 'Invoke-SQLCmd:TrustServerCertificate' must be removed
  elseif($SQLModuleVersion -lt [System.version]'22.0.0')
  {
    if($PSDefaultParameterValues.ContainsKey($SqlModuleKey) -eq $true)
    {
      $PSDefaultParameterValues[$SqlModuleKey]= $true
      Write-Output "The key $SqlModuleKeyvalue is removed because the module version  $SQLModuleVersion  is lower then '22.0.0'."
    }
  }
}
catch 
{
  Throw ("Error: " + ($PsItem.Exception))
}
#==================================================================================================
#Get the script location.
#==================================================================================================
$ScriptLoc = $MyInvocation.MyCommand.Path
$ScriptLoc = $ScriptLoc.Replace($MyInvocation.MyCommand.ToString(), "") #remove the script name from the file path
#================================================================================================== 
#Get variables from the xml file.
#==================================================================================================
try
{
  $XmlLocation    = ($ScriptLoc + "Variables.xml")
  [xml]$Variables = Get-Content $XmlLocation -ErrorAction Stop
  $MetaServerName = $Variables.General.MetaServerName #Name of the where the metadata will be stored
  $MetaDb         = $Variables.General.MetaDb #Name of the database where the data will be stored 
  $Delimiter      = $Variables.General.CsvDelimiter #delimiter used in the csv file 
}
catch 
{
  Throw ("Error: " + ($PsItem.Exception))
}
#================================================================================================== 
#Get the server and instance names from the csv file
#==================================================================================================
$Servers = Import-Csv -Path ($ScriptLoc + "servers.txt") -Delimiter $Delimiter -Header ServerName, InName
#================================================================================================== 
#Add server info.
#==================================================================================================
Foreach ($Server in $Servers)
{
  $ServerName   = $Server.ServerName
  $InstanceName = $Server.InName
  $Sid = Import-Server
  Import-Instance
}
#================================================================================================== 
#Result.
#==================================================================================================
$EndDate = Get-Date
New-TimeSpan -Start $StartDate -End $EndDate