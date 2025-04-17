<!--docs\base\meta\functions\about-test-schema-exists.md-->



Test Schema Existence
=====================

The user-defined function `meta.test_schema_exists` returns false if a given schema does not exist. 

The function searches system tables for object existence using a query derived from the Information Schema Schemata view definition. 


Parameters
---------- 

- p_test_schema : nvarchar(128) 
    Identifier of the schema to verify 


Return Type 
-----------

- bit (boolean)


Example Usage: 
-------------- 

Syntax: 

```sql 
    SELECT assert = [meta].[test_schema_exists] ('meta') ; 
``` 

Result: 

| assert | 
| ------ | 
| 1 | 


