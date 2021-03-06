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
		from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	as a
		inner join MiniHPDM..Fact_Claims	as b on a.Indv_Sys_Id = b.Indv_Sys_Id
		inner join MiniHPDM..Dim_Date		as c1 on b.Dt_Sys_Id  = c1.DT_SYS_ID -- admit
		inner join MiniHPDM..Dim_Date		as c2 on b.Dt_Sys_Id  = c2.DT_SYS_ID -- discharge
		where wChronicPain = 1
			and b.Srvc_Typ_Sys_Id = 1
			and b.Admit_Cnt = 1
			and c1.YEAR_NBR = 2017
			--and a.Indv_Sys_Id = 1205073346
	)							as a
inner join MiniHPDM..Dim_Date	as b on b.DT_SYS_ID between a.Admit_DtSys and a.Discharge_DtSys
group by a.Indv_Sys_Id, b.DT_SYS_ID
--267,686 3mins
create unique index ucix_Indv_sys_id on #ip_conf (Indv_Sys_Id, DT_SYS_ID);

if (object_id('tempdb..#utilization_paindiag') is not null)
drop table #utilization_paindiag
go

Select Indv_sys_id
	, Pain_Total_Allow = isnull(sum(allw_amt),0)
	, Pain_IP_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'IP' then Allw_Amt end),0)
	, Pain_OP_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'OP' then Allw_Amt end),0)
	, Pain_ER_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'ER' then Allw_Amt end),0)
	, Pain_DR_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'DR' then Allw_Amt end),0)
	, Pain_RX_Allow		=isnull(sum(case when Derived_Srvc_type_cd = 'RX' then Allw_Amt end),0)
--	, IP_Visits		= isnull(count(distinct case when Derived_Srvc_type_cd = 'IP' and Admit_Cnt = 1 then FULL_DT end), 0)
--	, IP_Days		= isnull(sum(case when Derived_Srvc_type_cd = 'IP' and Admit_Cnt = 1 then Day_Cnt end), 0)
--	, OP_Visits		= isnull(count(distinct case when Derived_Srvc_type_cd = 'OP' then FULL_DT end), 0)
--	, ER_Visits		= isnull(count(distinct case when Derived_Srvc_type_cd = 'ER' then FULL_DT end), 0)
--	, DR_Visits		= isnull(count(distinct case when Derived_Srvc_type_cd = 'DR' then FULL_DT end), 0)
--	, RX_Scripts	= isnull(sum(case when Derived_Srvc_type_cd = 'RX' then Scrpt_Cnt end), 0)
--	, DME_Allow		= isnull(sum(case when Derived_Srvc_Type_cd = 'DME' 	then Allw_Amt else 0	end), 0)

