/*
Developer - Prajakta Patil
Date - 1/8/2019
Goal - 1. To prepare a dataset for members with cont enrollment 
		from 2012 - June 2018 with lower back problems that lead to chronic condition.
	   2. Compare the cost between different definitions of chronic conditions
*/

-- Looking at UHC customer segments in 201201 and 201806. 
--Not a perfect way to identify, but for the purpose of this project, this will be sufficient. 
Drop table #CustSegUHCFI
select distinct Cust_Seg_Sys_Id
into #CustSegUHCFI
from Dim_CustSegSysId_Detail
where Co_Nm like '%UNITED HEALTHCARE%'
and Hlth_Pln_Fund_Cd like '%FI%'
and (Year_Mo = 201201 or Year_Mo = 201806)
group by Cust_Seg_Sys_Id
having count(*)=2
create unique index uix_CustSeg on #CustSegUHCFI(Cust_Seg_Sys_Id) 

select count(*) from #CustSegUHCFI


--(70922053 row(s) affected). 
Drop table #tempMem
select Indv_Sys_Id,Year_Mo,mm.Cust_Seg_Sys_Id
into #tempMem
from MiniHPDM..Summary_Indv_Demographic mm 
join #CustSegUHCFI cust_seg on cust_seg.Cust_Seg_Sys_Id = mm.Cust_Seg_Sys_Id
where Year_Mo>=201201
and Year_Mo <= 201806

select * from #tempMem

--(324205 row(s) affected). 
--Identify members with continuous enrollment from 2012 Jan - 2018 June
Drop table pdb_VT_ChronicPain..MemWithContEnrol2012_2018June
select Indv_Sys_Id
into pdb_VT_ChronicPain..MemWithContEnrol2012_2018June
from #tempMem
group by Indv_Sys_Id
--order by count(*) desc
having count(distinct year_mo)=78
create unique index Mem on pdb_VT_ChronicPain..MemWithContEnrol2012_2018June(indv_sys_id)


-- Diagnosis codes for lower back injury/pain. (614 row(s) affected)
Drop table pdb_VT_ChronicPain..DCLowerBackPain
select dc.DIAG_CD_SYS_ID,dc.DIAG_CD,dc.DIAG_DESC,dc.AHRQ_DIAG_GENL_CATGY_CD
,dc.AHRQ_DIAG_DTL_CATGY_NM
,dc.CHRNC_FLG_NM, dc.DIAG_FULL_DESC
into pdb_VT_ChronicPain..DCLowerBackPain
from pdb_VT_ChronicPain.[dbo].[WrongDC] a -- From Alhera's list
left join MiniHPDM..dim_diagnosis_code dc on dc.diag_Cd = a.diag_cd
where flag = 1
union
select dc.DIAG_CD_SYS_ID,dc.DIAG_CD,dc.DIAG_DESC,dc.AHRQ_DIAG_GENL_CATGY_CD
,dc.AHRQ_DIAG_DTL_CATGY_NM
,dc.CHRNC_FLG_NM, dc.DIAG_FULL_DESC
from pdb_VT_ChronicPain.[dbo].DC a -- from Alhera's list of lumbar diagnosis codes. 
join MiniHPDM..dim_diagnosis_code dc on dc.diag_Cd = a.diag_cd



--Get claims for all members 
--(82649636 row(s) affected) 00:15:17
Drop table pdb_VT_Chronicpain..MemClaims2012_2018June
select fc.Indv_Sys_Id,fc.Dt_Sys_Id,dt.FULL_DT,fc.Diag_1_Cd_Sys_Id
	   ,fc.Diag_2_Cd_Sys_Id
	   ,fc.Diag_3_Cd_Sys_Id
	   ,chrpain_dc1.diag_cd_sys_id dc1
	   ,chrpain_dc2.diag_cd_sys_id dc2
	   ,chrpain_dc3.diag_cd_sys_id dc3
	   ,fc.Sys_DRG_Cd_Sys_Id
	   ,fc.Proc_Cd_Sys_Id
	   ,fc.Allw_Amt
	   ,fc.Admit_Cnt
	   ,fc.Day_Cnt
	   ,fc.NDC_Drg_Sys_Id
	   ,fc.Pl_of_Srvc_Sys_Id
	   ,fc.Srvc_Typ_Sys_Id 
	   ,fc.Vst_Cnt
