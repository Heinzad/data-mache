<!--docs\base\meta\functions\about-test-table-exists.md-->



Test Table Existence 
==================== 

The user-defined function `test_table_exists` returns false if a given table name does not exist.  
It searches system tables for object existence using a query derived from the Information Schema Tables view definition. 

Parameters 
----------

- p_test_schema : nvarchar(128)	-- Name of the schema containing the table to verify 
- p_test_table : nvarchar(128)	-- Name of the table to verify 


Return Type 
-----------

- bit (boolean)


Examples
--------

Syntax: 

```sql 
    SELECT assert = [meta].[test_table_exists] ('dbo', 'info_schema_tables') ; 
```
 
Result: 

| assert | 
| ------ | 
| 1 |