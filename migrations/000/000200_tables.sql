
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


/* base\meta\tables\design_schema.Table.sql
-- -------------------------------------------------- --
-- -------------------------------------------------- */

CREATE TABLE [meta].[design_schema] 
(
    design_schema_id int identity not null, 
    design_schema_name varchar(128) not null,  
    design_schema_description varchar(256) not null,
    CONSTRAINT design_schema_pk PRIMARY KEY (design_schema_id),
    CONSTRAINT design_schema_uk UNIQUE (design_schema_name)
)
;
GO
