$params = @{
    TrustServerCertificate = $true
    ServerInstance         = 'AutoMagically\V01'
    Database               = 'master'
    Query                  = "SELECT [name] FROM sys.databases ORDER BY [name] DESC"
    ErrorAction            = 'SilentlyContinue'
}
$DbNames = (Invoke-Sqlcmd @params).name
foreach ($DbName in $DbNames)
{
  New-Item -Path 'c:\Dataminds\' -ItemType File -Name "$($DbName).txt" -ErrorAction SilentlyContinue
}