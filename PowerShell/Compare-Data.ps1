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
  Try
  {
    New-Item $LogFile -type file -Force -ErrorAction Stop | out-null
    Add-Content $LogFile "$StartTime`t`t=================================================================================================="
    Add-Content $LogFile ("$StartTime`t`t" + $MyInvocation.MyCommand.Path)
    Add-Content $LogFile "$StartTime`t`t=================================================================================================="
    Add-Content $LogFile "$StartTime`t`t'$LogFile' is created."
  }
  Catch
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
#Get the script location.
#==================================================================================================
$ScriptLoc = $MyInvocation.MyCommand.Path
$ScriptLoc = $ScriptLoc.Replace($MyInvocation.MyCommand.ToString(), "") #remove the script name from the file path
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
  Throw ("Error: " + ($PsItem.Exception))
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
    Write-TerminatingError -FileName $LogFile -Message ("Error: " + ($PsItem.Exception))
  }
}
#==================================================================================================
#Import-Module powershell module(s).
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
    throw ("Error: " + ($PsItem.Exception))
    Write-TerminatingError -FileName $LogFile -ErrorObject $_
  }
}
#==================================================================================================
#Get the server names.
Write-Log -FileName $LogFile -Message "Get the server names."
#==================================================================================================
$Query = "SELECT
            s.[name] AS [server_name],
            i.[name] AS [instance_name],
            i.[i_id]
          FROM  
            [dbo].[servers] s
          INNER JOIN
            [dbo].[instances] i ON i.s_id = s.s_id"
try
{
  $Results = Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
}
catch
{
  Write-TerminatingError -FileName $LogFile -ErrorObject $_
}
#==================================================================================================
#Create datatables.
Write-Log -FileName $LogFile -Message "Create datatables."
#==================================================================================================
$ReachableServers = New-Object system.Data.DataTable  #servers that can be checked
[void]$ReachableServers.Columns.Add("server_name"      ,"System.String")
[void]$ReachableServers.Columns.Add("instance_name"    ,"System.String")
[void]$ReachableServers.Columns.Add("i_id"             ,"System.int64")
[void]$ReachableServers.Columns.Add("full_name"        ,"System.String")

$DtOutPut = New-Object system.Data.DataTable #output anomalies
[void]$DtOutPut.Columns.Add("date"           ,"System.DateTime")
[void]$DtOutPut.Columns.Add("server_name"    ,"System.String")
[void]$DtOutPut.Columns.Add("object_name"    ,"System.String")
[void]$DtOutPut.Columns.Add("column_name"    ,"System.String")
[void]$DtOutPut.Columns.Add("Mdb_value"      ,"System.String")
[void]$DtOutPut.Columns.Add("value"          ,"System.String")
[void]$DtOutPut.Columns.Add("Mdb_Exists"     ,"System.Boolean")
[void]$DtOutPut.Columns.Add("Db_Exists"      ,"System.Boolean")
[void]$DtOutPut.Columns.Add("Is_Unreachable" ,"System.Boolean")
[void]$DtOutPut.Columns.Add("Is_Db"          ,"System.Boolean")

