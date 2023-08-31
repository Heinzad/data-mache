

/* Column Generator 
-- Returns a string of column ddl for given column definitions 
-- Used in table generation ddl 
-- Assumes one table is in the param 
-- -------------------------------------------------- ---  
-- script_name: meta.column_generator.Function.sql 
-- script_author: Adam Heinz 
-- script_date: 6 Feb 2023 
-- script_license: MIT 
-- -------------------------------------------------- ---  
-- example_usage: 

------DECLARE	@col_defn [meta].[column_schemata] ; 
------DECLARE @col_string  varchar(8000) ; 
------DECLARE 
------ @catalog_name varchar(128) = 'testdb' 
------,@schema_name varchar(128) = 'testing' 
------,@table_name varchar(128) = 'testable'
------; 

------INSERT INTO @col_defn ( 
------ [table_catalog] 
------,[table_schema] 
------,[table_name] 
------,[column_name] 
------,[ordinal_position] 
------,[column_default] 
------,[is_nullable] 
------,[data_type] 
------,[character_maximum_length] 
------,[numeric_precision] 
------,[numeric_scale] 
------,[datetime_precision] 
------) 
------SELECT 
------[table_catalog] 
------,[table_schema] 
------,[table_name] 
------,[column_name] 
------,[ordinal_position] 
------,[column_default] 
------,[is_nullable] 
------,[data_type] 
------,[character_maximum_length] 
------,[numeric_precision] 
------,[numeric_scale] 
------,[datetime_precision] 
------FROM ( 
------VALUES 
------	( 
------		 @catalog_name  
------		,@schema_name  
------		,@table_name
------		,'CHARACTER_DEMO' 
------		,1 
------		,NULL 
------		,'YES' 
------		,'varchar' 
------		,50 
------		,NULL 
------		,NULL 
------		,NULL
------	) 
------	,( 
------		 @catalog_name  
------		,@schema_name  
------		,@table_name
------		,'NUMERIC_DEMO' 
------		,2 
------		,NULL 
------		,'YES' 
------		,'decimal' 
------		,NULL 
------		,8 
------		,0 
------		,NULL
------	) 
------	,( 
------		 @catalog_name  
------		,@schema_name  
------		,@table_name  
------		,'DATE_DEMO' 
------		,3 
------		,NULL 
------		,'YES' 
------		,'datetime2' 
------		,NULL 
------		,NULL  
------		,NULL  
------		,7 
------	)
------	,( 
------		 @catalog_name  
------		,@schema_name  
------		,@table_name  
------		,'SEQUENCE_DEMO' 
------		,4 
------		,'SEQ' 
------		,'NO' 
------		,'bigint' 
------		,NULL 
------		,NULL  
------		,NULL  
------		,7 
------	)  
------) as v ( 
------[table_catalog] 
------,[table_schema] 
------,[table_name] 
------,[column_name] 
------,[ordinal_position] 
------,[column_default] 
------,[is_nullable] 
------,[data_type] 
------,[character_maximum_length] 
------,[numeric_precision] 
------,[numeric_scale] 
------,[datetime_precision] 
------) ; 

------SELECT * FROM @col_defn 

------SET @col_string = [meta].[column_generator] ( 
------	@catalog_name  
------	,@schema_name  
------	,@table_name
------	,@col_defn 
------) ; 

------PRINT(@col_string) ; 

-- -------------------------------------------------- ---
*/ 

CREATE OR ALTER FUNCTION [meta].[column_generator] ( 
 @p_catalog_name varchar(128) 
,@p_schema_name varchar(128) 
,@p_table_name varchar(128) 
,@p_columns_tbl [meta].[column_schemata] READONLY 
) 
RETURNS varchar(8000) 
AS 
BEGIN 

DECLARE		/* prevent parameter sniffing */ 
 @v_catalog_name varchar(128) = @p_catalog_name  
,@v_schema_name varchar(128) = @p_schema_name 
,@v_table_name varchar(128) = @p_table_name 
;  

DECLARE @sql_string varchar(8000) 

