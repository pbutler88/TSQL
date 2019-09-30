IF OBJECT_ID('tempdb..#CompareTempProc') IS NOT NULL drop table #CompareTempProc

Create Table #CompareTempProc
(ID INT NOT NULL Identity(1,1),
    DataSource Varchar(255) NULL,
    ProcName Varchar(255) NULL,
    VersionNumber Varchar(255) NULL
)

--PASTE your inserts here.
Insert #CompareTempProc Values ('<AddDataSourceNameHERE>','<AddYourTableNameHere>','$Revision: 1.2.2.14 $')

IF OBJECT_ID('tempdb..#TempProc') IS NOT NULL drop table #TempProc

Create Table #TempProc
(ID INT NOT NULL Identity(1,1),
    ProcName Varchar(255) NULL,
    VersionNumber Varchar(255) NULL
)

--Loop through Procedures using wildcards
--PERFORM ACTIONS
DECLARE curRequest INSENSITIVE Cursor FOR 

Select Name as ProcName
from sysobjects as A
Where Name like '<AddYourWildCardSearchHere>%'	and xtype = 'P'
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

Select B.ProcName, A.VersionNumber as STG3_Version, B.VersionNumber as ST2_Version
from #CompareTempProc as A
    LEFT JOIN #TempProc as B
        On A.ProcName = B.ProcName
Where A.VersionNumber <> B.VersionNumber
Order by B.ProcName
