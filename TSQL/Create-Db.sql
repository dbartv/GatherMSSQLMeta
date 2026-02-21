/*Create the database*/

USE master;
IF DB_ID (N'MDB') IS NULL
CREATE DATABASE [MDB];
GO
USE [MDB]
/*Create the servers table*/
IF NOT EXISTS 
	(
		SELECT s.* FROM 
			sys.tables t 
			INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
		WHERE
			t.[name] = 'servers' AND
			s.[name] = 'dbo'
	)
BEGIN
	CREATE TABLE [dbo].[servers](
	[s_id] [int] IDENTITY (1,1) NOT NULL,
	[name] [sysname] NOT NULL
	CONSTRAINT PK_servers PRIMARY KEY CLUSTERED ([s_id]),
	CONSTRAINT UC_servers_name UNIQUE ([name])
	)
END;

/*instances table*/
IF NOT EXISTS 
	(
		SELECT s.* FROM 
			sys.tables t 
			INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
		WHERE
			t.[name] = 'instances' AND
			s.[name] = 'dbo'
	)
BEGIN
	CREATE TABLE [dbo].[instances](
	[i_id] [int] IDENTITY (1,1) NOT NULL,
	[s_id] [int] NOT NULL,
	[name] [sysname] NOT NULL,
	[version] [smallint] ,
	[BuildClrVersion] nvarchar(128),
	[Collation]  nvarchar(128),
	[CollationID] int,
	[ComparisonStyle] int,
	[ComputerNamePhysicalNetBIOS] nvarchar(128),
	[Edition] nvarchar(128),
	[EditionID] bigint,
	[EngineEdition] int,
	[FilestreamConfiguredLevel] int,
	[FilestreamEffectiveLevel] int,
	[FilestreamShareName] nvarchar(128),
	[HadrManagerStatus] int,
	[InstanceDefaultBackupPath] nvarchar(128),
	[InstanceDefaultDataPath] nvarchar(128),
	[InstanceDefaultLogPath] nvarchar(128),
	[InstanceName] nvarchar(128),
	[IsAdvancedAnalyticsInstalled] int,
	[IsBigDataCluster] int,
	[IsClustered] int,
	[IsExternalAuthenticationOnly] int,
	[IsExternalGovernanceEnabled] int,
	[IsFullTextInstalled] int,
	[IsHadrEnabled] int,
	[IsIntegratedSecurityOnly] int,
	[IsLocalDB] int,
	[IsPolyBaseInstalled] int,
	[IsServerSuspendedForSnapshotBackup] int,
	[IsSingleUser] int,
	[IsTempDbMetadataMemoryOptimized] int,
	[IsXTPSupported] int,
	[LCID] int,
	[LicenseType] nvarchar(128),
	[MachineName] nvarchar(128),
	[NumLicenses] int,
	[PathSeparator] nvarchar(1),
	[ProcessID] int,
	[ProductBuild] nvarchar(128),
	[ProductBuildType] nvarchar(128),
	[ProductLevel] nvarchar(128),
	[ProductMajorVersion] nvarchar(128),
	[ProductMinorVersion] nvarchar(128),
	[ProductUpdateLevel] nvarchar(128),
	[ProductUpdateReference] nvarchar(128),
	[ProductVersion] nvarchar(128),
	[ResourceLastUpdateDateTime] datetime,
	[ResourceVersion] nvarchar(128),
	[ServerName] nvarchar(128),
	[SqlCharSet] tinyint,
	[SqlCharSetName] nvarchar(128),
	[SqlSortOrder] tinyint,
	[SqlSortOrderName] nvarchar(128),
	[SuspendedDatabaseCount] int,
	CONSTRAINT PK_instances PRIMARY KEY CLUSTERED ([i_id]),
	CONSTRAINT FK_instances_servers FOREIGN KEY ([s_id]) REFERENCES [dbo].[servers] ([s_id]),
	CONSTRAINT UC_instances_name_s_id UNIQUE ([name],[s_id])
	)
END;
/*databases table*/
IF NOT EXISTS 
	(
		SELECT s.* FROM 
			sys.tables t 
			INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
		WHERE
			t.[name] = 'databases' AND
			s.[name] = 'dbo'
	)
