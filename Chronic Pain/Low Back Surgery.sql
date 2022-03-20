-- Getting the first diag_dt
-- drop table #first_diag_dt
select Indv_Sys_Id, min(full_dt) as first_diag_dt
into #first_diag_dt --select *
  from [pdb_vt_chronicpain].[dbo].[memclaimslowerbackpain] 
  where dc1 is not null or dc2 is not null or dc3 is not null
  group by Indv_Sys_Id
--88,953 
  create unique index uix on #first_diag_dt(indv_sys_id,first_diag_dt)

--get the year of lower back surgery
--drop table #LBS
select a.Indv_Sys_Id, DATEDIFF(year,first_diag_dt,FULL_DT) as yearnum_LBS
into #LBS
from [pdb_vt_chronicpain].[dbo].[memclaimslowerbackpain]	a
join #first_diag_dt											b on a.Indv_Sys_Id = b.Indv_Sys_Id
join MiniHPDM..Dim_Procedure_Code							c on a.Proc_Cd_Sys_Id = c.PROC_CD_SYS_ID
join pdb_VT_ChronicPain..SurgeryPC							d on c.PROC_CD = d.PROC_CD
group by a.Indv_Sys_Id, DATEDIFF(year,first_diag_dt,FULL_DT)
--3,710
select top 1000 * 
--select distinct indv_sys_id
from #LBS
select * from #LBS where indv_sys_id = 29431858
/*
select Indv_Sys_Id, PROC_DESC, FULL_DT
from MiniHPDM..Fact_Claims	a
join MiniHPDM..Dim_Procedure_Code	b on a.Proc_Cd_Sys_Id = b.PROC_CD_SYS_ID
join MiniHPDM..Dim_Date		c	on a.Dt_Sys_Id = c.DT_SYS_ID
where indv_sys_id = 29431858 and YEAR_MO between 201201 and 201806
*/

--percentage --3322 members
select yearnum_LBS, mbr_cnt = count(distinct Indv_Sys_Id), perc_LBS=count(distinct Indv_Sys_Id)/(3322*1.0), perc_chrncmbr=count(distinct Indv_Sys_Id)/(88953 *1.0)
from #LBS
group by yearnum_LBS
