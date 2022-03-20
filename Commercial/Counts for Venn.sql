--Commercial/Medicare
select count(distinct a.diag_Cd)
from pdb_VT_ChronicPain..Com_ChronicPain_type_app2 a
join pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1	b on a.diag_cd = b.diag_cd

--Commercial/SMA
select count(distinct a.diag_Cd)
from pdb_VT_ChronicPain..Com_ChronicPain_type_app2 a
join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1	b on a.diag_cd = b.diag_cd

--Medicare/SMA
select count(distinct a.diag_Cd)
from pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1 a
join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1	b on a.diag_cd = b.diag_cd

--Medicare/SMA/Commercial
select count(distinct a.diag_Cd)
from pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1 a
join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1	b on a.diag_cd = b.diag_cd
join pdb_VT_ChronicPain..Com_ChronicPain_type_app2		c on a.diag_cd = c.diag_cd

--Commercial 75/hybrid
select count(distinct a.diag_Cd)
from pdb_VT_ChronicPain..Com_ChronicPain_type_app2 a
join pdb_VT_ChronicPain..ChronicPain_types	b on a.diag_cd = b.diag_cd

--Commercial people 75/hybrid
select count(distinct a.Indv_Sys_Id)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
join pdb_VT_ChronicPain..Com_MemberSummary_TTL		b on a.Indv_Sys_Id = b.Indv_Sys_Id
where b.wChronicPain = 1 and a.wChronicPain = 1 and a.DiagV2_SRTFlag_1 = 1

--Alhera
select count(distinct Indv_Sys_Id)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	
where DiagV2_SRTFlag_1 = 1 and wChronicPain = 1 

--Cleo
select count(distinct Indv_Sys_Id)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL	
where wChronicPain = 1 


select distinct a.diag_Cd from pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1
select distinct a.diag_Cd from pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1
