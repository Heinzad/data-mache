/****** Object:  UserDefinedFunction [meta].[test_database_exists]    Script Date: 4/23/2023 8:50:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/* test database exists  
-- Searches sys databases for a given database name 
-- Returns false if given database name does not exist 
-- N.B. "Catalog" is a synonym for database in the information schema. 
-- ---------------
-- script_name: meta.test_database_exists.Function.sql 
-- script_author: Adam Heinz
-- script_license: MIT 
-- script_date 23 April 2023 
-- --------------- 
-- example_usage: 

-- SELECT assert = [meta].[test_database_exists] ('DataHub') ; 

-- GO  
-- --------------- 
*/ 
CREATE   FUNCTION [meta].[test_database_exists] ( 
	@p_test_database nvarchar(128)	/* database name to check */ 
) 
RETURNS bit 
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
