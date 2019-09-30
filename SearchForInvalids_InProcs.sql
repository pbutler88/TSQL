BEGIN TRAN

DECLARE @i INT = 0

IF OBJECT_ID('tempdb..#References') IS NOT NULL drop table #References

create table #References
(
ObjectCount INT NULL,   
ProcName VARCHAR(500) NULL,
TableName Varchar(500) NULL,   
ColumnName VARCHAR(500) NULL
)            

--Loop through each of these and search for errors
--PERFORM ACTIONS
DECLARE curRequest INSENSITIVE Cursor FOR 

SELECT 'dbo.' + Name AS ProcName
FROM sysobjects WITH (NOLOCK)
WHERE xtype = 'P'
AND name NOT LIKE '%<YourWildCardProcedureNameHere>%'
ORDER BY name
				
Open curRequest

DECLARE @ProcName Varchar(500)

While 1 = 1
	BEGIN
		Fetch NEXT FROM curRequest INTO @ProcName
		IF (@@FETCH_STATUS <> 0)
			Break
			
			--Select @ProcName
			--This will show errors in the "Message" tab.
			INSERT #References (ObjectCount, ProcName, TableName, ColumnName)
			SELECT @i AS ObjectCount, 
				@ProcName AS ProcName,
				referenced_entity_name AS TableName, 
				referenced_minor_name AS ColumnName
			FROM sys.dm_sql_referenced_entities (@ProcName, 'OBJECT');  
			
			SELECT @i = @i + 1	     		 
	END

CLOSE curRequest
DEALLOCATE curRequest

SELECT @i AS TotalObjectCount
Select DISTINCT ProcName from #References

ROLLBACK TRAN