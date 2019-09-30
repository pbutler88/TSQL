IF OBJECT_ID('tempdb..#findgap') IS NOT NULL drop table #findgap

create table #findgap  
(
MEME_CK int,   
CSPD_CAT char(1),   
MEES_EFF_DT datetime,   
MEES_TERM_DT datetime,  
idx int identity(1,1)
)            

Select * from #findgap
