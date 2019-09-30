/*
----------------------------------------------------------------------------
The goal of this tSQL is to get a list of tables that are used within a 
    stored procedure

Once located, 
    loop through each table to get a record count.
    review the indexes associated with each table.

Other ideas... Add statistics info
               Add Threshold ratings
----------------------------------------------------------------------------
*/
DECLARE @StoredProcedureName Varchar(255) = '<Your Proc Name Here>'; 
DECLARE @retval int   
DECLARE @sSQL nvarchar(500);
DECLARE @ParmDefinition nvarchar(500);

--Temp table stores info
IF OBJECT_ID('tempdb..#SP_Tables') IS NOT NULL drop table #SP_Tables

create table #SP_Tables
(
ProcedureName Varchar(255) NOT NULL,   
TableName Varchar(255) NOT NULL,   
RecordCount INT NULL
)            

--Seed the temp table
Insert #SP_Tables
SELECT DISTINCT p.name AS proc_name, 
    t.name AS table_name
    , NULL as SeededVal
FROM sys.sql_dependencies d 
INNER JOIN sys.procedures p ON p.object_id = d.object_id
INNER JOIN sys.tables     t ON t.object_id = d.referenced_major_id
Where p.name = @StoredProcedureName
ORDER BY proc_name, table_name

--Loop through the temp table and review each one
DECLARE curRecordCounter INSENSITIVE Cursor FOR 

Select TableName
from #SP_Tables
				
Open curRecordCounter

DECLARE @TableName Varchar(255)

While 1 = 1
    BEGIN
	   Fetch NEXT FROM curRecordCounter INTO @TableName
	   IF (@@FETCH_STATUS <> 0)
			 Break

                --Get overall record counts.			
                SELECT @sSQL = N'SELECT @retvalOUT = Count(*) FROM ' + @TableName + ' With (NOLOCK)';  
                SET @ParmDefinition = N'@retvalOUT int OUTPUT';

                EXEC sp_executesql @sSQL, @ParmDefinition, @retvalOUT=@retval OUTPUT;

                Update #SP_Tables
                Set RecordCount = @retval
                Where TableName = @TableName

                --Run DBCC
                --Results from DBCC are on the "Messages" tab.
                --Not sure if permissions would be available in production.
                DBCC SHOWCONTIG (@TableName) WITH ALL_INDEXES

                --Display index info
                Select '---- Show Indexes For ' + @TableName + ' ----'
                SELECT 
                    OBJECT_SCHEMA_NAME(t.[object_id],DB_ID()) AS [Schema],
                    t.[name] AS [TableName], 
                    ind.[name] AS [IndexName], 
                    col.[name] AS [ColumnName],
                    ic.column_id AS [ColumnId],
                    ind.[type_desc] AS [IndexTypeDesc], 
                    col.is_identity AS [IsIdentity],
                    ind.[is_unique] AS [IsUnique],
                    ind.[is_primary_key] AS [IsPrimaryKey],
                    ic.[is_descending_key] AS [IsDescendingKey],
                    ic.[is_included_column] AS [IsIncludedColumn]
                FROM 
                    sys.indexes ind 
                INNER JOIN 
                    sys.index_columns ic 
                    ON ind.object_id = ic.object_id AND ind.index_id = ic.index_id 
                INNER JOIN 
                    sys.columns col 
                    ON ic.object_id = col.object_id and ic.column_id = col.column_id 
                INNER JOIN 
                    sys.tables t 
                    ON ind.object_id = t.object_id 
                WHERE 
                    t.is_ms_shipped = 0
                    --ind.is_primary_key = 1 -- include or not pks, etc
                    --AND ind.is_unique = 0
                    --AND ind.is_unique_constraint = 0 
                    and t.name = @TableName
                ORDER BY 
                    [Schema],
                    TableName, 
                    IndexName,
                    [ColumnId],
                    ColumnName

                --Display index usage
                Select '---- Show Index Usage For ' + @TableName + ' ----'
                SELECT
                        sys.indexes.name AS IndexName,
                        sys.tables.name AS TableName,
                        REPLACE((
                            SELECT sys.columns.name + CASE WHEN is_descending_key = 1 THEN ' DESC' ELSE '' END AS [data()]
                            FROM sys.index_columns
                            INNER JOIN sys.columns ON sys.index_columns.object_id = sys.columns.object_id AND sys.index_columns.column_id = sys.columns.column_id
                            WHERE sys.index_columns.object_id = sys.indexes.object_id AND sys.index_columns.index_id = sys.indexes.index_id AND sys.index_columns.is_included_column = 0
                            ORDER BY sys.index_columns.key_ordinal
                            FOR XML PATH('')
                        ), ' ', ', ') AS KeyColumns,
                        REPLACE((
                            SELECT sys.columns.name AS [data()]
                            FROM sys.index_columns
                            INNER JOIN sys.columns ON sys.index_columns.object_id = sys.columns.object_id AND sys.index_columns.column_id = sys.columns.column_id
                            WHERE sys.index_columns.object_id = sys.indexes.object_id AND sys.index_columns.index_id = sys.indexes.index_id AND sys.index_columns.is_included_column = 1
                            ORDER BY sys.index_columns.index_column_id
                            FOR XML PATH('')
                        ), ' ', ', ') AS IncludedColumns,
                        sys.dm_db_index_usage_stats.user_updates,
                        sys.dm_db_index_usage_stats.user_seeks,
                        sys.dm_db_index_usage_stats.user_scans,
                        sys.dm_db_index_usage_stats.user_lookups,
                        sys.dm_db_index_usage_stats.user_seeks + sys.dm_db_index_usage_stats.user_scans + sys.dm_db_index_usage_stats.user_lookups AS total_usage
                    FROM sys.indexes
                    LEFT JOIN sys.tables ON sys.indexes.object_id = sys.tables.object_id
                    LEFT JOIN sys.dm_db_index_usage_stats ON sys.indexes.object_id = sys.dm_db_index_usage_stats.object_id AND sys.indexes.index_id = sys.dm_db_index_usage_stats.index_id
                    WHERE sys.indexes.type <> 0 AND sys.tables.is_ms_shipped = 0
                    and sys.tables.name = @TableName

    END

CLOSE curRecordCounter
DEALLOCATE curRecordCounter

--Display final record counts
Select '---- Show Tables in SP ----'
Select * from #SP_Tables

