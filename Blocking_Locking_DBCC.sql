--Show locks.
select convert (int, sli.req_spid)		As 'Spid',
		db_name(sli.rsc_dbid)			As 'dbid',
		object_name(sli.rsc_objid)		As 'Object Name',
		sli.rsc_indid					As 'Index Id',
		substring (v1.name, 1, 4)		As 'Lock Type',
		substring (sli.rsc_text, 1, 16)	As 'Resource',
		substring (v3.name, 1, 8)		As 'Lock Mode',
		substring (v2.name, 1, 5)		As 'Lock Status'
from master.dbo.syslockinfo sli with (nolock) 
	join master.dbo.spt_values v1 
		on sli.rsc_type = v1.number
	join master.dbo.spt_values v2 
		on sli.req_status = v2.number 
	join master.dbo.spt_values v3 
		on sli.req_mode + 1 = v3.number
Where db_name(sli.rsc_dbid) like 'ClaimLineSQL%' and
		object_name(sli.rsc_objid) is not null

--Checkout individual spid.
DECLARE @SPID INT
Select @SPID = 93

DBCC INPUTBUFFER (@SPID)

--Check overall blocking.
sp_who2