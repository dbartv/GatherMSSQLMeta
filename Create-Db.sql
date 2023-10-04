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

/**/

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

/*Create table [CHECK_CONSTRAINTS]*/
IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
			s.[name] = 'dbo' AND
			t.[name] = 'CHECK_CONSTRAINTS'
			
)
BEGIN
	CREATE TABLE [dbo].[CHECK_CONSTRAINTS](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[CONSTRAINT_CATALOG] [nvarchar] (128) NULL,
	[CONSTRAINT_SCHEMA] [nvarchar] (128) NULL,
	[CONSTRAINT_NAME] [sysname] NULL,
	[CHECK_CLAUSE] [nvarchar] (4000) NULL,
	CONSTRAINT PK_CHECK_CONSTRAINTS PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_CHECK_CONSTRAINTS_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO


/*Create table [COLUMN_DOMAIN_USAGE]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'COLUMN_DOMAIN_USAGE'
)
BEGIN
	CREATE TABLE [dbo].[COLUMN_DOMAIN_USAGE](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[DOMAIN_CATALOG] [nvarchar] (128) NULL,
	[DOMAIN_SCHEMA] [nvarchar] (128) NULL,
	[DOMAIN_NAME] [sysname] NULL,
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[COLUMN_NAME] [sysname] NULL
	CONSTRAINT PK_COLUMN_DOMAIN_USAGE PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_COLUMN_DOMAIN_USAGE_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO


/*Create table [COLUMN_PRIVILEGES]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'COLUMN_PRIVILEGES'
)
BEGIN
	CREATE TABLE [dbo].[COLUMN_PRIVILEGES](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[GRANTOR] [nvarchar] (128) NULL,
	[GRANTEE] [nvarchar] (128) NULL,
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[COLUMN_NAME] [sysname] NULL,
	[PRIVILEGE_TYPE] [varchar] (10) NULL,
	[IS_GRANTABLE] [varchar] (3) NULL
	CONSTRAINT PK_COLUMN_PRIVILEGES PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_COLUMN_PRIVILEGES_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [COLUMNS]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'COLUMNS'
)
BEGIN
	CREATE TABLE [dbo].[COLUMNS](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[COLUMN_NAME] [sysname] NULL,
	[ORDINAL_POSITION] [int] NULL,
	[COLUMN_DEFAULT] [nvarchar] (4000) NULL,
	[IS_NULLABLE] [varchar] (3) NULL,
	[DATA_TYPE] [nvarchar] (128) NULL,
	[CHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[CHARACTER_OCTET_LENGTH] [int] NULL,
	[NUMERIC_PRECISION] [tinyint] NULL,
	[NUMERIC_PRECISION_RADIX] [smallint] NULL,
	[NUMERIC_SCALE] [int] NULL,
	[DATETIME_PRECISION] [smallint] NULL,
	[CHARACTER_SET_CATALOG] [sysname] NULL,
	[CHARACTER_SET_SCHEMA] [sysname] NULL,
	[CHARACTER_SET_NAME] [sysname] NULL,
	[COLLATION_CATALOG] [sysname] NULL,
	[COLLATION_SCHEMA] [sysname] NULL,
	[COLLATION_NAME] [sysname] NULL,
	[DOMAIN_CATALOG] [sysname] NULL,
	[DOMAIN_SCHEMA] [sysname] NULL,
	[DOMAIN_NAME] [sysname] NULL
	CONSTRAINT PK_COLUMNS PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_COLUMNS_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [CONSTRAINT_COLUMN_USAGE]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'CONSTRAINT_COLUMN_USAGE'
)
BEGIN
	CREATE TABLE [dbo].[CONSTRAINT_COLUMN_USAGE](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[COLUMN_NAME] [nvarchar] (128) NULL,
	[CONSTRAINT_CATALOG] [nvarchar] (128) NULL,
	[CONSTRAINT_SCHEMA] [nvarchar] (128) NULL,
	[CONSTRAINT_NAME] [sysname] NULL
	CONSTRAINT PK_CONSTRAINT_COLUMN_USAGE PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_CONSTRAINT_COLUMN_USAGE_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [CONSTRAINT_TABLE_USAGE]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'CONSTRAINT_TABLE_USAGE'
)
BEGIN
	CREATE TABLE [dbo].[CONSTRAINT_TABLE_USAGE](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[CONSTRAINT_CATALOG] [nvarchar] (128) NULL,
	[CONSTRAINT_SCHEMA] [nvarchar] (128) NULL,
	[CONSTRAINT_NAME] [sysname] NULL
	CONSTRAINT PK_CONSTRAINT_TABLE_USAGE PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_CONSTRAINT_TABLE_USAGE_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [DOMAIN_CONSTRAINTS]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'DOMAIN_CONSTRAINTS'
)
BEGIN
	CREATE TABLE [dbo].[DOMAIN_CONSTRAINTS](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[CONSTRAINT_CATALOG] [nvarchar] (128) NULL,
	[CONSTRAINT_SCHEMA] [nvarchar] (128) NULL,
	[CONSTRAINT_NAME] [sysname] NULL,
	[DOMAIN_CATALOG] [nvarchar] (128) NULL,
	[DOMAIN_SCHEMA] [nvarchar] (128) NULL,
	[DOMAIN_NAME] [sysname] NULL,
	[IS_DEFERRABLE] [varchar] (2) NULL,
	[INITIALLY_DEFERRED] [varchar] (2) NULL
	CONSTRAINT PK_DOMAIN_CONSTRAINTS PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_DOMAIN_CONSTRAINTS_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [DOMAINS]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'DOMAINS'
)
BEGIN
	CREATE TABLE [dbo].[DOMAINS](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[DOMAIN_CATALOG] [nvarchar] (128) NULL,
	[DOMAIN_SCHEMA] [nvarchar] (128) NULL,
	[DOMAIN_NAME] [sysname] NULL,
	[DATA_TYPE] [nvarchar] (128) NULL,
	[CHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[CHARACTER_OCTET_LENGTH] [int] NULL,
	[COLLATION_CATALOG] [sysname] NULL,
	[COLLATION_SCHEMA] [sysname] NULL,
	[COLLATION_NAME] [sysname] NULL,
	[CHARACTER_SET_CATALOG] [sysname] NULL,
	[CHARACTER_SET_SCHEMA] [sysname] NULL,
	[CHARACTER_SET_NAME] [sysname] NULL,
	[NUMERIC_PRECISION] [tinyint] NULL,
	[NUMERIC_PRECISION_RADIX] [smallint] NULL,
	[NUMERIC_SCALE] [int] NULL,
	[DATETIME_PRECISION] [smallint] NULL,
	[DOMAIN_DEFAULT] [nvarchar] (4000) NULL
	CONSTRAINT PK_DOMAINS PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_DOMAINS_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [KEY_COLUMN_USAGE]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'KEY_COLUMN_USAGE'
)
BEGIN
	CREATE TABLE [dbo].[KEY_COLUMN_USAGE](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[CONSTRAINT_CATALOG] [nvarchar] (128) NULL,
	[CONSTRAINT_SCHEMA] [nvarchar] (128) NULL,
	[CONSTRAINT_NAME] [sysname] NULL,
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[COLUMN_NAME] [nvarchar] (128) NULL,
	[ORDINAL_POSITION] [int] NULL
	CONSTRAINT PK_KEY_COLUMN_USAGE PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_KEY_COLUMN_USAGE_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [PARAMETERS]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'PARAMETERS'
)
BEGIN
	CREATE TABLE [dbo].[PARAMETERS](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[SPECIFIC_CATALOG] [nvarchar] (128) NULL,
	[SPECIFIC_SCHEMA] [nvarchar] (128) NULL,
	[SPECIFIC_NAME] [sysname] NULL,
	[ORDINAL_POSITION] [int] NULL,
	[PARAMETER_MODE] [nvarchar] (10) NULL,
	[IS_RESULT] [nvarchar] (10) NULL,
	[AS_LOCATOR] [nvarchar] (10) NULL,
	[PARAMETER_NAME] [sysname] NULL,
	[DATA_TYPE] [nvarchar] (128) NULL,
	[CHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[CHARACTER_OCTET_LENGTH] [int] NULL,
	[COLLATION_CATALOG] [sysname] NULL,
	[COLLATION_SCHEMA] [sysname] NULL,
	[COLLATION_NAME] [sysname] NULL,
	[CHARACTER_SET_CATALOG] [sysname] NULL,
	[CHARACTER_SET_SCHEMA] [sysname] NULL,
	[CHARACTER_SET_NAME] [sysname] NULL,
	[NUMERIC_PRECISION] [tinyint] NULL,
	[NUMERIC_PRECISION_RADIX] [smallint] NULL,
	[NUMERIC_SCALE] [int] NULL,
	[DATETIME_PRECISION] [smallint] NULL,
	[INTERVAL_TYPE] [nvarchar] (30) NULL,
	[INTERVAL_PRECISION] [smallint] NULL,
	[USER_DEFINED_TYPE_CATALOG] [sysname] NULL,
	[USER_DEFINED_TYPE_SCHEMA] [sysname] NULL,
	[USER_DEFINED_TYPE_NAME] [sysname] NULL,
	[SCOPE_CATALOG] [sysname] NULL,
	[SCOPE_SCHEMA] [sysname] NULL,
	[SCOPE_NAME] [sysname] NULL
	CONSTRAINT PK_PARAMETERS PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_PARAMETERS_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [REFERENTIAL_CONSTRAINTS]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'REFERENTIAL_CONSTRAINTS'
)
BEGIN
	CREATE TABLE [dbo].[REFERENTIAL_CONSTRAINTS](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[CONSTRAINT_CATALOG] [nvarchar] (128) NULL,
	[CONSTRAINT_SCHEMA] [nvarchar] (128) NULL,
	[CONSTRAINT_NAME] [sysname] NULL,
	[UNIQUE_CONSTRAINT_CATALOG] [nvarchar] (128) NULL,
	[UNIQUE_CONSTRAINT_SCHEMA] [nvarchar] (128) NULL,
	[UNIQUE_CONSTRAINT_NAME] [sysname] NULL,
	[MATCH_OPTION] [varchar] (7) NULL,
	[UPDATE_RULE] [varchar] (11) NULL,
	[DELETE_RULE] [varchar] (11) NULL
	CONSTRAINT PK_REFERENTIAL_CONSTRAINTS PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_REFERENTIAL_CONSTRAINTS_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [ROUTINE_COLUMNS]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'ROUTINE_COLUMNS'
)
BEGIN
	CREATE TABLE [dbo].[ROUTINE_COLUMNS](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[COLUMN_NAME] [sysname] NULL,
	[ORDINAL_POSITION] [int] NULL,
	[COLUMN_DEFAULT] [nvarchar] (4000) NULL,
	[IS_NULLABLE] [varchar] (3) NULL,
	[DATA_TYPE] [nvarchar] (128) NULL,
	[CHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[CHARACTER_OCTET_LENGTH] [int] NULL,
	[NUMERIC_PRECISION] [tinyint] NULL,
	[NUMERIC_PRECISION_RADIX] [smallint] NULL,
	[NUMERIC_SCALE] [int] NULL,
	[DATETIME_PRECISION] [smallint] NULL,
	[CHARACTER_SET_CATALOG] [sysname] NULL,
	[CHARACTER_SET_SCHEMA] [sysname] NULL,
	[CHARACTER_SET_NAME] [sysname] NULL,
	[COLLATION_CATALOG] [sysname] NULL,
	[COLLATION_SCHEMA] [sysname] NULL,
	[COLLATION_NAME] [sysname] NULL,
	[DOMAIN_CATALOG] [sysname] NULL,
	[DOMAIN_SCHEMA] [sysname] NULL,
	[DOMAIN_NAME] [sysname] NULL
	CONSTRAINT PK_ROUTINE_COLUMNS PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_ROUTINE_COLUMNS_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [ROUTINES]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'ROUTINES'
)
BEGIN
	CREATE TABLE [dbo].[ROUTINES](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[SPECIFIC_CATALOG] [nvarchar] (128) NULL,
	[SPECIFIC_SCHEMA] [nvarchar] (128) NULL,
	[SPECIFIC_NAME] [sysname] NULL,
	[ROUTINE_CATALOG] [nvarchar] (128) NULL,
	[ROUTINE_SCHEMA] [nvarchar] (128) NULL,
	[ROUTINE_NAME] [sysname] NULL,
	[ROUTINE_TYPE] [nvarchar] (20) NULL,
	[MODULE_CATALOG] [sysname] NULL,
	[MODULE_SCHEMA] [sysname] NULL,
	[MODULE_NAME] [sysname] NULL,
	[UDT_CATALOG] [sysname] NULL,
	[UDT_SCHEMA] [sysname] NULL,
	[UDT_NAME] [sysname] NULL,
	[DATA_TYPE] [sysname] NULL,
	[CHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[CHARACTER_OCTET_LENGTH] [int] NULL,
	[COLLATION_CATALOG] [sysname] NULL,
	[COLLATION_SCHEMA] [sysname] NULL,
	[COLLATION_NAME] [sysname] NULL,
	[CHARACTER_SET_CATALOG] [sysname] NULL,
	[CHARACTER_SET_SCHEMA] [sysname] NULL,
	[CHARACTER_SET_NAME] [sysname] NULL,
	[NUMERIC_PRECISION] [tinyint] NULL,
	[NUMERIC_PRECISION_RADIX] [smallint] NULL,
	[NUMERIC_SCALE] [int] NULL,
	[DATETIME_PRECISION] [smallint] NULL,
	[INTERVAL_TYPE] [nvarchar] (30) NULL,
	[INTERVAL_PRECISION] [smallint] NULL,
	[TYPE_UDT_CATALOG] [sysname] NULL,
	[TYPE_UDT_SCHEMA] [sysname] NULL,
	[TYPE_UDT_NAME] [sysname] NULL,
	[SCOPE_CATALOG] [sysname] NULL,
	[SCOPE_SCHEMA] [sysname] NULL,
	[SCOPE_NAME] [sysname] NULL,
	[MAXIMUM_CARDINALITY] [bigint] NULL,
	[DTD_IDENTIFIER] [sysname] NULL,
	[ROUTINE_BODY] [nvarchar] (30) NULL,
	[ROUTINE_DEFINITION] [nvarchar] (4000) NULL,
	[EXTERNAL_NAME] [sysname] NULL,
	[EXTERNAL_LANGUAGE] [nvarchar] (30) NULL,
	[PARAMETER_STYLE] [nvarchar] (30) NULL,
	[IS_DETERMINISTIC] [nvarchar] (10) NULL,
	[SQL_DATA_ACCESS] [nvarchar] (30) NULL,
	[IS_NULL_CALL] [nvarchar] (10) NULL,
	[SQL_PATH] [sysname] NULL,
	[SCHEMA_LEVEL_ROUTINE] [nvarchar] (10) NULL,
	[MAX_DYNAMIC_RESULT_SETS] [smallint] NULL,
	[IS_USER_DEFINED_CAST] [nvarchar] (10) NULL,
	[IS_IMPLICITLY_INVOCABLE] [nvarchar] (10) NULL,
	[CREATED] [datetime] NULL,
	[LAST_ALTERED] [datetime] NULL
	CONSTRAINT PK_ROUTINES PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_ROUTINES_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [SCHEMATA]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'SCHEMATA'
)
BEGIN
	CREATE TABLE [dbo].[SCHEMATA](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[CATALOG_NAME] [nvarchar] (128) NULL,
	[SCHEMA_NAME] [sysname] NULL,
	[SCHEMA_OWNER] [nvarchar] (128) NULL,
	[DEFAULT_CHARACTER_SET_CATALOG] [sysname] NULL,
	[DEFAULT_CHARACTER_SET_SCHEMA] [sysname] NULL,
	[DEFAULT_CHARACTER_SET_NAME] [sysname] NULL
	CONSTRAINT PK_SCHEMATA PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_SCHEMATA_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [SEQUENCES]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'SEQUENCES'
)
BEGIN
	CREATE TABLE [dbo].[SEQUENCES](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[SEQUENCE_CATALOG] [nvarchar] (128) NULL,
	[SEQUENCE_SCHEMA] [nvarchar] (128) NULL,
	[SEQUENCE_NAME] [sysname] NULL,
	[DATA_TYPE] [nvarchar] (128) NULL,
	[NUMERIC_PRECISION] [tinyint] NULL,
	[NUMERIC_PRECISION_RADIX] [smallint] NULL,
	[NUMERIC_SCALE] [int] NULL,
	[START_VALUE] [sql_variant] NULL,
	[MINIMUM_VALUE] [sql_variant] NULL,
	[MAXIMUM_VALUE] [sql_variant] NULL,
	[INCREMENT] [sql_variant] NULL,
	[CYCLE_OPTION] [bit] NULL,
	[DECLARED_DATA_TYPE] [sysname] NULL,
	[DECLARED_NUMERIC_PRECISION] [tinyint] NULL,
	[DECLARED_NUMERIC_SCALE] [tinyint] NULL
	CONSTRAINT PK_SEQUENCES PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_SEQUENCES_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [TABLE_CONSTRAINTS]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'TABLE_CONSTRAINTS'
)
BEGIN
	CREATE TABLE [dbo].[TABLE_CONSTRAINTS](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[CONSTRAINT_CATALOG] [nvarchar] (128) NULL,
	[CONSTRAINT_SCHEMA] [nvarchar] (128) NULL,
	[CONSTRAINT_NAME] [sysname] NULL,
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[CONSTRAINT_TYPE] [varchar] (11) NULL,
	[IS_DEFERRABLE] [varchar] (2) NULL,
	[INITIALLY_DEFERRED] [varchar] (2) NULL
	CONSTRAINT PK_TABLE_CONSTRAINTS PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_TABLE_CONSTRAINTS_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [TABLE_PRIVILEGES]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'TABLE_PRIVILEGES'
)
BEGIN
	CREATE TABLE [dbo].[TABLE_PRIVILEGES](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[GRANTOR] [nvarchar] (128) NULL,
	[GRANTEE] [nvarchar] (128) NULL,
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[PRIVILEGE_TYPE] [varchar] (10) NULL,
	[IS_GRANTABLE] [varchar] (3) NULL
	CONSTRAINT PK_TABLE_PRIVILEGES PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_TABLE_PRIVILEGES_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [TABLES]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'TABLES'
)
BEGIN
	CREATE TABLE [dbo].[TABLES](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [sysname] NULL,
	[TABLE_NAME] [sysname] NULL,
	[TABLE_TYPE] [varchar] (10) NULL
	CONSTRAINT PK_TABLES PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_TABLES_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO


/*Create table [VIEW_COLUMN_USAGE]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'VIEW_COLUMN_USAGE'
)
BEGIN
	CREATE TABLE [dbo].[VIEW_COLUMN_USAGE](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],[VIEW_CATALOG] [nvarchar] (128) NULL,
	[VIEW_SCHEMA] [nvarchar] (128) NULL,
	[VIEW_NAME] [sysname] NULL,
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[COLUMN_NAME] [sysname] NULL
	CONSTRAINT PK_VIEW_COLUMN_USAGE PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_VIEW_COLUMN_USAGE_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [VIEW_TABLE_USAGE]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'VIEW_TABLE_USAGE'
)
BEGIN
	CREATE TABLE [dbo].[VIEW_TABLE_USAGE](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[VIEW_CATALOG] [nvarchar] (128) NULL,
	[VIEW_SCHEMA] [nvarchar] (128) NULL,
	[VIEW_NAME] [sysname] NULL,
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL
	CONSTRAINT PK_VIEW_TABLE_USAGE PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_VIEW_TABLE_USAGE_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO

/*Create table [VIEWS]*/

IF NOT EXISTS 
(
	SELECT s.* FROM 
		sys.tables t 
		INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
	WHERE
		s.[name] = 'dbo' AND
		t.[name] = 'VIEWS'
)
BEGIN
	CREATE TABLE [dbo].[VIEWS](
	[id] [int] IDENTITY (1,1) NOT NULL,
	[db_id] [int],
	[TABLE_CATALOG] [nvarchar] (128) NULL,
	[TABLE_SCHEMA] [nvarchar] (128) NULL,
	[TABLE_NAME] [sysname] NULL,
	[VIEW_DEFINITION] [nvarchar] (4000) NULL,
	[CHECK_OPTION] [varchar] (7) NULL,
	[IS_UPDATABLE] [varchar] (2) NULL
	CONSTRAINT PK_VIEWS PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT FK_VIEWS_databases FOREIGN KEY ([db_id]) REFERENCES [dbo].[databases] ([db_id]))
END;
GO
/* 
=============================================
SP to UPDATE serverproperties in the instances table
=============================================
 */
CREATE OR ALTER   PROCEDURE [dbo].[update_serverproperties]
/*Parameters*/
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

/*Create a view with all the databases
CREATE OR ALTER VIEW dbo.vw_databases
AS 

SELECT 
[dbo].[databases2016].[db_id],
[dbo].[databases2016].[i_id],
[dbo].[databases2016].[name],
[dbo].[databases2016].[database_id],
[dbo].[databases2016].[source_database_id],
[dbo].[databases2016].[owner_sid],
[dbo].[databases2016].[create_date],
[dbo].[databases2016].[compatibility_level],
[dbo].[databases2016].[collation_name],
[dbo].[databases2016].[user_access],
[dbo].[databases2016].[user_access_desc],
[dbo].[databases2016].[is_read_only],
[dbo].[databases2016].[is_auto_close_on],
[dbo].[databases2016].[is_auto_shrink_on],
[dbo].[databases2016].[state],
[dbo].[databases2016].[state_desc],
[dbo].[databases2016].[is_in_standby],
[dbo].[databases2016].[is_cleanly_shutdown],
[dbo].[databases2016].[is_supplemental_logging_enabled],
[dbo].[databases2016].[snapshot_isolation_state],
[dbo].[databases2016].[snapshot_isolation_state_desc],
[dbo].[databases2016].[is_read_committed_snapshot_on],
[dbo].[databases2016].[recovery_model],
[dbo].[databases2016].[recovery_model_desc],
[dbo].[databases2016].[page_verify_option],
[dbo].[databases2016].[page_verify_option_desc],
[dbo].[databases2016].[is_auto_create_stats_on],
[dbo].[databases2016].[is_auto_create_stats_incremental_on],
[dbo].[databases2016].[is_auto_update_stats_on],
[dbo].[databases2016].[is_auto_update_stats_async_on],
[dbo].[databases2016].[is_ansi_null_default_on],
[dbo].[databases2016].[is_ansi_nulls_on],
[dbo].[databases2016].[is_ansi_padding_on],
[dbo].[databases2016].[is_ansi_warnings_on],
[dbo].[databases2016].[is_arithabort_on],
[dbo].[databases2016].[is_concat_null_yields_null_on],
[dbo].[databases2016].[is_numeric_roundabort_on],
[dbo].[databases2016].[is_quoted_identifier_on],
[dbo].[databases2016].[is_recursive_triggers_on],
[dbo].[databases2016].[is_cursor_close_on_commit_on],
[dbo].[databases2016].[is_local_cursor_default],
[dbo].[databases2016].[is_fulltext_enabled],
[dbo].[databases2016].[is_trustworthy_on],
[dbo].[databases2016].[is_db_chaining_on],
[dbo].[databases2016].[is_parameterization_forced],
[dbo].[databases2016].[is_master_key_encrypted_by_server],
[dbo].[databases2016].[is_query_store_on],
[dbo].[databases2016].[is_published],
[dbo].[databases2016].[is_subscribed],
[dbo].[databases2016].[is_merge_published],
[dbo].[databases2016].[is_distributor],
[dbo].[databases2016].[is_sync_with_backup],
[dbo].[databases2016].[service_broker_guid],
[dbo].[databases2016].[is_broker_enabled],
[dbo].[databases2016].[log_reuse_wait],
[dbo].[databases2016].[log_reuse_wait_desc],
[dbo].[databases2016].[is_date_correlation_on],
[dbo].[databases2016].[is_cdc_enabled],
[dbo].[databases2016].[is_encrypted],
[dbo].[databases2016].[is_honor_broker_priority_on],
[dbo].[databases2016].[replica_id],
[dbo].[databases2016].[group_database_id],
[dbo].[databases2016].[resource_pool_id],
[dbo].[databases2016].[default_language_lcid],
[dbo].[databases2016].[default_language_name],
[dbo].[databases2016].[default_fulltext_language_lcid],
[dbo].[databases2016].[default_fulltext_language_name],
[dbo].[databases2016].[is_nested_triggers_on],
[dbo].[databases2016].[is_transform_noise_words_on],
[dbo].[databases2016].[two_digit_year_cutoff],
[dbo].[databases2016].[containment],
[dbo].[databases2016].[containment_desc],
[dbo].[databases2016].[target_recovery_time_in_seconds],
[dbo].[databases2016].[delayed_durability],
[dbo].[databases2016].[delayed_durability_desc],
[dbo].[databases2016].[is_memory_optimized_elevate_to_snapshot_on],
[dbo].[databases2016].[is_federation_member],
[dbo].[databases2016].[is_remote_data_archive_enabled],
[dbo].[databases2016].[is_mixed_page_allocation_on]
FROM 
[dbo].[databases2016]

UNION ALL
SELECT 
[dbo].[databases2019].[db_id],
[dbo].[databases2019].[i_id],
[dbo].[databases2019].[name],
[dbo].[databases2019].[database_id],
[dbo].[databases2019].[source_database_id],
[dbo].[databases2019].[owner_sid],
[dbo].[databases2019].[create_date],
[dbo].[databases2019].[compatibility_level],
[dbo].[databases2019].[collation_name],
[dbo].[databases2019].[user_access],
[dbo].[databases2019].[user_access_desc],
[dbo].[databases2019].[is_read_only],
[dbo].[databases2019].[is_auto_close_on],
[dbo].[databases2019].[is_auto_shrink_on],
[dbo].[databases2019].[state],
[dbo].[databases2019].[state_desc],
[dbo].[databases2019].[is_in_standby],
[dbo].[databases2019].[is_cleanly_shutdown],
[dbo].[databases2019].[is_supplemental_logging_enabled],
[dbo].[databases2019].[snapshot_isolation_state],
[dbo].[databases2019].[snapshot_isolation_state_desc],
[dbo].[databases2019].[is_read_committed_snapshot_on],
[dbo].[databases2019].[recovery_model],
[dbo].[databases2019].[recovery_model_desc],
[dbo].[databases2019].[page_verify_option],
[dbo].[databases2019].[page_verify_option_desc],
[dbo].[databases2019].[is_auto_create_stats_on],
[dbo].[databases2019].[is_auto_create_stats_incremental_on],
[dbo].[databases2019].[is_auto_update_stats_on],
[dbo].[databases2019].[is_auto_update_stats_async_on],
[dbo].[databases2019].[is_ansi_null_default_on],
[dbo].[databases2019].[is_ansi_nulls_on],
[dbo].[databases2019].[is_ansi_padding_on],
[dbo].[databases2019].[is_ansi_warnings_on],
[dbo].[databases2019].[is_arithabort_on],
[dbo].[databases2019].[is_concat_null_yields_null_on],
[dbo].[databases2019].[is_numeric_roundabort_on],
[dbo].[databases2019].[is_quoted_identifier_on],
[dbo].[databases2019].[is_recursive_triggers_on],
[dbo].[databases2019].[is_cursor_close_on_commit_on],
[dbo].[databases2019].[is_local_cursor_default],
[dbo].[databases2019].[is_fulltext_enabled],
[dbo].[databases2019].[is_trustworthy_on],
[dbo].[databases2019].[is_db_chaining_on],
[dbo].[databases2019].[is_parameterization_forced],
[dbo].[databases2019].[is_master_key_encrypted_by_server],
[dbo].[databases2019].[is_query_store_on],
[dbo].[databases2019].[is_published],
[dbo].[databases2019].[is_subscribed],
[dbo].[databases2019].[is_merge_published],
[dbo].[databases2019].[is_distributor],
[dbo].[databases2019].[is_sync_with_backup],
[dbo].[databases2019].[service_broker_guid],
[dbo].[databases2019].[is_broker_enabled],
[dbo].[databases2019].[log_reuse_wait],
[dbo].[databases2019].[log_reuse_wait_desc],
[dbo].[databases2019].[is_date_correlation_on],
[dbo].[databases2019].[is_cdc_enabled],
[dbo].[databases2019].[is_encrypted],
[dbo].[databases2019].[is_honor_broker_priority_on],
[dbo].[databases2019].[replica_id],
[dbo].[databases2019].[group_database_id],
[dbo].[databases2019].[resource_pool_id],
[dbo].[databases2019].[default_language_lcid],
[dbo].[databases2019].[default_language_name],
[dbo].[databases2019].[default_fulltext_language_lcid],
[dbo].[databases2019].[default_fulltext_language_name],
[dbo].[databases2019].[is_nested_triggers_on],
[dbo].[databases2019].[is_transform_noise_words_on],
[dbo].[databases2019].[two_digit_year_cutoff],
[dbo].[databases2019].[containment],
[dbo].[databases2019].[containment_desc],
[dbo].[databases2019].[target_recovery_time_in_seconds],
[dbo].[databases2019].[delayed_durability],
[dbo].[databases2019].[delayed_durability_desc],
[dbo].[databases2019].[is_memory_optimized_elevate_to_snapshot_on],
[dbo].[databases2019].[is_federation_member],
[dbo].[databases2019].[is_remote_data_archive_enabled],
[dbo].[databases2019].[is_mixed_page_allocation_on]
FROM 
[dbo].[databases2019] 

UNION ALL
SELECT 
[dbo].[databases2022].[db_id],
[dbo].[databases2022].[i_id],
[dbo].[databases2022].[name],
[dbo].[databases2022].[database_id],
[dbo].[databases2022].[source_database_id],
[dbo].[databases2022].[owner_sid],
[dbo].[databases2022].[create_date],
[dbo].[databases2022].[compatibility_level],
[dbo].[databases2022].[collation_name],
[dbo].[databases2022].[user_access],
[dbo].[databases2022].[user_access_desc],
[dbo].[databases2022].[is_read_only],
[dbo].[databases2022].[is_auto_close_on],
[dbo].[databases2022].[is_auto_shrink_on],
[dbo].[databases2022].[state],
[dbo].[databases2022].[state_desc],
[dbo].[databases2022].[is_in_standby],
[dbo].[databases2022].[is_cleanly_shutdown],
[dbo].[databases2022].[is_supplemental_logging_enabled],
[dbo].[databases2022].[snapshot_isolation_state],
[dbo].[databases2022].[snapshot_isolation_state_desc],
[dbo].[databases2022].[is_read_committed_snapshot_on],
[dbo].[databases2022].[recovery_model],
[dbo].[databases2022].[recovery_model_desc],
[dbo].[databases2022].[page_verify_option],
[dbo].[databases2022].[page_verify_option_desc],
[dbo].[databases2022].[is_auto_create_stats_on],
[dbo].[databases2022].[is_auto_create_stats_incremental_on],
[dbo].[databases2022].[is_auto_update_stats_on],
[dbo].[databases2022].[is_auto_update_stats_async_on],
[dbo].[databases2022].[is_ansi_null_default_on],
[dbo].[databases2022].[is_ansi_nulls_on],
[dbo].[databases2022].[is_ansi_padding_on],
[dbo].[databases2022].[is_ansi_warnings_on],
[dbo].[databases2022].[is_arithabort_on],
[dbo].[databases2022].[is_concat_null_yields_null_on],
[dbo].[databases2022].[is_numeric_roundabort_on],
[dbo].[databases2022].[is_quoted_identifier_on],
[dbo].[databases2022].[is_recursive_triggers_on],
[dbo].[databases2022].[is_cursor_close_on_commit_on],
[dbo].[databases2022].[is_local_cursor_default],
[dbo].[databases2022].[is_fulltext_enabled],
[dbo].[databases2022].[is_trustworthy_on],
[dbo].[databases2022].[is_db_chaining_on],
[dbo].[databases2022].[is_parameterization_forced],
[dbo].[databases2022].[is_master_key_encrypted_by_server],
[dbo].[databases2022].[is_query_store_on],
[dbo].[databases2022].[is_published],
[dbo].[databases2022].[is_subscribed],
[dbo].[databases2022].[is_merge_published],
[dbo].[databases2022].[is_distributor],
[dbo].[databases2022].[is_sync_with_backup],
[dbo].[databases2022].[service_broker_guid],
[dbo].[databases2022].[is_broker_enabled],
[dbo].[databases2022].[log_reuse_wait],
[dbo].[databases2022].[log_reuse_wait_desc],
[dbo].[databases2022].[is_date_correlation_on],
[dbo].[databases2022].[is_cdc_enabled],
[dbo].[databases2022].[is_encrypted],
[dbo].[databases2022].[is_honor_broker_priority_on],
[dbo].[databases2022].[replica_id],
[dbo].[databases2022].[group_database_id],
[dbo].[databases2022].[resource_pool_id],
[dbo].[databases2022].[default_language_lcid],
[dbo].[databases2022].[default_language_name],
[dbo].[databases2022].[default_fulltext_language_lcid],
[dbo].[databases2022].[default_fulltext_language_name],
[dbo].[databases2022].[is_nested_triggers_on],
[dbo].[databases2022].[is_transform_noise_words_on],
[dbo].[databases2022].[two_digit_year_cutoff],
[dbo].[databases2022].[containment],
[dbo].[databases2022].[containment_desc],
[dbo].[databases2022].[target_recovery_time_in_seconds],
[dbo].[databases2022].[delayed_durability],
[dbo].[databases2022].[delayed_durability_desc],
[dbo].[databases2022].[is_memory_optimized_elevate_to_snapshot_on],
[dbo].[databases2022].[is_federation_member],
[dbo].[databases2022].[is_remote_data_archive_enabled],
[dbo].[databases2022].[is_mixed_page_allocation_on]
FROM 
[dbo].[databases2022] 
*/
