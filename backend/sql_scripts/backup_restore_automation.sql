-- ========================================================================================
-- 🛡️ Automated Backup & Restore Script for LanguageAppDB (SQL Server 2019/2022/Docker)
-- ========================================================================================

USE LanguageAppDB;
GO

-- 1. Run Full Backup using Stored Procedure
PRINT '⏳ [Backup] Executing Full Backup of LanguageAppDB...';
EXEC dbo.sp_BackupLanguageAppDB @BackupDirectory = N'/var/opt/mssql/backup', @BackupType = 'FULL';
GO

-- 2. Print Restore Guidance
EXEC dbo.sp_RestoreLanguageAppDB_Guidance;
GO
