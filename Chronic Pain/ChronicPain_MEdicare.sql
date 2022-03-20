
--Members with continuous enrollment. (417973 row(s) affected) 00:03:16
Drop table pdb_VT_ChronicPain..SavvyIDCntEnrol
select b.savvyid
into pdb_VT_ChronicPain..SavvyIDCntEnrol
from [MiniOV]..[Dim_MemberDetail] b
where b.year_mo between 201201 and 201806
and b.MAPDFlag = 1
and b.Src_Sys_Cd = 'CO'
group by b.SavvyID
having count(distinct Year_Mo) = 78


--(872 row(s) affected)
Drop table pdb_VT_ChronicPain..DCLowerBackPain_Medicare
select b.Diag_Cd_Sys_Id,b.DIAG_CD, b.DIAG_DESC, b.AHRQ_DIAG_DTL_CATGY_CD
, b.AHRQ_DIAG_DTL_CATGY_NM, b.CHRNC_FLG_NM, b.DIAG_FULL_DESC
into pdb_VT_ChronicPain..DCLowerBackPain_Medicare
from 
pdb_VT_ChronicPain..DCLowerBackPain a
join MiniOV..Dim_Diagnosis_Code b
on a.DIAG_CD = b.DIAG_CD
  


--Get claims for all members 
--(238791774 row(s) affected) 00:38:06
Drop table pdb_VT_Chronicpain..MemClaims2012_2018June_Medicare
select fc.SavvyId,fc.Dt_Sys_Id,dt.FULL_DT,fc.Diag_1_Cd_Sys_Id
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
into pdb_VT_Chronicpain..MemClaims2012_2018June_Medicare
from pdb_VT_ChronicPain..SavvyIDCntEnrol mem
join MiniOV..Fact_Claims fc  on fc.SavvyId = mem.SavvyID
join MiniOV..Dim_Date dt on dt.DT_SYS_ID = fc.Dt_Sys_Id
left join pdb_VT_ChronicPain..DCLowerBackPain_Medicare chrpain_dc1 on fc.Diag_1_Cd_Sys_Id = chrpain_dc1.diag_cd_sys_id
left join pdb_VT_ChronicPain..DCLowerBackPain_Medicare chrpain_dc2 on fc.Diag_2_Cd_Sys_Id = chrpain_dc2.diag_cd_sys_id
left join pdb_VT_ChronicPain..DCLowerBackPain_Medicare chrpain_dc3 on fc.Diag_3_Cd_Sys_Id = chrpain_dc3.diag_cd_sys_id
where YEAR_MO >=201201 and YEAR_MO<=201806

--ignored creating indices because it was taking too long to run
--create clustered index cix_fc on pdb_VT_Chronicpain..MemClaims2012_2018June_Medicare(savvyid, dt_sys_id)
--create index ix_ndc on pdb_VT_Chronicpain..MemClaims2012_2018June_Medicare(NDC_Drg_Sys_Id)

-- (186512 row(s) affected)have a lower back pain diagnosis.
Drop table pdb_VT_Chronicpain..MemWithLowerBackPain_Medicare
select distinct SavvyId 
into pdb_VT_Chronicpain..MemWithLowerBackPain_Medicare
from pdb_VT_Chronicpain..MemClaims2012_2018June_Medicare a 
left join pdb_VT_Chronicpain..DCLowerBackPain_Medicare d1 on d1.DIAG_CD_SYS_ID = a.dc1
left join pdb_VT_Chronicpain..DCLowerBackPain_Medicare d2 on d2.DIAG_CD_SYS_ID = a.dc2
left join pdb_VT_Chronicpain..DCLowerBackPain_Medicare d3 on d3.DIAG_CD_SYS_ID = a.dc3
where (dc1 is not null or dc2 is not null or dc3 is not null )


--Get claims for only above members. (29708320 row(s) affected) 00:06:14
--(140216626 row(s) affected)
Drop table pdb_VT_Chronicpain..MemClaimsLowerBackPain_Medicare
select fc.*, ndc.[EXT_AHFS_THRPTC_CLSS_DESC], ndc.[GNRC_NM]
,ChrBackPainDrug = case when ((ndc.EXT_AHFS_THRPTC_CLSS_DESC like '%opiate%') 
		OR (ndc.EXT_AHFS_THRPTC_CLSS_DESC like '%skeletal%')) then 1 else 0 end