into #utilization_paindiag
from (
				select a.Indv_Sys_Id, b.Clm_Aud_Nbr, b.Dt_Sys_Id, b.Allw_Amt
					, c.FULL_DT, Derived_Srvc_type_cd = case when d.HCE_SRVC_TYP_DESC in ('ER','Emergency Room')		then 'ER' else e.Srvc_Typ_Cd end
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_Claims				b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.Dt_Sys_Id = c.DT_SYS_ID
				inner join MiniHPDM..Dim_Service_Type			e on b.Srvc_Typ_Sys_Id = e.Srvc_Typ_Sys_Id
				inner join MiniHPDM..DIM_HP_SERVICE_TYPE_CODE	d on b.Hlth_Pln_Srvc_Typ_Cd_Sys_ID = d.HLTH_PLN_SRVC_TYP_CD_SYS_ID
				left join pdb_VT_ChronicPain..pain_types_v2 h on b.Diag_1_Cd_Sys_Id = h.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h1 on b.Diag_2_Cd_Sys_Id = h1.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h2 on b.Diag_3_Cd_Sys_Id = h2.diag_cd_sys_id
				where c.YEAR_NBR = 2017 and (h.diag_cd_sys_id is not null or h1.diag_cd_sys_id is not null or h2.diag_cd_sys_id is not null)-- and a.indv_sys_id = 1211602490
					and wChronicPain = 1

				union
				select a.Indv_Sys_Id, b.CLM_AUD_NBR, b.FST_SRVC_DT_SYS_ID, b.ALLW_AMT
				, c.FULL_DT
				, Derived_Srvc_type_cd = case when e.Bil_Typ_Cd in ('111','112','113','114','116','117') then 'IP'
												when  d.AMA_PL_OF_SRVC_DESC = 'EMERGENCY ROOM'										  then 'ER'
												when e.Bil_Typ_Cd in ('131','132','133','134','136','137',
																	'710','711','712','713','714','715','716','717','718','719',
																	'760','761','762','763','764','765','766','767','768','769',
																	'770','771','772','773','774','775','776','777','778','779') then 'OP'
												when RVNU_CD_SYS_ID <= 2 and d.AMA_PL_OF_SRVC_DESC not in ('HOME','SKILLED NURSING FACILITY') then 'DR'
												when g.AHRQ_PROC_DTL_CATGY_DESC = 'DME AND SUPPLIES'											then 'DME'
												else 'OTH' end
				
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_UBH_Claims			b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.FST_SRVC_DT_SYS_ID = c.DT_SYS_ID
				inner join MiniHPDM..Dim_Place_of_Service_Code	d on b.PL_OF_SRVC_SYS_ID = d.PL_OF_SRVC_SYS_ID
				inner join MiniHPDM..Dim_Bill_Type_Code			e on b.BIL_TYP_CD_SYS_ID = e.Bil_Typ_Cd_Sys_Id
				inner join MiniHPDM..Dim_Procedure_Code			g on b.Proc_Cd_Sys_Id = g.Proc_Cd_Sys_Id
				left join pdb_VT_ChronicPain..pain_types_v2 h on b.Diag_1_Cd_Sys_Id = h.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h1 on b.Diag_2_Cd_Sys_Id = h1.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h2 on b.DIAG_3_CD_SYS_ID = h2.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h3 on b.DIAG_4_CD_SYS_ID = h3.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h4 on b.DIAG_5_CD_SYS_ID = h4.diag_cd_sys_id
				where c.YEAR_NBR = 2017 and (h.diag_cd_sys_id is not null or h1.diag_cd_sys_id is not null or h2.diag_cd_sys_id is not null or h3.diag_cd_sys_id is not null or h4.DIAG_CD is not null)
					and wChronicPain = 1
				) b --on a.indv_sys_id = b.Indv_Sys_Id
