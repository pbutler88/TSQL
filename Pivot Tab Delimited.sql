SELECT ClientID
      ,ClientTypeId
      ,AttrA
      ,AttrB
      ,AttrC
      ,AttrD
FROM
(
    SELECT CASE
               WHEN ColumnRow = 1
                   THEN 'ClientID'
               WHEN ColumnRow = 2
                   THEN 'ClientTypeId'
               WHEN ColumnRow = 3
                   THEN 'AttrA'
               WHEN ColumnRow = 4
                   THEN 'AttrB'
               WHEN ColumnRow = 5
                   THEN 'AttrC'
               WHEN ColumnRow = 6
                   THEN 'AttrD'
               ELSE NULL
           END AS ColumnRow
          ,t.value
          ,ColumnID
    FROM
(
    SELECT ColumnID
          ,z.value AS                                                                       stringsplit
          ,b.value
          ,CAST(ROW_NUMBER() OVER(PARTITION BY z.value ORDER BY z.value) AS VARCHAR(50)) AS ColumnRow
    FROM
(
    SELECT CAST(ROW_NUMBER() OVER(ORDER BY a.value) AS VARCHAR(50)) AS ColumnID
          ,a.value
    FROM string_split('123,4,1,0,0,5|324,2,0,0,0,4','|') AS a
) AS z
    CROSS APPLY string_split(value,',') AS b
) AS t
) AS SOURCETABLE PIVOT(MAX(value) FOR ColumnRow IN(ClientID
                                                  ,ClientTypeId
                                                  ,AttrA
                                                  ,AttrB
                                                  ,AttrC
                                                  ,AttrD)) AS PivotTable