into pdb_VT_Chronicpain..MemClaimsLowerBackPain_Medicare
from 
pdb_VT_Chronicpain..MemClaims2012_2018June_Medicare fc 
join pdb_VT_Chronicpain..MemWithLowerBackPain_Medicare m on fc.SavvyId = m.SavvyId
left join MiniOV..Dim_NDC_Drug ndc on fc.NDC_Drg_Sys_Id = ndc.NDC_DRG_SYS_ID
create clustered index cix_SavvyID_Date on pdb_VT_Chronicpain..MemClaimsLowerBackPain(savvyid, Dt_Sys_Id)




Create table pdb_VT_ChronicPain..ChronicDefs(Defs varchar(50), Logic varchar(max))
Insert into pdb_VT_ChronicPain..ChronicDefs
values ('Def1','2 or more visits with lower back pain diagnosis atleast 90 days apart')
Insert into pdb_VT_ChronicPain..ChronicDefs
values ('Def2','2 or more visits with primary lower back pain diagnosis atleast 14 days apart')
Insert into pdb_VT_ChronicPain..ChronicDefs
values ('Def3','atleast one occurence of lower back pain diagnosis with atleast 90 days of pain medication')


--(108221 row(s) affected)
Drop table #Def1
select SavvyId, min(full_dt) as def1_minDateth
/*,day90 = case when datediff(day, min(Full_dt), max(Full_dt)) > = 90 then 1 else 0 end
, vst_Cnt = case when sum(vst_cnt)>=2 then 1 else 0 end*/
into #Def1
from pdb_VT_Chronicpain..MemClaimsLowerBackPain_Medicare
where (dc1 is not null or dc2 is not null or dc3 is not null)
group by SavvyId
having  (case when datediff(day, min(Full_dt), max(Full_dt)) > = 90
		and sum(vst_cnt)>=2 then 1 else 0 end=1)
create unique index uix_SavvyID on #Def1(savvyid)



--(94256 row(s) affected)
Drop table #Def2
select SavvyId, min(full_dt) as def2_minDate
/*,day90 = case when datediff(day, min(Full_dt), max(Full_dt)) > = 14 then 1 else 0 end
, vst_Cnt = case when sum(vst_cnt)>=2 then 1 else 0 end*/
into #Def2
from pdb_VT_Chronicpain..MemClaimsLowerBackPain_Medicare
where (dc1 is not null)
group by SavvyId
having  (case when datediff(day, min(Full_dt), max(Full_dt)) > = 14
		and sum(vst_cnt)>=2 then 1 else 0 end=1)
create unique index uix_SavvyID on #Def2(savvyid)


--(64538 row(s) affected)
Drop table #Def3
select savvyid, min(full_dt) as def3_minDate
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
from pdb_VT_Chronicpain..MemClaimsLowerBackPain_Medicare fc
join MiniHPDM..Dim_NDC_Drug ndc on ndc.NDC_DRG_SYS_ID = fc.NDC_Drg_Sys_Id
--where (dc1 is not null or dc2 is not null or dc3 is not null)
group by savvyid
having case when sum(case when ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'OPIATE AGONISTS' 
		OR ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'CENTRALLY ACTING SKELETAL MUSCLE RELAXNT'
		THEN Day_Cnt end) >= 90 then 1 else 0 end = 1
create unique index uix_SavvyID on #Def3(savvyid)


--(186512 row(s) affected)
Drop table pdb_VT_Chronicpain..MemandChrDefs_Medicare
select all_mbrs.savvyID, def1_minDate = def1.def1_minDate
,def2_minDate = def2.def2_minDate
,def3_minDate = def3.def3_minDate
into pdb_VT_Chronicpain..MemandChrDefs_Medicare
from pdb_VT_Chronicpain..MemWithLowerBackPain_Medicare all_mbrs
left join #def1 def1 on def1.savvyID = all_mbrs.savvyID
left join #def2 def2 on def2.savvyID = all_mbrs.savvyID
left join #def3 def3 on def3.savvyID = all_mbrs.savvyID
create unique index uix_savvyID on pdb_VT_Chronicpain..MemandChrDefs(savvyID)