--where indv_sys_id = 1347169773
group by indv_sys_id
create unique index uIx_Indv on #utilization_paindiag (Indv_sys_id);
--293,941
/*
Alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
add Pain_Total_Allow decimal(18,2)
	,Pain_Ip_Allow	 decimal(18,2)
	,Pain_OP_Allow	 decimal(18,2)
	,Pain_ER_Allow	 decimal(18,2)
	,Pain_DR_Allow	 decimal(18,2)
	,Pain_RX_Allow	 decimal(18,2)
	go
	*/

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
set		  Pain_Total_Allow		=isnull(b.Pain_Total_Allow,0)
		, Pain_Ip_Allow			=isnull(b.Pain_IP_Allow,0)
		, Pain_OP_Allow			=isnull(b.Pain_OP_Allow,0)
		, Pain_ER_Allow			=isnull(b.Pain_ER_Allow,0)
		, Pain_DR_Allow			=isnull(b.Pain_DR_Allow,0)
		, Pain_RX_Allow			=isnull(b.Pain_RX_Allow,0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 a
left join #utilization_paindiag b on a.indv_sys_id = b.indv_sys_id
where wChronicPain = 1


drop table #check
select a.Indv_Sys_Id, DIAG_CD
into #check
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 a
right join (			
				select a.Indv_Sys_Id, DIAG_CD
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_Claims				b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.Dt_Sys_Id = c.DT_SYS_ID
				inner join pdb_VT_ChronicPain..pain_types_v2 h on b.Diag_1_Cd_Sys_Id = h.diag_cd_sys_id
				where YEAR_NBR = 2017
				group by a.Indv_Sys_Id, h.DIAG_CD
				union
				select a.Indv_Sys_Id, DIAG_CD
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_Claims				b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.Dt_Sys_Id = c.DT_SYS_ID
				inner join pdb_VT_ChronicPain..pain_types_v2 h on b.Diag_2_Cd_Sys_Id = h.diag_cd_sys_id
				where YEAR_NBR = 2017
				group by a.Indv_Sys_Id, h.DIAG_CD
				union
				select a.Indv_Sys_Id, DIAG_CD
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_Claims				b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.Dt_Sys_Id = c.DT_SYS_ID
				inner join pdb_VT_ChronicPain..pain_types_v2 h on b.Diag_3_Cd_Sys_Id = h.diag_cd_sys_id
				where YEAR_NBR = 2017
				group by a.Indv_Sys_Id, h.DIAG_CD
				) b on a.Indv_Sys_Id = b.Indv_Sys_Id
where wChronicPain = 1

Select count( distinct indv_sys_id)
from #check


--average morphine equivalency for Pain Members
If (object_id('tempdb..#mme') Is Not Null)
Drop Table #mme
go


select a.Indv_Sys_Id
	, Avg_MME = avg(Dose_day)
into #mme
from	(
			select a.Indv_Sys_Id, a.Fill_Dt, a.Script_Thru, a.DRG_STRGTH_UNIT_DESC, BRND_NM, PROC_CD
				, Dose_day = avg(Dose_day)
				, Dose_day2 = sum(Dose_day)
			--into #test
			from	(
						select a.Indv_Sys_Id, Fill_Dt = d.FULL_DT, Script_Thru = dateadd(dd, c.Day_Cnt, d.FULL_DT)
							, c.Day_Cnt, c.Qty_Cnt, f.DRG_STRGTH_NBR, f.DRG_STRGTH_UNIT_DESC, f.BRND_NM, PROC_CD	--, c.*
							, Dose_day	= case when	Proc_Cd = 'J2271'	then 100
												when Proc_Cd = 'J2275'	then 10
												when Proc_Cd = 'J2270'	then 10		else (Qty_Cnt * DRG_STRGTH_NBR * 1.0) / nullif(Day_Cnt, 0)	end
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			a
						inner join MiniHPDM..Fact_Claims		c	on	a.Indv_Sys_Id = c.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			d	on	c.Dt_Sys_Id = d.DT_SYS_ID
																	--and d.Full_Dt between a.WeekStart and a.WeekEnd
						inner join MiniHPDM..Dim_Procedure_Code	e	on	c.Proc_Cd_Sys_Id = e.PROC_CD_SYS_ID
						inner join MiniHPDM..Dim_NDC_Drug		f	on	c.NDC_Drg_Sys_Id = f.NDC_DRG_SYS_ID
						where d.YEAR_NBR = 2017
							and (PROC_CD in ('J2271','J2275','J2270')
							or BRND_NM in ('MS CONTIN', 'ASTRAMORPH-PF', 'DEPODUR', 'DURAMORPH', 'INFUMORPH', 'KADIAN', 'MORPHABOND ER', 'ARYMO ER')	--https://www.rxlist.com/consumer_morphine_duramorph_arymo_er/drugs-condition.htm 
							or GNRC_NM like 'morphine%')	
				) a
			inner join MiniHPDM..Dim_Date			b	on	b.FULL_DT between a.Fill_Dt and a.Script_Thru
			where b.YEAR_NBR = 2017
			group by a.Indv_Sys_Id, a.Fill_Dt, a.Script_Thru, a.DRG_STRGTH_UNIT_DESC, BRND_NM, PROC_CD
			--order by FULL_DT
	) a
--where BRND_NM = 'MS CONTIN'
group by Indv_Sys_Id		
--50,464 2.21hrs
create index uIx_ID_WeekInd_DrugName on #mme (Indv_Sys_Id);
/*
/* adding average dose per day */
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
	add	  Avg_MME			decimal(9,2) 
	go
*/
--use pdb_VT_ChronicPain
--select * from INFORMATION_SCHEMA.COLUMNS where table_name = 'Com_MemberSummary_TTL_v2'
update pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
set Avg_MME = isnull(b.Avg_MME,0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 a
left join #mme b on a.indv_sys_id = b.Indv_Sys_Id
where wChronicPain = 1
--293,941
--Back Surgery Allow
--drop table #back_allw
select Indv_Sys_Id, Back_Surgery_Allow = sum(Allw_Amt)
into #back_allw
from (
			Select  a.Indv_Sys_Id, d.PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_1_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			union
			Select  a.Indv_Sys_Id, d.PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_2_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			union
			Select  a.Indv_Sys_Id, d.PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_3_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			union
			Select  a.Indv_Sys_Id, d.PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_1_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			union
			Select  a.Indv_Sys_Id, d.PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_2_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			union
			Select  a.Indv_Sys_Id, d.PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_3_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
				
			union
			Select  a.Indv_Sys_Id, d.PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_4_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			union
			Select  a.Indv_Sys_Id, d.PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_5_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
	) a
group by Indv_Sys_Id
--3,667 5mins
create unique index uid_idv on #back_allw (Indv_Sys_Id)

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 set 
  BackSurgery_Allow		= isnull(b.Back_Surgery_Allow		,0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	m
left join #back_allw							b on m.Indv_Sys_Id = b.Indv_Sys_Id
--3,411,943