SET @sql_string = ( 
	SELECT col_str = STUFF(( 
		SELECT TOP 100 PERCENT cols = CHAR(44)
		+ QUOTENAME(c.[column_name]) 
		+ CHAR(32) 
		+ QUOTENAME(LOWER(c.[data_type]))  
		+ COALESCE( 
			CHAR(40) + 
			CASE 
			WHEN QUOTENAME(c.data_type) IN ('[decimal]', '[numeric]') 
			THEN TRY_CONVERT(varchar, c.numeric_precision) + COALESCE(CHAR(44) + TRY_CONVERT(varchar, c.numeric_scale), '')  
			WHEN QUOTENAME(c.data_type) LIKE '%char]' 
			THEN TRY_CONVERT(varchar, CASE WHEN c.character_maximum_length =  -1 THEN 'MAX' ELSE c.character_maximum_length END )  
			WHEN QUOTENAME(c.data_type) LIKE '[date%'
			THEN TRY_CONVERT(varchar, c.datetime_precision)	
			END + CHAR(41)  
			,''  
		) 
		+ CHAR(32) 
		+ COALESCE( 
			CASE 
			WHEN c.column_default = 'SEQ'  
			THEN CHAR(10) + CHAR(9) 
			+ 'CONSTRAINT ' + QUOTENAME(c.column_name + '_DF') + ' DEFAULT ' + CHAR(40) 
			+ 'NEXT VALUE FOR' + CHAR(32) 
			+ QUOTENAME(LOWER(c.table_schema)) + CHAR(46) + QUOTENAME(UPPER(c.table_name + CHAR(95) + c.column_default)) 
			+ CHAR(41) + CHAR(32) + CHAR(10) + CHAR(9) 
			END 
		,'')
		 
		+ COALESCE(
			CASE 
			WHEN c.is_nullable = 'YES' THEN 'NULL' 
			WHEN c.is_nullable = 'NO' THEN 'NOT NULL' 
			END 
		, '') 

		+ CHAR(10) 

		from @p_columns_tbl as c 
		WHERE c.table_catalog = @v_catalog_name 
		AND c.table_schema = @v_schema_name 
		AND c.table_name = @v_table_name 
		order by c.[ordinal_position] 
	FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')  ,1,1,'')
) 

RETURN @sql_string ; 
END 
; 
GO

--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column Generator 
---- Returns a string of column scoped ddl for a given set of column definitions.  
---- Assumes one table is provided in the param ' 
--,@level0type=N'SCHEMA',@level0name=N'meta'
--,@level1type=N'FUNCTION',@level1name=N'column_generator'
--GO


DECLARE	@col_defn [meta].[column_schemata] ; 
DECLARE @col_string  varchar(8000) ; 
DECLARE 
 @catalog_name varchar(128) = 'testdb' 
,@schema_name varchar(128) = 'testing' 
,@table_name varchar(128) = 'testable'
; 

INSERT INTO @col_defn ( 
 [table_catalog] 
,[table_schema] 
,[table_name] 
,[column_name] 
,[ordinal_position] 
,[column_default] 
,[is_nullable] 
,[data_type] 
,[character_maximum_length] 
,[numeric_precision] 
,[numeric_scale] 
,[datetime_precision] 
) 
SELECT 
[table_catalog] 
,[table_schema] 
,[table_name] 
,[column_name] 
,[ordinal_position] 
,[column_default] 
,[is_nullable] 
,[data_type] 
,[character_maximum_length] 
,[numeric_precision] 
,[numeric_scale] 
,[datetime_precision] 
FROM ( 
VALUES 
	( 
		 @catalog_name  
		,@schema_name  
		,@table_name
		,'CHARACTER_DEMO' 
		,1 
		,NULL 
		,'YES' 
		,'varchar' 
		,50 
		,NULL 
		,NULL 
		,NULL
	) 
	,( 
		 @catalog_name  
		,@schema_name  
		,@table_name
		,'NUMERIC_DEMO' 
		,2 
		,NULL 
		,'YES' 
		,'decimal' 
		,NULL 
		,8 
		,0 
		,NULL
	) 
	,( 
		 @catalog_name  
		,@schema_name  
		,@table_name  
		,'DATE_DEMO' 
		,3 
		,NULL 
		,'YES' 
		,'datetime2' 
		,NULL 
		,NULL  
		,NULL  
		,7 
	)
	,( 
		 @catalog_name  
		,@schema_name  
		,@table_name  
		,'SEQUENCE_DEMO' 
		,4 
		,'SEQ' 
		,'NO' 
		,'bigint' 
		,NULL 
		,NULL  
		,NULL  
		,7 
	)  
) as v ( 
[table_catalog] 
,[table_schema] 
,[table_name] 
,[column_name] 
,[ordinal_position] 
,[column_default] 
,[is_nullable] 
,[data_type] 
,[character_maximum_length] 
,[numeric_precision] 
,[numeric_scale] 
,[datetime_precision] 
) ; 

SELECT * FROM @col_defn 

SET @col_string = [meta].[column_generator] ( 
	@catalog_name  
	,@schema_name  
	,@table_name
	,@col_defn 
) ; 

PRINT(@col_string) ; 

