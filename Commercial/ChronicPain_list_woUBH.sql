/* Version 2 using 496 diagnosis codes
January 17, 2019
  */
  select distinct diag_cd from pdb_VT_ChronicPain..pain_types_v2
  select count(*) from pdb_VT_ChronicPain..member_summary2017
  select count(*) from pdb_VT_ChronicPain..Com_MemberSummary_TTL
  
  create index ix_Dx on pdb_VT_ChronicPain..pain_types_v2 (DIAG_CD,ICD_VER_CD)

--drop table pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
select *
into pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
from pdb_VT_ChronicPain..Com_MemberSummary_TTL
create index ix_Idv on pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH (Indv_Sys_Id)

--Depression
If (object_id('tempdb..#antidepressants') Is Not Null)
Drop Table #antidepressants
go

select *
into #antidepressants
from MiniHPDM..Dim_NDC_Drug
where rtrim(ext_ahfs_thrptc_clss_desc) in ('ANTIDEPRESSANTS  MISCELLANEOUS'
												,'ANTIDEPRESSANTS, MISCELLANEOUS' --added Alhera 01/17/19
												,'MONOAMINE OXIDASE INHIBITORS'
												,'MONOAMINE OXIDASE B INHIBITORS'--added Alhera 01/17/19
												,'SEROTONIN MODULATORS'
												,'SEL.SEROTONIN NOREPI REUPTAKE INHIBITOR'
												,'SEL.SEROTONIN,NOREPI REUPTAKE INHIBITOR '--added Alhera 01/17/19
												,'SELECTIVE-SEROTONIN REUPTAKE INHIBITORS'
												,'TRICYCLICS  OTHER NOREPI-RU INHIBITORS'
												,'TRICYCLICS, OTHER NOREPI-RU INHIBITORS'--added Alhera 01/17/19
												)
--15,459
create unique index uIx_SysID on #antidepressants (NDC_DRG_SYS_ID);
--select * from MiniHPDM..Dim_NDC_Drug where EXT_AHFS_THRPTC_CLSS_DESC in('MONOAMINE OXIDASE B INHIBITORS    ','MONOAMINE OXIDASE INHIBITORS')
--select distinct EXT_AHFS_THRPTC_CLSS_DESC from MiniHPDM..Dim_NDC_Drug order by EXT_AHFS_THRPTC_CLSS_DESC 
                                                                                                                                     
If (object_id('tempdb..#depressed_mbrs') Is Not Null)
Drop Table #depressed_mbrs
go

select a.Indv_Sys_Id, Depression_Flag = 1, Depression_Allw_Amt = sum(Allw_Amt)
into #depressed_mbrs
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
inner join #antidepressants				d	on	b.NDC_Drg_Sys_Id = d.NDC_DRG_SYS_ID
where c.YEAR_NBR = 2017
	and b.Srvc_Typ_Sys_Id = 4	--RX claims only
group by a.Indv_Sys_Id
--(398,380 row(s) affected) 18:44
create unique index uIx_Indv on #depressed_mbrs (Indv_Sys_Id);
/*select * from #depressed_mbrs group by Indv_Sys_Id, Depression_Flag

select Indv_Sys_Id from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH where DepressionFlag = 1 and Indv_Sys_Id not in (select Indv_Sys_Id from #depressed_mbrs)
select * from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH where  Indv_Sys_Id = 1409194167
select * from #depressed_mbrs where  Indv_Sys_Id = 1409194167

select a.Indv_Sys_Id, ext_ahfs_thrptc_clss_desc
from MiniHPDM..Fact_Claims	a
join MiniHPDM..Dim_NDC_Drug	b on a.NDC_Drg_Sys_Id = b.NDC_DRG_SYS_ID
join MiniHPDM..Dim_Date		c on a.Dt_Sys_Id = c.DT_SYS_ID
where YEAR_NBR = 2017
and Indv_Sys_Id = 1409194167*/

