--drop table pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly
select Indv_Sys_Id, DepressionFlag, Depression_Allow
into pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly
from pdb_VT_ChronicPain..Com_MemberSummary_TTL
create index ix_Idv on pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly (Indv_Sys_Id)

--pain members
if object_id('tempdb..#tmp_pain_mbrs2017') is not null
drop table #tmp_pain_mbrs2017
go

--select count(distinct Indv_Sys_Id)
select Indv_Sys_Id, Category, DIAG_CD, diag_desc
into #tmp_pain_mbrs2017
from	(
			select Indv_Sys_Id, Category, DIAG_CD, diag_desc	
				, Flag = case when datediff(MONTH, min(Min_Date) over(partition by Indv_Sys_Id, Category), max(Max_Date) over(partition by Indv_Sys_Id, Category)) >= 3	-- 3 months or more with chronic pain
							and max(Vst_Cnt) over(partition by Indv_Sys_Id, Category) >= 2	then 1	else 0	end
			from	(
						/** UBH claims **/
						
						select a.Indv_Sys_Id, e.[Final Category] as Category, e.DIAG_CD, e.diag_desc
							, Min_Date = min(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Max_Date = max(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Vst_Cnt = dense_rank() over(partition by a.Indv_Sys_Id, e.[Final Category] order by c.Full_Dt)
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
						inner join MiniHPDM..Fact_UBH_Claims	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
						inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.DIAG_1_CD_SYS_ID = f1.DIAG_CD_SYS_ID
						inner join pdb_VT_ChronicPain..pain_types_v2 e	on	f1.DIAG_CD = e.diag_cd
																		and f1.ICD_VER_CD = e.ICD_VER_CD
						where c.YEAR_NBR = 2017
						--group by a.Indv_Sys_Id, e.[Final Category]
			
						union
						select a.Indv_Sys_Id, e.[Final Category] as Category, e.DIAG_CD, e.diag_desc
							, Min_Date = min(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Max_Date = max(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Vst_Cnt = dense_rank() over(partition by a.Indv_Sys_Id, e.[Final Category] order by c.Full_Dt)
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
						inner join MiniHPDM..Fact_UBH_Claims	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
						inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.DIAG_2_CD_SYS_ID = f1.DIAG_CD_SYS_ID
						inner join pdb_VT_ChronicPain..pain_types_v2 e	on	f1.DIAG_CD = e.diag_cd
																		and f1.ICD_VER_CD = e.ICD_VER_CD
						where c.YEAR_NBR = 2017
						--group by a.Indv_Sys_Id, e.[Final Category]
			
						union
						select a.Indv_Sys_Id, e.[Final Category] as Category, e.DIAG_CD, e.diag_desc
							, Min_Date = min(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Max_Date = max(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Vst_Cnt = dense_rank() over(partition by a.Indv_Sys_Id, e.[Final Category] order by c.Full_Dt)
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
						inner join MiniHPDM..Fact_UBH_Claims	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
						inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.DIAG_3_CD_SYS_ID = f1.DIAG_CD_SYS_ID
						inner join pdb_VT_ChronicPain..pain_types_v2 e	on	f1.DIAG_CD = e.diag_cd
																		and f1.ICD_VER_CD = e.ICD_VER_CD
						where c.YEAR_NBR = 2017
						--group by a.Indv_Sys_Id, e.[Final Category]
			
						union
						select a.Indv_Sys_Id, e.[Final Category] as Category, e.DIAG_CD, e.diag_desc
							, Min_Date = min(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Max_Date = max(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Vst_Cnt = dense_rank() over(partition by a.Indv_Sys_Id, e.[Final Category] order by c.Full_Dt)
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
						inner join MiniHPDM..Fact_UBH_Claims	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
						inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.DIAG_4_CD_SYS_ID = f1.DIAG_CD_SYS_ID
						inner join pdb_VT_ChronicPain..pain_types_v2 e	on	f1.DIAG_CD = e.diag_cd
																		and f1.ICD_VER_CD = e.ICD_VER_CD
						where c.YEAR_NBR = 2017
						--group by a.Indv_Sys_Id, e.[Final Category]
			
						union
						select a.Indv_Sys_Id, e.[Final Category] as Category, e.DIAG_CD, e.diag_desc
							, Min_Date = min(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Max_Date = max(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Vst_Cnt = dense_rank() over(partition by a.Indv_Sys_Id, e.[Final Category] order by c.Full_Dt)
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
						inner join MiniHPDM..Fact_UBH_Claims	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
						inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.DIAG_5_CD_SYS_ID = f1.DIAG_CD_SYS_ID
						inner join pdb_VT_ChronicPain..pain_types_v2 e	on	f1.DIAG_CD = e.diag_cd
																		and f1.ICD_VER_CD = e.ICD_VER_CD
						where c.YEAR_NBR = 2017 
						--group by a.Indv_Sys_Id, e.[Final Category]
					)	a
		) x
where Flag = 1
	--and Category = 'Chronic Idiopathic Pain Syndrome'
--2,828
create index ix_Indv on #tmp_pain_mbrs2017 (Indv_Sys_Id)

-------
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly
	add	wChronicPain	tinyint
		, IdiopathicPain	tinyint
		--, DegenerativePain	tinyint
		, NeuropathicPain	tinyint
		, MusclePain		tinyint
		, InflammatoryPain	tinyint
		--, CancerPain		tinyint
		, NervePain			tinyint
		, UnknownCategory	tinyint
go


--drop table #tmp_pain_mbrs2017
update pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly
set wChronicPain	= case when b.Indv_Sys_Id is not null	then 1	else 0	end
	, IdiopathicPain	= isnull(b.IdiopathicPain	, 0)
	--, DegenerativePain	= isnull(b.DegenerativePain	, 0)
	, NeuropathicPain	= isnull(b.NeuropathicPain	, 0)
	, MusclePain		= isnull(b.MusclePain		, 0)
	, InflammatoryPain	= isnull(b.InflammatoryPain	, 0)
	--, CancerPain		= isnull(b.CancerPain		, 0)
	, NervePain			= isnull(b.NervePain			, 0)
	, UnknownCategory	= isnull(b.UnknownCategory	, 0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
left join	(
				select Indv_Sys_Id
					, IdiopathicPain	= max(case when Category = 'Chronic Idiopathic Pain Syndrome'	then 1 else 0	end)
					--, DegenerativePain	= max(case when Category = 'Degenerative Pain'	then 1 else 0	end)
					, NeuropathicPain	= max(case when Category = 'Neuropathic Pain'	then 1 else 0	end)
					, MusclePain		= max(case when Category = 'Muscle Pain'	then 1 else 0	end)
					, InflammatoryPain	= max(case when Category = 'inflammatory'	then 1 else 0	end)
					--, CancerPain		= max(case when Category = 'cancer pain'	then 1 else 0	end)
					, NervePain			= max(case when Category = 'nerve pain'	then 1 else 0	end)
					, UnknownCategory	= max(case when Category = 'UNKNOWN CATEGORY'	then 1 else 0	end)
				--from #tmp_pain_mbrs2017
				from #tmp_pain_mbrs2017
				group by Indv_Sys_Id
			)	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id

--3,411,943


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
			
			--UBH claims
			select a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, b.Allw_Amt
				, TherapyFlag = case when e.Proc_Cd is not null	then 'Psychotherapy'
									when d.AHRQ_PROC_DTL_CATGY_DESC like '%Psychological%'			then 'General Psychotherapy' 
									when d.AHRQ_PROC_DTL_CATGY_DESC = 'PT EXERCISES; MANIPULATION'	then 'Physical Therapy'			end
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
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
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
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
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.PROC_3_CD_SYS_ID = d.PROC_CD_SYS_ID
			left join pdb_VT_ChronicPain..therapy	e	on	d.PROC_CD = e.PROC_CD
			where c.YEAR_NBR = 2017
			group by a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, e.Proc_Cd, d.AHRQ_PROC_DTL_CATGY_DESC, b.Allw_Amt
		)	a
group by Indv_Sys_Id
--218,284

create unique index uix_Indv on #therapycosts (Indv_Sys_Id);


alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly
	--drop column GnrlPsychotherapy_Flag
	add  Psychotherapy_Allow decimal(10,2)
	, GnrlPsychotherapy_Allow decimal(10,2)
	, PhysicalTherapy_Allow decimal(10,2)
	, Psychotherapy_Flag tinyint
	, GenlPsychotherapy_Flag tinyint
	, PhysicalTherapy_Flag	tinyint
go

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly
set Psychotherapy_Allow	= isnull(b.Psychotherapy_Allow, 0)
		, GnrlPsychotherapy_Allow	= isnull(b.GnrlPsychotherapy_Allow, 0)
		, PhysicalTherapy_Allow	= isnull(b.PhysicalTherapy_Allow, 0)
		, Psychotherapy_Flag = isnull(b.Psychotherapy_Flag,0)
		, GenlPsychotherapy_Flag = isnull(b.GnrlPsychotherapy_Flag,0)
		, PhysicalTherapy_Flag = isnull(b.PhysicalTherapy_Flag,0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly	a
left join #therapycosts							b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
--3,411,943

--CHECKING------------------------------------------------------------------
select * 
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly
where GenlPsychotherapy_Flag = 1 and wChronicPain <> 1 
--255

--drop table #tmp_UBH
select Indv_Sys_Id
	, GnrlPsychotherapy_Flag	= max(case when TherapyFlag = 'General Psychotherapy'	then 1	else 0	end)
into #tmp_UBH
from (
	select Indv_Sys_Id
		, TherapyFlag = case when e.Proc_Cd is not null	then 'Psychotherapy'
										when d.AHRQ_PROC_DTL_CATGY_DESC like '%Psychological%'			then 'General Psychotherapy' 
										when d.AHRQ_PROC_DTL_CATGY_DESC = 'PT EXERCISES; MANIPULATION'	then 'Physical Therapy'			end
	from MiniHPDM..Fact_UBH_Claims			b
	inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
	inner join MiniHPDM..Dim_Procedure_Code	d	on	b.PROC_1_CD_SYS_ID = d.PROC_CD_SYS_ID
	left join pdb_VT_ChronicPain..therapy	e	on	d.PROC_CD = e.PROC_CD
	where c.YEAR_NBR = 2017
	union
	select Indv_Sys_Id
		, TherapyFlag = case when e.Proc_Cd is not null	then 'Psychotherapy'
										when d.AHRQ_PROC_DTL_CATGY_DESC like '%Psychological%'			then 'General Psychotherapy' 
										when d.AHRQ_PROC_DTL_CATGY_DESC = 'PT EXERCISES; MANIPULATION'	then 'Physical Therapy'			end
	from MiniHPDM..Fact_UBH_Claims			b
	inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
	inner join MiniHPDM..Dim_Procedure_Code	d	on	b.PROC_2_CD_SYS_ID = d.PROC_CD_SYS_ID
	left join pdb_VT_ChronicPain..therapy	e	on	d.PROC_CD = e.PROC_CD
	where c.YEAR_NBR = 2017
	union 
	select Indv_Sys_Id
		, TherapyFlag = case when e.Proc_Cd is not null	then 'Psychotherapy'
										when d.AHRQ_PROC_DTL_CATGY_DESC like '%Psychological%'			then 'General Psychotherapy' 
										when d.AHRQ_PROC_DTL_CATGY_DESC = 'PT EXERCISES; MANIPULATION'	then 'Physical Therapy'			end
	from MiniHPDM..Fact_UBH_Claims			b
	inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
	inner join MiniHPDM..Dim_Procedure_Code	d	on	b.PROC_3_CD_SYS_ID = d.PROC_CD_SYS_ID
	left join pdb_VT_ChronicPain..therapy	e	on	d.PROC_CD = e.PROC_CD
	where c.YEAR_NBR = 2017
) as a
group by Indv_Sys_Id
--402,302

select distinct a.Indv_Sys_Id,GnrlPsychotherapy_Flag
from #tmp_UBH	a
join pdb_VT_ChronicPain..Com_MemberSummary_TTL_UBHonly b on a.Indv_Sys_Id = b.Indv_Sys_Id
where GnrlPsychotherapy_Flag = 1--wChronicPain = 1