-- Get year-mo wise claims cost along with some flags for further analysis. 
--(1942859 row(s) affected) 00:00:25
Drop table pdb_VT_Chronicpain..CostChronicLowerback_Medicare
select  m.SavvyId
		,dt.YEAR_MO
		,TotalCost = sum(fc.Allw_Amt)
		,CostIP = case when MIN(fc.Srvc_Typ_Sys_Id) = 1 then sum(fc.Allw_Amt) end
		,CostOP = case when MIN(fc.Srvc_Typ_Sys_Id) = 2 then sum(fc.Allw_Amt) end
		,CostPhy = case when MIN(fc.Srvc_Typ_Sys_Id) = 3 then sum(fc.Allw_Amt) end
		,CostRx = case when MIN(fc.Srvc_Typ_Sys_Id) = 4 then sum(fc.Allw_Amt) end
		,ind_PainMeds = case when min(NDC_Drg_Sys_Id) <> -1 then 1 else 0 end
		--,ind_PainSurgery = case when min(pc.proc_CD_SYS_ID) is not null then 1 else 0 end
		,ind_diagofChronicPain = case when min(dc1) is not null or min(dc2) is not null or min(dc3) is not null then 1 else 0 end
into pdb_VT_Chronicpain..CostChronicLowerback_Medicare
from pdb_VT_Chronicpain..MemWithLowerBackPain_Medicare m
join pdb_VT_Chronicpain..MemClaimsLowerBackPain_Medicare fc on m.SavvyId = fc.SavvyId
join miniOV..Dim_Service_Type st on st.Srvc_Typ_Sys_Id = fc.Srvc_Typ_Sys_Id	
join miniOV..Dim_Date dt on fc.Dt_Sys_Id = dt.DT_SYS_ID
--left join pdb_VT_ChronicPain..Proc_CD_SurgeryLowerBack pc on fc.Proc_Cd_Sys_Id = pc.PROC_CD_SYS_ID
--left join pdb_VT_ChronicPain..DRG_CD_SurgeryLowerBack drg on drg.DRG_CD_SYS_ID = fc.sys_drg_cd_sys_id
where (dc1 is not null or dc2 is not null or dc3 is not null -- to get claims only for lower back pain
OR NDC_Drg_Sys_Id <> -1) -- to get pharmacy claims related to lower back pain
group by m.SavvyId
		,dt.YEAR_MO	
order by m.SavvyId, dt.YEAR_MO


--(11310834 row(s) affected)
Drop table pdb_VT_Chronicpain..CostChronicLowerback_Medicare
select  m.SavvyID
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
		,ind_PainMeds = max(case when ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'OPIATE AGONISTS' 
						OR ndc.EXT_AHFS_THRPTC_CLSS_DESC = 'CENTRALLY ACTING SKELETAL MUSCLE RELAXNT'
						then 1 else 0 end)
		,ind_PainSurgery = max(case when pc.proc_CD is not null then 1 else 0 end)
into pdb_VT_Chronicpain..CostChronicLowerback_Medicare 
from pdb_VT_Chronicpain..MemandChrDefs_Medicare m
join pdb_VT_Chronicpain..MemClaimsLowerBackPain_Medicare fc on m.SavvyID = fc.SavvyID
left join miniOV..Dim_Procedure_Code b on fc.proc_cd_Sys_id = b.proc_cd_sys_id
left join miniOV..Dim_Service_Type st on st.Srvc_Typ_Sys_Id = fc.Srvc_Typ_Sys_Id	
left join miniOV..Dim_Date dt on fc.Dt_Sys_Id = dt.DT_SYS_ID
left join miniOV..Dim_Procedure_Code all_pc on all_pc.PROC_CD_SYS_ID = fc.Proc_Cd_Sys_Id
left join miniOV..Dim_NDC_Drug ndc on ndc.NDC_DRG_SYS_ID = fc.NDC_Drg_Sys_Id
left join pdb_VT_ChronicPain..surgerypc pc on all_pc.PROC_CD = pc.proc_cd
left join pdb_VT_ChronicPain..therapy th on th.proc_cd = b.proc_cd
--left join pdb_VT_ChronicPain..DRG_CD_SurgeryLowerBack drg on drg.DRG_CD_SYS_ID = fc.sys_drg_cd_sys_id
--where (dc1 is not null or dc2 is not null or dc3 is not null -- to get claims only for lower back pain
--OR fc.NDC_Drg_Sys_Id <> -1) -- to get pharmacy claims related to lower back pain
group by m.SavvyID
		,dt.YEAR_MO	
order by m.SavvyID, dt.YEAR_MO





select * from miniOV..Dim_Procedure_Code a
join pdb_VT_ChronicPain..therapy b on a.PROC_CD = b.PROC_CD
join pdb_VT_Chronicpain..MemClaimsLowerBackPain_Medicare c 
						on c.Proc_Cd_Sys_Id = a.PROC_CD_SYS_ID

select * from pdb_vt_chronicpain..CostChronicLowerback_Medicare
where Cost_PainSurgery >0