BEGIN
	CREATE TABLE [dbo].[databases](
	[db_id] [int] IDENTITY (1,1) NOT NULL,
	[i_id] [int],
	[name] [sysname] NOT NULL,
	[database_id] [int] NOT NULL,
	[source_database_id] [int] NULL,
	[owner_sid] [varbinary] (85) NULL,
	[create_date] [datetime] NOT NULL,
	[compatibility_level] [tinyint] NOT NULL,
	[collation_name] [sysname] NULL,
	[user_access] [tinyint] NULL,
	[user_access_desc] [nvarchar] (60) NULL,
	[is_read_only] [bit] NULL,
	[is_auto_close_on] [bit] NOT NULL,
	[is_auto_shrink_on] [bit] NULL,
	[state] [tinyint] NULL,
	[state_desc] [nvarchar] (60) NULL,
	[is_in_standby] [bit] NULL,
	[is_cleanly_shutdown] [bit] NULL,
	[is_supplemental_logging_enabled] [bit] NULL,
	[snapshot_isolation_state] [tinyint] NULL,
	[snapshot_isolation_state_desc] [nvarchar] (60) NULL,
	[is_read_committed_snapshot_on] [bit] NULL,
	[recovery_model] [tinyint] NULL,
	[recovery_model_desc] [nvarchar] (60) NULL,
	[page_verify_option] [tinyint] NULL,
	[page_verify_option_desc] [nvarchar] (60) NULL,
	[is_auto_create_stats_on] [bit] NULL,
	[is_auto_create_stats_incremental_on] [bit] NULL,
	[is_auto_update_stats_on] [bit] NULL,
	[is_auto_update_stats_async_on] [bit] NULL,
	[is_ansi_null_default_on] [bit] NULL,
	[is_ansi_nulls_on] [bit] NULL,
	[is_ansi_padding_on] [bit] NULL,
	[is_ansi_warnings_on] [bit] NULL,
	[is_arithabort_on] [bit] NULL,
	[is_concat_null_yields_null_on] [bit] NULL,
	[is_numeric_roundabort_on] [bit] NULL,
	[is_quoted_identifier_on] [bit] NULL,
	[is_recursive_triggers_on] [bit] NULL,
	[is_cursor_close_on_commit_on] [bit] NULL,
	[is_local_cursor_default] [bit] NULL,
	[is_fulltext_enabled] [bit] NULL,
	[is_trustworthy_on] [bit] NULL,
	[is_db_chaining_on] [bit] NULL,
	[is_parameterization_forced] [bit] NULL,
	[is_master_key_encrypted_by_server] [bit] NOT NULL,
	[is_query_store_on] [bit] NULL,
	[is_published] [bit] NOT NULL,
	[is_subscribed] [bit] NOT NULL,
	[is_merge_published] [bit] NOT NULL,
	[is_distributor] [bit] NOT NULL,
	[is_sync_with_backup] [bit] NOT NULL,
	[service_broker_guid] [uniqueidentifier] NOT NULL,
	[is_broker_enabled] [bit] NOT NULL,
	[log_reuse_wait] [tinyint] NULL,
	[log_reuse_wait_desc] [nvarchar] (60) NULL,
	[is_date_correlation_on] [bit] NOT NULL,
	[is_cdc_enabled] [bit] NOT NULL,
	[is_encrypted] [bit] NULL,
	[is_honor_broker_priority_on] [bit] NULL,
	[replica_id] [uniqueidentifier] NULL,
	[group_database_id] [uniqueidentifier] NULL,
	[resource_pool_id] [int] NULL,
	[default_language_lcid] [smallint] NULL,
	[default_language_name] [nvarchar] (128) NULL,
	[default_fulltext_language_lcid] [int] NULL,
	[default_fulltext_language_name] [nvarchar] (128) NULL,
	[is_nested_triggers_on] [bit] NULL,
	[is_transform_noise_words_on] [bit] NULL,
	[two_digit_year_cutoff] [smallint] NULL,
	[containment] [tinyint] NULL,
	[containment_desc] [nvarchar] (60) NULL,
	[target_recovery_time_in_seconds] [int] NULL,
	[delayed_durability] [int] NULL,
	[delayed_durability_desc] [nvarchar] (60) NULL,
	[is_memory_optimized_elevate_to_snapshot_on] [bit] NULL,
	[is_federation_member] [bit] NULL,
	[is_remote_data_archive_enabled] [bit] NULL,
	[is_mixed_page_allocation_on] [bit] NULL,
	[is_temporal_history_retention_enabled] [bit] NULL,
	[catalog_collation_type] [int] NULL,
	[catalog_collation_type_desc] [nvarchar] (60) NULL,
	[physical_database_name] [nvarchar] (128) NULL,
	[is_result_set_caching_on] [bit] NULL,
	[is_accelerated_database_recovery_on] [bit] NULL,
	[is_tempdb_spill_to_remote_store] [bit] NULL,
	[is_stale_page_detection_on] [bit] NULL,
	[is_memory_optimized_enabled] [bit] NULL,
	[is_data_retention_enabled] [bit] NULL,
	[is_ledger_on] [bit] NULL,
	[is_change_feed_enabled] [bit] NULL,
  [is_data_lake_replication_enabled] [bit] NULL,
  [is_event_stream_enabled] [bit] NULL,
  [data_compaction] [tinyint] NULL,
  [data_compaction_desc] [nvarchar](60) NULL,
  [data_lake_log_publishing] [tinyint] NULL,
  [data_lake_log_publishing_desc] [nvarchar](60) NULL,
  [is_vorder_enabled] [bit] NULL,
  [is_proactive_statistics_refresh_on] [bit] NULL,
  [is_optimized_locking_on] [bit] NULL
	CONSTRAINT PK_databases PRIMARY KEY CLUSTERED ([db_id]),
	CONSTRAINT FK_databases_instances FOREIGN KEY ([i_id])REFERENCES [dbo].[instances] ([i_id]),
	CONSTRAINT UC_databases_name_iId UNIQUE ([name], [i_id]))
