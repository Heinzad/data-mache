<!--docs\base\meta\functions\about-column-generator.md-->



About Column Generator UDF 
==========================

The user-defined function `column_generator` returns a string of column definitions for a table creation script. 


Parameters
---------- 

@p_catalog_name varchar(128)
    Name of the database by which to filter the given columns table 

@p_schema_name varchar(128) 
    Name of the schema by which to filter the given columns table 

@p_table_name varchar(128)
    Name of the table by which to filter the given columns table 

@p_columns_tbl [meta].[column_schemata] 
    Table of column definitions reflecting the structure of information schema columns. 


Return Value
------------ 

string varchar(8000)


Example Usage 
------------- 

```sql
    -- initialise parameter values 
    DECLARE 
         @catalog_name varchar(128) = 'testdb' 
        ,@schema_name varchar(128) = 'testy' 
        ,@table_name varchar(128) = 'testable'
    ; 
    DECLARE @columns_tbl [meta].[column_schemata]
    ;
    DECLARE @column_definitions  varchar(8000) 
    ; 

    -- populate the table variable from data dictionary
    INSERT INTO @columns_tbl ( 
        table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, character_maximum_length, numeric_precision, numeric_scale, datetime_precision
    )
    SELECT 
        table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, character_maximum_length, numeric_precision, numeric_scale, datetime_precision 
    FROM 
        information_schema.columns 
    ; 

    -- query the function 
    SET @column_definitions = [meta].[column_generator] ( 
        @catalog_name  
        ,@schema_name  
        ,@table_name
        ,@columns_tbl 
    ) 
    ; 

    -- inspect the results
    PRINT(@column_definitions) ; 
``` 

Result
-------   

```sql 
    [character_column_name] [varchar](50) NULL, 
    [numeric_column_name] [decimal](8,0) NULL, 
    [date_column_name] [datetime2](7) NULL 
```



...
