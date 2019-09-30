
SELECT SysTbls.name, SysTbls.type_desc, ExtProp.*
,SysCols.*
FROM sys.tables AS SysTbls
   LEFT JOIN sys.extended_properties AS ExtProp
         ON ExtProp.major_id = SysTbls.[object_id]
   LEFT JOIN sys.columns AS SysCols
         ON ExtProp.major_id = SysCols.[object_id]
         AND ExtProp.minor_id = SysCols.column_id
   LEFT JOIN sys.objects as SysObj
         ON SysTbls.[object_id] = SysObj.[object_id]
   INNER JOIN sys.types AS SysTyp
         ON SysCols.user_type_id = SysTyp.user_type_id
WHERE SysTbls.name LIKE '%<YourTableNameHere>%'

SELECT OBJECT_NAME(ep.major_id) AS [ObjectName], ep.class_desc, ep.name, ep.value
FROM sys.extended_properties AS ep
WHERE OBJECT_NAME(ep.major_id) LIKE '%<YourTableNameHere>%'