END;

/*create dbo.configurations*/
IF NOT EXISTS 
	(
		SELECT s.* FROM 
			sys.tables t 
			INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
		WHERE
			t.[name] = 'configurations' AND
			s.[name] = 'dbo'
	)
BEGIN
	CREATE TABLE [dbo].[configurations](
	[cf_id] [int] IDENTITY (1,1) NOT NULL,
	[i_id] [int],
	[configuration_id] [int] NOT NULL,
	[name] [nvarchar] (35) NOT NULL,
	[value] [sql_variant] NULL,
	[minimum] [sql_variant] NULL,
	[maximum] [sql_variant] NULL,
	[value_in_use] [sql_variant] NULL,
	[description] [nvarchar] (255) NOT NULL,
	[is_dynamic] [bit] NOT NULL,
	[is_advanced] [bit] NOT NULL,
	CONSTRAINT PK_configurations PRIMARY KEY CLUSTERED ([cf_id]),
	CONSTRAINT FK_configurations_instances FOREIGN KEY ([i_id]) REFERENCES [dbo].[instances] ([i_id]),
	CONSTRAINT UC_configurations_name_iId UNIQUE ([name], [i_id]))
END;

/*Create sysjobs table*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
			s.[name] = 'dbo' AND
			t.[name] = 'sysjobs'
			
)
BEGIN
	CREATE TABLE [dbo].[sysjobs](
	[jv_id] [int] IDENTITY (1,1) NOT NULL,
	[i_id] [int],
	[job_id] [uniqueidentifier] NOT NULL,
	[originating_server] [nvarchar] (128) NULL,
	[name] [sysname] NOT NULL,
	[enabled] [tinyint] NOT NULL,
	[description] [nvarchar] (512) NULL,
	[start_step_id] [int] NOT NULL,
	[category_id] [int] NOT NULL,
	[owner_sid] [varbinary] (85) NOT NULL,
	[notify_level_eventlog] [int] NOT NULL,
	[notify_level_email] [int] NOT NULL,
	[notify_level_netsend] [int] NOT NULL,
	[notify_level_page] [int] NOT NULL,
	[notify_email_operator_id] [int] NOT NULL,
	[notify_netsend_operator_id] [int] NOT NULL,
	[notify_page_operator_id] [int] NOT NULL,
	[delete_level] [int] NOT NULL,
	[date_created] [datetime] NOT NULL,
	[date_modified] [datetime] NOT NULL,
	[version_number] [int] NOT NULL,
	[originating_server_id] [int] NOT NULL,
	[master_server] [int] NULL,
	CONSTRAINT PK_sysjobs PRIMARY KEY CLUSTERED ([jv_id]),
	CONSTRAINT FK_sysjobs_instances FOREIGN KEY ([i_id]) REFERENCES [dbo].[instances] ([i_id]),
	CONSTRAINT UC_sysjobs_jobid_iId UNIQUE ([job_id], [i_id]))
END;

/*dm_os_sys_info table*/
CREATE TABLE [dbo].[dm_os_sys_info](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[i_id] [int] NOT NULL,
	[cpu_ticks] [bigint] NOT NULL,
	[ms_ticks] [bigint] NOT NULL,
	[cpu_count] [int] NOT NULL,
	[hyperthread_ratio] [int] NOT NULL,
	[physical_memory_kb] [bigint] NOT NULL,
	[virtual_memory_kb] [bigint] NOT NULL,
	[committed_kb] [bigint] NOT NULL,
	[committed_target_kb] [bigint] NOT NULL,
	[visible_target_kb] [bigint] NOT NULL,
	[stack_size_in_bytes] [int] NOT NULL,
	[os_quantum] [bigint] NOT NULL,
	[os_error_mode] [int] NOT NULL,
	[os_priority_class] [int] NULL,
	[max_workers_count] [int] NOT NULL,
	[scheduler_count] [int] NOT NULL,
	[scheduler_total_count] [int] NOT NULL,
	[deadlock_monitor_serial_number] [int] NOT NULL,
	[sqlserver_start_time_ms_ticks] [bigint] NOT NULL,
	[sqlserver_start_time] [datetime] NOT NULL,
	[affinity_type] [int] NOT NULL,
	[affinity_type_desc] [nvarchar](60) NOT NULL,
	[process_kernel_time_ms] [bigint] NOT NULL,
	[process_user_time_ms] [bigint] NOT NULL,
	[time_source] [int] NOT NULL,
	[time_source_desc] [nvarchar](60) NOT NULL,
	[virtual_machine_type] [int] NOT NULL,
	[virtual_machine_type_desc] [nvarchar](60) NOT NULL,
	[softnuma_configuration] [int] NOT NULL,
	[softnuma_configuration_desc] [nvarchar](60) NOT NULL,
	[process_physical_affinity] [nvarchar](3072) NOT NULL,
	[sql_memory_model] [int] NOT NULL,
	[sql_memory_model_desc] [nvarchar](60) NOT NULL,
	[socket_count] [int] NOT NULL,
	[cores_per_socket] [int] NOT NULL,
	[numa_node_count] [int] NOT NULL,
	[container_type] [int] NOT NULL,
	[container_type_desc] [nvarchar](60) NOT NULL,
	CONSTRAINT [PK_dm_os_sys_info] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	 CONSTRAINT [UC_dm_os_sys_info_iId] UNIQUE NONCLUSTERED 
	(
		[i_id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[dm_os_sys_info]  WITH NOCHECK ADD  CONSTRAINT [FK_dm_os_sys_info_instances] FOREIGN KEY([i_id])
REFERENCES [dbo].[instances] ([i_id])
ALTER TABLE [dbo].[dm_os_sys_info] CHECK CONSTRAINT [FK_dm_os_sys_info_instances]
GO

/*
=============================================
Create SP to UPDATE serverproperties in the instances table
=============================================
 */
 /*

USE MDB
GO
CREATE OR ALTER   PROCEDURE [dbo].[update_serverproperties]

@i_id [int],
@BuildClrVersion nvarchar(128),
@Collation nvarchar(128),
@CollationID int,
@ComparisonStyle int,
@ComputerNamePhysicalNetBIOS nvarchar(128),
@Edition nvarchar(128),
@EditionID bigint,
@EngineEdition int,
@FilestreamConfiguredLevel int,
@FilestreamEffectiveLevel int,
@FilestreamShareName nvarchar(128),
@HadrManagerStatus int,
@InstanceDefaultBackupPath nvarchar(128),
@InstanceDefaultDataPath nvarchar(128),
@InstanceDefaultLogPath nvarchar(128),
@InstanceName nvarchar(128),
@IsAdvancedAnalyticsInstalled int,
@IsBigDataCluster int,
@IsClustered int,
@IsExternalAuthenticationOnly int,
@IsExternalGovernanceEnabled int,
@IsFullTextInstalled int,
@IsHadrEnabled int,
@IsIntegratedSecurityOnly int,
@IsLocalDB int,
@IsPolyBaseInstalled int,
@IsServerSuspendedForSnapshotBackup int,
@IsSingleUser int,
@IsTempDbMetadataMemoryOptimized int,
@IsXTPSupported int,
@LCID int,
@LicenseType nvarchar(128),
@MachineName nvarchar(128),
@NumLicenses int,
@PathSeparator nvarchar(1),
@ProcessID int,
@ProductBuild nvarchar(128),
@ProductBuildType nvarchar(128),
@ProductLevel nvarchar(128),
@ProductMajorVersion nvarchar(128),
@ProductMinorVersion nvarchar(128),
@ProductUpdateLevel nvarchar(128),
@ProductUpdateReference nvarchar(128),
@ProductVersion nvarchar(128),
@ResourceLastUpdateDateTime datetime,
@ResourceVersion nvarchar(128),
@ServerName nvarchar(128),
@SqlCharSet tinyint,
@SqlCharSetName nvarchar(128),
@SqlSortOrder tinyint,
@SqlSortOrderName nvarchar(128),
@SuspendedDatabaseCount int
AS
BEGIN
	UPDATE [dbo].[instances]
	SET 
     [BuildClrVersion]                    = @BuildClrVersion
	,[Collation]                          = @Collation
	,[ComparisonStyle]                    = @ComparisonStyle
	,[ComputerNamePhysicalNetBIOS]        = @ComputerNamePhysicalNetBIOS
	,[Edition]                            = @Edition
	,[EditionID]                          = @EditionID
	,[EngineEdition]                      = @EngineEdition
	,[FilestreamConfiguredLevel]          = @FilestreamConfiguredLevel
	,[FilestreamEffectiveLevel]           = @FilestreamEffectiveLevel
	,[FilestreamShareName]                = @FilestreamShareName
	,[HadrManagerStatus]                  = @HadrManagerStatus
	,[InstanceDefaultBackupPath]          = @InstanceDefaultBackupPath
	,[InstanceDefaultDataPath]            = @InstanceDefaultDataPath
	,[InstanceDefaultLogPath]             = @InstanceDefaultLogPath
	,[InstanceName]                       = @InstanceName
	,[IsAdvancedAnalyticsInstalled]       = @IsAdvancedAnalyticsInstalled
	,[IsBigDataCluster]                   = @IsBigDataCluster
	,[IsClustered]                        = @IsClustered
	,[IsExternalAuthenticationOnly]       = @IsExternalAuthenticationOnly
	,[IsExternalGovernanceEnabled]        = @IsExternalGovernanceEnabled
	,[IsFullTextInstalled]                = @IsFullTextInstalled
	,[IsHadrEnabled]                      = @IsHadrEnabled
	,[IsIntegratedSecurityOnly]           = @IsIntegratedSecurityOnly
	,[IsLocalDB]                          = @IsLocalDB
	,[IsPolyBaseInstalled]                = @IsPolyBaseInstalled
	,[IsServerSuspendedForSnapshotBackup] = @IsServerSuspendedForSnapshotBackup
	,[IsSingleUser]                       = @IsSingleUser
	,[IsTempDbMetadataMemoryOptimized]    = @IsTempDbMetadataMemoryOptimized
	,[IsXTPSupported]                     = @IsXTPSupported
	,[LCID]                               = @LCID
	,[LicenseType]                        = @LicenseType
	,[MachineName]                        = @MachineName
	,[NumLicenses]                        = @NumLicenses
	,[PathSeparator]                      = @PathSeparator
	,[ProcessID]                          = @ProcessID
	,[ProductBuild]                       = @ProductBuild
	,[ProductBuildType]                   = @ProductBuildType
	,[ProductLevel]                       = @ProductLevel
	,[ProductMajorVersion]                = @ProductMajorVersion
	,[ProductMinorVersion]                = @ProductMinorVersion
	,[ProductUpdateLevel]                 = @ProductUpdateLevel
	,[ProductUpdateReference]             = @ProductUpdateReference
	,[ProductVersion]                     = @ProductVersion
	,[ResourceLastUpdateDateTime]         = @ResourceLastUpdateDateTime
	,[ResourceVersion]                    = @ResourceVersion
	,[ServerName]                         = @ServerName
	,[SqlCharSet]                         = @SqlCharSet
	,[SqlCharSetName]                     = @SqlCharSetName
	,[SqlSortOrder]                       = @SqlSortOrder
	,[SqlSortOrderName]                   = @SqlSortOrderName
	,[SuspendedDatabaseCount]             = @SuspendedDatabaseCount
	WHERE i_id = @i_id
END
GO

*/
GO

CREATE   OR ALTER  VIEW [dbo].[vw_DB_Basic_Info]
AS
SELECT      
  i.ServerName,
  d.name,
  i.Edition,
  CASE
    WHEN i.[ProductMajorVersion] = '12' THEN 2014
    WHEN i.[ProductMajorVersion] = '13' THEN 2016
    WHEN i.[ProductMajorVersion] = '14' THEN 2017
    WHEN i.[ProductMajorVersion] = '15' THEN 2019
    WHEN i.[ProductMajorVersion] = '16' THEN 2022
    WHEN i.[ProductMajorVersion] = '17' THEN 2025
  END AS ProductVersion,
  d.compatibility_level,
  d.collation_name AS [Database Collation],
  d.state_desc,
  d.recovery_model_desc,
  d.create_date
FROM            
  dbo.databases AS d INNER JOIN
  dbo.instances AS i ON d.i_id = i.i_id INNER JOIN
  dbo.servers AS s ON s.s_id = i.s_id 

USE master;