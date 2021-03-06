---- getting the first diag_dt

-- drop table #lbs_members
select a.savvyid
into #lbs_members
from [pdb_vt_chronicpain].[dbo].[memclaimslowerbackpain_medicare] as a
left join MiniOV..dim_procedure_code as b on a.proc_cd_sys_id = b.proc_cd_sys_id
left join [pdb_vt_chronicpain]..surgerypc  as c on ltrim(rtrim(b.proc_cd)) = ltrim(rtrim(c.proc_cd))
group by a.savvyid
having max(case when c.proc_cd is not null then 1 else 0 end) = 1
  
create unique index uix on #lbs_members(savvyid)

-- whatever periods/demographics in chronic population match to random population
-- make time period for both populations match
-- match demographics
-- 3 years prior to random population
/*
select b.Gender
, count(distinct case when b.Age >= 60 and b.Age < 70 then a.savvyid else null end) age_60_69
, count(distinct case when b.Age >= 70 and b.Age < 80 then a.savvyid else null end) age_70_79
, count(distinct case when b.Age >= 80 and b.Age < 90 then a.savvyid else null end) age_80_89
, count(distinct case when b.Age >= 90 and b.Age < 100 then a.savvyid else null end) age_90_99
from #lbs_members as a
join MiniOV..Dim_Member as b on a.savvyid = b.savvyid
group by b.Gender
*/

-- drop table #first_diag_dt
select a.[savvyid], min(full_dt) as first_diag_dt--, max(case when c.proc_cd is not null then 1 else 0 end) as lbp_surg_flag
--- surgery date not diag
into #first_diag_dt
from [pdb_vt_chronicpain].[dbo].[memclaimslowerbackpain_medicare] as a
join #lbs_members as b on a.savvyid = b.savvyid
join miniov..dim_procedure_code as c on a.proc_cd_sys_id = c.proc_cd_sys_id
join [pdb_vt_chronicpain]..surgerypc  as d on c.proc_cd = d.proc_cd 
join miniov..Dim_Member as f on a.savvyid = f.savvyid
--where age >= 30 and age < 60 -- match demographics better 
group by a.[savvyid]
  
  create unique index uix on #first_diag_dt(savvyid,first_diag_dt)


---- identifying members who meet the sum(day supply) >= 180 criteria
-- drop table #chronic_med_initial
select a.savvyid, ext_ahfs_thrptc_clss_desc, sum(day_cnt) as total_day_supply, case when sum(day_cnt) >= 180 then 1 else 0 end as chronic_mbr_flag
into #chronic_med_initial
from pdb_VT_ChronicPain..memclaimslowerbackpain_medicare as a
join  #first_diag_dt as e on a.savvyid = e.savvyid 
						and a.full_dt >= DATEADD(year,-3,e.first_diag_dt) and a.full_dt < e.first_diag_dt 
						and year(e.first_diag_dt) = 2015 -- 2012,2013,2014,2015
group by a.savvyid, ext_ahfs_thrptc_clss_desc