into pdb_VT_Chronicpain..MemClaims2012_2018June
from pdb_VT_ChronicPain..MemWithContEnrol2012_2018June mem
join MiniHPDM..Fact_Claims fc  on fc.Indv_Sys_Id = mem.Indv_Sys_Id
join MiniHPDM..Dim_Date dt on dt.DT_SYS_ID = fc.Dt_Sys_Id
left join pdb_VT_ChronicPain..DCLowerBackPain chrpain_dc1 on fc.Diag_1_Cd_Sys_Id = chrpain_dc1.diag_cd_sys_id
left join pdb_VT_ChronicPain..DCLowerBackPain chrpain_dc2 on fc.Diag_2_Cd_Sys_Id = chrpain_dc2.diag_cd_sys_id
left join pdb_VT_ChronicPain..DCLowerBackPain chrpain_dc3 on fc.Diag_3_Cd_Sys_Id = chrpain_dc3.diag_cd_sys_id
where YEAR_MO >=201201 and YEAR_MO<=201806

create clustered index cix_fc on pdb_VT_Chronicpain..MemClaims2012_2018June(indv_sys_id, dt_sys_id)
create index ix_ndc on pdb_VT_Chronicpain..MemClaims2012_2018June(NDC_Drg_Sys_Id)



-- (88953 row(s) affected) have a lower back pain diagnosis.
-- filtered out burns and ulcers as they seem irrelevant here
Drop table pdb_VT_Chronicpain..MemWithLowerBackPain
select distinct indv_sys_id 
into pdb_VT_Chronicpain..MemWithLowerBackPain
from pdb_VT_Chronicpain..MemClaims2012_2018June a 
left join pdb_VT_Chronicpain..DCLowerBackPain d1 on d1.DIAG_CD_SYS_ID = a.dc1
left join pdb_VT_Chronicpain..DCLowerBackPain d2 on d2.DIAG_CD_SYS_ID = a.dc2
left join pdb_VT_Chronicpain..DCLowerBackPain d3 on d3.DIAG_CD_SYS_ID = a.dc3
where (dc1 is not null or dc2 is not null or dc3 is not null )

select count(distinct indv_Sys_id) from pdb_VT_Chronicpain..MemWithLowerBackPain

--Get claims for only above members. (36804532 row(s) affected) 00:00:55
Drop table pdb_VT_Chronicpain..MemClaimsLowerBackPain
select fc.*, ndc.[EXT_AHFS_THRPTC_CLSS_DESC], ndc.[GNRC_NM]
,ChrBackPainDrug = case when ((ndc.EXT_AHFS_THRPTC_CLSS_DESC like '%opiate%') 
		OR (ndc.EXT_AHFS_THRPTC_CLSS_DESC like '%skeletal%')) then 1 else 0 end
into pdb_VT_Chronicpain..MemClaimsLowerBackPain
from 
pdb_VT_Chronicpain..MemClaims2012_2018June fc 
join pdb_VT_Chronicpain..MemWithLowerBackPain m on fc.Indv_Sys_Id = m.indv_sys_id
left join MiniHPDM..Dim_NDC_Drug ndc on fc.NDC_Drg_Sys_Id = ndc.NDC_DRG_SYS_ID
create clustered index cix_Indv_Sys_ID_Date on pdb_VT_Chronicpain..MemClaimsLowerBackPain(indv_sys_id, Dt_Sys_Id)





