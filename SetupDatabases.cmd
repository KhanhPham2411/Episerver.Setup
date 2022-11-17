:: Setup EPiServer CMS and Commerce databases
@echo off

set user=Quicksilver
set password=Episerver15

set cms_db=Quicksilver.Cms
set commerce_db=Quicksilver.Commerce

set sql=sqlcmd -S . -E

:: Determine CMS package folders
for /F " tokens=*" %%i in ('dir "..\Packages\EPiServer.CMS.Core*" /b /o:d') do (set cms_core=%%i) 
if "%cms_core%"=="" (
	echo CMS Core package is missing. Please build the project before running the setup.
	exit /b
)

echo Dropping CMS databases...
%sql% -Q "EXEC msdb.dbo.sp_delete_database_backuphistory N'%cms_db%'"
%sql% -Q "if db_id('%cms_db%') is not null ALTER DATABASE [%cms_db%] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
%sql% -Q "if db_id('%cms_db%') is not null DROP DATABASE [%cms_db%]"

echo Creating CMS databases...
%sql% -Q "CREATE DATABASE [%cms_db%] COLLATE SQL_Latin1_General_CP1_CI_AS"

echo Installing CMS database...
%sql% -d %cms_db% -b -i "..\packages\%cms_core%\tools\EPiServer.Cms.Core.sql" > SetupCmsDb.log

:: Determine Commerce package folders
for /F " tokens=*" %%i in ('dir "..\Packages\EPiServer.Commerce.Core*" /b /o:d') do (set commerce_core=%%i)
if "%commerce_core%"=="" (
	echo Commerce Core package is missing. Please build the project before running the setup.
	exit /b
)

echo Dropping Commerce databases...
%sql% -Q "EXEC msdb.dbo.sp_delete_database_backuphistory N'%commerce_db%'"
%sql% -Q "if db_id('%commerce_db%') is not null ALTER DATABASE [%commerce_db%] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
%sql% -Q "if db_id('%commerce_db%') is not null DROP DATABASE [%commerce_db%]"

echo Creating Commerce databases...
%sql% -Q "CREATE DATABASE [%commerce_db%] COLLATE SQL_Latin1_General_CP1_CI_AS"

echo Installing Commerce database...
%sql% -d %commerce_db% -b -i "..\packages\%commerce_core%\tools\EPiServer.Commerce.Core.sql" > SetupCommerceDb.log

echo Installing ASP.NET Identity...
%sql% -d %commerce_db% -b -i ".\aspnet_identity.sql" > SetupIdentity.log

:: Determine Personalization Commerce package folders
for /F " tokens=*" %%i in ('dir "..\Packages\EPiServer.Personalization.Commerce*" /b /o:d') do (set personalization_commerce=%%i) 
if "%personalization_commerce%"=="" (
	echo Personalization Commerce package is missing. Please build the project before running the setup.
	exit /b
)

echo Installing Personalization Commerce database...
%sql% -d %commerce_db% -b -i "..\packages\%personalization_commerce%\tools\epiupdates_commerce\sql\1.0.0.sql" > SetupPersonalizationCommerce.log

@REM echo Dropping user...
@REM %sql% -Q "if exists (select loginname from master.dbo.syslogins where name = '%user%') EXEC sp_droplogin @loginame='%user%'"
@REM echo Creating user...
@REM %sql% -Q "EXEC sp_addlogin @loginame='%user%', @passwd='%password%', @defdb='%cms_db%'"
@REM %sql% -d %cms_db% -Q "EXEC sp_adduser @loginame='%user%'"
@REM %sql% -d %cms_db% -Q "EXEC sp_addrolemember N'db_owner', N'%user%'"
@REM %sql% -d %commerce_db% -Q "EXEC sp_adduser @loginame='%user%'"
@REM %sql% -d %commerce_db% -Q "EXEC sp_addrolemember N'db_owner', N'%user%'"


Pause
