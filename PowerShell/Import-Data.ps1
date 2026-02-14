#==================================================================================================
#Function: Bulk insert data into $MetaDb
#==================================================================================================
Function Import-Bulk ($TableName, $Query, $SqlFullName,$Database)
{
  try
  {
    #Retrieve the data from SQL Server    
    $DataTable  = Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $SqlFullName -Database $Database -Query $Query -ErrorAction Stop -OutputAs DataTables
    if($null -ne $DataTable) #Write it to $MetaDb
    {
      $cn = new-object System.Data.SqlClient.SqlConnection(('Data Source={0};Integrated Security=SSPI;Initial Catalog={1}' -f $MetaServerName, $MetaDb))
      $cn.Open()
      $bc  = new-object ('System.Data.SqlClient.SqlBulkCopy') $cn
      $bc.DestinationTableName = $TableName
      $bc.WriteToServer($DataTable)
      $cn.Close()
    }
  }
  catch
  {
    Write-TerminatingError -FileName $LogFile -ErrorObject $_
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
  $Schema         = $Variables.General.OutputSchema
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
#Get the server names from $MetaDb.
Write-Log -FileName $LogFile -Message "Get the server names from $MetaDb."
#==================================================================================================
$Query = 'SELECT 
	          s.[name]    AS [server_name],
	          i.[name]    AS [instance_name],
            i.[i_id] 
          FROM  
            [dbo].[servers] s 
          INNER JOIN 
            [dbo].[instances] i ON i.s_id = s.s_id'
try
{
  $Results = Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
}
catch
{
  Write-Error ($Global:Error[0] | Format-List -Force | Out-String)	
}
#================================================================================================== 
#Create datatables.
Write-Log -FileName $LogFile -Message "Create datatables."
#==================================================================================================
$ReachableServers = New-Object system.Data.DataTable 
[void]$ReachableServers.Columns.Add("server_name"     ,"System.String")
[void]$ReachableServers.Columns.Add("instance_name"   ,"System.String")
[void]$ReachableServers.Columns.Add("instance_version", "System.int64")
[void]$ReachableServers.Columns.Add("i_id"            ,"System.int64")
[void]$ReachableServers.Columns.Add("full_name"       ,"System.String")

$UnReachableServers = New-Object system.Data.DataTable 
[void]$UnReachableServers.Columns.Add("server_name"  ,"System.String")
[void]$UnReachableServers.Columns.Add("instance_name", "System.String")
[void]$UnReachableServers.Columns.Add("i_id"         ,"System.int64")
[void]$UnReachableServers.Columns.Add("full_name"    ,"System.String")
#================================================================================================== 
#Check if the servers are available.
Write-Log -FileName $LogFile -Message "Check if the servers are available."
#==================================================================================================
#Try to get the version for each  SQL server instance that is added to your metadata database (MDB)
$Query = "SELECT 
          CASE
            WHEN  SERVERPROPERTY('ProductMajorVersion')  = '13' THEN 2016
            WHEN  SERVERPROPERTY('ProductMajorVersion')  = '14' THEN 2017 
            WHEN  SERVERPROPERTY('ProductMajorVersion')  = '15' THEN 2019 
            WHEN  SERVERPROPERTY('ProductMajorVersion')  = '16' THEN 2022 
            WHEN  SERVERPROPERTY('ProductMajorVersion')  = '17' THEN 2025
          END AS  [ProductVersion]"
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
    [int]$Version= (Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $SqlFullName -Database master -Query $Query -ErrorAction Stop).ProductVersion
    [void]$ReachableServers.Rows.Add($ServerName,$InstanceName,$Version, $InId, $SqlFullName)
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
#Truncate table '[$schema].[sysjobs]'.
Write-Log -FileName $LogFile -Message "Truncate table '[$schema].[sysjobs]'."
#==================================================================================================
$TableName = "[$schema].[sysjobs]"
$Query     = "TRUNCATE TABLE $TableName"
try 
{
  Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
  Write-Log -FileName $LogFile -Message "Table $TableName is truncated."
}
catch 
{
  Write-TerminatingError -FileName $LogFile -ErrorObject $_	
}
#================================================================================================== 
#Upload jobs info.
Write-Log -FileName $LogFile -Message "Upload jobs info."
#==================================================================================================
foreach ($Result in $ReachableServers)
{
  $SqlFullName     = $Result.full_name
  [int]$InId       = $Result.i_id
  #Retrieve the information from System view msdb.[dbo].[sysjobs_view] 
  $Query      = "SELECT null as [jv_id], $InId AS [i_id],  t.* FROM [dbo].[sysjobs_view] t"
  Import-Bulk $TableName $Query $SqlFullName 'msdb'
  Write-Log -FileName $LogFile -Message "Imported data for Server: $SqlFullName table: $TableName"
}
#================================================================================================== 
#Truncate table '[$schema].[configurations]'.
Write-Log -FileName $LogFile -Message "Truncate table '[$schema].[configurations]'."
#==================================================================================================
$TableName = "[$schema].[configurations]"
$Query     = "TRUNCATE TABLE $TableName"
try 
{
  Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
  Write-Log -FileName $LogFile -Message "Table '$TableName' is truncated."
}
catch 
{
  Write-TerminatingError -FileName $LogFile -ErrorObject $_
}
#================================================================================================== 
#Upload configurations info.
Write-Log -FileName $LogFile -Message "Upload configurations info."
#==================================================================================================
foreach ($Result in $ReachableServers)
{
  $SqlFullName     = $Result.full_name
  [int]$InId       = $Result.i_id
  #Retrieve the information from System view master.[sys].[configurations] 
  $Query      = "SELECT null as [db_id], $InId AS [i_id],  t.* FROM [sys].[configurations] t"
  Import-Bulk $TableName $Query $SqlFullName 'master'
  Write-Log -FileName $LogFile -Message "Imported data for Server: $SqlFullName table: $TableName"
}
#================================================================================================== 
#Get SERVERPROPERTY info.
Write-Log -FileName $LogFile -Message "Get SERVERPROPERTY info."
#==================================================================================================
#Query to select all the serverproperties 
$Query = "SELECT 
	          COALESCE ((SERVERPROPERTY('BuildClrVersion')),'NULL')                    AS [BuildClrVersion],
            COALESCE ((SERVERPROPERTY('Collation')),'NULL')                          AS [Collation],
            COALESCE ((SERVERPROPERTY('CollationID')),'NULL')                        AS [CollationID],
            COALESCE ((SERVERPROPERTY('ComparisonStyle')),'NULL')                    AS [ComparisonStyle],
            COALESCE ((SERVERPROPERTY('ComputerNamePhysicalNetBIOS')),'NULL')        AS [ComputerNamePhysicalNetBIOS],
            COALESCE ((SERVERPROPERTY('Edition')),'NULL')                            AS [Edition],
            COALESCE ((SERVERPROPERTY('EditionID')),'NULL')                          AS [EditionID],
            COALESCE ((SERVERPROPERTY('EngineEdition')),'NULL')                      AS [EngineEdition],
            COALESCE ((SERVERPROPERTY('FilestreamConfiguredLevel')),'NULL')          AS [FilestreamConfiguredLevel],
            COALESCE ((SERVERPROPERTY('FilestreamEffectiveLevel')),'NULL')           AS [FilestreamEffectiveLevel],
            COALESCE ((SERVERPROPERTY('FilestreamShareName')),'NULL')                AS [FilestreamShareName],
            COALESCE ((SERVERPROPERTY('HadrManagerStatus')),'NULL')                  AS [HadrManagerStatus],
            COALESCE ((SERVERPROPERTY('InstanceDefaultBackupPath')),'NULL')          AS [InstanceDefaultBackupPath],
            COALESCE ((SERVERPROPERTY('InstanceDefaultDataPath')),'NULL')            AS [InstanceDefaultDataPath],
            COALESCE ((SERVERPROPERTY('InstanceDefaultLogPath')),'NULL')             AS [InstanceDefaultLogPath],
            COALESCE ((SERVERPROPERTY('InstanceName')),'NULL')                       AS [InstanceName],
            COALESCE ((SERVERPROPERTY('IsAdvancedAnalyticsInstalled')),'NULL')       AS [IsAdvancedAnalyticsInstalled],
            COALESCE ((SERVERPROPERTY('IsBigDataCluster')),'NULL')                   AS [IsBigDataCluster],
            COALESCE ((SERVERPROPERTY('IsClustered')),'NULL')                        AS [IsClustered],
            COALESCE ((SERVERPROPERTY('IsExternalAuthenticationOnly')),'NULL')       AS [IsExternalAuthenticationOnly],
            COALESCE ((SERVERPROPERTY('IsExternalGovernanceEnabled')),'NULL')        AS [IsExternalGovernanceEnabled],
            COALESCE ((SERVERPROPERTY('IsFullTextInstalled')),'NULL')                AS [IsFullTextInstalled],
            COALESCE ((SERVERPROPERTY('IsHadrEnabled')),'NULL')                      AS [IsHadrEnabled],
            COALESCE ((SERVERPROPERTY('IsIntegratedSecurityOnly')),'NULL')           AS [IsIntegratedSecurityOnly],
            COALESCE ((SERVERPROPERTY('IsLocalDB')),'NULL')                          AS [IsLocalDB],
            COALESCE ((SERVERPROPERTY('IsPolyBaseInstalled')),'NULL')                AS [IsPolyBaseInstalled],
            COALESCE ((SERVERPROPERTY('IsServerSuspendedForSnapshotBackup')),'NULL') AS [IsServerSuspendedForSnapshotBackup],
            COALESCE ((SERVERPROPERTY('IsSingleUser')),'NULL')                       AS [IsSingleUser],
            COALESCE ((SERVERPROPERTY('IsTempDbMetadataMemoryOptimized')),'NULL')    AS [IsTempDbMetadataMemoryOptimized],
            COALESCE ((SERVERPROPERTY('IsXTPSupported')),'NULL')                     AS [IsXTPSupported],
            COALESCE ((SERVERPROPERTY('LCID')),'NULL')                               AS [LCID],
            COALESCE ((SERVERPROPERTY('LicenseType')),'NULL')                        AS [LicenseType],
            COALESCE ((SERVERPROPERTY('MachineName')),'NULL')                        AS [MachineName],
            COALESCE ((SERVERPROPERTY('NumLicenses')),'NULL')                        AS [NumLicenses],
            COALESCE ((SERVERPROPERTY('PathSeparator')),'')                          AS [PathSeparator],
            COALESCE ((SERVERPROPERTY('ProcessID')),'NULL')                          AS [ProcessID],
            COALESCE ((SERVERPROPERTY('ProductBuild')),'NULL')                       AS [ProductBuild],
            COALESCE ((SERVERPROPERTY('ProductBuildType')),'NULL')                   AS [ProductBuildType],
            COALESCE ((SERVERPROPERTY('ProductLevel')),'NULL')                       AS [ProductLevel],
            COALESCE ((SERVERPROPERTY('ProductMajorVersion')),'NULL')                AS [ProductMajorVersion],
            COALESCE ((SERVERPROPERTY('ProductMinorVersion')),'NULL')                AS [ProductMinorVersion],
            COALESCE ((SERVERPROPERTY('ProductUpdateLevel')),'NULL')                 AS [ProductUpdateLevel],
            COALESCE ((SERVERPROPERTY('ProductUpdateReference')),'NULL')             AS [ProductUpdateReference],
            COALESCE ((SERVERPROPERTY('ProductVersion')),'NULL')                     AS [ProductVersion],
            COALESCE ((SERVERPROPERTY('ResourceLastUpdateDateTime')),'NULL')         AS [ResourceLastUpdateDateTime],
            COALESCE ((SERVERPROPERTY('ResourceVersion')),'NULL')                    AS [ResourceVersion],
            COALESCE ((SERVERPROPERTY('ServerName')),'NULL')                         AS [ServerName],
            COALESCE ((SERVERPROPERTY('SqlCharSet')),'NULL')                         AS [SqlCharSet],
            COALESCE ((SERVERPROPERTY('SqlCharSetName')),'NULL')                     AS [SqlCharSetName],
            COALESCE ((SERVERPROPERTY('SqlSortOrder')),'NULL')                       AS [SqlSortOrder],
            COALESCE ((SERVERPROPERTY('SqlSortOrderName')),'NULL')                   AS [SqlSortOrderName],
            COALESCE ((SERVERPROPERTY('SuspendedDatabaseCount')),'NULL')             AS [SuspendedDatabaseCount]"
foreach ($Result in $ReachableServers)
{
  $SqlFullName = $Result.full_name
  [int]$InId   = $Result.i_id
  $Data = Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $SqlFullName -Database master -Query $Query -ErrorAction Stop 
  #Call the stored procedure [dbo].[update_serverproperties]  to update the properties of the instance in MDB.[dbo].[instances]
  $Update = "EXEC [dbo].[update_serverproperties] 
               @i_id                               =  $InId
              ,@BuildClrVersion                    = '$($Data.BuildClrVersion)'
              ,@Collation                          = '$($Data.Collation)'
              ,@CollationID                        =  $($Data.CollationID)
              ,@ComparisonStyle                    =  $($Data.ComparisonStyle)
              ,@ComputerNamePhysicalNetBIOS        = '$($Data.ComputerNamePhysicalNetBIOS)'
              ,@Edition                            = '$($Data.Edition)'
              ,@EditionID                          =  $($Data.EditionID)
              ,@EngineEdition                      =  $($Data.EngineEdition)
              ,@FilestreamConfiguredLevel          =  $($Data.FilestreamConfiguredLevel)
              ,@FilestreamEffectiveLevel           =  $($Data.FilestreamEffectiveLevel)
              ,@FilestreamShareName                = '$($Data.FilestreamShareName)'
              ,@HadrManagerStatus                  =  $($Data.HadrManagerStatus)
              ,@InstanceDefaultBackupPath          = '$($Data.InstanceDefaultBackupPath)'
              ,@InstanceDefaultDataPath            = '$($Data.InstanceDefaultDataPath)'
              ,@InstanceDefaultLogPath             = '$($Data.InstanceDefaultLogPath)'
              ,@InstanceName                       = '$($Data.InstanceName)'
              ,@IsAdvancedAnalyticsInstalled       =  $($Data.IsAdvancedAnalyticsInstalled)
              ,@IsBigDataCluster                   =  $($Data.IsBigDataCluster)
              ,@IsClustered                        =  $($Data.IsClustered)
              ,@IsExternalAuthenticationOnly       =  $($Data.IsExternalAuthenticationOnly)
              ,@IsExternalGovernanceEnabled        =  $($Data.IsExternalGovernanceEnabled)
              ,@IsFullTextInstalled                =  $($Data.IsFullTextInstalled)
              ,@IsHadrEnabled                      =  $($Data.IsHadrEnabled)
              ,@IsIntegratedSecurityOnly           =  $($Data.IsIntegratedSecurityOnly)
              ,@IsLocalDB                          =  $($Data.IsLocalDB)
              ,@IsPolyBaseInstalled                =  $($Data.IsPolyBaseInstalled)
              ,@IsServerSuspendedForSnapshotBackup =  $($Data.IsServerSuspendedForSnapshotBackup)
              ,@IsSingleUser                       =  $($Data.IsSingleUser)
              ,@IsTempDbMetadataMemoryOptimized    =  $($Data.IsTempDbMetadataMemoryOptimized)
              ,@IsXTPSupported                     =  $($Data.IsXTPSupported)
              ,@LCID                               =  $($Data.LCID)
              ,@LicenseType                        = '$($Data.LicenseType)'
              ,@MachineName                        = '$($Data.MachineName)'
              ,@NumLicenses                        =  $($Data.NumLicenses)
              ,@PathSeparator                      = '$($Data.PathSeparator)'
              ,@ProcessID                          =  $($Data.ProcessID)
              ,@ProductBuild                       = '$($Data.ProductBuild)'
              ,@ProductBuildType                   = '$($Data.ProductBuildType)'
              ,@ProductLevel                       = '$($Data.ProductLevel)'
              ,@ProductMajorVersion                = '$($Data.ProductMajorVersion)'
              ,@ProductMinorVersion                = '$($Data.ProductMinorVersion)'
              ,@ProductUpdateLevel                 = '$($Data.ProductUpdateLevel)'
              ,@ProductUpdateReference             = '$($Data.ProductUpdateReference)'
              ,@ProductVersion                     = '$($Data.ProductVersion)'
              ,@ResourceLastUpdateDateTime         = '$($Data.ResourceLastUpdateDateTime)'
              ,@ResourceVersion                    = '$($Data.ResourceVersion)'
              ,@ServerName                         = '$($Data.ServerName)'
              ,@SqlCharSet                         =  $($Data.SqlCharSet)
              ,@SqlCharSetName                     = '$($Data.SqlCharSetName)'
              ,@SqlSortOrder                       =  $($Data.SqlSortOrder)
              ,@SqlSortOrderName                   = '$($Data.SqlSortOrderName)'
              ,@SuspendedDatabaseCount             =  $($Data.SuspendedDatabaseCount)" 
  Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Update -ErrorAction Stop
  Write-Log -FileName $LogFile -Message "Imported data for Server: $SqlFullName table: [dbo].[instances]"
}
#================================================================================================== 
#Remove constraints that point to table '[dbo].[databases]' and truncate child tables.
Write-Log -FileName $LogFile -Message "Remove constraints that point to table '[dbo].[databases]' and truncate child tables."
#==================================================================================================
#Do this so you can truncate table [dbo].[databases]
$SchemaTableNames = @('dbo.CHECK_CONSTRAINTS',
                      'dbo.COLUMN_DOMAIN_USAGE',
                      'dbo.COLUMN_PRIVILEGES',
                      'dbo.COLUMNS',
                      'dbo.CONSTRAINT_COLUMN_USAGE',
                      'dbo.CONSTRAINT_TABLE_USAGE',
                      'dbo.DOMAIN_CONSTRAINTS',
                      'dbo.DOMAINS',
                      'dbo.KEY_COLUMN_USAGE',
                      'dbo.PARAMETERS',
                      'dbo.REFERENTIAL_CONSTRAINTS',
                      'dbo.ROUTINE_COLUMNS',
                      'dbo.ROUTINES',
                      'dbo.SCHEMATA',
                      'dbo.SEQUENCES',
                      'dbo.TABLE_CONSTRAINTS',
                      'dbo.TABLE_PRIVILEGES',
                      'dbo.TABLES',
                      'dbo.VIEW_COLUMN_USAGE',
                      'dbo.VIEW_TABLE_USAGE',
                      'dbo.VIEWS')
#Truncate tables and remove the constraints
foreach ($TableName in $SchemaTableNames)
{
  $ConstraintName = ('FK_' + ($TableName.Split('.')[1]) + '_databases')
          $Query  = "TRUNCATE TABLE $TableName
                     IF EXISTS 
                     (
                       SELECT *
                       FROM [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS]
                        WHERE 
                          CONSTRAINT_TYPE = 'FOREIGN KEY' AND 
                          CONSTRAINT_SCHEMA = 'dbo' AND 
                          CONSTRAINT_NAME = '$ConstraintName'
                      )
                      BEGIN
                        ALTER TABLE $TableName DROP CONSTRAINT [$ConstraintName]
                      END"        
  Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
  Write-Log -FileName $LogFile -Message "Constraint '$ConstraintName' on table '$TableName' is removed and the table is truncated."
}
#================================================================================================== 
#Truncate table [dbo].[databases]'.
Write-Log -FileName $LogFile -Message "Truncate table [dbo].[databases]'."
#==================================================================================================
$Query = "TRUNCATE TABLE [dbo].[databases]"
try 
{
  Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
  Write-Log -FileName $LogFile -Message "Table [dbo].[databases]' is truncated."
}
catch 
{
  Write-Error ($Global:Error[0] | Format-List -Force | Out-String)	
}
#================================================================================================== 
#Reëanable the constraints.
Write-Log -FileName $LogFile -Message "Reëanable the constraints."
#==================================================================================================
try 
{
  foreach ($TableName in $SchemaTableNames)
  {
    $ConstraintName = ('[FK_' + ($TableName.Split('.')[1]) + '_databases]')
    $Query = "ALTER TABLE $TableName  WITH NOCHECK ADD  CONSTRAINT $ConstraintName FOREIGN KEY([db_id]) REFERENCES [dbo].[databases] ([db_id])
              ALTER TABLE $TableName CHECK CONSTRAINT $ConstraintName"
    Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
    Write-Log -FileName $LogFile -Message "Constraint '$ConstraintName' on table '$TableName' is enabled."
  } 
}
catch 
{
  Write-Error ($Global:Error[0] | Format-List -Force | Out-String)	
}
#================================================================================================== 
#Upload databases info.
Write-Log -FileName $LogFile -Message "Upload databases info."
#==================================================================================================
$TableName = '[dbo].[databases]'
#Retrieve the information from master.sys.databases
foreach ($Result in $ReachableServers)
{
  $SqlFullName = $Result.full_name
  [int]$InId   = $Result.i_id
  $Query       = "SELECT null as [db_id], $InId AS [i_id],  t.* FROM [sys].[databases] t"
  Import-Bulk $TableName $Query $SqlFullName 'master'
  Write-Log -FileName $LogFile -Message "Imported data for Server: $SqlFullName table: $TableName"
}
#================================================================================================== 
#Get a the list of databases from $MetaDb.
Write-Log -FileName $LogFile -Message "Get a the list of databases from $MetaDb."
#==================================================================================================
#Get a list of all the databases that were inserted in the previous step
$Query = "SELECT 
            CASE
              WHEN i.[name]  = 'MSSQLSERVER' THEN  s.[name]
              ELSE(s.[name] + '\' + i.[name])
            END AS [server_name]
            ,d.[name] AS [database_name]
            ,d.[db_id] 
          FROM 
            [dbo].[servers] s 
          INNER JOIN 
            [dbo].[instances] i ON i.s_id = s.s_id 
          INNER JOIN
            [dbo].[databases] d ON d.i_id = i.i_id
          WHERE
            d.[state_desc] = 'ONLINE' 
          AND
            d.name NOT IN ('master','model','msdb','tempdb')"
try 
{
  $Databases = Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop 
}
catch 
{
  Write-Error ($Global:Error[0] | Format-List -Force | Out-String)	
}
#================================================================================================== 
#Loop trough the tables and databases.
Write-Log -FileName $LogFile -Message "Loop trough the tables and databases."
#==================================================================================================
#$Schemaviews is an array of all the views under the INFORMATION_SCHEMA schema
#These views are present in each database and contain database specific information
#https://learn.microsoft.com/en-us/sql/relational-databases/system-information-schema-views/system-information-schema-views-transact-sql?view=sql-server-ver16

$SchemaViews= @('INFORMATION_SCHEMA.CHECK_CONSTRAINTS',
                'INFORMATION_SCHEMA.COLUMN_DOMAIN_USAGE',
                'INFORMATION_SCHEMA.COLUMN_PRIVILEGES',
                'INFORMATION_SCHEMA.COLUMNS',
                'INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE',
                'INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE',
                'INFORMATION_SCHEMA.DOMAIN_CONSTRAINTS',
                'INFORMATION_SCHEMA.DOMAINS',
                'INFORMATION_SCHEMA.KEY_COLUMN_USAGE',
                'INFORMATION_SCHEMA.PARAMETERS',
                'INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS',
                'INFORMATION_SCHEMA.ROUTINE_COLUMNS',
                'INFORMATION_SCHEMA.ROUTINES',
                'INFORMATION_SCHEMA.SCHEMATA',
                'INFORMATION_SCHEMA.SEQUENCES',
                'INFORMATION_SCHEMA.TABLE_CONSTRAINTS',
                'INFORMATION_SCHEMA.TABLE_PRIVILEGES',
                'INFORMATION_SCHEMA.TABLES',
                'INFORMATION_SCHEMA.VIEW_COLUMN_USAGE',
                'INFORMATION_SCHEMA.VIEW_TABLE_USAGE',
                'INFORMATION_SCHEMA.VIEWS')
#Loop for each database trough all these views and insert the data into $MetaDb
foreach ($Database in $Databases)
{
  $SqlFullName = $Database.server_name 
  $DbName      = $Database.database_name 
  $DbId        = $Database.db_id
  foreach ($View in $SchemaViews)
  {
    $Query = "SELECT null as [id], $DbId AS [db_id],  t.* FROM $View t"
    $TableName = ("dbo.[" + ($View.Split('.')[1]) + ']')
    Import-Bulk $TableName $Query $SqlFullName $DbName
    Write-Log -FileName $LogFile -Message "Imported data for Server: $SqlFullName Database: $DbName table: $TableName"
  }
}
#================================================================================================== 
#If needed write warning(s) about unreachable server(s).
Write-Log -FileName $LogFile -Message "If needed write warning(s) about unreachable server(s)."
#==================================================================================================
if ($UnReachableServers.Rows.count -ne 0)
{
  foreach ($Row in $UnReachableServers.Rows)
  {
    Write-Log -FileName $LogFile -Message "Unable to connect to server:$($Row.full_name)."
  }
  Write-LogicalError -FileName $LogFile -Message "Unable to connect to the above servers. Data is incomplete."
}
#================================================================================================== 
#End of script.
Write-Log -FileName $LogFile -Message "End of script."
#==================================================================================================
$EndDate = Get-Date
New-TimeSpan -Start $StartDate -End $EndDate