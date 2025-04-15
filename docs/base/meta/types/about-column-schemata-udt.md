<!--docs\base\meta\types\about-column-schemata-udt.md-->



Column Schemata UDT 
===================

`column_schemata` is a user-defined table type that supports the quick creation of a table variable reflecting information schema columns. 

Using `column_schemata` reduces repetitive code reflecting the structure of information schema columns. 
Enabling table variables means that this code can be compiled in user stored procedures. 


Quickstart 
----------- 

Create a table variable of column schemata type: 

```sql 
    -- instantiate table variable with user-defined type 
    DECLARE	@info_cols [meta].[column_schemata] 
    ; 

    -- put column info 
    INSERT INTO @info_cols (
        table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, character_maximum_length, numeric_precision, numeric_scale, datetime_precision
    )
    SELECT 
        table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, character_maximum_length, numeric_precision, numeric_scale, datetime_precision
    FROM 
        information_schema.columns 
    ; 

    -- get column info 
    SELECT * 
    FROM @info_cols
    ;  
``` 


Data Structure
--------------

`column_schemata` reflects the structure of information schema columns 

| column name | data type | nullability | description |
| ----------- | --------- | ----------- | ----------- | 
| table_entity | varchar(128) | NULL | Name of related entity (optional) | 
| table_catalog | varchar(128) | NULL | Name of the database containing the table schema (optional) | 
| table_schema | varchar(128) | NULL | Name of the schema containing the table (optional) | 
| table_name | varchar(128) | NOT NULL | Name of the table containing the column | 
| column_name | varchar(128) | NOT NULL | Name of the column | 
| ordinal_position | int | NULL | Numeric sequence identifying the order of the column within the table (optional) | 
| column_default | nvarchar(4000) | NULL | Default value of the column, if any (optional) | 
| is_nullable | varchar(3) | NULL | Indicates if the column allows null values or not (optional) | 
| data_type | nvarchar(128) | NULL | System data type (optional) | 
| character_maximum_length | int | NULL | Maximum number of characters for text, character, binary or image data, or -1 for blobs |  
| character_octet_length | int | NULL | Maximum number of bytes for text, character, binary or image data, or -1 for blobs | 
| numeric_precision | tinyint | NULL | Precision of approximate numeric data, exact numeric data, integer data, or monetary data (optional) | 
| numeric_precision_radix | smallint | NULL | Precision radix of approximate numeric data, exact numeric data, integer data, or monetary data (optional) | 
| numeric_scale | int | NULL | Scale of approximate numeric data, exact numeric data, integer data, or monetary data (optional) |
| datetime_precision | smallint | NULL | Subtype code for datetime and ISO interval data types. For other data types (optional) |
| character_set_catalog | varchar(128) | NULL | 
| character_set_schema | varchar(128) | NULL | 
| character_set_name | varchar(128) | NULL | 
| collation_catalog | varchar(128) | NULL | 
| collation_schema | varchar(128) | NULL | 
| collation_name | varchar(128) | NULL | 
| domain_catalog | varchar(128) | NULL | 
| domain_schema | varchar(128) | NULL | 
| domain_name | varchar(128) | NULL | 
| column_definition | varchar(4000) | NULL | 
| column_row_id | int | IDENTITY(1,1) | NOT NULL | 



Example Usage
------------- 

This example demonstrates instantiating a table variable using the `column_schemata` type, then inserting values for text, numeric, and date columns. 

```sql

-- instantiate a table variable of column schemata type  
DECLARE	@cols [meta].[column_schemata] ; 

-- put values for a text column 
INSERT INTO @cols
    ( table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, character_maximum_length )
VALUES 
    ( 'testdb', 'testy', 'testable', 'character_column_name', 1, 'varchar', 50 ) 
;

-- put values for a numeric column
INSERT INTO @cols
    ( table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, numeric_precision, numeric_scale )
VALUES 
    ( 'testdb', 'testy', 'testable', 'numeric_column_name', 2, 'decimal',8 , 0 ) 
;

-- put values for a date column 
INSERT INTO @cols
    ( table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, datetime_precision )
VALUES 
    ( 'testdb', 'testy', 'testable', 'date_column_name', 3, 'datetime2', 7 ) 
; 

-- get column definitions from table variable 
SELECT 
    table_catalog, table_schema, table_name, column_name, ordinal_position, data_type, character_maximum_length, numeric_precision, numeric_scale, datetime_precision
FROM 
    @cols as cc 
; 

```


### Return Values 


| table_catalog | table_schema | table_name | column_name | ordinal_position | data_type | character_maximum_length | numeric_precision | numeric_scale | datetime_precision | 
| ------------- | ------------ | ---------- | ----------- | ---------------- | --------- | ------------------------ | ----------------- | ------------- | ------------------ |
| 'testdb' | 'testy' | 'testable' | 'numeric_column_name' | 1 | 'varchar' | 50 | NULL | NULL | NULL | 
| 'testdb' | 'testy' | 'testable' | 'numeric_column_name' | 2 | 'decimal' | NULL |8 | 0 | NULL |  
| 'testdb' | 'testy' | 'testable' | 'date_column_name' | 3 | 'datetime2' | NULL | NULL | NULL | 7 | 


...  
