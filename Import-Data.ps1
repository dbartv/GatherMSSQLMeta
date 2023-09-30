#==================================================================================================
#Function: Bulk insert data into $MetaDb
#==================================================================================================
Function Import-Bulk ($TableName, $Query, $Database)
{
  Try
  {
    
    $DataTable  = Invoke-Sqlcmd -ServerInstance $SqlFullName -Database $Database -Query $Query -ErrorAction Stop -OutputAs DataTables
    If($null -ne $DataTable)
    {
      $cn         = new-object System.Data.SqlClient.SqlConnection(('Data Source={0};Integrated Security=SSPI;Initial Catalog={1}' -f $MetaServerName, $MetaDb))
      $cn.Open()
      $bc         = new-object ('System.Data.SqlClient.SqlBulkCopy') $cn
      $bc.DestinationTableName = $TableName
      $bc.WriteToServer($DataTable)
      $cn.Close()
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
}
catch 
{
  Throw ("Error: " + ($PsItem.Exception))
}
#================================================================================================== 
#Get the server names.
#==================================================================================================
$Query = 'SELECT 
	          s.[name]    AS [server_name],
	          i.[name]    AS [instance_name],
            i.[i_id] 
          FROM  
            [dbo].[servers] s INNER JOIN 
            [dbo].[instances] i ON i.s_id = s.s_id'
Try
{
  $Results = Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
}
Catch
{
  Write-Error ($Global:Error[0] | Format-List -Force | Out-String)	
}
#================================================================================================== 
#Create datatables 
#==================================================================================================
$ReachableServers = New-Object system.Data.DataTable 
[void]$ReachableServers.Columns.Add("server_name",      "System.String")
[void]$ReachableServers.Columns.Add("instance_name",    "System.String")
[void]$ReachableServers.Columns.Add("instance_version", "System.int64")
[void]$ReachableServers.Columns.Add("i_id",             "System.int64")
[void]$ReachableServers.Columns.Add("full_name",        "System.String")

$UnReachableServers = New-Object system.Data.DataTable 
[void]$UnReachableServers.Columns.Add("server_name",   "System.String")
[void]$UnReachableServers.Columns.Add("instance_name", "System.String")
[void]$UnReachableServers.Columns.Add("i_id",          "System.int64")
[void]$UnReachableServers.Columns.Add("full_name",     "System.String")
#================================================================================================== 
#Check if the servers are available.
#==================================================================================================
#Try to get the version for each  SQL server instance that is added to your metadata database (MDB)
$Query = "SELECT 
          CASE
            WHEN  SERVERPROPERTY('ProductMajorVersion')  = '13' THEN 2016
            WHEN  SERVERPROPERTY('ProductMajorVersion')  = '14' THEN 2017 
            WHEN  SERVERPROPERTY('ProductMajorVersion')  = '15' THEN 2019 
            WHEN  SERVERPROPERTY('ProductMajorVersion')  = '16' THEN 2022 
          END AS  [ProductVersion]"
Foreach ($Result in $Results)
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
  Try
  {
    #When the version number is retrieved, add the server to $ReachableServers, servers in this datatable will be queried to retrieve other info
    [int]$Version= (Invoke-Sqlcmd -ServerInstance $SqlFullName -Database master -Query $Query -ErrorAction Stop).ProductVersion
    [void]$ReachableServers.Rows.Add($ServerName,$InstanceName,$Version, $InId, $SqlFullName)
  }
  Catch
  {
    #If we cannot connect to this server, there's no point to try to retrieve other info from this server (this is only for this run)
    Write-Warning "Unable to connect to server '$SqlFullName'."
    [void]$UnReachableServers.Rows.Add($ServerName,$InstanceName, $InId, $SqlFullName)
  }
}
#================================================================================================== 
#Get jobs info.
#==================================================================================================
$TableName = "[$schema].[sysjobs]"
#Clear all content from table $TableName 
$Query     = "TRUNCATE TABLE $TableName"
Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
Foreach ($Result in $ReachableServers)
{
  $SqlFullName     = $Result.full_name
  [int]$InId       = $Result.i_id
  #Retrieve the information from System view msdb.[dbo].[sysjobs_view] 
  $Query      = "SELECT null as [jv_id], $InId AS [i_id],  t.* FROM [dbo].[sysjobs_view] t"
  Import-Bulk $TableName $Query 'msdb'
}
#================================================================================================== 
#Get configurations info.
#==================================================================================================
$TableName = "[$schema].[configurations]"
$Query     = "TRUNCATE TABLE $TableName"
#Clear all content from table $TableName
Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
Foreach ($Result in $ReachableServers)
{
  $SqlFullName     = $Result.full_name
  [int]$InId       = $Result.i_id
  #Retrieve the information from System view master.[sys].[configurations] 
  $Query      = "SELECT null as [db_id], $InId AS [i_id],  t.* FROM [sys].[configurations] t"
  Import-Bulk $TableName $Query 'master'
}
#================================================================================================== 
#Get instance info.
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
Foreach ($Result in $ReachableServers)
{
  $SqlFullName = $Result.full_name
  [int]$InId   = $Result.i_id
  
  $Data = Invoke-Sqlcmd -ServerInstance $SqlFullName -Database master -Query $Query -ErrorAction Stop 
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
  Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Update -ErrorAction Stop
}
#================================================================================================== 
#Remove the constraints to the table '[dbo].[databases]'.
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
Foreach ($TableName in $SchemaTableNames)
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
           
  Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
}
#Clear all content from table [dbo].[databases]
$Query = "TRUNCATE TABLE [dbo].[databases]"
Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
#Reëanable the constraints 
Foreach ($TableName in $SchemaTableNames)
{
  $ConstraintName = ('[FK_' + ($TableName.Split('.')[1]) + '_databases]')
  $Query = "ALTER TABLE $TableName  WITH NOCHECK ADD  CONSTRAINT $ConstraintName FOREIGN KEY([db_id]) REFERENCES [dbo].[databases] ([db_id])
            ALTER TABLE $TableName CHECK CONSTRAINT $ConstraintName"
  Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop
}
#================================================================================================== 
#Get databases info.
#==================================================================================================
$TableName = '[dbo].[databases]'
#Retrieve the information from master.sys.databases
Foreach ($Result in $ReachableServers)
{
  $SqlFullName = $Result.full_name
  [int]$InId   = $Result.i_id
  $Query       = "SELECT null as [db_id], $InId AS [i_id],  t.* FROM [sys].[databases] t"
  Import-Bulk $TableName $Query 'master'
}
#================================================================================================== 
#Get the databases
#==================================================================================================
#Get a list of all the databases that were inserted in the previous step
$Query = "SELECT 
            CASE
              WHEN i.[name]  = 'MSSQLSERVER' THEN  s.[name]
              ELSE(s.[name] + '\' + i.[name])
            END AS [server_name]
              ,d.[name] AS [database_name]
              ,d.[db_id] 

          FROM [dbo].[servers] s INNER JOIN 
            [dbo].[instances] i ON i.s_id = s.s_id INNER JOIN
            [dbo].[databases] d ON d.i_id = i.i_id
          WHERE d.[state_desc] = 'ONLINE' AND
          d.name NOT IN ('master','model','msdb','tempdb')"
$Databases =  Invoke-Sqlcmd -ServerInstance $MetaServerName -Database $MetaDb -Query $Query -ErrorAction Stop 
#================================================================================================== 
#Loop trough the tables and databases
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
Foreach ($Database in $Databases)
{
  $SqlFullName = $Database.server_name 
  $DbName = $Database.database_name 
  $DbId   = $Database.db_id
  Foreach ($View in $SchemaViews)
  {
    $Query = "SELECT null as [id], $DbId AS [db_id],  t.* FROM $View t"
    $TableName = ("dbo.[" + ($View.Split('.')[1]) + ']')
    Import-Bulk $TableName $Query $DbName
  }
}
#================================================================================================== 
#If needed write warning(s) about unreachable server(s).
#==================================================================================================
If ($UnReachableServers.Rows.count -ne 0)
{
  Write-Warning 'Following server(s) were unreachable:'
  Foreach ($Row in $UnReachableServers.Rows)
  {
    Write-Warning ($Row.full_name)
  }
}
#================================================================================================== 
#Result.
#==================================================================================================
$EndDate = Get-Date
New-TimeSpan -Start $StartDate -End $EndDate