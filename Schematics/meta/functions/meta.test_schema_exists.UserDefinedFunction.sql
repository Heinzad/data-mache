/****** Object:  UserDefinedFunction [meta].[test_schema_exists]    Script Date: 4/23/2023 8:50:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/* test schema exists  
-- Returns False if a given schema does not exist 
-- Query derived from Information Schema Schemata view definition   
-- ---------------
-- script_name: meta.test_schema_exists.Function.sql 
-- script_author: Adam Heinz
-- script_license: MIT 
-- script_date 23 April 2023 
-- --------------- 
-- example_usage: 

-- SELECT assert = [meta].[test_schema_exists] ('meta') ; 

-- GO  
-- --------------- 
*/ 
CREATE   FUNCTION [meta].[test_schema_exists] ( 
	 @p_test_schema nvarchar(128)	/* schema name to verify */ 
) 
RETURNS bit 
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