-- All Drugs used by members with chronic condition. (4595 row(s) affected) 00:02:40
-- Not all seem relevant here. 
-- Hence, taking the ones with (b.EXT_AHFS_THRPTC_CLSS_DESC like '%opiate%') 
--                              OR (b.EXT_AHFS_THRPTC_CLSS_DESC like '%skeletal%'))
Drop table #DrugsByPatientsWithLowerBackPain
select b.EXT_AHFS_THRPTC_CLSS_DESC
--, d1.DIAG_DESC,d1.AHRQ_DIAG_GENL_CATGY_CD,d1.AHRQ_DIAG_DTL_CATGY_NM
--,d2.DIAG_DESC,d2.AHRQ_DIAG_GENL_CATGY_CD,d2.AHRQ_DIAG_DTL_CATGY_NM
--,d3.DIAG_DESC,d3.AHRQ_DIAG_GENL_CATGY_CD,d3.AHRQ_DIAG_DTL_CATGY_NM
--,a.Diag_1_Cd_Sys_Id,a.Diag_2_Cd_Sys_Id,a.Diag_3_Cd_Sys_Id
,count(distinct indv_sys_id) as cnt_Members
,(1.* count(distinct indv_sys_id)/ sum(count(distinct indv_sys_id)) over())*100 as shr_members
--into #DrugsByPatientsWithLowerBackPain
from pdb_VT_Chronicpain..MemClaimsLowerBackPain a
join miniHPDM..Dim_NDC_Drug b on a.NDC_Drg_Sys_Id = b.NDC_DRG_SYS_ID
where 1=1
and b.NDC_Drg_Sys_Id <> -1
--and EXT_AHFS_THRPTC_CLSS_DESC not like '%antibiotic%'                                                                                                                                                                                                     
group by b.EXT_AHFS_THRPTC_CLSS_DESC
order by count(distinct indv_sys_id) desc



--(43635 row(s) affected)
Drop table #Def1
select Indv_Sys_Id, min(full_dt) as def1_minDate
/*,day90 = case when datediff(day, min(Full_dt), max(Full_dt)) > = 90 then 1 else 0 end
, vst_Cnt = case when sum(vst_cnt)>=2 then 1 else 0 end*/
into #Def1
from pdb_VT_Chronicpain..MemClaimsLowerBackPain
where (dc1 is not null or dc2 is not null or dc3 is not null)
group by Indv_Sys_Id
having  (case when datediff(day, min(Full_dt), max(Full_dt)) > = 90
		and sum(vst_cnt)>=2 then 1 else 0 end=1)
create unique index uix_Indv_Sys_ID on #Def1(Indv_Sys_Id)



--(38967 row(s) affected)
Drop table #Def2
select Indv_Sys_Id, min(full_dt) as def2_minDate
/*,day90 = case when datediff(day, min(Full_dt), max(Full_dt)) > = 14 then 1 else 0 end
, vst_Cnt = case when sum(vst_cnt)>=2 then 1 else 0 end*/
into #Def2
from pdb_VT_Chronicpain..MemClaimsLowerBackPain
where (dc1 is not null)
group by Indv_Sys_Id
having  (case when datediff(day, min(Full_dt), max(Full_dt)) > = 14
		and sum(vst_cnt)>=2 then 1 else 0 end=1)
create unique index uix_Indv_Sys_ID on #Def2(Indv_Sys_Id)


--(17123 row(s) affected)
Drop table #Def3
select Indv_Sys_Id, min(full_dt) as def3_minDate
--,drug = case when sum(case when ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'OPIATE AGONISTS' 
--		OR ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'CENTRALLY ACTING SKELETAL MUSCLE RELAXNT'
--		THEN Day_Cnt end) >= 90 then 1 else 0 end
/*, LBP_drug = sum(case when ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'OPIATE AGONISTS' 
		OR ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'CENTRALLY ACTING SKELETAL MUSCLE RELAXNT'
		THEN 1 else 0 end)
,day_cnt = sum(case when ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'OPIATE AGONISTS' 
		OR ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'CENTRALLY ACTING SKELETAL MUSCLE RELAXNT'
		THEN Day_Cnt end)*/
into #Def3
from pdb_VT_Chronicpain..MemClaimsLowerBackPain fc
join MiniHPDM..Dim_NDC_Drug ndc on ndc.NDC_DRG_SYS_ID = fc.NDC_Drg_Sys_Id
--where (dc1 is not null or dc2 is not null or dc3 is not null)
group by Indv_Sys_Id
having case when sum(case when ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'OPIATE AGONISTS' 
		OR ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'CENTRALLY ACTING SKELETAL MUSCLE RELAXNT'
		THEN Day_Cnt end) >= 90 then 1 else 0 end = 1
