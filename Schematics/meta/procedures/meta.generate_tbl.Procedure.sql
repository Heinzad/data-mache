

/* Table Generator 
-- Performs DDL for a given set of column definitions and a given DDL command. 
-- NB. Data Definition Language (DDL) defines the schema and the objects in it.
-- -------------------------------------------------- ---  
-- script_name: meta.generate_tbl.Procedure.sql 
-- script_author: Adam Heinz 
-- script_date: 6 Feb 2023 
-- script_license: MIT 
-- -------------------------------------------------- ---  
------------example_usage: 


------------	DECLARE	@col_defn [meta].[column_schemata] ; 
------------	DECLARE @col_string  varchar(8000) ; 
------------	DECLARE 
------------	 @catalog_name varchar(128) = 'DataHub' 
------------	,@schema_name varchar(128) = 'meta' 
------------	,@table_name varchar(128) = 'testable'
------------	; 

------------	INSERT INTO @col_defn ( 
------------	 [table_catalog] 
------------	,[table_schema] 
------------	,[table_name] 
------------	,[column_name] 
------------	,[ordinal_position] 
------------	,[column_default] 
------------	,[is_nullable] 
------------	,[data_type] 
------------	,[character_maximum_length] 
------------	,[numeric_precision] 
------------	,[numeric_scale] 
------------	,[datetime_precision] 
------------	) 
------------	SELECT 
------------	[table_catalog] 
------------	,[table_schema] 
------------	,[table_name] 
------------	,[column_name] 
------------	,[ordinal_position] 
------------	,[column_default] 
------------	,[is_nullable] 
------------	,[data_type] 
------------	,[character_maximum_length] 
------------	,[numeric_precision] 
------------	,[numeric_scale] 
------------	,[datetime_precision] 
------------	FROM ( 
------------	VALUES 
------------		( 
------------			 @catalog_name  
------------			,@schema_name  
------------			,@table_name
------------			,'CHARACTER_DEMO' 
------------			,1 
------------			,NULL 
------------			,'YES' 
------------			,'varchar' 
------------			,50 
------------			,NULL 
------------			,NULL 
------------			,NULL
------------		) 
------------		,( 
------------			 @catalog_name  
------------			,@schema_name  
------------			,@table_name
------------			,'NUMERIC_DEMO' 
------------			,2 
------------			,NULL 
------------			,'YES' 
------------			,'decimal' 
------------			,NULL 
------------			,8 
------------			,0 
------------			,NULL
------------		) 
------------		,( 
------------			 @catalog_name  
------------			,@schema_name  
------------			,@table_name  
------------			,'DATE_DEMO' 
------------			,3 
------------			,NULL 
------------			,'YES' 
------------			,'datetime2' 
------------			,NULL 
------------			,NULL  
------------			,NULL  
------------			,7 
------------		)
------------		,( 
------------			 @catalog_name  
------------			,@schema_name  
------------			,@table_name  
------------			,'SEQUENCE_DEMO' 
------------			,4 
------------			,'SEQ' 
------------			,'NO' 
------------			,'bigint' 
------------			,NULL 
------------			,NULL  
------------			,NULL  
------------			,7 
------------		)  
------------	) as v ( 
------------	[table_catalog] 
------------	,[table_schema] 
------------	,[table_name] 
------------	,[column_name] 
------------	,[ordinal_position] 
------------	,[column_default] 
------------	,[is_nullable] 
------------	,[data_type] 
------------	,[character_maximum_length] 
------------	,[numeric_precision] 
------------	,[numeric_scale] 
------------	,[datetime_precision] 
------------	) ; 

------------SELECT * FROM @col_defn 

------------DECLARE @sql nvarchar(4000) ; 
------------SET @sql = 'DROP TABLE IF EXISTS ' + QUOTENAME(@schema_name) + CHAR(46) + QUOTENAME(@table_name) + CHAR(59) ; 
------------EXEC (@sql) ; 

------------EXEC meta.generate_tbl 
------------ @p_columns_tbl = @col_defn 
------------,@p_action = 'create' 
------------; 

------------SELECT ist.* 
------------FROM INFORMATION_SCHEMA.TABLES as ist 
------------WHERE ist.TABLE_CATALOG = @catalog_name 
------------AND ist.TABLE_SCHEMA = @schema_name 
------------AND ist.TABLE_NAME = @table_name 
------------;
 

-- -------------------------------------------------- --- 
*/ 

CREATE OR ALTER PROCEDURE meta.generate_tbl ( 
 @p_columns_tbl [meta].[column_schemata] READONLY 
,@p_action varchar(128) = 'create' /* options: ('create', 'alter', 'drop') */   
) 
AS 
BEGIN 

