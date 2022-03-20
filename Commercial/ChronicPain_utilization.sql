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
		where --wChronicPain = 1 and 
			b.Srvc_Typ_Sys_Id = 1
			and b.Admit_Cnt = 1
			and c1.YEAR_NBR = 2017
			--and a.Indv_Sys_Id = 1205073346
	)							as a
inner join MiniHPDM..Dim_Date	as b on b.DT_SYS_ID between a.Admit_DtSys and a.Discharge_DtSys
group by a.Indv_Sys_Id, b.DT_SYS_ID
--743,130 28mins
create unique index ucix_Indv_sys_id on #ip_conf (Indv_Sys_Id, DT_SYS_ID);



if (object_id('tempdb..#utilization') is not null)
drop table #utilization
go

Select Indv_sys_id
	, Total_Allow = isnull(sum(allw_amt),0)
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
				select a.Indv_Sys_Id, b.Clm_Aud_Nbr, b.Dt_Sys_Id, b.Proc_Cd_Sys_Id, b.Allw_Amt, b.Admit_Cnt, b.Day_Cnt, b.Scrpt_Cnt
					, Derived_Srvc_type_cd = case when f.Indv_Sys_Id is not null and e.Srvc_Typ_Cd <> 'IP' then 'IP' -- if ER,OP or DR falls within IP days then consider as IP
											when d.HCE_SRVC_TYP_DESC in ('ER','Emergency Room')		then 'ER' 
											when g.AHRQ_PROC_DTL_CATGY_DESC = 'DME AND SUPPLIES'			then 'DME'	else 	e.Srvc_Typ_Cd end
					, c.FULL_DT
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_Claims				b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.Dt_Sys_Id = c.DT_SYS_ID
				inner join MiniHPDM..DIM_HP_SERVICE_TYPE_CODE	d on b.Hlth_Pln_Srvc_Typ_Cd_Sys_ID = d.HLTH_PLN_SRVC_TYP_CD_SYS_ID
				inner join MiniHPDM..Dim_Service_Type			e on b.Srvc_Typ_Sys_Id = e.Srvc_Typ_Sys_Id
				inner join MiniHPDM..Dim_Procedure_Code			g on b.Proc_Cd_Sys_Id = g.Proc_Cd_Sys_Id
				left join #ip_conf								f on b.Indv_Sys_Id = f.Indv_Sys_Id and b.Dt_Sys_Id = f.DT_SYS_ID
				where c.YEAR_NBR = 2017

				union
				select a.Indv_Sys_Id, b.CLM_AUD_NBR, b.FST_SRVC_DT_SYS_ID, b.PROC_CD_SYS_ID, b.ALLW_AMT
				, admit_cnt = case when f.Indv_Sys_Id is not null or e.Bil_Typ_Cd in ('111','112','113','114','116','117') then 1 else 0 end
				, Day_cnt = case when f.Indv_Sys_Id is not null or e.Bil_Typ_Cd in ('111','112','113','114','116','117') then (b.LST_SRVC_DT_SYS_ID - b.FST_SRVC_DT_SYS_ID) else 0 end
				, Scrpt_cnt = 0
				, Derived_Srvc_type_cd = case when f.Indv_Sys_Id is not null or e.Bil_Typ_Cd in ('111','112','113','114','116','117') then 'IP'
												when  d.AMA_PL_OF_SRVC_DESC = 'EMERGENCY ROOM'										  then 'ER'
												when e.Bil_Typ_Cd in ('131','132','133','134','136','137',
																	'710','711','712','713','714','715','716','717','718','719',
																	'760','761','762','763','764','765','766','767','768','769',
																	'770','771','772','773','774','775','776','777','778','779') then 'OP'
												when RVNU_CD_SYS_ID <= 2 and d.AMA_PL_OF_SRVC_DESC not in ('HOME','SKILLED NURSING FACILITY') then 'DR'
												when g.AHRQ_PROC_DTL_CATGY_DESC = 'DME AND SUPPLIES'											then 'DME'
												else 'OTH' end
				, c.FULL_DT
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_UBH_Claims			b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.FST_SRVC_DT_SYS_ID = c.DT_SYS_ID
				inner join MiniHPDM..Dim_Place_of_Service_Code	d on b.PL_OF_SRVC_SYS_ID = d.PL_OF_SRVC_SYS_ID
				inner join MiniHPDM..Dim_Bill_Type_Code			e on b.BIL_TYP_CD_SYS_ID = e.Bil_Typ_Cd_Sys_Id
				inner join MiniHPDM..Dim_Procedure_Code			g on b.Proc_Cd_Sys_Id = g.Proc_Cd_Sys_Id
				left join #ip_conf								f on b.Indv_Sys_Id = f.Indv_Sys_Id and b.FST_SRVC_DT_SYS_ID = f.DT_SYS_ID
				where c.YEAR_NBR = 2017
				) b --on a.indv_sys_id = b.Indv_Sys_Id