create unique index uix_Indv_Sys_ID on #Def3(Indv_Sys_Id)

select * from [dbo].[ChronicLBP_Thrptc_Class_Summary]
order by [difference] desc

--88953 rows
Drop table pdb_VT_Chronicpain..MemandChrDefs
select all_mbrs.Indv_Sys_Id, def1_minDate = def1.def1_minDate
,def2_minDate = def2.def2_minDate
,def3_minDate = def3.def3_minDate
into pdb_VT_Chronicpain..MemandChrDefs
from pdb_VT_Chronicpain..MemWithLowerBackPain all_mbrs
left join #def1 def1 on def1.Indv_Sys_Id = all_mbrs.Indv_Sys_Id
left join #def2 def2 on def2.Indv_Sys_Id = all_mbrs.Indv_Sys_Id
left join #def3 def3 on def3.Indv_Sys_Id = all_mbrs.Indv_Sys_Id
create unique index uix_Indv_Sys_ID on pdb_VT_Chronicpain..MemandChrDefs(Indv_Sys_Id)







-- Get year-mo wise claims cost along with some flags for further analysis. 
--(3631856 row(s) affected) 00:03:25

--(4425207 row(s) affected)
Drop table pdb_VT_Chronicpain..CostChronicLowerback
select  m.Indv_Sys_Id
		,dt.YEAR_MO
		,TotalCost = sum(fc.Allw_Amt)
		,CostIP = sum(case when fc.Srvc_Typ_Sys_Id = 1 then fc.Allw_Amt end)
		,CostOP = sum(case when fc.Srvc_Typ_Sys_Id = 2 then fc.Allw_Amt end)
		,CostPhy = sum(case when fc.Srvc_Typ_Sys_Id = 3 then fc.Allw_Amt end)
		,CostRx = sum(case when fc.Srvc_Typ_Sys_Id = 4 then fc.Allw_Amt end)
		,CostPT = sum(case when th.PROC_CD is not null then allw_amt end)
		,Cost_PainMeds = sum(case when ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'OPIATE AGONISTS' 
						OR ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'CENTRALLY ACTING SKELETAL MUSCLE RELAXNT'
						then Allw_Amt else 0 end)
		,Cost_PainSurgery = sum(case when pc.proc_CD is not null then Allw_Amt else 0 end)
		,ind_PainMeds = min(case when ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'OPIATE AGONISTS' 
						OR ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'CENTRALLY ACTING SKELETAL MUSCLE RELAXNT'
						then 1 else 0 end)
		,ind_PainSurgery = max(case when pc.proc_CD is not null then 1 else 0 end)
into pdb_VT_Chronicpain..CostChronicLowerback 
from pdb_VT_Chronicpain..MemandChrDefs m
join pdb_VT_Chronicpain..MemClaimsLowerBackPain fc on m.Indv_Sys_Id = fc.Indv_Sys_Id
left join miniHPDM..Dim_Procedure_Code b on fc.proc_cd_Sys_id = b.proc_cd_sys_id
left join miniHPDM..Dim_Service_Type st on st.Srvc_Typ_Sys_Id = fc.Srvc_Typ_Sys_Id	
left join MiniHPDM..Dim_Date dt on fc.Dt_Sys_Id = dt.DT_SYS_ID
left join MiniHPDM..Dim_Procedure_Code all_pc on all_pc.PROC_CD_SYS_ID = fc.Proc_Cd_Sys_Id
left join MiniHPDM..Dim_NDC_Drug ndc on ndc.NDC_DRG_SYS_ID = fc.NDC_Drg_Sys_Id
left join pdb_VT_ChronicPain..surgerypc pc on all_pc.PROC_CD = pc.proc_cd
left join pdb_VT_ChronicPain..therapy th on th.proc_cd = b.proc_cd
--left join pdb_VT_ChronicPain..DRG_CD_SurgeryLowerBack drg on drg.DRG_CD_SYS_ID = fc.sys_drg_cd_sys_id
--where (dc1 is not null or dc2 is not null or dc3 is not null -- to get claims only for lower back pain
--OR fc.NDC_Drg_Sys_Id <> -1) -- to get pharmacy claims related to lower back pain
group by m.Indv_Sys_Id
		,dt.YEAR_MO	