/*
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
	add Depression_Flag	tinyint*/

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
set DepressionFlag = isnull(b.Depression_Flag, 0)
	, Depression_Allow = isnull(b.Depression_Allw_Amt, 0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
left join #depressed_mbrs b on a.Indv_Sys_Id = b.Indv_Sys_Id
--3,411,943

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
						select a.Indv_Sys_Id, e.[Final Category] as Category, e.DIAG_CD, e.diag_desc
							, Min_Date = min(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Max_Date = max(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Vst_Cnt = dense_rank() over(partition by a.Indv_Sys_Id, e.[Final Category] order by c.Full_Dt)
						--into #tmp1
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
						inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
						inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.Diag_1_Cd_Sys_Id = f1.DIAG_CD_SYS_ID
						inner join pdb_VT_ChronicPain..pain_types_v2 e	on	f1.DIAG_CD = e.diag_cd
																		and f1.ICD_VER_CD = e.ICD_VER_CD
						where c.YEAR_NBR = 2017 
						--group by a.Indv_Sys_Id, e.[Final Category]
						
						union
						select a.Indv_Sys_Id, e.[Final Category] as Category, e.DIAG_CD, e.diag_desc
							, Min_Date = min(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Max_Date = max(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Vst_Cnt = dense_rank() over(partition by a.Indv_Sys_Id, e.[Final Category] order by c.Full_Dt)
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
						inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
						inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.Diag_2_Cd_Sys_Id = f1.DIAG_CD_SYS_ID
						inner join pdb_VT_ChronicPain..pain_types_v2 e	on	f1.DIAG_CD = e.diag_cd
																		and f1.ICD_VER_CD = e.ICD_VER_CD
						where c.YEAR_NBR = 2017
						--group by a.Indv_Sys_Id, e.[Final Category]
						
						union
						select a.Indv_Sys_Id, e.[Final Category] as Category, e.DIAG_CD, e.diag_desc
							, Min_Date = min(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Max_Date = max(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Vst_Cnt = dense_rank() over(partition by a.Indv_Sys_Id, e.[Final Category] order by c.Full_Dt)
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
						inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
						inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.Diag_3_Cd_Sys_Id = f1.DIAG_CD_SYS_ID
						inner join pdb_VT_ChronicPain..pain_types_v2 e	on	f1.DIAG_CD = e.diag_cd
																		and f1.ICD_VER_CD = e.ICD_VER_CD
						where c.YEAR_NBR = 2017
						--group by a.Indv_Sys_Id, e.[Final Category]
			/*
						/** UBH claims **/
						union
						select a.Indv_Sys_Id, e.[Final Category] as Category, e.DIAG_CD, e.diag_desc
							, Min_Date = min(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Max_Date = max(c.Full_Dt) over(partition by a.Indv_Sys_Id, e.[Final Category])
							, Vst_Cnt = dense_rank() over(partition by a.Indv_Sys_Id, e.[Final Category] order by c.Full_Dt)
						--into #tmp
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
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
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
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
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
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
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
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
						from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
						inner join MiniHPDM..Fact_UBH_Claims	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
						inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
						inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.DIAG_5_CD_SYS_ID = f1.DIAG_CD_SYS_ID
						inner join pdb_VT_ChronicPain..pain_types_v2 e	on	f1.DIAG_CD = e.diag_cd
																		and f1.ICD_VER_CD = e.ICD_VER_CD
						where c.YEAR_NBR = 2017 */
						--group by a.Indv_Sys_Id, e.[Final Category]
					)	a
		) x
where Flag = 1
	--and Category = 'Chronic Idiopathic Pain Syndrome'
--3,372,677 2:15hr
create index ix_Indv on #tmp_pain_mbrs2017 (Indv_Sys_Id)

/*
select count(distinct DIAG_CD)
from pdb_VT_ChronicPain..pain_types_v2
-------
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
	add	wChronicPain	tinyint
		, IdiopathicPain	tinyint
		--, DegenerativePain	tinyint
		, NeuropathicPain	tinyint
		, MusclePain		tinyint
		, InflammatoryPain	tinyint
		--, CancerPain		tinyint
		, NervePain			tinyint
		, UnknownCategory	tinyint
		, DepressionFlag	tinyint
go
*/

--this is due to tmp DB issue we had with Kiara
--select * into pdb_VT_ChronicPain..tmp_pain_mbrs_AJ from #tmp_pain_mbrs2017
--drop table #tmp_pain_mbrs2017
update pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
set wChronicPain	= case when b.Indv_Sys_Id is not null	then 1	else 0	end
	, IdiopathicPain	= isnull(b.IdiopathicPain	, 0)
	--, DegenerativePain	= isnull(b.DegenerativePain	, 0)
	, NeuropathicPain	= isnull(b.NeuropathicPain	, 0)
	, MusclePain		= isnull(b.MusclePain		, 0)
	, InflammatoryPain	= isnull(b.InflammatoryPain	, 0)
	--, CancerPain		= isnull(b.CancerPain		, 0)
	, NervePain			= isnull(b.NervePain			, 0)
	, UnknownCategory	= isnull(b.UnknownCategory	, 0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
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
				from pdb_VT_ChronicPain..tmp_pain_mbrs_AJ
				group by Indv_Sys_Id
			)	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id

--3,411,943 - 34mins
/*
--Opioids FLAG and Spend
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
	add OpioidFlag	tinyint
	, Opioid_Allow decimal(18,2)
go*/

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
set OpioidFlag = isnull(b.OpioidFlag, 0)
	, Opioid_Allow = isnull(b.Opioid_Allow, 0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
left join	(
				select a.Indv_Sys_Id, OpioidFlag = 1, Opioid_Allow = sum(Allw_Amt)
				from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
				inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
				inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id = c.DT_SYS_ID
				inner join MiniHPDM..Dim_NDC_Drug		d	on	b.NDC_Drg_Sys_Id = d.NDC_DRG_SYS_ID
				where c.YEAR_NBR = 2017
					and b.Srvc_Typ_Sys_Id = 4	--rx only
					and EXT_AHFS_THRPTC_CLSS_DESC like '%opiate%'
				group by a.Indv_Sys_Id
			)	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
--3,411,943
/*
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
	add	  Total_Allow		decimal(18,2)
		, Ip_Allow			decimal(18,2)
		, OP_Allow			decimal(18,2)
		, ER_Allow			decimal(18,2)
		, DR_Allow			decimal(18,2)
		, RX_Allow			decimal(18,2)
		, IP_Visits			smallint
		, IP_Days			smallint
		, OP_Visits			smallint
		, ER_Visits			smallint
		, DR_Visits			smallint
		, RX_Scripts		smallint
		, PM_Visits			smallint
		, ChiroMed_Visits	smallint
		, Acu_Visits		smallint
		, Pod_Visits		smallint
		, RAF				smallint
		, HCC_Cnt			smallint
go
*/
--Specialists
if object_id('tempdb..#specialty') is not null
drop table #specialty
go

select a.MPIN, c.SpecTypeCd, c.ShortDesc, c.LongDesc
into #specialty
from NDB..Provider   a
inner join NDB..Prov_Specialties  b      on     a.MPIN = b.MPIN
left join NDB..Specialty_Types    c      on     b.SpecTypeCd = c.SpecTypeCd
where c.LongDesc in ('PAIN MANAGEMENT', 'CHIROPRACTIC MEDICINE', 'ACUPUNCTURE', 'PODIATRY')
--241,168
create index ucIx_MPIN on #specialty (MPIN);


/*select *
from (
		select e.LongDesc, f1.DIAG_DESC
			, MPIN_Cnt = count(distinct e.MPIN)
			, Mbr_Cnt = count(distinct a.Indv_Sys_Id)
			, Clm_Cnt = count(distinct b.Clm_aud_nbr)
			, OID = row_number() over(partition by e.LongDesc order by count(distinct a.Indv_Sys_Id) desc)
		from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
		inner join MiniHPDM..Fact_Claims10		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
		inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
		inner join MiniHPDM..Dim_Provider		d	on	b.Prov_Sys_Id = d.PROV_SYS_ID
		inner join #specialty					e	on	d.MPIN = e.MPIN
		inner join MiniHPDM..Dim_Diagnosis_Code	f1	on	b.Diag_1_Cd_Sys_Id = f1.DIAG_CD_SYS_ID
		where YEAR_NBR = 2017
		group by e.LongDesc, f1.DIAG_DESC
	)	z
where OID between 1 and 10
order by 1, OID  */


if object_id('tempdb..#vst_specialty') is not null
drop table #vst_specialty
go

select Indv_Sys_Id, LongDesc,  
	Total_Allow = isnull(sum(allw_amt),0)
	, Vst_Cnt = count(distinct FULL_DT)
	, MPIN_Cnt = count(distinct MPIN)
into #vst_specialty
from	(
			select a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, e.MPIN, e.LongDesc, Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
			inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Provider		d	on	b.Prov_Sys_Id = d.PROV_SYS_ID
			inner join #specialty					e	on	d.MPIN = e.MPIN
			where c.YEAR_NBR = 2017
			group by a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, e.MPIN, e.LongDesc, Allw_Amt
			/*
			union
			select a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, e.MPIN, e.LongDesc, Allw_Amt
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
			inner join MiniHPDM..Fact_UBH_Claims	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Provider		d	on	b.Prov_Sys_Id = d.PROV_SYS_ID
			inner join #specialty					e	on	d.MPIN = e.MPIN
			where c.YEAR_NBR = 2017
			group by a.Indv_Sys_Id, b.Clm_Aud_Nbr, c.FULL_DT, e.MPIN, e.LongDesc, Allw_Amt*/
		)	z
group by Indv_Sys_Id, LongDesc
--select count(*) from #vst_specialty
--380,541 26mins
create unique index uid_Indv on #vst_specialty (Indv_Sys_Id, LongDesc)
/*
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
	add	  PM_Allow			decimal(18,2)
		, ChiroMed_Allow	decimal(18,2)
		, Acu_Allow			decimal(18,2)
		, Pod_Allow			decimal(18,2)
		*/

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
set		PM_Visits		= isnull(b.Spclty_PM_Vst	, 0)
	, ChiroMed_Visits	= isnull(b.Spclty_CM_Vst	, 0)
	, Acu_Visits		= isnull(b.Spclty_Acu_Vst	, 0)
	, Pod_Visits		= isnull(b.Spclty_Pod_Vst	, 0)
	, PM_Allow			= isnull(b.Spclty_PM_Allow	, 0)
	, ChiroMed_Allow	= isnull(b.Spclty_CM_Allow	, 0)
	, Acu_Allow			= isnull(b.Spclty_Acu_Allow	, 0)
	, Pod_Allow			= isnull(b.Spclty_Pod_Allow	, 0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
left join	(
				select Indv_Sys_Id
					, Spclty_PM_Vst			= max(case when LongDesc = 'PAIN MANAGEMENT'	then Vst_Cnt	else 0 end)
					, Spclty_CM_Vst			= max(case when LongDesc = 'CHIROPRACTIC MEDICINE'	then Vst_Cnt	else 0 end)
					, Spclty_Acu_Vst		= max(case when LongDesc = 'ACUPUNCTURE'	then Vst_Cnt	else 0 end)
					, Spclty_Pod_Vst		= max(case when LongDesc = 'PODIATRY'	then Vst_Cnt else 0 end)
					, Spclty_PM_Allow		= max(case when LongDesc = 'PAIN MANAGEMENT'	then Total_Allow	else 0 end)
					, Spclty_CM_Allow		= max(case when LongDesc = 'CHIROPRACTIC MEDICINE'	then Total_Allow	else 0 end)
					, Spclty_Acu_Allow		= max(case when LongDesc = 'ACUPUNCTURE'	then Total_Allow	else 0 end)
					, Spclty_Pod_Allow		= max(case when LongDesc = 'PODIATRY'	then Total_Allow else 0 end)
				from #vst_specialty
				group by Indv_Sys_Id
			)	b	on	a.Indv_Sys_Id = b.Indv_Sys_Id

--(3411943 row(s) affected)

/*select*
  into pdb_VT_ChronicPain..Com_MemberSummary_PainMbr
  from [pdb_VT_ChronicPain].[dbo].[member_summary2017]
  where [wChronicPain] = 1*/
  /*
/* Opioid Dependency based on diagnosis code */
alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
	add Opioid_Dependency tinyint
go
*/

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH
set Opioid_Dependency = isnull(b.Opioid_Dependency, 0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH	a
left join	(
				select Indv_Sys_Id, Opioid_Dependency = 1
				from (
					select d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH d
					inner join MiniHPDM..Fact_Claims	a	on d.Indv_Sys_Id = a.Indv_Sys_Id
					inner join MiniHPDM..Dim_Date	b on a.Dt_Sys_Id = b.DT_SYS_ID
					inner join MiniHPDM..Dim_Diagnosis_Code c on a.Diag_1_Cd_Sys_Id = c.DIAG_CD_SYS_ID
					where YEAR_NBR = 2017
										and (((c.DIAG_DECM_CD between '304.00' and '304.03') and c.ICD_VER_CD = 9)
										or (c.DIAG_DECM_CD = 'F11.20' and c.ICD_VER_CD = 0))
					group by d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					union
					select d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH d
					inner join MiniHPDM..Fact_Claims	a	on d.Indv_Sys_Id = a.Indv_Sys_Id
					inner join MiniHPDM..Dim_Date	b on a.Dt_Sys_Id = b.DT_SYS_ID
					inner join MiniHPDM..Dim_Diagnosis_Code c on a.Diag_2_Cd_Sys_Id = c.DIAG_CD_SYS_ID
					where YEAR_NBR = 2017
										and (((c.DIAG_DECM_CD between '304.00' and '304.03') and c.ICD_VER_CD = 9)
										or (c.DIAG_DECM_CD = 'F11.20' and c.ICD_VER_CD = 0))
					group by d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					union
					select d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH d
					inner join MiniHPDM..Fact_Claims	a	on d.Indv_Sys_Id = a.Indv_Sys_Id
					inner join MiniHPDM..Dim_Date	b on a.Dt_Sys_Id = b.DT_SYS_ID
					inner join MiniHPDM..Dim_Diagnosis_Code c on a.Diag_3_Cd_Sys_Id = c.DIAG_CD_SYS_ID
					where YEAR_NBR = 2017
										and (((c.DIAG_DECM_CD between '304.00' and '304.03') and c.ICD_VER_CD = 9)
										or (c.DIAG_DECM_CD = 'F11.20' and c.ICD_VER_CD = 0))
					group by d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					/*--UBH claims 
					union
					select d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH d
					inner join MiniHPDM..Fact_UBH_Claims	a	on d.Indv_Sys_Id = a.Indv_Sys_Id
					inner join MiniHPDM..Dim_Date	b on a.FST_SRVC_DT_SYS_ID = b.DT_SYS_ID
					inner join MiniHPDM..Dim_Diagnosis_Code c on a.DIAG_1_CD_SYS_ID = c.DIAG_CD_SYS_ID
					where YEAR_NBR = 2017
										and (((c.DIAG_DECM_CD between '304.00' and '304.03') and c.ICD_VER_CD = 9)
										or (c.DIAG_DECM_CD = 'F11.20' and c.ICD_VER_CD = 0))
					group by d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					union
					select d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH d
					inner join MiniHPDM..Fact_UBH_Claims	a	on d.Indv_Sys_Id = a.Indv_Sys_Id
					inner join MiniHPDM..Dim_Date	b on a.FST_SRVC_DT_SYS_ID = b.DT_SYS_ID
					inner join MiniHPDM..Dim_Diagnosis_Code c on a.DIAG_2_CD_SYS_ID = c.DIAG_CD_SYS_ID
					where YEAR_NBR = 2017
										and (((c.DIAG_DECM_CD between '304.00' and '304.03') and c.ICD_VER_CD = 9)
										or (c.DIAG_DECM_CD = 'F11.20' and c.ICD_VER_CD = 0))
					group by d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					union
					select d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH d
					inner join MiniHPDM..Fact_UBH_Claims	a	on d.Indv_Sys_Id = a.Indv_Sys_Id
					inner join MiniHPDM..Dim_Date	b on a.FST_SRVC_DT_SYS_ID = b.DT_SYS_ID
					inner join MiniHPDM..Dim_Diagnosis_Code c on a.DIAG_3_CD_SYS_ID = c.DIAG_CD_SYS_ID
					where YEAR_NBR = 2017
										and (((c.DIAG_DECM_CD between '304.00' and '304.03') and c.ICD_VER_CD = 9)
										or (c.DIAG_DECM_CD = 'F11.20' and c.ICD_VER_CD = 0))
					group by d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					union
					select d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH d
					inner join MiniHPDM..Fact_UBH_Claims	a	on d.Indv_Sys_Id = a.Indv_Sys_Id
					inner join MiniHPDM..Dim_Date	b on a.FST_SRVC_DT_SYS_ID = b.DT_SYS_ID
					inner join MiniHPDM..Dim_Diagnosis_Code c on a.DIAG_4_CD_SYS_ID = c.DIAG_CD_SYS_ID
					where YEAR_NBR = 2017
										and (((c.DIAG_DECM_CD between '304.00' and '304.03') and c.ICD_VER_CD = 9)
										or (c.DIAG_DECM_CD = 'F11.20' and c.ICD_VER_CD = 0))
					group by d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					union
					select d.Indv_Sys_Id, DIAG_CD, DIAG_DESC
					from pdb_VT_ChronicPain..Com_MemberSummary_TTL_woUBH d
					inner join MiniHPDM..Fact_UBH_Claims	a	on d.Indv_Sys_Id = a.Indv_Sys_Id
					inner join MiniHPDM..Dim_Date	b on a.FST_SRVC_DT_SYS_ID = b.DT_SYS_ID
					inner join MiniHPDM..Dim_Diagnosis_Code c on a.DIAG_5_CD_SYS_ID = c.DIAG_CD_SYS_ID
					where YEAR_NBR = 2017
										and (((c.DIAG_DECM_CD between '304.00' and '304.03') and c.ICD_VER_CD = 9)
										or (c.DIAG_DECM_CD = 'F11.20' and c.ICD_VER_CD = 0))
					group by d.Indv_Sys_Id, DIAG_CD, DIAG_DESC*/
					)a
			group by Indv_sys_id
			) b on a.Indv_Sys_id = b.Indv_Sys_Id
--3,411,943 11mins


select count(distinct Indv_Sys_id) from #tmp
--4387
select count(distinct Indv_Sys_id) from #tmp1
--1,079,288

select Indv_Sys_id, Category from #tmp where Indv_Sys_id  not in (select Indv_Sys_id from #tmp1) and Category <> 'UNKNOWN CATEGORY'
--96