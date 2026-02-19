WITH Props AS
(
    SELECT
        ROW_NUMBER() OVER (ORDER BY v.PropertyName) AS rn,
        v.PropertyName,
        v.PropertyValue
    FROM (VALUES
        ('BuildClrVersion',                    CONVERT(nvarchar(256), SERVERPROPERTY('BuildClrVersion'))),
        ('Collation',                          CONVERT(nvarchar(256), SERVERPROPERTY('Collation'))),
        ('CollationID',                        CONVERT(nvarchar(256), SERVERPROPERTY('CollationID'))),
        ('ComparisonStyle',                    CONVERT(nvarchar(256), SERVERPROPERTY('ComparisonStyle'))),
        ('ComputerNamePhysicalNetBIOS',        CONVERT(nvarchar(256), SERVERPROPERTY('ComputerNamePhysicalNetBIOS'))),
        ('Edition',                            CONVERT(nvarchar(256), SERVERPROPERTY('Edition'))),
        ('EditionID',                          CONVERT(nvarchar(256), SERVERPROPERTY('EditionID'))),
        ('EngineEdition',                      CONVERT(nvarchar(256), SERVERPROPERTY('EngineEdition'))),
        ('FilestreamConfiguredLevel',          CONVERT(nvarchar(256), SERVERPROPERTY('FilestreamConfiguredLevel'))),
        ('FilestreamEffectiveLevel',           CONVERT(nvarchar(256), SERVERPROPERTY('FilestreamEffectiveLevel'))),
        ('FilestreamShareName',                CONVERT(nvarchar(256), SERVERPROPERTY('FilestreamShareName'))),
        ('HadrManagerStatus',                  CONVERT(nvarchar(256), SERVERPROPERTY('HadrManagerStatus'))),
        ('InstanceDefaultBackupPath',          CONVERT(nvarchar(256), SERVERPROPERTY('InstanceDefaultBackupPath'))),
        ('InstanceDefaultDataPath',            CONVERT(nvarchar(256), SERVERPROPERTY('InstanceDefaultDataPath'))),
        ('InstanceDefaultLogPath',             CONVERT(nvarchar(256), SERVERPROPERTY('InstanceDefaultLogPath'))),
        ('InstanceName',                       CONVERT(nvarchar(256), SERVERPROPERTY('InstanceName'))),
        ('IsAdvancedAnalyticsInstalled',       CONVERT(nvarchar(256), SERVERPROPERTY('IsAdvancedAnalyticsInstalled'))),
        ('IsBigDataCluster',                   CONVERT(nvarchar(256), SERVERPROPERTY('IsBigDataCluster'))),
        ('IsClustered',                        CONVERT(nvarchar(256), SERVERPROPERTY('IsClustered'))),
        ('IsExternalAuthenticationOnly',       CONVERT(nvarchar(256), SERVERPROPERTY('IsExternalAuthenticationOnly'))),
        ('IsExternalGovernanceEnabled',        CONVERT(nvarchar(256), SERVERPROPERTY('IsExternalGovernanceEnabled'))),
        ('IsFullTextInstalled',                CONVERT(nvarchar(256), SERVERPROPERTY('IsFullTextInstalled'))),
        ('IsHadrEnabled',                      CONVERT(nvarchar(256), SERVERPROPERTY('IsHadrEnabled'))),
        ('IsIntegratedSecurityOnly',           CONVERT(nvarchar(256), SERVERPROPERTY('IsIntegratedSecurityOnly'))),
        ('IsLocalDB',                          CONVERT(nvarchar(256), SERVERPROPERTY('IsLocalDB'))),
        ('IsPolyBaseInstalled',                CONVERT(nvarchar(256), SERVERPROPERTY('IsPolyBaseInstalled'))),
        ('IsServerSuspendedForSnapshotBackup', CONVERT(nvarchar(256), SERVERPROPERTY('IsServerSuspendedForSnapshotBackup'))),
        ('IsSingleUser',                       CONVERT(nvarchar(256), SERVERPROPERTY('IsSingleUser'))),
        ('IsTempDbMetadataMemoryOptimized',    CONVERT(nvarchar(256), SERVERPROPERTY('IsTempDbMetadataMemoryOptimized'))),
        ('IsXTPSupported',                     CONVERT(nvarchar(256), SERVERPROPERTY('IsXTPSupported'))),
        ('LCID',                               CONVERT(nvarchar(256), SERVERPROPERTY('LCID'))),
        ('LicenseType',                        CONVERT(nvarchar(256), SERVERPROPERTY('LicenseType'))),
        ('MachineName',                        CONVERT(nvarchar(256), SERVERPROPERTY('MachineName'))),
        ('NumLicenses',                        CONVERT(nvarchar(256), SERVERPROPERTY('NumLicenses'))),
        ('PathSeparator',                      CONVERT(nvarchar(256), SERVERPROPERTY('PathSeparator'))),
        ('ProcessID',                          CONVERT(nvarchar(256), SERVERPROPERTY('ProcessID'))),
        ('ProductBuild',                       CONVERT(nvarchar(256), SERVERPROPERTY('ProductBuild'))),
        ('ProductBuildType',                   CONVERT(nvarchar(256), SERVERPROPERTY('ProductBuildType'))),
        ('ProductLevel',                       CONVERT(nvarchar(256), SERVERPROPERTY('ProductLevel'))),
        ('ProductMajorVersion',                CONVERT(nvarchar(256), SERVERPROPERTY('ProductMajorVersion'))),
        ('ProductMinorVersion',                CONVERT(nvarchar(256), SERVERPROPERTY('ProductMinorVersion'))),
        ('ProductUpdateLevel',                 CONVERT(nvarchar(256), SERVERPROPERTY('ProductUpdateLevel'))),
        ('ProductUpdateReference',             CONVERT(nvarchar(256), SERVERPROPERTY('ProductUpdateReference'))),
        ('ProductVersion',                     CONVERT(nvarchar(256), SERVERPROPERTY('ProductVersion'))),
        ('ResourceLastUpdateDateTime',         CONVERT(nvarchar(256), SERVERPROPERTY('ResourceLastUpdateDateTime'))),
        ('ResourceVersion',                    CONVERT(nvarchar(256), SERVERPROPERTY('ResourceVersion'))),
        ('ServerName',                         CONVERT(nvarchar(256), SERVERPROPERTY('ServerName'))),
        ('SqlCharSet',                         CONVERT(nvarchar(256), SERVERPROPERTY('SqlCharSet'))),
        ('SqlCharSetName',                     CONVERT(nvarchar(256), SERVERPROPERTY('SqlCharSetName'))),
        ('SqlSortOrder',                       CONVERT(nvarchar(256), SERVERPROPERTY('SqlSortOrder'))),
        ('SqlSortOrderName',                   CONVERT(nvarchar(256), SERVERPROPERTY('SqlSortOrderName'))),
        ('SuspendedDatabaseCount',             CONVERT(nvarchar(256), SERVERPROPERTY('SuspendedDatabaseCount')))
    ) v(PropertyName, PropertyValue)
),
LeftSide AS
(
    SELECT rn, PropertyName, PropertyValue
    FROM Props
    WHERE rn <= 26
),
RightSide AS
(
    SELECT rn - 26 AS rn, PropertyName, PropertyValue
    FROM Props
    WHERE rn > 26
)
SELECT
    L.PropertyName  AS Property,
    L.PropertyValue AS Value,
    R.PropertyName  AS Property,
    R.PropertyValue AS Value
FROM LeftSide L
LEFT JOIN RightSide R
    ON L.rn = R.rn
ORDER BY L.rn;
