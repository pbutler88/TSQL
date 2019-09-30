IF OBJECT_ID('tempdb..#TempProc') IS NOT NULL drop table #TempProc

Create Table #TempProc
(ID INT NOT NULL Identity(1,1),
    ProcName Varchar(255) NULL,
    VersionNumber Varchar(255) NULL
)

--Loop through Procedures using a wildcard     
--PERFORM ACTIONS
DECLARE curRequest INSENSITIVE Cursor FOR 

Select Name as ProcName
from sysobjects as A
Where Name like '<AddYourSearchCriteriaHere>%'	and xtype = 'P'
Order by Name

Open curRequest

DECLARE @ProcName Varchar(255)

While 1 = 1
    BEGIN
	   Fetch NEXT FROM curRequest INTO @ProcName
	   IF (@@FETCH_STATUS <> 0)
			 Break
			
               Insert #TempProc
               SELECT @ProcName, Convert(Varchar(255), value)
	          FROM sys.fn_listextendedproperty ('SourceCodeVersion', 'schema', 'dbo', 'procedure', @ProcName, default, default)
    END

CLOSE curRequest
DEALLOCATE curRequest

/*
--Use these for Part 2
Select ID, 'Insert #CompareTempProc Values (''Dev03''' + ',''' + ProcName + ''',''' + VersionNumber + ''')'
from #TempProc
Where LEN(VersionNumber) <> 10
*/
