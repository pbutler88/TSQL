SELECT DATABASEPROPERTYEX('YourDatabaseNameHere')
GO

--Show All the Columns with the collation name
SELECT obj.name + '.' + col.name AS TableColumnName, col.collation_name
FROM sys.columns AS col
    JOIN sys.objects AS obj
        ON col.object_id = obj.object_id
WHERE obj.type = 'U'
and col.collation_name not like '%Latin1_General_BIN%' 
--and col.collation_name not like '%SQL_Latin1_General_CP1_CI_AS%' 

USE master
GO

--Find columns that have a specific collation
SELECT OBJECT_NAME(c.object_id) as Table_Name,
       COL_NAME(sd.referenced_major_id, sd.referenced_minor_id) AS Column_Name,
       c.collation_name AS Collation,
       definition AS Definition
FROM sys.computed_columns cc INNER JOIN
       sys.sql_dependencies sd ON cc.object_id=sd.object_id AND 
                                  cc.column_id=sd.column_id AND 
                                  sd.object_id=sd.referenced_major_id INNER JOIN
       sys.columns c ON c.object_id=sd.referenced_major_id AND 
                        c.column_id = sd.referenced_minor_id
WHERE c.collation_name like 'SQL_Latin1_General_CP1_CI_AS'
--WHERE c.collation_name like '%Latin1_General_BIN%' 
   --AND sd.class=1

--Server Level Collation
SELECT SERVERPROPERTY('collation');

--Database Level Collation
SELECT DATABASEPROPERTYEX('YourDataBaseNameHere', 'Collation')
GO

/*
ALTER DATABASE YourDatabaseNameHere
  COLLATE Latin1_General_100_CI_AS;
  GO

ALTER TABLE YourTableNameHere
  ALTER COLUMN YourColumnNameHere VARCHAR(50) 
    COLLATE Modern_Spanish_CI_AI NOT NULL;
*/

SELECT name, description
  FROM sys.fn_helpcollations()
WHERE NAME IN ('SQL_Latin1_General_CP1_CI_AS','Latin1_General_BIN')
