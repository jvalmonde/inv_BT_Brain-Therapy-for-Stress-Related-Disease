select top 1000 * from pdb_VT_ChronicPain..MemClaimsLowerBackPain

select top 1000 * from MiniHPDM..Dim_Member --where DIAG_CD = 'S31001'
select top 1000 * from pdb_VT_ChronicPain..DCLowerBackPain where DIAG_CD = 'S31001'

if object_id('tempdb..#ip_conf') is not null
drop table #ip_conf
go

select a.Indv_Sys_Id, b.DT_SYS_ID
into #ip_conf
from (
		select a.Indv_Sys_Id
			, Admit_DtSys		= c1.DT_SYS_ID
			, Admit_Dt			= c1.FULL_DT
			, Discharge_DtSys	= c2.DT_SYS_ID + Day_Cnt
			, Discharge_Dt		= dateadd(dd, Day_Cnt, c2.Full_Dt)
			, Day_Cnt
			, Episode_ID			= row_number() over(partition by a.Indv_Sys_ID order by c1.Dt_Sys_ID)
		from pdb_VT_ChronicPain..MemClaimsLowerBackPain			as a
		--inner join pdb_VT_ChronicPain..MemClaimsLowerBackPain	as b on a.Indv_Sys_Id = b.Indv_Sys_Id
		inner join MiniHPDM..Dim_Date							as c1 on a.Dt_Sys_Id  = c1.DT_SYS_ID -- admit
		inner join MiniHPDM..Dim_Date							as c2 on a.Dt_Sys_Id  = c2.DT_SYS_ID -- discharge
		where a.Srvc_Typ_Sys_Id = 1
			and a.Admit_Cnt = 1
			and c1.Year_Mo between 201201 and 201806
	)							as a
inner join MiniHPDM..Dim_Date	as b on b.DT_SYS_ID between a.Admit_DtSys and a.Discharge_DtSys
group by a.Indv_Sys_Id, b.DT_SYS_ID
--743,130 28mins
create unique index ucix_Indv_sys_id on #ip_conf (Indv_Sys_Id, DT_SYS_ID);

if (object_id('tempdb..#utilization') is not null)
drop table #utilization
go

Select Indv_sys_id, Year_Mo
	, Total_Allow	= isnull(sum(allw_amt),0)
	, IP_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'IP' then Allw_Amt end),0)
	, OP_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'OP' then Allw_Amt end),0)
	, ER_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'ER' then Allw_Amt end),0)
	, DR_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'DR' then Allw_Amt end),0)
	, RX_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'RX' then Allw_Amt end),0)
	, IP_Visits		= isnull(count(distinct case when Derived_Srvc_type_cd = 'IP' and Admit_Cnt = 1 then FULL_DT end), 0)
	, IP_Days		= isnull(sum(case when Derived_Srvc_type_cd = 'IP' and Admit_Cnt = 1 then Day_Cnt end), 0)
	, OP_Visits		= isnull(count(distinct case when Derived_Srvc_type_cd = 'OP' then FULL_DT end), 0)
	, ER_Visits		= isnull(count(distinct case when Derived_Srvc_type_cd = 'ER' then FULL_DT end), 0)
	, DR_Visits		= isnull(count(distinct case when Derived_Srvc_type_cd = 'DR' then FULL_DT end), 0)
	, RX_Scripts	= isnull(sum(case when Derived_Srvc_type_cd = 'RX' then Scrpt_Cnt end), 0)
	, DME_Allow		= isnull(sum(case when Derived_Srvc_Type_cd = 'DME' 	then Allw_Amt else 0	end), 0)
into #utilization
from (
				select a.Indv_Sys_Id, a.Clm_Aud_Nbr, a.Dt_Sys_Id, a.Proc_Cd_Sys_Id, a.Allw_Amt, a.Admit_Cnt, a.Day_Cnt, a.Scrpt_Cnt, c.Year_Mo
					, Derived_Srvc_type_cd = case when f.Indv_Sys_Id is not null and e.Srvc_Typ_Cd <> 'IP' then 'IP' -- if ER,OP or DR falls within IP days then consider as IP
											when d.HCE_SRVC_TYP_DESC in ('ER','Emergency Room')		then 'ER' 
											when g.AHRQ_PROC_DTL_CATGY_DESC = 'DME AND SUPPLIES'			then 'DME'	else 	e.Srvc_Typ_Cd end
					, c.FULL_DT
				from pdb_VT_ChronicPain..MemClaimsLowerBackPain				a
				--inner join pdb_VT_ChronicPain..MemClaimsLowerBackPain		b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date								c on a.Dt_Sys_Id = c.DT_SYS_ID
				inner join MiniHPDM..DIM_HP_SERVICE_TYPE_CODE				d on a.Hlth_Pln_Srvc_Typ_Cd_Sys_ID = d.HLTH_PLN_SRVC_TYP_CD_SYS_ID
				inner join MiniHPDM..Dim_Service_Type						e on a.Srvc_Typ_Sys_Id = e.Srvc_Typ_Sys_Id
				inner join MiniHPDM..Dim_Procedure_Code						g on a.Proc_Cd_Sys_Id = g.Proc_Cd_Sys_Id
				left join #ip_conf											f on a.Indv_Sys_Id = f.Indv_Sys_Id and b.Dt_Sys_Id = f.DT_SYS_ID
				where c.Year_Mo between 201201 and 201806
				) b 
group by indv_sys_id, Year_Mo
--2,879,045 - 1:17hrs
create unique index uIx_Indv on #utilization (Indv_sys_id);

update pdb_VT_Chronicpain..MemWithLowerBackPain set
	  TotalCost	= isnull(b.Total_Allow,0)
	, CostIP 	= isnull(b.IP_Allow,0)
	, CostOP 	= isnull(b.OP_Allow,0)
	, CostPhy	= isnull(b.DR_Allow,0)
	, CostRx	= isnull(b.RX_Allow,0) 
from pdb_VT_Chronicpain..MemWithLowerBackPain	a
left join #utilization							b on a.Indv_sys_id = b.Indv_sys_id