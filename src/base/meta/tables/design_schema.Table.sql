CREATE TABLE [meta].[design_schema] 
(
    design_schema_id int identity not null, 
    design_schema_name varchar(128) not null,  
    design_schema_description varchar(256) not null,
    CONSTRAINT design_schema_pk PRIMARY KEY (design_schema_id),
    CONSTRAINT design_schema_uk UNIQUE (design_schema_name)
)
;
