/*
Create TABLE #TempDates
(Eff_Date DateTime NULL, 
    Term_Date Datetime NULL)

Select * from #TempDates
Insert #TempDates Values ('1/1/2018', '1/7/2018') 
Insert #TempDates Values ('1/8/2018', '1/14/2018') 
Insert #TempDates Values ('1/20/2018', '1/24/2018') 
Insert #TempDates Values ('1/25/2018', '1/31/2018') 
*/


Select Eff_Date, 
        Term_Date, 
        DateDiff(Day,Eff_Date,Term_Date) as NumberOfDays,
        LAG(Eff_Date,1,0) OVER (ORDER BY Eff_Date, Term_Date) LagValue,
        LEAD(Eff_Date,1,0) OVER (ORDER BY Eff_Date, Term_Date) LeadValue,
        --Now see if we can find days between
        DateDiff(Day,Term_Date,LEAD(Eff_Date,1,0) OVER (ORDER BY Eff_Date, Term_Date)) as Gaps
from #TempDates