--where indv_sys_id = 378113799

group by indv_sys_id
--2,879,045 - 1:17hrs
create unique index uIx_Indv on #utilization (Indv_sys_id);


/*
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
	add DME_Allow	decimal(9,2)
	*/
update pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
set		  Total_Allow		=isnull(b.Total_Allow,0)
		, Ip_Allow			=isnull(b.IP_Allow,0)
		, OP_Allow			=isnull(b.OP_Allow,0)
		, ER_Allow			=isnull(b.ER_Allow,0)
		, DR_Allow			=isnull(b.DR_Allow,0)
		, RX_Allow			=isnull(b.RX_Allow,0)
		, IP_Visits			=isnull(b.IP_Visits,0)
		, IP_Days			=isnull(b.IP_Days,0)
		, OP_Visits			=isnull(b.OP_Visits,0)
		, ER_Visits			=isnull(b.ER_Visits,0)
		, DR_Visits			=isnull(b.DR_Visits,0)
		, RX_Scripts		=isnull(b.RX_Scripts,0)
		, DME_Allow			=isnull(b.DME_Allow,0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 a
left join #utilization b on a.indv_sys_id = b.indv_sys_id
--3,411,943 5mins

--procedure costs
if object_id('tempdb..#therapycosts') is not null
drop table #therapycosts
go

select Indv_Sys_Id
	, Psychotherapy_Allow		= sum(case when TherapyFlag = 'Psychotherapy'	then Allw_Amt	else 0	end)
	, GnrlPsychotherapy_Allow	= sum(case when TherapyFlag = 'General Psychotherapy'	then Allw_Amt	else 0	end)
	, PhysicalTherapy_Allow		= sum(case when TherapyFlag = 'Physical Therapy'		then Allw_Amt	else 0	end)
	, Psychotherapy_Flag		= max(case when TherapyFlag = 'Psychotherapy'	then 1	else 0	end)
	, GnrlPsychotherapy_Flag	= max(case when TherapyFlag = 'General Psychotherapy'	then 1	else 0	end)
	, PhysicalTherapy_Flag		= max(case when TherapyFlag = 'Physical Therapy'		then 1	else 0	end)
into #therapycosts
from	(
			select a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, b.Allw_Amt
				, TherapyFlag = case when e.Proc_Cd is not null	then 'Psychotherapy'
									when d.AHRQ_PROC_DTL_CATGY_DESC like '%Psychological%'			then 'General Psychotherapy' 
									when d.AHRQ_PROC_DTL_CATGY_DESC = 'PT EXERCISES; MANIPULATION'	then 'Physical Therapy'			end
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			left join pdb_VT_ChronicPain..therapy	e	on	d.PROC_CD = e.PROC_CD
			where c.YEAR_NBR = 2017
			group by a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, e.Proc_Cd, d.AHRQ_PROC_DTL_CATGY_DESC, Allw_Amt

			--UBH claims
			union
			select a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, b.Allw_Amt
				, TherapyFlag = case when e.Proc_Cd is not null	then 'Psychotherapy'
									when d.AHRQ_PROC_DTL_CATGY_DESC like '%Psychological%'			then 'General Psychotherapy' 
									when d.AHRQ_PROC_DTL_CATGY_DESC = 'PT EXERCISES; MANIPULATION'	then 'Physical Therapy'			end
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.PROC_1_CD_SYS_ID = d.PROC_CD_SYS_ID
			left join pdb_VT_ChronicPain..therapy	e	on	d.PROC_CD = e.PROC_CD
			where c.YEAR_NBR = 2017
			group by a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, e.Proc_Cd, d.AHRQ_PROC_DTL_CATGY_DESC, b.Allw_Amt

			union
			select a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, b.Allw_Amt
				, TherapyFlag = case when e.Proc_Cd is not null	then 'Psychotherapy'
									when d.AHRQ_PROC_DTL_CATGY_DESC like '%Psychological%'			then 'General Psychotherapy' 
									when d.AHRQ_PROC_DTL_CATGY_DESC = 'PT EXERCISES; MANIPULATION'	then 'Physical Therapy'			end
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.PROC_2_CD_SYS_ID = d.PROC_CD_SYS_ID
			left join pdb_VT_ChronicPain..therapy	e	on	d.PROC_CD = e.PROC_CD
			where c.YEAR_NBR = 2017
			group by a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, e.Proc_Cd, d.AHRQ_PROC_DTL_CATGY_DESC, b.Allw_Amt

			union
			select a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, b.Allw_Amt
				, TherapyFlag = case when e.Proc_Cd is not null	then 'Psychotherapy'
									when d.AHRQ_PROC_DTL_CATGY_DESC like '%Psychological%'			then 'General Psychotherapy' 
									when d.AHRQ_PROC_DTL_CATGY_DESC = 'PT EXERCISES; MANIPULATION'	then 'Physical Therapy'			end
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.PROC_3_CD_SYS_ID = d.PROC_CD_SYS_ID
			left join pdb_VT_ChronicPain..therapy	e	on	d.PROC_CD = e.PROC_CD
			where c.YEAR_NBR = 2017
			group by a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, e.Proc_Cd, d.AHRQ_PROC_DTL_CATGY_DESC, b.Allw_Amt
		)	a
group by Indv_Sys_Id
--2,879,045 1:19hrs

create unique index uix_Indv on #therapycosts (Indv_Sys_Id);

select top 1000 Indv_Sys_Id, GenlPsychotherapy_Flag,GnrlPsychotherapy_Allow from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
	--drop column GnrlPsychotherapy_Flag
	add  PhysicalTherapy_Flag	tinyint
go

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
set Psychotherapy_Allow	= isnull(b.Psychotherapy_Allow, 0)
		, GnrlPsychotherapy_Allow	= isnull(b.GnrlPsychotherapy_Allow, 0)
		, PhysicalTherapy_Allow	= isnull(b.PhysicalTherapy_Allow, 0)
		, Psychotherapy_Flag = isnull(b.Psychotherapy_Flag,0)
		, GenlPsychotherapy_Flag = isnull(b.GnrlPsychotherapy_Flag,0)
		, PhysicalTherapy_Flag = isnull(b.PhysicalTherapy_Flag,0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
left join #therapycosts							b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
--3,411,943
						b	on	a.Indv_Sys_Id = b.Indv_Sys_Id

-------------------------------------------------------------------------
select b. Indv_Sys_Id,
		 Total_Allow = sum(Total_Allow)
		, IP_Allow = sum(IP_Allow)
		, OP_Allow =  sum(OP_Allow)
		, ER_Allow =  sum(ER_Allow)
		, DR_Allow =  sum(DR_Allow)
		, RX_Allow =  sum(RX_Allow)
		, IP_Visits =  sum(IP_Visits)
		, OP_Visits = sum (OP_Visits)
		, ER_Visits = sum (ER_Visits)
		, Dr_Visits = sum (DR_Visits)
		, RX_Scripts = sum(RX_Scripts)
		, Psychotherapy_total_Allow				=	 isnull(sum(case when b.Psychotherapy = 1 then Total_Allow else null end),0)
		, Psychotherapy_IP_Allow				=	 isnull(sum(case when b.Psychotherapy = 1 then IP_Allow else null end) , 0)
		, Psychotherapy_OP_Allow				=	 isnull(sum(case when b.Psychotherapy = 1 then OP_Allow else null end) , 0)
		, Psychotherapy_ER_Allow				=	 isnull(sum(case when b.Psychotherapy = 1 then ER_Allow else null end) , 0)
		, Psychotherapy_DR_Allow				=	 isnull(sum(case when b.Psychotherapy = 1 then DR_Allow else null end) , 0)
		, Psychotherapy_RX_Allow				=	 isnull(sum(case when b.Psychotherapy = 1 then RX_Allow else null end) , 0)
		, Psychotherapy_I_Visits				=	 isnull(sum(case when b.Psychotherapy = 1 then IP_Visits else null end), 0)
		, Psychotherapy_OP_Visits				=	 isnull(sum(case when b.Psychotherapy = 1 then OP_Visits else null end), 0)
		, Psychotherapy_ER_Visits				=	 isnull(sum(case when b.Psychotherapy = 1 then ER_Visits else null end), 0)
		, Psychotherapy_Dr_Visits				=	 isnull(sum(case when b.Psychotherapy = 1 then DR_Visits else null end), 0)
		, Psychotherapy_RX_Scripts				=	 isnull(sum(case when b.Psychotherapy = 1 then RX_Scripts else null end), 0)
		, Genl_Psychotherapy_total_Allow		=	 isnull(sum(case when b.Genltherapy = 1 then Total_Allow else null end),0)
		, Genl_Psychotherapy_IP_Allow			=	 isnull(sum(case when b.Genltherapy = 1 then IP_Allow else null end), 0)
		, Genl_Psychotherapy_OP_Allow			=	 isnull(sum(case when b.Genltherapy = 1 then OP_Allow else null end), 0)
		, Genl_Psychotherapy_ER_Allow			=	 isnull(sum(case when b.Genltherapy = 1 then ER_Allow else null end), 0)
		, Genl_Psychotherapy_DR_Allow			=	 isnull(sum(case when b.Genltherapy = 1 then DR_Allow else null end), 0)
		, Genl_Psychotherapy_RX_Allow			=	 isnull(sum(case when b.Genltherapy = 1 then RX_Allow else null end), 0)
		, Genl_Psychotherapy_I_Visits			=	 isnull(sum(case when b.Genltherapy = 1 then IP_Visits else null end), 0)
		, Genl_Psychotherapy_OP_Visits			=	 isnull(sum(case when b.Genltherapy = 1 then OP_Visits else null end), 0)
		, Genl_Psychotherapy_ER_Visits			=	 isnull(sum(case when b.Genltherapy = 1 then ER_Visits else null end), 0)
		, Genl_Psychotherapy_Dr_Visits			=	 isnull(sum(case when b.Genltherapy = 1 then DR_Visits else null end), 0)
		, Genl_Psychotherapy_RX_Scripts			=	 isnull(sum(case when b.Genltherapy = 1 then RX_Scripts else null end), 0)
		, Depression_total_Allow				=	 isnull(sum(case when b.DepressionFlag = 1 then Total_Allow else null end),0)
		, Depression_IP_Allow					=	 isnull(sum(case when b.DepressionFlag = 1 then IP_Allow else null end)   , 0)
		, Depression_OP_Allow					=	 isnull(sum(case when b.DepressionFlag = 1 then OP_Allow else null end)	  , 0)
		, Depression_ER_Allow					=	 isnull(sum(case when b.DepressionFlag = 1 then ER_Allow else null end)	  , 0)
		, Depression_DR_Allow					=	 isnull(sum(case when b.DepressionFlag = 1 then DR_Allow else null end)	  , 0)
		, Depression_RX_Allow					=	 isnull(sum(case when b.DepressionFlag = 1 then RX_Allow else null end)	  , 0)
		, Depression_I_Visits					=	 isnull(sum(case when b.DepressionFlag = 1 then IP_Visits else null end)  , 0)
		, Depression_OP_Visits					=	 isnull(sum(case when b.DepressionFlag = 1 then OP_Visits else null end)  , 0)
		, Depression_ER_Visits					=	 isnull(sum(case when b.DepressionFlag = 1 then ER_Visits else null end)  , 0)
		, Depression_Dr_Visits					=	 isnull(sum(case when b.DepressionFlag = 1 then DR_Visits else null end)  , 0)
		, Depression_RX_Scripts					=	 isnull(sum(case when b.DepressionFlag = 1 then RX_Scripts else null end) , 0)
from #utilization a
right join pdb_VT_ChronicPain..tmp_Member2017  b on a.indv_sys_id = b.indv_sys_id
group by b.Indv_Sys_Id

select total_mbrs = count(distinct indv_sys_id)
, Psychotherapy = sum(Psychotherapy)
, DepressionFlag = sum(DepressionFlag)
from pdb_VT_ChronicPain..tmp_Member2017

select pain_mbrs = sum(wChronicPain)
, Psychotherapy = sum(Psychotherapy)
, DepressionFlag = sum(DepressionFlag)
from pdb_VT_ChronicPain..tmp_Member2017
where wChronicPain = 1

select a.Indv_Sys_Id 
	,Pain_Total_Allow = sum(Allw_Amt)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 a
inner join MiniHPDM..Fact_Claims  b on a.Indv_Sys_Id = b.Indv_Sys_Id
inner join pdb_VT_ChronicPain..pain_types_v2  d on b.Diag_1_Cd_Sys_Id = d.diag_cd_sys_id
left  join pdb_VT_ChronicPain..pain_types_v2 d1 on b.Diag_2_Cd_Sys_Id = d1.diag_cd_sys_id
left  join pdb_VT_ChronicPain..pain_types_v2 d2 on b.Diag_3_Cd_Sys_Id = d2.diag_cd_sys_id
where a.Indv_Sys_Id = 378113799
group by a.Indv_Sys_Id
-----------------------------------------------------------------------------------------------------------------------------------------------------------
 
-- DME list
select PROC_CD, PROC_DESC,Derived_Srvc_type_cd, cnt_mbrs = count(distinct indv_sys_id), Allow_Amt = sum(Allw_Amt)
from (
				select a.Indv_Sys_Id, b.Clm_Aud_Nbr, b.Dt_Sys_Id, b.Proc_Cd_Sys_Id, b.Allw_Amt, b.Admit_Cnt, b.Day_Cnt, b.Scrpt_Cnt,PROC_CD,PROC_DESC
					, Derived_Srvc_type_cd = case when f.Indv_Sys_Id is not null and e.Srvc_Typ_Cd <> 'IP' then 'IP' -- if ER,OP or DR falls within IP days then consider as IP
											when d.HCE_SRVC_TYP_DESC in ('ER','Emergency Room')		then 'ER' 
											when g.AHRQ_PROC_DTL_CATGY_DESC = 'DME AND SUPPLIES'			then 'DME'	else 	e.Srvc_Typ_Cd end
					, c.FULL_DT
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_Claims				b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.Dt_Sys_Id = c.DT_SYS_ID
				inner join MiniHPDM..DIM_HP_SERVICE_TYPE_CODE	d on b.Hlth_Pln_Srvc_Typ_Cd_Sys_ID = d.HLTH_PLN_SRVC_TYP_CD_SYS_ID
				inner join MiniHPDM..Dim_Service_Type			e on b.Srvc_Typ_Sys_Id = e.Srvc_Typ_Sys_Id
				inner join MiniHPDM..Dim_Procedure_Code			g on b.Proc_Cd_Sys_Id = g.Proc_Cd_Sys_Id
				left join #ip_conf								f on b.Indv_Sys_Id = f.Indv_Sys_Id and b.Dt_Sys_Id = f.DT_SYS_ID
				where c.YEAR_NBR = 2017

				union
				select a.Indv_Sys_Id, b.CLM_AUD_NBR, b.FST_SRVC_DT_SYS_ID, b.PROC_CD_SYS_ID, b.ALLW_AMT
				, admit_cnt = case when f.Indv_Sys_Id is not null or e.Bil_Typ_Cd in ('111','112','113','114','116','117') then 1 else 0 end
				, Day_cnt = case when f.Indv_Sys_Id is not null or e.Bil_Typ_Cd in ('111','112','113','114','116','117') then (b.LST_SRVC_DT_SYS_ID - b.FST_SRVC_DT_SYS_ID) else 0 end
				, Scrpt_cnt = 0
				, PROC_CD,PROC_DESC
				, Derived_Srvc_type_cd = case when f.Indv_Sys_Id is not null or e.Bil_Typ_Cd in ('111','112','113','114','116','117') then 'IP'
												when  d.AMA_PL_OF_SRVC_DESC = 'EMERGENCY ROOM'										  then 'ER'
												when e.Bil_Typ_Cd in ('131','132','133','134','136','137',
																	'710','711','712','713','714','715','716','717','718','719',
																	'760','761','762','763','764','765','766','767','768','769',
																	'770','771','772','773','774','775','776','777','778','779') then 'OP'
												when RVNU_CD_SYS_ID <= 2 and d.AMA_PL_OF_SRVC_DESC not in ('HOME','SKILLED NURSING FACILITY') then 'DR'
												when g.AHRQ_PROC_DTL_CATGY_DESC = 'DME AND SUPPLIES'											then 'DME'
												else 'OTH' end
				, c.FULL_DT
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_UBH_Claims			b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.FST_SRVC_DT_SYS_ID = c.DT_SYS_ID
				inner join MiniHPDM..Dim_Place_of_Service_Code	d on b.PL_OF_SRVC_SYS_ID = d.PL_OF_SRVC_SYS_ID
				inner join MiniHPDM..Dim_Bill_Type_Code			e on b.BIL_TYP_CD_SYS_ID = e.Bil_Typ_Cd_Sys_Id
				inner join MiniHPDM..Dim_Procedure_Code			g on b.Proc_Cd_Sys_Id = g.Proc_Cd_Sys_Id
				left join #ip_conf								f on b.Indv_Sys_Id = f.Indv_Sys_Id and b.FST_SRVC_DT_SYS_ID = f.DT_SYS_ID
				where c.YEAR_NBR = 2017
				) b 
where Derived_Srvc_type_cd = 'DME'
group by PROC_CD, PROC_DESC,Derived_Srvc_type_cd
order by cnt_mbrs desc


--DME specific diagnosis --
select PROC_CD, PROC_DESC,Derived_Srvc_type_cd, cnt_mbrs = count(distinct indv_sys_id), Allow_Amt = sum(Allw_Amt)
from (
				select a.Indv_Sys_Id, b.Clm_Aud_Nbr, b.Dt_Sys_Id, b.Proc_Cd_Sys_Id, b.Allw_Amt, b.Admit_Cnt, b.Day_Cnt, b.Scrpt_Cnt,PROC_CD,PROC_DESC
					, Derived_Srvc_type_cd = case when f.Indv_Sys_Id is not null and e.Srvc_Typ_Cd <> 'IP' then 'IP' -- if ER,OP or DR falls within IP days then consider as IP
											when d.HCE_SRVC_TYP_DESC in ('ER','Emergency Room')		then 'ER' 
											when g.AHRQ_PROC_DTL_CATGY_DESC = 'DME AND SUPPLIES'			then 'DME'	else 	e.Srvc_Typ_Cd end
					, c.FULL_DT
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_Claims				b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.Dt_Sys_Id = c.DT_SYS_ID
				inner join MiniHPDM..DIM_HP_SERVICE_TYPE_CODE	d on b.Hlth_Pln_Srvc_Typ_Cd_Sys_ID = d.HLTH_PLN_SRVC_TYP_CD_SYS_ID
				inner join MiniHPDM..Dim_Service_Type			e on b.Srvc_Typ_Sys_Id = e.Srvc_Typ_Sys_Id
				inner join MiniHPDM..Dim_Procedure_Code			g on b.Proc_Cd_Sys_Id = g.Proc_Cd_Sys_Id
				left join #ip_conf								f on b.Indv_Sys_Id = f.Indv_Sys_Id and b.Dt_Sys_Id = f.DT_SYS_ID
				left join pdb_VT_ChronicPain..pain_types_v2 h on b.Diag_1_Cd_Sys_Id = h.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h1 on b.Diag_2_Cd_Sys_Id = h1.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h2 on b.Diag_3_Cd_Sys_Id = h2.diag_cd_sys_id
				where c.YEAR_NBR = 2017 and (h.diag_cd_sys_id is not null or h1.diag_cd_sys_id is not null or h2.diag_cd_sys_id is not null)

				union
				select a.Indv_Sys_Id, b.CLM_AUD_NBR, b.FST_SRVC_DT_SYS_ID, b.PROC_CD_SYS_ID, b.ALLW_AMT
				, admit_cnt = case when f.Indv_Sys_Id is not null or e.Bil_Typ_Cd in ('111','112','113','114','116','117') then 1 else 0 end
				, Day_cnt = case when f.Indv_Sys_Id is not null or e.Bil_Typ_Cd in ('111','112','113','114','116','117') then (b.LST_SRVC_DT_SYS_ID - b.FST_SRVC_DT_SYS_ID) else 0 end
				, Scrpt_cnt = 0
				, PROC_CD,PROC_DESC
				, Derived_Srvc_type_cd = case when f.Indv_Sys_Id is not null or e.Bil_Typ_Cd in ('111','112','113','114','116','117') then 'IP'
												when  d.AMA_PL_OF_SRVC_DESC = 'EMERGENCY ROOM'										  then 'ER'
												when e.Bil_Typ_Cd in ('131','132','133','134','136','137',
																	'710','711','712','713','714','715','716','717','718','719',
																	'760','761','762','763','764','765','766','767','768','769',
																	'770','771','772','773','774','775','776','777','778','779') then 'OP'
												when RVNU_CD_SYS_ID <= 2 and d.AMA_PL_OF_SRVC_DESC not in ('HOME','SKILLED NURSING FACILITY') then 'DR'
												when g.AHRQ_PROC_DTL_CATGY_DESC = 'DME AND SUPPLIES'											then 'DME'
												else 'OTH' end
				, c.FULL_DT
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
				inner join MiniHPDM..Fact_UBH_Claims			b on a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date					c on b.FST_SRVC_DT_SYS_ID = c.DT_SYS_ID
				inner join MiniHPDM..Dim_Place_of_Service_Code	d on b.PL_OF_SRVC_SYS_ID = d.PL_OF_SRVC_SYS_ID
				inner join MiniHPDM..Dim_Bill_Type_Code			e on b.BIL_TYP_CD_SYS_ID = e.Bil_Typ_Cd_Sys_Id
				inner join MiniHPDM..Dim_Procedure_Code			g on b.Proc_Cd_Sys_Id = g.Proc_Cd_Sys_Id
				left join #ip_conf								f on b.Indv_Sys_Id = f.Indv_Sys_Id and b.FST_SRVC_DT_SYS_ID = f.DT_SYS_ID
				left join pdb_VT_ChronicPain..pain_types_v2 h on b.Diag_1_Cd_Sys_Id = h.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h1 on b.Diag_2_Cd_Sys_Id = h1.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h2 on b.DIAG_3_CD_SYS_ID = h2.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h3 on b.DIAG_4_CD_SYS_ID = h3.diag_cd_sys_id
				left join pdb_VT_ChronicPain..pain_types_v2 h4 on b.DIAG_5_CD_SYS_ID = h4.diag_cd_sys_id
				where c.YEAR_NBR = 2017 and (h.diag_cd_sys_id is not null or h1.diag_cd_sys_id is not null or h2.diag_cd_sys_id is not null or h3.diag_cd_sys_id is not null or h4.DIAG_CD is not null)
				) b 
where Derived_Srvc_type_cd = 'DME'
group by PROC_CD, PROC_DESC,Derived_Srvc_type_cd
order by cnt_mbrs desc