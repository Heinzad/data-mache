/****** Object:  UserDefinedFunction [meta].[test_table_exists]    Script Date: 4/23/2023 8:50:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* test table exists  
-- Returns false if a given table name does not exist 
-- Query derived from Information Schema Tables view definition  
-- ---------------
-- script_name:		meta.test_table_exists.Function.sql 
-- script_author:	Adam Heinz
-- script_license:	MIT 
-- script_date		23 April 2023 
-- --------------- 
-- example_usage: 

-- SELECT assert = [meta].[test_table_exists] ('dbo', 'info_schema_tables') ; 

-- GO  
-- --------------- 
*/ 
CREATE   FUNCTION [meta].[test_table_exists] ( 
	 @p_test_schema nvarchar(128)	/* schema name to verify */ 
	,@p_test_table nvarchar(128)	/* table name to verify */ 
) 
RETURNS bit 
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