-- percentage computation
-- drop table #chroniclbp_thrptc_class_summary
select ext_ahfs_thrptc_clss_desc
, count(distinct case when chronic_mbr_flag = 1 then a.savvyid else null end) as  chronic_mbr_cnt
, count(distinct a.savvyid)  as total_mbr_cnt
,(select count(*) from #first_diag_dt) as all_lbs_mbrs
,(select count(distinct savvyid) from [pdb_vt_chronicpain].[dbo].[memclaimslowerbackpain_medicare]) as all_pain_mbrs
-- percentage within the drug class
,count(distinct case when chronic_mbr_flag = 1 then a.savvyid else null end) * 1.0 / 
	count(distinct a.savvyid) as percent_chronic_mbr 
-- percentage out of all lbp members
,count(distinct case when chronic_mbr_flag = 1 then a.savvyid else null end) * 1.0 / 
	(select count(*) from #first_diag_dt) as percent_chronic_mbr2
-- percentage out of all members
,count(distinct case when chronic_mbr_flag = 1 then a.savvyid else null end) * 1.0 / 
	(select count(distinct savvyid) from [pdb_vt_chronicpain].[dbo].[memclaimslowerbackpain_medicare]) as percent_chronic_mbr3
into #chroniclbp_thrptc_class_summary
from #chronic_med_initial as a
group by ext_ahfs_thrptc_clss_desc
order by percent_chronic_mbr3 desc


-- for the random members
-- drop table #nonchron_mbrs_initial
select a.savvyid
into #nonchron_mbrs_initial
from (select distinct savvyid from [pdb_vt_chronicpain].[dbo].[memclaims2012_2018june_medicare]) as a
left join (select distinct savvyid from [pdb_vt_chronicpain].[dbo].[memclaimslowerbackpain_medicare]) as  b on a.savvyid = b.savvyid
where b.savvyid is null

create unique index uix on #nonchron_mbrs_initial(savvyid)


/*
Gender	age_60_69	age_70_79	age_80_89	age_90_99
F		15397		92858		72041		20792
M		12742		61936		43503		8945
*/

-- drop table #nonchron_mbrs
select *
into #nonchron_mbrs
from (
	select *, ROW_NUMBER()over(partition by gender, age_group order by newid()) as rn
	from (
		select a.savvyid , gender
		,case when b.Age >= 30 and b.Age < 40 then 'age_30_39'
		 when b.Age >= 40 and b.Age < 50 then 'age_40_49'
		when b.Age >= 50 and b.Age < 60 then 'age_50_59' end as age_group
		from #nonchron_mbrs_initial as a
		join miniov..Dim_Member as b on a.savvyid = b.savvyid
		where age between 30 and 60
		) as sub1
) as sub2
where (gender = 'F' and age_group = 'age_30_39' and rn <= 98)
or (gender = 'F' and age_group = 'age_40_49' and rn <= 226)
or (gender = 'F' and age_group = 'age_50_59' and rn <= 441)
or (gender = 'M' and age_group = 'age_30_39' and rn <= 112)
or (gender = 'M' and age_group = 'age_40_49' and rn <= 312)
or (gender = 'M' and age_group = 'age_50_59' and rn <= 541)

create unique index uix on #nonchron_mbrs(savvyid)


-- drop table #nonchron_first_diag_dt
select a.savvyid, min(full_dt) as first_diag_dt
into #nonchron_first_diag_dt
  from [pdb_vt_chronicpain].[dbo].[memclaims2012_2018june_medicare] as a
  join #nonchron_mbrs as b on a.savvyid = b.savvyid
  --where dc1 is not null or dc2 is not null or dc3 is not null
  group by a.savvyid
  
create unique index uix on #nonchron_first_diag_dt(savvyid,first_diag_dt)


-- drop table #nonchronic_med_initial
select a.savvyid, b.ext_ahfs_thrptc_clss_desc, sum(day_cnt) as total_day_supply, case when sum(day_cnt) >= 180 then 1 else 0 end as mbr_flag
into #nonchronic_med_initial
from [pdb_vt_chronicpain].[dbo].[memclaims2012_2018june_medicare] as a
join miniov..dim_ndc_drug as b on a.ndc_drg_sys_id = b.ndc_drg_sys_id
join #nonchron_first_diag_dt as c on a.savvyid = c.savvyid and year(a.full_dt) between 2012 and 2015
group by  a.savvyid,b.ext_ahfs_thrptc_clss_desc


-- drop table #rndm_thrptc_class_summary
select ext_ahfs_thrptc_clss_desc
, count(distinct case when mbr_flag = 1 then a.savvyid else null end) as  chronic_mbr_cnt
, count(distinct a.savvyid)  as total_mbr_cnt
,(select count(*) from #nonchron_first_diag_dt) as all_lbs_mbrs
,(select count(distinct savvyid) from [pdb_vt_chronicpain].[dbo].[memclaims2012_2018june_medicare]) as all_pain_mbrs
-- percentage within the drug class
,count(distinct case when mbr_flag = 1 then a.savvyid else null end) * 1.0 / 
	count(distinct a.savvyid) as percent_chronic_mbr 
-- percentage out of all lbp members
,count(distinct case when mbr_flag = 1 then a.savvyid else null end) * 1.0 / 
	(select count(*) from #nonchron_first_diag_dt) as percent_chronic_mbr2
-- percentage out of all members
,count(distinct case when mbr_flag = 1 then a.savvyid else null end) * 1.0 / 
	(select count(distinct savvyid) from [pdb_vt_chronicpain].[dbo].[memclaims2012_2018june_medicare]) as percent_chronic_mbr3
into #rndm_thrptc_class_summary
from #nonchronic_med_initial as a
group by ext_ahfs_thrptc_clss_desc
order by percent_chronic_mbr3 desc

-- drop table [pdb_vt_chronicpain].[dbo].[chroniclbp_thrptc_class_summary_medicare]
select  a.ext_ahfs_thrptc_clss_desc
,a.chronic_mbr_cnt as chrnc_num
,a.all_lbs_mbrs as chrnc_den
, a.percent_chronic_mbr2 as chrnc_pop_percentage
,b.chronic_mbr_cnt as rndm_num
,b.all_lbs_mbrs as rndm_den
, b.percent_chronic_mbr2 as rndm_pop_percentage
, a.percent_chronic_mbr2 - b.percent_chronic_mbr2 as 'difference'
into [pdb_vt_chronicpain].[dbo].[chroniclbp_thrptc_class_summary_medicare]
from #chroniclbp_thrptc_class_summary as a
left join #rndm_thrptc_class_summary as b on a.ext_ahfs_thrptc_clss_desc = b.ext_ahfs_thrptc_clss_desc
order by a.percent_chronic_mbr2 - b.percent_chronic_mbr2 desc


select *
from [pdb_vt_chronicpain].[dbo].[chroniclbp_thrptc_class_summary_medicare]
order by [difference] desc
