<!--docs\base\meta\procedures\about-table-generator.md-->



About the Table Generator User Stored Procedure  
=============================================== 

The table generator takes as parameters a DDL action like 'create' and a table-valued variable reflecting the structure of information schema columns

```sql 
    EXEC meta.table_generator 
    @p_columns_tbl = @col_defn 
    ,@p_action = 'create' 
    ; 
```

The procedure loops through the table names given in the table columns parameter, executing the `column_generator` function to stringify a block of column definitions for use in the create table statement, wraps the column definitions in a create table statement and executes the sql. 


Table Columns Parameter 
--------------------------- 

The principal parameter required is a table of column definitions reflecting information schema columns. 

```sql 
    -- initialise a table variable of column schemata type
    DECLARE	@columns_tbl [meta].[column_schemata] ; 
```

We can populate that table variable with definitions for text, numeric, or date columns for example: 

```sql  
    -- put values for a text column 
    INSERT INTO @columns_tbl
        ( table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, character_maximum_length )
    VALUES 
        ( 'testdb', 'testy', 'testable', 'character_column_name', 1, 'varchar', 50 ) 
    ;

    -- put values for a numeric column
    INSERT INTO @columns_tbl
        ( table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, numeric_precision, numeric_scale )
    VALUES 
        ( 'testdb', 'testy', 'testable', 'numeric_column_name', 2, 'decimal', 8, 0 ) 
    ;

    -- put values for a date column 
    INSERT INTO @columns_tbl
        ( table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, datetime_precision )
    VALUES 
        ( 'testdb', 'testy', 'testable', 'date_column_name', 3, 'datetime2', 7 ) 
    ; 
```

inspect progress by querying the table-valued variable: 

```sql  
    -- get column definitions from table variable 
    SELECT 
        table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, character_maximum_length, numeric_precision, numeric_scale, datetime_precision
    FROM 
        @columns_tbl 
    ; 
```

Querying the table-valued variable returns a table of values: 

| table_catalog | table_schema | table_name | column_name | ordinal_position | data_type | character_maximum_length | numeric_precision | numeric_scale | datetime_precision | 
| ------------- | ------------ | ---------- | ----------- | ---------------- | --------- | ------------------------ | ----------------- | ------------- | ------------------ |
| 'testdb' | 'testy' | 'testable' | 'numeric_column_name' | 1 | 'varchar' | 50 | NULL | NULL | NULL | 
| 'testdb' | 'testy' | 'testable' | 'numeric_column_name' | 2 | 'decimal' | NULL |8 | 0 | NULL |  
| 'testdb' | 'testy' | 'testable' | 'date_column_name' | 3 | 'datetime2' | NULL | NULL | NULL | 7 | 
------



Loop thru Tables 
---------------- 

The process iterates over the table names given in the column parameter and calls the `column_generator` function to get the column definitions for a create table operation. 

```sql
    DECLARE @column_definitions  varchar(8000) ; 

    SET @column_definitions = [meta].[column_generator] ( 
        @catalog_name  
        ,@schema_name  
        ,@table_name
        ,@columns_tbl 
    ) 
    ; 
``` 

The result is column definitions laid out in the sequence of their ordinal position, with data type formatting and nullability, ready to be used in a create table statement.  

```sql 
    [character_column_name] [varchar](50) NULL, 
    [numeric_column_name] [decimal](8,0) NULL, 
    [date_column_name] [datetime2](7) NULL 
```

Constraints -- like primary, unique, or foreign keys -- and indexes may be applied later with `ALTER TABLE` statements. 


Table DDL 
---------

We can verify the results of the create table operation by querying information schema tables:  

```sql
    -- initialise database, schema, and table variables 
    DECLARE 
         @catalog_name varchar(128) = 'testdb' 
        ,@schema_name varchar(128) = 'testy' 
        ,@table_name varchar(128) = 'testable'
    ;
    -- inspect information schema tables 
    SELECT ist.* 
    FROM INFORMATION_SCHEMA.TABLES as ist 
    WHERE ist.TABLE_CATALOG = @catalog_name 
    AND ist.TABLE_SCHEMA = @schema_name 
    AND ist.TABLE_NAME = @table_name 
    ;
```


.