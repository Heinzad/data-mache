<!--docs\base\meta\functions\about-test-column-exists.md-->



Test Column Existence 
===================== 

Returns false if a given column name does not exist.

Searches system tables for object existence using a query derived from the Information Schema Columns view definition.  

### Example Usage: 

```sql 
    SELECT assert = [meta].[test_column_exists] ('dbo', 'info_schema_columns', 'ORDINAL_POSITION') ;
```
