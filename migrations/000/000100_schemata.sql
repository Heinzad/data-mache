
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


SET NOEXEC OFF
GO

:setvar DatabaseName "base"
GO
IF ('$(DatabaseName)' = '$' + '(DatabaseName)')
    RAISERROR ('This script must be run in SQLCMD mode. Disconnecting.', 20, 1) WITH LOG
GO
IF @@ERROR != 0
    SET NOEXEC ON
GO


/* base\meta\schemata\meta.Schema.sql
-- -------------------------------------------------- --

-- -------------------------------------------------- */

CREATE SCHEMA meta AUTHORIZATION dbo;
GO
