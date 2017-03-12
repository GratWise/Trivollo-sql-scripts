IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND name = 'sp_ColumnDesc')
	DROP PROCEDURE sp_ColumnDesc
GO

IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND name = 'sp_MergeUsers')
	DROP PROCEDURE sp_MergeUsers
GO

IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND name = 'sp_RemoveUser')
	DROP PROCEDURE sp_RemoveUser
GO

IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND name = 'sp_TableDesc')
	DROP PROCEDURE sp_TableDesc
GO

EXEC
('
	CREATE PROCEDURE sp_ColumnDesc(@tableName SYSNAME, @columnName SYSNAME, @description SQL_VARIANT)
	AS
		IF EXISTS 
				(	
					SELECT 1 
					FROM fn_listextendedproperty(''Description'', ''SCHEMA'', ''lebryant'', ''TABLE'', @tableName, ''COLUMN'', @columnName)
				)
			EXEC sp_dropextendedproperty ''Description'', ''SCHEMA'', ''lebryant'', ''TABLE'', @tableName, ''COLUMN'', @columnName

		IF (NOT @description IS NULL) AND (NOT @description = '''')
			EXEC sp_addextendedproperty ''Description'', @description, ''SCHEMA'', ''lebryant'', ''TABLE'', @tableName, ''COLUMN'', @columnName
')
GO

EXEC
('
	CREATE PROCEDURE sp_RemoveUser(@userId INT)
	AS
		DELETE tblPasswordReset
		FROM tblPasswordReset
		INNER JOIN tblUserEmails ON usem_email = pwr_email
		WHERE usem_us_id = @userId;

		DELETE tblUserSocialMedia WHERE ussm_us_id = @userId;
		DELETE tblUserEmails WHERE usem_us_id = @userId;
		DELETE tblUsers WHERE us_id = @userId;
')
GO

EXEC
('
	CREATE PROCEDURE sp_MergeUsers(@userId1 INT, @userId2 INT)
	AS
		UPDATE tblUserSocialMedia SET ussm_us_id = @userId1 WHERE ussm_us_id = @userId2;
		UPDATE tblUserEmails SET usem_us_id = @userId1 WHERE usem_us_id = @userId2;
		UPDATE tblUserEmails SET usem_us_id = @userId1 WHERE usem_us_id = @userId2;
		EXEC sp_RemoveUser @userId2;
')
GO

EXEC
('
	CREATE PROCEDURE sp_TableDesc(@tableName SYSNAME, @description SQL_VARIANT)
	AS
		IF EXISTS
			(
				SELECT 1
				FROM fn_listextendedproperty(''Description'', ''SCHEMA'', ''lebryant'', ''TABLE'', @tableName, NULL, NULL)
			)
			EXEC sp_dropextendedproperty ''Description'', ''SCHEMA'', ''lebryant'', ''TABLE'', @tableName

		IF (NOT @description IS NULL) AND (NOT @description = '''')
			EXEC sp_addextendedproperty ''Description'', @description, ''SCHEMA'', ''lebryant'', ''TABLE'', @tableName
')
GO
