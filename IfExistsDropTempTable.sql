IF OBJECT_ID('tempdb..#MyTestTempTableName') IS NOT NULL drop table #MyTestTempTableName

create table #MyTestTempTableName
(
ID int,   
CategoryType char(1),   
CategoryEffectiveDate datetime,   
CategoryTerminationDate datetime
)            

Select * from #MyTestTempTableName