$DtOutput.Columns["date"].DefaultValue  = [System.DateTime]::UtcNow
$DtOutput.Columns["Is_Db"].DefaultValue = $false
#==================================================================================================
#Check if the servers are available.
Write-Log -FileName $LogFile -Message "Check if the servers are available."
#==================================================================================================
#Try to get the name of each SQL server instance that is added to your metadata database (MDB)
$Query  = "SELECT @@SERVERNAME AS [server_name]"
foreach ($Result in $Results)
{
  $ServerName      = $Result.server_name
  $InstanceName    = $Result.instance_name
  [int]$InId       = $Result.i_id
  #If it's a default instance (MSSQLSERVER) only use the server name to connect to the server, else use server and instance name.
  Switch ($InstanceName)
  {
    $null          {$SqlFullName = $ServerName
                    break}
    'MSSQLSERVER'  {$SqlFullName = $ServerName
                    break}
    default        {$SqlFullName = ($ServerName +'\' + $InstanceName)
                    break}
  }
  try
  {
    #When the version number is retrieved, add the server to $ReachableServers, servers in this datatable will be queried to retrieve other info
    Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $SqlFullName -Database master -Query $Query -ErrorAction Stop | Out-Null
    [void]$ReachableServers.Rows.Add($ServerName,$InstanceName,$InId, $SqlFullName)
  }
  catch
  {
    #If we cannot connect to this server, there's no point to try to retrieve other info from this server (this is only for this run)
    Write-Warning "Unable to connect to server '$SqlFullName'."
    Write-Log -FileName $LogFile -Message "Unable to connect to server '$SqlFullName'."
    Write-NonTerminatingError -FileName $LogFile -ErrorObject $_
    [void]$UnReachableServers.Rows.Add($ServerName,$InstanceName, $InId, $SqlFullName)
  }
}
#==================================================================================================
#Check databases info.
Write-Log -FileName $LogFile -Message "Check databases info."
#==================================================================================================
foreach ($ReachableServer in $ReachableServers)
{
  try
  {
    $TableName     = '[dbo].[databases]'
    $Query         = "SELECT * FROM $TableName WHERE i_id = $($ReachableServer.i_id)"
    $MdbResults    = Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop -OutputAs DataTables
    $TableName     = '[sys].[databases]'
    $Query         = "SELECT * FROM sys.databases"
    $ServerResults =  Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $ReachableServer.full_name -Database master -Query $Query -ErrorAction Stop -OutputAs DataTables
    #Output if the database is registered but not found on the server.
    foreach ($MdbResult in $MdbResults)
    {
      if($ServerResults.name -notcontains $MdbResult.name)
      {
        $NewRow             = $DtOutPut.NewRow()
        $NewRow.server_name = $($ReachableServer.full_name)
        $NewRow.object_name = $($MdbResult.name)
        $NewRow.Mdb_Exists  = $true
        $NewRow.Db_Exists   = $false
        $NewRow.Is_Db       = $true
        [void]$DtOutPut.Rows.Add($NewRow)
      }
      else
      {
        $ServerRow      = $ServerResults | Where-Object {$PsItem.name -eq $($MdbResult.name)}
        $ExcludeColumns = @('database_id', 'is_cleanly_shutdown', 'log_reuse_wait_desc', 'log_reuse_wait','create_date', 'service_broker_guid')
        $ColumnNames    = $ServerResults.columns.ColumnName | Where-Object {$ExcludeColumns -notContains $PsItem}
        foreach ($ColumnName in $ColumnNames)
        {
          if ($MdbResult.${columnName}.ToString() -ne $ServerRow.${columnName}.ToString())
          {
            $NewRow             = $DtOutPut.NewRow()
            $NewRow.server_name = $($ReachableServer.full_name)
            $NewRow.object_name = $($MdbResult.name)
            $NewRow.column_name = $ColumnName
            $NewRow.Mdb_value   = $($MdbResult.${columnName}.ToString())
            $NewRow.value       = $($ServerRow.${columnName}.ToString())
            $NewRow.Is_Db       = $true
            [void]$DtOutPut.Rows.Add($NewRow)
          }
        }
      }
    }
    #Output if the database isn't registered but is found on the server.
    $TableName     = '[dbo].[databases]'
    $Query         = "SELECT * FROM $TableName WHERE i_id = $($ReachableServer.i_id)" #excute query again but now get databases with all operational statuses
    $MdbResults    = Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop -OutputAs DataTables
    foreach ($Result in $ServerResults)
    {
      if($MdbResults.name -notcontains $Result.name)
      {
        $NewRow             = $DtOutPut.NewRow()
        $NewRow.server_name = $($ReachableServer.full_name)
        $NewRow.object_name = $($Result.name)
        $NewRow.Mdb_Exists  = $false
        $NewRow.Db_Exists   = $true
        $NewRow.Is_Db       = $true
        [void]$DtOutPut.Rows.Add($NewRow)
      }
    }
  }
  catch
  {
    Write-Log -FileName $LogFile -Message "Error while executing 'Check databases info' on '$($ReachableServer.server_name)'."
    Write-NonTerminatingError -FileName $LogFile -Message ("Error: " + ($PsItem.Exception))
  }
}
#==================================================================================================
#Output the datatable.
Write-Log -FileName $LogFile -Message "Output the datatable."
#==================================================================================================
$DtOutPut | Out-GridView
#================================================================================================== 
#End of script.
Write-Log -FileName $LogFile -Message "End of script."
#==================================================================================================
$EndDate = Get-Date
New-TimeSpan -Start $StartDate -End $EndDate