order by m.Indv_Sys_Id, dt.YEAR_MO

-- Ignore below code
/*
select count(Distinct a.indv_sys_id)
from pdb_VT_Chronicpain..CostChronicLowerback a 
--join pdb_VT_Chronicpain..MemandChrDefs b on a.Indv_Sys_Id = b.indv_sys_id
where CostPT > 0
order by YEAR_MO



select *, ind_PainSurgery = case when c.proc_CD is not null then 1 else 0 end
from pdb_VT_ChronicPain..MemClaimsLowerBackPain a
join MiniHPDM..Dim_Procedure_Code b on a.Proc_Cd_Sys_Id = b.PROC_CD_SYS_ID
left join pdb_VT_ChronicPain..surgerypc c on c.PROC_CD = b.PROC_CD
where case when c.proc_CD is not null then 1 else 0 end = 1



Drop table pdb_VT_ChronicPain..Spclty_Codes
select SPCL_SYS_ID,SPCL_CD,SPCL_NM
into pdb_VT_ChronicPain..Spclty_Codes  
from MiniHPDM..Dim_OVA_Provider_Specialty
where SPCL_CD in ('CH', 'OC', 'PF', 'RD', 'RY', 'SP', 'ST')

select * from MiniHPDM..Dim_Provider a
--where COS_PROV_SPCL_CD in (116,140,164,175)
join pdb_VT_ChronicPain..Spclty_Codes b
on a.COS_PROV_SPCL_CD = b.SPCL_SYS_ID


select * 
from pdb_VT_ChronicPain..MemClaimsLowerBackPain a
join miniHPDM..Dim_Procedure_Code b on a.proc_cd_Sys_id = b.proc_cd_sys_id
join pdb_VT_ChronicPain..therapy c on c.proc_cd = b.proc_cd





select * from Fact_Claims fc
join Dim_Date dt on fc.Dt_Sys_Id = dt.DT_SYS_ID
join Dim_Procedure_Code pc on fc.Proc_Cd_Sys_Id = pc.PROC_CD_SYS_ID
where Indv_Sys_Id = 388381837
and YEAR_MO = 201708
order by FULL_DT

----Ignore below query
--Get minimum dates for all 3 definitions for chronic pain. (311357 row(s) affected) 00:06:27
Drop table pdb_VT_Chronicpain..MemWithChronicLowerBackPain
select indv_sys_id, min(minDate_def1) as minDate_def1
,min(minDate_def2) as minDate_def2, min(minDate_def3) as minDate_def3
into pdb_VT_Chronicpain..MemWithChronicLowerBackPain
from (
select Indv_Sys_Id
		,def1 = case when (dc1 is not null or dc2 is not null or dc3 is not null)
		and DATEDIFF(day, min(full_dt) over (partition by indv_Sys_id), max(full_dt) over (partition by indv_Sys_id)) >=90 
		and sum(vst_cnt)  over (partition by indv_Sys_id) >= 2 then 1 else 0 end
		,minDate_def1 = case when (dc1 is not null or dc2 is not null or dc3 is not null)
		and DATEDIFF(day, min(full_dt) over (partition by indv_Sys_id), max(full_dt) over (partition by indv_Sys_id)) >=90 
		and sum(vst_cnt)  over (partition by indv_Sys_id) >= 2 then min(full_dt) over (partition by indv_Sys_id) end
		,def2 = case when DATEDIFF(day, min(full_dt) over (partition by indv_Sys_id), max(full_dt) over (partition by indv_Sys_id)) >=14 
		and sum(vst_cnt)  over (partition by indv_Sys_id) >= 2 
		and dc1 is not null then 1 else 0 end
		,minDate_def2 = case when DATEDIFF(day, min(full_dt) over (partition by indv_Sys_id), max(full_dt) over (partition by indv_Sys_id)) >=14 
		and sum(vst_cnt)  over (partition by indv_Sys_id) >= 2 
		and dc1 is not null 
		then min(full_dt) over (partition by indv_Sys_id) end
		,def3 = case when sum(vst_cnt)  over (partition by indv_Sys_id) >= 1
		and ((b.EXT_AHFS_THRPTC_CLSS_DESC like '%opiate%') 
		OR (b.EXT_AHFS_THRPTC_CLSS_DESC like '%skeletal%'))
		and sum(a.Day_Cnt) over (partition by indv_Sys_id, GNRC_NM) >= 90
		then 1 else 0 end
		,minDate_def3 = case when sum(vst_cnt)  over (partition by indv_Sys_id) >= 1
		and ((b.EXT_AHFS_THRPTC_CLSS_DESC like '%opiate%') 
		OR (b.EXT_AHFS_THRPTC_CLSS_DESC like '%skeletal%'))
		and SUM(a.Day_Cnt) over (partition by indv_Sys_id, GNRC_NM) >= 90 
		then min(full_dt) over (partition by indv_Sys_id, GNRC_NM) end
		
from pdb_VT_Chronicpain..MemClaimsLowerBackPain a
join MiniHPDM..Dim_NDC_Drug b on a.NDC_Drg_Sys_Id = b.NDC_DRG_SYS_ID
) A
--where def3 = 1--Indv_Sys_Id = 16683916
--order by Dt_Sys_Id
group by Indv_Sys_Id





---------------------------logic check---------------------------------------
select distinct indv_sys_id*/
		/*,min(case when dc1 is not null or dc2 is not null or dc3 is not null then full_dt end) 
			 over (partition by indv_sys_id) as min_dt
		,max(case when dc1 is not null or dc2 is not null or dc3 is not null then full_dt end)
			 over (partition by indv_sys_id) as max_dt
		,vst_cnt = sum(case when dc1 is not null or dc2 is not null or dc3 is not null then vst_cnt end) over (partition by indv_sys_id) 
		,def1 = case when datediff(day, min(case when dc1 is not null or dc2 is not null or dc3 is not null then full_dt end) 
								 over (partition by indv_sys_id)
								,max(case when dc1 is not null or dc2 is not null or dc3 is not null then full_dt end) 
								over (partition by indv_sys_id)) > = 90 
			    and sum(case when dc1 is not null or dc2 is not null or dc3 is not null then vst_cnt end) over (partition by indv_sys_id) >=2
			    then 1 else 0 end
		,min(case when dc1 is not null then full_dt end) 
			 over (partition by indv_sys_id) as min_dt
		,max(case when dc1 is not null then full_dt end)
			 over (partition by indv_sys_id) as max_dt
		,def2 = case when datediff(day, min(case when dc1 is not null then full_dt end) 
								 over (partition by indv_sys_id)
								,max(case when dc1 is not null then full_dt end) 
								over (partition by indv_sys_id)) > = 14 
				and sum(case when dc1 is not null then vst_cnt end) over (partition by indv_sys_id) >=2						
				then 1 else 0 end*/
		/*,def3 = min(case when sum(case when b.EXT_AHFS_THRPTC_CLSS_DESC like '%opiate%' 
						OR b.EXT_AHFS_THRPTC_CLSS_DESC like '%skeletal%' then a.Day_cnt end)
						over (partition by indv_Sys_id, GNRC_NM) >= 90
						OR dc1 is not null or dc2 is not null or dc3 is not null 
						then full_dt end)
						over (partition by indv_sys_id) 
from pdb_VT_Chronicpain..MemClaimsLowerBackPain a 
join MiniHPDM..dim_NDC_Drug b on a.NDC_Drg_Sys_Id = b.NDC_DRG_SYS_ID
where  Indv_Sys_Id = 16072782
--and  (dc1 is not null or dc2 is not null or dc3 is not null)
--group by Indv_Sys_Id
order by Indv_Sys_Id

select * from pdb_VT_Chronicpain..MemClaimsLowerBackPain
--where indv_Sys_id = 176143075
--order by FULL_DT*/

/*
select *
from DCLowerBackPain
where DIAG_CD like '%73%' */

