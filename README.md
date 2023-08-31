# data-mache
Data Machination


## Overview 
"When your only tool is a hammmer, then you need to know how to bang in a screw" 

For various reasons, MS SQL Server may be the only tool you can access in an organisation. 
This database project demonstates how to build a metadata hub using MS SQL Server only. 

The project file structure is split into: 
* schematics, which script the ideal state of the database, and 
* migrations, which script the deployments of database developments 


## Schemas 
The sole schema is 'meta', with tables for holding metadata about objects, and functions and procedures for getting that information or doing something with it. 

## Features 

### Reflection 
As a developer, I want to accumulate metadata from various sources, so that I can describe their structure. 
* catalog 
* schemata 
* tables 
* columns 

### Metaprogramming  
As a developer, I want to access auto-generated DDL, so that I never have to manually generate scripts myself. 
Given an entity name and element properties, when I run the generator, then the object created should be discoverable in the information schema. 
* table generator 
* stingify column definitions 

### Testing 
As a developer, I want to access some routine tests, so that I don't have to rewrite them every time. 
When I use the routines then I should be able to check the existence of:  
* database  
* schema 
* table 
* column 
* column properties 


