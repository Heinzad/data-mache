/* USER-DEFINED FUNCTIONS

column_generator
test_column_exists
test_database_exists
test_schema_exists
test_table_exists
*/ 



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



/* column_generator.UserDefinedFunction.sql
-- -------------------------------------------------- --  
-- script_name: meta.column_generator.Function.sql 
-- script_author: Adam Heinz 
-- script_date: 6 Feb 2023 
-- script_license: MIT 
-- -------------------------------------------------- */

CREATE OR ALTER FUNCTION [meta].[column_generator] ( 
 @p_catalog_name varchar(128) 
,@p_schema_name varchar(128) 
,@p_table_name varchar(128) 
,@p_columns_tbl [meta].[column_schemata] READONLY 
) 
RETURNS varchar(8000) 
/* 	Column Generator 
	Returns a string of column ddl for given column definitions 
	Used in table generation ddl 
	Assumes one table is in the param 

	Parameters
	----------
	p_catalog_name varchar(128)
    	Name of the database by which to filter the given columns table 
	p_schema_name varchar(128) 
		Name of the schema by which to filter the given columns table 
	p_table_name varchar(128)
		Name of the table by which to filter the given columns table 
	p_columns_tbl [meta].[column_schemata] -- table-valued variable of `column_schemata` type 
		Table of column definitions reflecting the structure of information schema columns.
*/
AS 
BEGIN /* functionality */ 

	DECLARE		/* prevent parameter sniffing */ 
	@v_catalog_name varchar(128) = @p_catalog_name  
	,@v_schema_name varchar(128) = @p_schema_name 
	,@v_table_name varchar(128) = @p_table_name 
	;  

	DECLARE @sql_string varchar(256) 

	SET @sql_string = ( 
		SELECT col_str = STUFF(( 
			SELECT TOP 100 PERCENT cols = CHAR(44)
			+ QUOTENAME(c.[column_name]) 
			+ CHAR(32) 
			+ QUOTENAME(LOWER(c.[data_type]))  
			+ COALESCE( 
				CHAR(40) + 
				CASE 
					WHEN QUOTENAME(LOWER(c.[data_type])) IN ('[decimal]', '[numeric]') 
						THEN TRY_CONVERT(varchar, c.numeric_precision) + COALESCE(CHAR(44) + TRY_CONVERT(varchar, c.numeric_scale), '')  
					WHEN QUOTENAME(LOWER(c.[data_type])) LIKE '%char]' 
						THEN TRY_CONVERT(varchar, CASE WHEN c.character_maximum_length =  -1 THEN 'max' ELSE c.character_maximum_length END )  
					WHEN QUOTENAME(LOWER(c.[data_type])) LIKE '[date%'
						THEN TRY_CONVERT(varchar, c.datetime_precision)	
				END + CHAR(41)  
				,''  
			) 
			+ CHAR(32) /* space */ 
			+ COALESCE( 
				CASE 
				WHEN c.column_default = 'SEQ' /* sequence */  
				THEN CHAR(10) + CHAR(9) 
				+ 'CONSTRAINT ' + QUOTENAME(c.column_name + '_DF') + ' DEFAULT ' + CHAR(40) 
				+ 'NEXT VALUE FOR' + CHAR(32) 
				+ QUOTENAME(LOWER(c.table_schema)) + CHAR(46) + QUOTENAME(UPPER(c.table_name + CHAR(95) + c.column_default)) 
				+ CHAR(41) + CHAR(32) + CHAR(10) + CHAR(9) 
				END 
			,'')
			
			+ COALESCE(
				CASE 
				WHEN UPPER(c.is_nullable) = 'YES' THEN 'NULL' 
				WHEN UPPER(c.is_nullable) = 'NO' THEN 'NOT NULL' 
				ELSE UPPER(c.is_nullable) 
				END 
			, '') 

			+ CHAR(10) /* new line */ 

			from @p_columns_tbl as c 
			WHERE c.table_catalog = @v_catalog_name 
			AND c.table_schema = @v_schema_name 
			AND c.table_name = @v_table_name 
			order by c.[ordinal_position] 
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')  ,1,1,'')
	) 

	RETURN @sql_string ; 
END /* functionality */ 
; 
GO

EXEC sys.sp_addextendedproperty 
@name=N'MS_Description', @value=N'Column Generator 
---- Returns a string of column scoped ddl for a given set of column definitions.  
---- Assumes one table is provided in the param ' 
,@level0type=N'SCHEMA',@level0name=N'meta'
,@level1type=N'FUNCTION',@level1name=N'column_generator'
GO




/* test_column_exists.UserDefinedFunction.sql 
-- -------------------------------------------------- --
-- script_name:		meta.test_column_exists.Function.sql 
-- script_author:	Adam Heinz
-- script_license:	MIT 
-- script_date		23 April 2023 
-- -------------------------------------------------- */

CREATE   FUNCTION [meta].[test_column_exists] ( 
	 @p_test_schema nvarchar(128)	/* schema name to verify */ 
	,@p_test_table nvarchar(128)	/* table name to verify */ 
	,@p_test_column nvarchar(128)	/* column name to verify */ 
) 
RETURNS bit 
/* test column exists  
-- Returns false if a given column name does not exist 
-- Query derived from Information Schema Columns view definition  
*/ 
AS 
BEGIN 
	
	DECLARE /* return value */ 
	@assert bit = 0 

	DECLARE /* prevent parameter sniffing */ 
	 @v_test_schema nvarchar(128) = @p_test_schema  
	,@v_test_table nvarchar(128) = @p_test_table   
	,@v_test_column nvarchar(128) = @p_test_column  

	IF EXISTS ( 
		SELECT 1 
		FROM sys.objects o 
		INNER JOIN sys.schemas s   
		ON s.schema_id = o.schema_id 
		INNER JOIN sys.columns c 
		ON c.object_id = o.object_id   
		INNER JOIN sys.types t 
		ON c.user_type_id = t.user_type_id  
		WHERE o.type IN ('U', 'V') 
		AND QUOTENAME(s.[name]) = QUOTENAME(@v_test_schema) 
		AND QUOTENAME(o.[name]) = QUOTENAME(@v_test_table)  
		AND QUOTENAME(c.[name]) = QUOTENAME(@v_test_column) 
	) 
	SET @assert = 1 

	RETURN @assert  
END 
GO




/* test_database_exists.UserDefinedFunction.sql 
-- -------------------------------------------------- --
-- script_name: meta.test_database_exists.Function.sql 
-- script_author: Adam Heinz
-- script_license: MIT 
-- script_date 23 April 2023 
-- -------------------------------------------------- */

CREATE   FUNCTION [meta].[test_database_exists] ( 
	@p_test_database nvarchar(128)	/* database name to check */ 
) 
RETURNS bit 
/* test database exists  
-- Searches sys databases for a given database name 
-- Returns false if given database name does not exist 
-- N.B. "Catalog" is a synonym for database in the information schema. 
*/ 
AS 
BEGIN 
	
	DECLARE @assert bit = 0 

	DECLARE /* prevent parameter sniffing */ 
	@v_test_database nvarchar(128) = @p_test_database 

	IF EXISTS ( 
		SELECT 1 
		FROM [sys].[databases] as d 
		WHERE QUOTENAME(d.[name]) = QUOTENAME(@v_test_database) 
	) 
	SET @assert = 1 

	RETURN @assert  
END 
GO




/* test_schema_exists.UserDefinedFunction.sql 
-- -------------------------------------------------- --
-- script_name: meta.test_schema_exists.Function.sql 
-- script_author: Adam Heinz
-- script_license: MIT 
-- script_date 23 April 2023 
-- -------------------------------------------------- */

CREATE   FUNCTION [meta].[test_schema_exists] ( 
	 @p_test_schema nvarchar(128)	/* schema name to verify */ 
) 
RETURNS bit 
/* test schema exists  
-- Returns False if a given schema does not exist 
-- Query derived from Information Schema Schemata view definition 
*/ 
AS 
BEGIN 
	
	DECLARE /* return value */ 
	@assert bit = 'False'  

	DECLARE /* prevent parameter sniffing */ 
	 @v_test_schema nvarchar(128) = @p_test_schema 

	IF EXISTS ( 
		SELECT 1  
		FROM [sys].[schemas] as s 
		WHERE QUOTENAME(s.[name]) = QUOTENAME(@v_test_schema) 
	) 
	SET @assert = 'True'  

	RETURN @assert  
END 
GO




/* test_table_exists.UserDefinedFunction.sql 
-- -------------------------------------------------- --
-- script_name:		meta.test_table_exists.UserDefinedFunction.sql 
-- script_author:	Adam Heinz
-- script_license:	MIT 
-- script_date		23 April 2023 
-- -------------------------------------------------- */

CREATE   FUNCTION [meta].[test_table_exists] ( 
	 @p_test_schema nvarchar(128)	/* schema name to verify */ 
	,@p_test_table nvarchar(128)	/* table name to verify */ 
) 
RETURNS bit 
/* test table exists  
-- Returns false if a given table name does not exist 
-- Query derived from Information Schema Tables view definition  
*/ 
AS 
BEGIN 
	
	DECLARE /* return value */ 
	@assert bit = 0 

	DECLARE /* prevent parameter sniffing */ 
	 @v_test_schema nvarchar(128) = @p_test_schema  
	,@v_test_table nvarchar(128) = @p_test_table  

	IF EXISTS ( 
		SELECT 1 
		FROM sys.objects o 
		INNER JOIN sys.schemas s   
		ON s.schema_id = o.schema_id  
		WHERE o.type IN (
			 'U' /* table */ 
			,'V' /* view */ 
		) 
		AND QUOTENAME(s.[name]) = QUOTENAME(@v_test_schema) 
		AND QUOTENAME(o.[name]) = QUOTENAME(@v_test_table)  
	) 
	SET @assert = 1 

	RETURN @assert  
END 
GO
