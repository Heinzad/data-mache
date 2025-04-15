-- src\base\meta\types\meta.column_schemata.UserDefinedType.sql 
-- -------------------------------------------------- ---  
-- script_name: meta.column_schemata.Type.sql 
-- script_author: Adam Heinz 
-- script_date: 6 Feb 2023 
-- script_license: MIT 
-- -------------------------------------------------- ---


CREATE TYPE [meta].[column_schemata] 
/* Column Schemata 
	Enables quick creation of table variables. 
	Holds the definitions for a set of columns.  
	Reflects the structure of information schema columns. 
*/ 
AS TABLE(
	[table_entity] [varchar](128) NULL,
	[table_catalog] [varchar](128) NULL,
	[table_schema] [varchar](128) NULL,
	[table_name] [varchar](128) NOT NULL,
	[column_name] [varchar](128) NOT NULL,
	[ordinal_position] [int] NULL,
	[column_default] [nvarchar](4000) NULL,
	[is_nullable] [varchar](3) NULL,
	[data_type] [nvarchar](128) NULL,
	[character_maximum_length] [int] NULL,
	[character_octet_length] [int] NULL,
	[numeric_precision] [tinyint] NULL,
	[numeric_precision_radix] [smallint] NULL,
	[numeric_scale] [int] NULL,
	[datetime_precision] [smallint] NULL,
	[character_set_catalog] [varchar](128) NULL,
	[character_set_schema] [varchar](128) NULL,
	[character_set_name] [varchar](128) NULL,
	[collation_catalog] [varchar](128) NULL,
	[collation_schema] [varchar](128) NULL,
	[collation_name] [varchar](128) NULL,
	[domain_catalog] [varchar](128) NULL,
	[domain_schema] [varchar](128) NULL,
	[domain_name] [varchar](128) NULL,
	[column_definition] [varchar](4000) NULL,
	[column_row_id] [int] IDENTITY(1,1) NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[column_row_id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO


 