SET NOCOUNT, XACT_ABORT ON; 

DECLARE		/* prevent parameter sniffing */ 
@v_action varchar(128) = @p_action 

DECLARE 
 @tables [meta].[table_schemata] 
,@columns [meta].[column_schemata]  
; 

DECLARE		/* internal variables */ 
 @v_table_entity varchar(128) 
,@v_table_catalog varchar(128)  
,@v_table_schema varchar(128)   
,@v_table_name varchar(128)  
; 

DECLARE		/* composers */ 
@sql_string varchar(8000) 

INSERT INTO @tables ( 
 table_entity 
,table_catalog 
,table_schema  
,table_name  
) 
SELECT DISTINCT 
 cols.table_entity 
,cols.table_catalog 
,cols.table_schema 
,cols.table_name  
FROM @p_columns_tbl as cols 
; 
 
DECLARE @id int = 0 
SET @id = (SELECT MIN(t.table_row_id) FROM @tables t WHERE t.table_row_id > @id) 

/* loop */ 
BEGIN 

SELECT 
 @v_table_entity = tt.table_entity 
,@v_table_catalog = tt.table_catalog   
,@v_table_schema = tt.table_schema    
,@v_table_name = tt.table_name 
FROM @tables tt 
WHERE tt.table_row_id = @id 
; 

INSERT INTO @columns ( 
	table_catalog 
	,table_schema 
	,table_name 
	,column_name 
	,ordinal_position 
	,column_default 
	,is_nullable 
	,data_type
	,character_maximum_length
	,character_octet_length
	,numeric_precision
	,numeric_precision_radix
	,numeric_scale
	,datetime_precision 
) 
SELECT 
 c.table_catalog 
,c.table_schema 
,c.table_name 
,c.column_name 
,c.ordinal_position 
,c.column_default 
,CASE WHEN LOWER(@v_action) = 'create' THEN c.column_default ELSE NULL END 
,c.data_type
,c.character_maximum_length
,c.character_octet_length
,c.numeric_precision
,c.numeric_precision_radix
,c.numeric_scale
,c.datetime_precision  
FROM @p_columns_tbl as c 
WHERE c.table_catalog = @v_table_catalog 
AND c.table_schema = @v_table_schema 
AND c.table_name = @v_table_name 
; 


SET @sql_string = 
'
IF ' + CASE WHEN LOWER(@v_action) = 'create' THEN 'NOT' ELSE '' END + CHAR(32) + 
'EXISTS ( 
	SELECT 1 
	FROM INFORMATION_SCHEMA.TABLES ist 
	WHERE QUOTENAME(ist.TABLE_SCHEMA) = ' + CHAR(39) + QUOTENAME(@v_table_schema) + CHAR(39) + ' 
	AND QUOTENAME(ist.TABLE_NAME) = ' + CHAR(39) + QUOTENAME(@v_table_name) + CHAR(39) + '   
) 
BEGIN 
'
SET @sql_string = @sql_string + 
CASE 
WHEN @v_action = 'alter' THEN 'ALTER' 
WHEN @v_action = 'drop' THEN 'DROP' 
ELSE 'CREATE' 
END + CHAR(32) + 
'TABLE ' + QUOTENAME(@v_table_schema) + CHAR(46) + QUOTENAME(@v_table_name) 
 
SET @sql_string = @sql_string + 
CASE 
WHEN LOWER(@v_action) = 'alter' THEN 'ADD' + CHAR(32) +  CHAR(10) 
WHEN LOWER(@v_action) = 'drop' THEN CHAR(59) + CHAR(10)  
ELSE CHAR(40) + CHAR(10) 
END 
 
IF (LOWER(@v_action) != 'drop') 
SET @sql_string = @sql_string + [meta].[column_generator]( 
 @v_table_catalog 
,@v_table_schema 
,@v_table_name 
,@columns 
) 

SET @sql_string = @sql_string + 

CASE 
WHEN LOWER(@v_action) = 'create' THEN CHAR(41) + CHAR(59) + CHAR(10) 
WHEN LOWER(@v_action) = 'alter' THEN CHAR(59) + CHAR(10) 
ELSE CHAR(10) 
END 

SET @sql_string = @sql_string + 'END' 

BEGIN TRY 

	EXEC (@sql_string) 

END TRY 
BEGIN CATCH 
	PRINT(ERROR_MESSAGE()) 
	PRINT('-------------') 
	PRINT(@sql_string) 
	RETURN 
END CATCH 

DELETE @columns  


SET @id = (SELECT MIN(t.table_row_id) FROM @tables t WHERE t.table_row_id > @id) 
END 
/* loop */ 

END 

GO 

