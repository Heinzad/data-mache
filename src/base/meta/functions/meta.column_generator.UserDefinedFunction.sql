-- src\base\meta\functions\meta.column_generator.UserDefinedFunction.sql
-- -------------------------------------------------- ---  
-- script_name: meta.column_generator.Function.sql 
-- script_author: Adam Heinz 
-- script_date: 6 Feb 2023 
-- script_license: MIT 
-- -------------------------------------------------- ---  
 

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

