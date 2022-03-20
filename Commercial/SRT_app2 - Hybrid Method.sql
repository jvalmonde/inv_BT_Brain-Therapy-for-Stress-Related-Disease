--drop table #SRT_Members_Matt
select Indv_Sys_Id, DepressionFlag, wChronicPain, IdiopathicPain, NeuropathicPain, MusclePain, InflammatoryPain, NervePain, UnknownCategory
	, DIAG_CD, DIAG_DESC, ICD_VER_CD, FULL_DT, [Final Category]
into #SRT_Members_Matt
from (
	select m.Indv_Sys_Id, DepressionFlag, wChronicPain, IdiopathicPain, NeuropathicPain, MusclePain, InflammatoryPain, NervePain, UnknownCategory, d.DIAG_CD, d.DIAG_DESC, dc.ICD_VER_CD, FULL_DT, [Final Category]
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	m
	join MiniHPDM..Fact_Claims						f on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code					d  on f.Diag_1_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..pain_types_v2			dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date							dt on f.Dt_Sys_Id = dt.DT_SYS_ID
	where YEAR_NBR = 2017 and wChronicPain = 1
	union 
	select m.Indv_Sys_Id, DepressionFlag, wChronicPain, IdiopathicPain, NeuropathicPain, MusclePain, InflammatoryPain, NervePain, UnknownCategory, d.DIAG_CD, d.DIAG_DESC, dc.ICD_VER_CD, FULL_DT, [Final Category]
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	m
	join MiniHPDM..Fact_Claims						f on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code					d  on f.Diag_2_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..pain_types_v2			dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date							dt on f.Dt_Sys_Id = dt.DT_SYS_ID
	where YEAR_NBR = 2017 and wChronicPain = 1
	union 
	select m.Indv_Sys_Id, DepressionFlag, wChronicPain, IdiopathicPain, NeuropathicPain, MusclePain, InflammatoryPain, NervePain, UnknownCategory, d.DIAG_CD, d.DIAG_DESC, dc.ICD_VER_CD, FULL_DT, [Final Category]
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	m
	join MiniHPDM..Fact_Claims						f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code					d  on f.Diag_3_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..pain_types_v2			dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date							dt on f.Dt_Sys_Id = dt.DT_SYS_ID
	where YEAR_NBR = 2017 and wChronicPain = 1
	union 
	select m.Indv_Sys_Id, DepressionFlag, wChronicPain, IdiopathicPain, NeuropathicPain, MusclePain, InflammatoryPain, NervePain, UnknownCategory, d.DIAG_CD, d.DIAG_DESC, dc.ICD_VER_CD, FULL_DT, [Final Category]
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	m
	join MiniHPDM..Fact_UBH_Claims						f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code					d  on f.Diag_1_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..pain_types_v2			dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date							dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017 and wChronicPain = 1
	union 
	select m.Indv_Sys_Id, DepressionFlag, wChronicPain, IdiopathicPain, NeuropathicPain, MusclePain, InflammatoryPain, NervePain, UnknownCategory, d.DIAG_CD, d.DIAG_DESC, dc.ICD_VER_CD, FULL_DT, [Final Category]
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	m
	join MiniHPDM..Fact_UBH_Claims						f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code					d  on f.Diag_2_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..pain_types_v2			dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date							dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017 and wChronicPain = 1
	union 
	select m.Indv_Sys_Id, DepressionFlag, wChronicPain, IdiopathicPain, NeuropathicPain, MusclePain, InflammatoryPain, NervePain, UnknownCategory, d.DIAG_CD, d.DIAG_DESC, dc.ICD_VER_CD, FULL_DT, [Final Category]
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	m
	join MiniHPDM..Fact_UBH_Claims						f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code					d  on f.Diag_3_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..pain_types_v2			dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date							dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017 and wChronicPain = 1
	union 
	select m.Indv_Sys_Id, DepressionFlag, wChronicPain, IdiopathicPain, NeuropathicPain, MusclePain, InflammatoryPain, NervePain, UnknownCategory, d.DIAG_CD, d.DIAG_DESC, dc.ICD_VER_CD, FULL_DT, [Final Category]
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	m
	join MiniHPDM..Fact_UBH_Claims						f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code					d  on f.Diag_4_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..pain_types_v2			dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date							dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017 and wChronicPain = 1
	union 
	select m.Indv_Sys_Id, DepressionFlag, wChronicPain, IdiopathicPain, NeuropathicPain, MusclePain, InflammatoryPain, NervePain, UnknownCategory, d.DIAG_CD, d.DIAG_DESC, dc.ICD_VER_CD, FULL_DT, [Final Category]
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	m
	join MiniHPDM..Fact_UBH_Claims						f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code					d  on f.Diag_5_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..pain_types_v2			dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date							dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017 and wChronicPain = 1
) a
--3,576,198
select * from #SRT_Members_Matt order by Indv_Sys_Id, FULL_DT
select distinct Indv_Sys_Id from #SRT_Members_Matt
select distinct Indv_Sys_Id,DIAG_CD from #SRT_Members_Matt
select distinct DIAG_CD from #SRT_Members_Matt

select top 1000 * from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2

--drop table #Med_DiagOnSRT_Matt
select DIAG_CD, DIAG_DESC, [Final Category], count(distinct Indv_Sys_Id) as Cnt_mmbrs
into #Med_DiagOnSRT_Matt
from #SRT_Members_Matt
group by DIAG_CD, DIAG_DESC, [Final Category]
--320

select * from #Med_DiagOnSRT_Matt where DIAG_CD = '3078'

select * from pdb_VT_ChronicPain..pain_types_v2 where DIAG_CD = '3078'
-----------------------------------------------------------
--drop table #tmp_mbrs
select Indv_Sys_Id, DIAG_CD, DIAG_DESC, DIAG_CD_Flag = 1
into #tmp_mbrs
from #SRT_Members_Matt
--3,576,198

--Dynamic Pivot:
if OBJECT_ID ('pdb_VT_ChronicPain..Com_tmpPvtDiag_Matt') is not null begin drop table pdb_VT_ChronicPain..Com_tmpPvtDiag_Matt	End;

declare @listcol varchar (max)			--provide dynamic DiagCdSysId_ConCat column list based on pivot base tbl
declare @listcolisnull varchar (max)	--provide isnull validation to pivot result
declare @query1 varchar (max)			--Pivot data with dynamic DiagCdSysId_ConCat



select @listcol =							--provide dynamic DiagCdSysId_ConCat column list based on #HCC
STUFF((select 
			'],[' + DIAG_CD
		from  ( select distinct d.DIAG_CD
				from (
					select distinct DIAG_CD from pdb_VT_ChronicPain..pain_types_v2	
					) d
				left join #tmp_mbrs b on b.DIAG_CD = d.DIAG_CD
			)		as	a
			
			order by '],[' + DIAG_CD
			for XML path('')
				),1,2,'') + ']'

select @listcolisnull =						--provide isnull validation to pivot result
STUFF((select 
			', isnull([' +ltrim(rtrim(DIAG_CD))+ '],0) as [' +ltrim(rtrim(DIAG_CD))+ '] '
		From (select distinct d.DIAG_CD
				from (
						select distinct DIAG_CD from pdb_VT_ChronicPain..pain_types_v2	
						) d
				left join #tmp_mbrs b on b.DIAG_CD = d.DIAG_CD
				)	as	b
		Order by DIAG_CD
			for XML path('')
				),1,2,'') 
				

--Set variable to pivot data based on #HCC using DiagCdSysId_ConCatcolumns in @listcol and @listcolisnull validation. 
		
set @query1 = 

'select Indv_Sys_Id, '+ @listcolisnull +'
into pdb_VT_ChronicPain..Com_tmpPvtDiag_Matt
from

(select distinct Indv_Sys_Id
	,DIAG_CD
	,DIAG_CD_Flag
	from #tmp_mbrs
	)	as s
	
	pivot(max(DIAG_CD_Flag) for DIAG_CD	
	in ( '+@listcol+'))				as pvt	'
	
	execute (@query1)
--293,941
--select count(distinct Indv_Sys_Id) from #SRT_Members_Matt
select top 1000 * from pdb_VT_ChronicPain..Med_tmpPvtDiag_Matt
--drop table #Com_SRT_Memberspvt_Matt
select a.Indv_Sys_Id, a.IdiopathicPain, a.NeuropathicPain, a.MusclePain, a.InflammatoryPain, a.NervePain, a.DepressionFlag
	, GenlPsychotherapy_Flag
	, [05312]	=	isnull([05312],0)
	, [05313]	=	isnull([05313],0)
	, [07272]	=	isnull([07272],0)
	, [3078]	=	isnull([3078],0)
	, [30780]	=	isnull([30780],0)
	, [30789]	=	isnull([30789],0)
	, [3370]	=	isnull([3370],0)
	, [33709]	=	isnull([33709],0)
	, [338]	=	isnull([338],0)
	, [3380]	=	isnull([3380],0)
	, [3381]	=	isnull([3381],0)
	, [33811]	=	isnull([33811],0)
	, [33812]	=	isnull([33812],0)
	, [33818]	=	isnull([33818],0)
	, [33819]	=	isnull([33819],0)
	, [3382]	=	isnull([3382],0)
	, [33821]	=	isnull([33821],0)
	, [33822]	=	isnull([33822],0)
	, [33828]	=	isnull([33828],0)
	, [33829]	=	isnull([33829],0)
	, [3383]	=	isnull([3383],0)
	, [3384]	=	isnull([3384],0)
	, [33909]	=	isnull([33909],0)
	, [3501]	=	isnull([3501],0)
	, [3502]	=	isnull([3502],0)
	, [3521]	=	isnull([3521],0)
	, [3544]	=	isnull([3544],0)
	, [3551]	=	isnull([3551],0)
	, [35571]	=	isnull([35571],0)
	, [356]	=	isnull([356],0)
	, [3560]	=	isnull([3560],0)
	, [3562]	=	isnull([3562],0)
	, [3564]	=	isnull([3564],0)
	, [3568]	=	isnull([3568],0)
	, [357]	=	isnull([357],0)
	, [3571]	=	isnull([3571],0)
	, [3572]	=	isnull([3572],0)
	, [3573]	=	isnull([3573],0)
	, [3574]	=	isnull([3574],0)
	, [3575]	=	isnull([3575],0)
	, [3576]	=	isnull([3576],0)
	, [3577]	=	isnull([3577],0)
	, [3578]	=	isnull([3578],0)
	, [35782]	=	isnull([35782],0)
	, [35789]	=	isnull([35789],0)
	, [3579]	=	isnull([3579],0)
	, [37733]	=	isnull([37733],0)
	, [37734]	=	isnull([37734],0)
	, [37741]	=	isnull([37741],0)
	, [37991]	=	isnull([37991],0)
	, [3887]	=	isnull([3887],0)
	, [38870]	=	isnull([38870],0)
	, [38871]	=	isnull([38871],0)
	, [38872]	=	isnull([38872],0)
	, [44022]	=	isnull([44022],0)
	, [44382]	=	isnull([44382],0)
	, [52462]	=	isnull([52462],0)
	, [56942]	=	isnull([56942],0)
	, [625]	=	isnull([625],0)
	, [7105]	=	isnull([7105],0)
	, [7194]	=	isnull([7194],0)
	, [71940]	=	isnull([71940],0)
	, [71941]	=	isnull([71941],0)
	, [71942]	=	isnull([71942],0)
	, [71943]	=	isnull([71943],0)
	, [71944]	=	isnull([71944],0)
	, [71945]	=	isnull([71945],0)
	, [71946]	=	isnull([71946],0)
	, [71947]	=	isnull([71947],0)
	, [71948]	=	isnull([71948],0)
	, [71949]	=	isnull([71949],0)
	, [7231]	=	isnull([7231],0)
	, [7241]	=	isnull([7241],0)
	, [7242]	=	isnull([7242],0)
	, [7243]	=	isnull([7243],0)
	, [725]	=	isnull([725],0)
	, [7291]	=	isnull([7291],0)
	, [7292]	=	isnull([7292],0)
	, [7295]	=	isnull([7295],0)
	, [78096]	=	isnull([78096],0)
	, [7841]	=	isnull([7841],0)
	, [78492]	=	isnull([78492],0)
	, [7865]	=	isnull([7865],0)
	, [78650]	=	isnull([78650],0)
	, [78651]	=	isnull([78651],0)
	, [78652]	=	isnull([78652],0)
	, [78659]	=	isnull([78659],0)
	, [7873]	=	isnull([7873],0)
	, [7890]	=	isnull([7890],0)
	, [78900]	=	isnull([78900],0)
	, [78901]	=	isnull([78901],0)
	, [78902]	=	isnull([78902],0)
	, [78903]	=	isnull([78903],0)
	, [78904]	=	isnull([78904],0)
	, [78905]	=	isnull([78905],0)
	, [78906]	=	isnull([78906],0)
	, [78907]	=	isnull([78907],0)
	, [78909]	=	isnull([78909],0)
	, [A5043]	=	isnull([A5043],0)
	, [A5215]	=	isnull([A5215],0)
	, [B0222]	=	isnull([B0222],0)
	, [B0223]	=	isnull([B0223],0)
	, [B2684]	=	isnull([B2684],0)
	, [B2711]	=	isnull([B2711],0)
	, [B2781]	=	isnull([B2781],0)
	, [B2791]	=	isnull([B2791],0)
	, [B330]	=	isnull([B330],0)
	, [E0840]	=	isnull([E0840],0)
	, [E0841]	=	isnull([E0841],0)
	, [E0842]	=	isnull([E0842],0)
	, [E0843]	=	isnull([E0843],0)
	, [E1040]	=	isnull([E1040],0)
	, [E1041]	=	isnull([E1041],0)
	, [E1042]	=	isnull([E1042],0)
	, [E1043]	=	isnull([E1043],0)
	, [E1140]	=	isnull([E1140],0)
	, [E1141]	=	isnull([E1141],0)
	, [E1142]	=	isnull([E1142],0)
	, [E1143]	=	isnull([E1143],0)
	, [E1340]	=	isnull([E1340],0)
	, [E1341]	=	isnull([E1341],0)
	, [E1342]	=	isnull([E1342],0)
	, [E71522]	=	isnull([E71522],0)
	, [F454]	=	isnull([F454],0)
	, [F4541]	=	isnull([F4541],0)
	, [F4542]	=	isnull([F4542],0)
	, [G4409]	=	isnull([G4409],0)
	, [G500]	=	isnull([G500],0)
	, [G501]	=	isnull([G501],0)
	, [G546]	=	isnull([G546],0)
	, [G547]	=	isnull([G547],0)
	, [G564]	=	isnull([G564],0)
	, [G5640]	=	isnull([G5640],0)
	, [G5641]	=	isnull([G5641],0)
	, [G5642]	=	isnull([G5642],0)
	, [G5643]	=	isnull([G5643],0)
	, [G569]	=	isnull([G569],0)
	, [G5690]	=	isnull([G5690],0)
	, [G5691]	=	isnull([G5691],0)
	, [G5692]	=	isnull([G5692],0)
	, [G5693]	=	isnull([G5693],0)
	, [G571]	=	isnull([G571],0)
	, [G5710]	=	isnull([G5710],0)
	, [G5711]	=	isnull([G5711],0)
	, [G5712]	=	isnull([G5712],0)
	, [G5713]	=	isnull([G5713],0)
	, [G577]	=	isnull([G577],0)
	, [G5770]	=	isnull([G5770],0)
	, [G5771]	=	isnull([G5771],0)
	, [G5772]	=	isnull([G5772],0)
	, [G5773]	=	isnull([G5773],0)
	, [G579]	=	isnull([G579],0)
	, [G5790]	=	isnull([G5790],0)
	, [G5791]	=	isnull([G5791],0)
	, [G5792]	=	isnull([G5792],0)
	, [G5793]	=	isnull([G5793],0)
	, [G580]	=	isnull([G580],0)
	, [G589]	=	isnull([G589],0)
	, [G59]	=	isnull([G59],0)
	, [G60]	=	isnull([G60],0)
	, [G600]	=	isnull([G600],0)
	, [G602]	=	isnull([G602],0)
	, [G603]	=	isnull([G603],0)
	, [G609]	=	isnull([G609],0)
	, [G61]	=	isnull([G61],0)
	, [G611]	=	isnull([G611],0)
	, [G6182]	=	isnull([G6182],0)
	, [G619]	=	isnull([G619],0)
	, [G620]	=	isnull([G620],0)
	, [G621]	=	isnull([G621],0)
	, [G622]	=	isnull([G622],0)
	, [G6281]	=	isnull([G6281],0)
	, [G6282]	=	isnull([G6282],0)
	, [G629]	=	isnull([G629],0)
	, [G63]	=	isnull([G63],0)
	, [G651]	=	isnull([G651],0)
	, [G652]	=	isnull([G652],0)
	, [G89]	=	isnull([G89],0)
	, [G890]	=	isnull([G890],0)
	, [G891]	=	isnull([G891],0)
	, [G8911]	=	isnull([G8911],0)
	, [G8912]	=	isnull([G8912],0)
	, [G8918]	=	isnull([G8918],0)
	, [G892]	=	isnull([G892],0)
	, [G8921]	=	isnull([G8921],0)
	, [G8922]	=	isnull([G8922],0)
	, [G8928]	=	isnull([G8928],0)
	, [G8929]	=	isnull([G8929],0)
	, [G893]	=	isnull([G893],0)
	, [G894]	=	isnull([G894],0)
	, [G900]	=	isnull([G900],0)
	, [G9009]	=	isnull([G9009],0)
	, [G905]	=	isnull([G905],0)
	, [G9050]	=	isnull([G9050],0)
	, [G9051]	=	isnull([G9051],0)
	, [G90511]	=	isnull([G90511],0)
	, [G90512]	=	isnull([G90512],0)
	, [G90513]	=	isnull([G90513],0)
	, [G90519]	=	isnull([G90519],0)
	, [G9052]	=	isnull([G9052],0)
	, [G90521]	=	isnull([G90521],0)
	, [G90522]	=	isnull([G90522],0)
	, [G90523]	=	isnull([G90523],0)
	, [G90529]	=	isnull([G90529],0)
	, [G9059]	=	isnull([G9059],0)
	, [G990]	=	isnull([G990],0)
	, [H462]	=	isnull([H462],0)
	, [H463]	=	isnull([H463],0)
	, [H4701]	=	isnull([H4701],0)
	, [H47011]	=	isnull([H47011],0)
	, [H47012]	=	isnull([H47012],0)
	, [H47013]	=	isnull([H47013],0)
	, [H47019]	=	isnull([H47019],0)
	, [H571]	=	isnull([H571],0)
	, [H5710]	=	isnull([H5710],0)
	, [H5711]	=	isnull([H5711],0)
	, [H5712]	=	isnull([H5712],0)
	, [H5713]	=	isnull([H5713],0)
	, [H92]	=	isnull([H92],0)
	, [H920]	=	isnull([H920],0)
	, [H9201]	=	isnull([H9201],0)
	, [H9202]	=	isnull([H9202],0)
	, [H9203]	=	isnull([H9203],0)
	, [H9209]	=	isnull([H9209],0)
	, [I7022]	=	isnull([I7022],0)
	, [I70221]	=	isnull([I70221],0)
	, [I70222]	=	isnull([I70222],0)
	, [I70223]	=	isnull([I70223],0)
	, [I70228]	=	isnull([I70228],0)
	, [I70229]	=	isnull([I70229],0)
	, [I7032]	=	isnull([I7032],0)
	, [I70321]	=	isnull([I70321],0)
	, [I70322]	=	isnull([I70322],0)
	, [I70323]	=	isnull([I70323],0)
	, [I70328]	=	isnull([I70328],0)
	, [I70329]	=	isnull([I70329],0)
	, [I7042]	=	isnull([I7042],0)
	, [I70421]	=	isnull([I70421],0)
	, [I70422]	=	isnull([I70422],0)
	, [I70423]	=	isnull([I70423],0)
	, [I70428]	=	isnull([I70428],0)
	, [I70429]	=	isnull([I70429],0)
	, [I7052]	=	isnull([I7052],0)
	, [I7062]	=	isnull([I7062],0)
	, [I70621]	=	isnull([I70621],0)
	, [I70622]	=	isnull([I70622],0)
	, [I70623]	=	isnull([I70623],0)
	, [I70628]	=	isnull([I70628],0)
	, [I70629]	=	isnull([I70629],0)
	, [I7072]	=	isnull([I7072],0)
	, [I70721]	=	isnull([I70721],0)
	, [I70722]	=	isnull([I70722],0)
	, [I70723]	=	isnull([I70723],0)
	, [I70728]	=	isnull([I70728],0)
	, [I70729]	=	isnull([I70729],0)
	, [I7381]	=	isnull([I7381],0)
	, [I8381]	=	isnull([I8381],0)
	, [I83811]	=	isnull([I83811],0)
	, [I83812]	=	isnull([I83812],0)
	, [I83813]	=	isnull([I83813],0)
	, [I83819]	=	isnull([I83819],0)
	, [M055]	=	isnull([M055],0)
	, [M0550]	=	isnull([M0550],0)
	, [M0551]	=	isnull([M0551],0)
	, [M05511]	=	isnull([M05511],0)
	, [M05512]	=	isnull([M05512],0)
	, [M05519]	=	isnull([M05519],0)
	, [M0552]	=	isnull([M0552],0)
	, [M05521]	=	isnull([M05521],0)
	, [M05522]	=	isnull([M05522],0)
	, [M05529]	=	isnull([M05529],0)
	, [M0553]	=	isnull([M0553],0)
	, [M05531]	=	isnull([M05531],0)
	, [M05532]	=	isnull([M05532],0)
	, [M05539]	=	isnull([M05539],0)
	, [M0554]	=	isnull([M0554],0)
	, [M05541]	=	isnull([M05541],0)
	, [M05542]	=	isnull([M05542],0)
	, [M05549]	=	isnull([M05549],0)
	, [M0555]	=	isnull([M0555],0)
	, [M05551]	=	isnull([M05551],0)
	, [M05552]	=	isnull([M05552],0)
	, [M05559]	=	isnull([M05559],0)
	, [M0556]	=	isnull([M0556],0)
	, [M05561]	=	isnull([M05561],0)
	, [M05562]	=	isnull([M05562],0)
	, [M05569]	=	isnull([M05569],0)
	, [M0557]	=	isnull([M0557],0)
	, [M05571]	=	isnull([M05571],0)
	, [M05572]	=	isnull([M05572],0)
	, [M05579]	=	isnull([M05579],0)
	, [M0559]	=	isnull([M0559],0)
	, [M255]	=	isnull([M255],0)
	, [M2550]	=	isnull([M2550],0)
	, [M2551]	=	isnull([M2551],0)
	, [M25511]	=	isnull([M25511],0)
	, [M25512]	=	isnull([M25512],0)
	, [M25519]	=	isnull([M25519],0)
	, [M2552]	=	isnull([M2552],0)
	, [M25521]	=	isnull([M25521],0)
	, [M25522]	=	isnull([M25522],0)
	, [M25529]	=	isnull([M25529],0)
	, [M2553]	=	isnull([M2553],0)
	, [M25531]	=	isnull([M25531],0)
	, [M25532]	=	isnull([M25532],0)
	, [M25539]	=	isnull([M25539],0)
	, [M25541]	=	isnull([M25541],0)
	, [M25542]	=	isnull([M25542],0)
	, [M25549]	=	isnull([M25549],0)
	, [M2555]	=	isnull([M2555],0)
	, [M25551]	=	isnull([M25551],0)
	, [M25552]	=	isnull([M25552],0)
	, [M25559]	=	isnull([M25559],0)
	, [M2556]	=	isnull([M2556],0)
	, [M25561]	=	isnull([M25561],0)
	, [M25562]	=	isnull([M25562],0)
	, [M25569]	=	isnull([M25569],0)
	, [M2557]	=	isnull([M2557],0)
	, [M25571]	=	isnull([M25571],0)
	, [M25572]	=	isnull([M25572],0)
	, [M25579]	=	isnull([M25579],0)
	, [M2662]	=	isnull([M2662],0)
	, [M26621]	=	isnull([M26621],0)
	, [M26622]	=	isnull([M26622],0)
	, [M26623]	=	isnull([M26623],0)
	, [M26629]	=	isnull([M26629],0)
	, [M3483]	=	isnull([M3483],0)
	, [M353]	=	isnull([M353],0)
	, [M472]	=	isnull([M472],0)
	, [M4720]	=	isnull([M4720],0)
	, [M4721]	=	isnull([M4721],0)
	, [M4722]	=	isnull([M4722],0)
	, [M4723]	=	isnull([M4723],0)
	, [M4724]	=	isnull([M4724],0)
	, [M4725]	=	isnull([M4725],0)
	, [M4726]	=	isnull([M4726],0)
	, [M4727]	=	isnull([M4727],0)
	, [M4728]	=	isnull([M4728],0)
	, [M4781]	=	isnull([M4781],0)
	, [M501]	=	isnull([M501],0)
	, [M5011]	=	isnull([M5011],0)
	, [M5013]	=	isnull([M5013],0)
	, [M5114]	=	isnull([M5114],0)
	, [M5115]	=	isnull([M5115],0)
	, [M5116]	=	isnull([M5116],0)
	, [M5117]	=	isnull([M5117],0)
	, [M54]	=	isnull([M54],0)
	, [M541]	=	isnull([M541],0)
	, [M5410]	=	isnull([M5410],0)
	, [M5411]	=	isnull([M5411],0)
	, [M5412]	=	isnull([M5412],0)
	, [M5413]	=	isnull([M5413],0)
	, [M5414]	=	isnull([M5414],0)
	, [M5415]	=	isnull([M5415],0)
	, [M5416]	=	isnull([M5416],0)
	, [M5417]	=	isnull([M5417],0)
	, [M5418]	=	isnull([M5418],0)
	, [M542]	=	isnull([M542],0)
	, [M543]	=	isnull([M543],0)
	, [M5430]	=	isnull([M5430],0)
	, [M5431]	=	isnull([M5431],0)
	, [M5432]	=	isnull([M5432],0)
	, [M544]	=	isnull([M544],0)
	, [M5440]	=	isnull([M5440],0)
	, [M5441]	=	isnull([M5441],0)
	, [M5442]	=	isnull([M5442],0)
	, [M545]	=	isnull([M545],0)
	, [M546]	=	isnull([M546],0)
	, [M548]	=	isnull([M548],0)
	, [M5481]	=	isnull([M5481],0)
	, [M5489]	=	isnull([M5489],0)
	, [M549]	=	isnull([M549],0)
	, [M774]	=	isnull([M774],0)
	, [M7740]	=	isnull([M7740],0)
	, [M7741]	=	isnull([M7741],0)
	, [M7742]	=	isnull([M7742],0)
	, [M791]	=	isnull([M791],0)
	, [M792]	=	isnull([M792],0)
	, [M796]	=	isnull([M796],0)
	, [M7960]	=	isnull([M7960],0)
	, [M79601]	=	isnull([M79601],0)
	, [M79602]	=	isnull([M79602],0)
	, [M79603]	=	isnull([M79603],0)
	, [M79604]	=	isnull([M79604],0)
	, [M79605]	=	isnull([M79605],0)
	, [M79606]	=	isnull([M79606],0)
	, [M79609]	=	isnull([M79609],0)
	, [M7962]	=	isnull([M7962],0)
	, [M79621]	=	isnull([M79621],0)
	, [M79622]	=	isnull([M79622],0)
	, [M79629]	=	isnull([M79629],0)
	, [M7963]	=	isnull([M7963],0)
	, [M79631]	=	isnull([M79631],0)
	, [M79632]	=	isnull([M79632],0)
	, [M79639]	=	isnull([M79639],0)
	, [M7964]	=	isnull([M7964],0)
	, [M79641]	=	isnull([M79641],0)
	, [M79642]	=	isnull([M79642],0)
	, [M79643]	=	isnull([M79643],0)
	, [M79644]	=	isnull([M79644],0)
	, [M79645]	=	isnull([M79645],0)
	, [M79646]	=	isnull([M79646],0)
	, [M7965]	=	isnull([M7965],0)
	, [M79651]	=	isnull([M79651],0)
	, [M79652]	=	isnull([M79652],0)
	, [M79659]	=	isnull([M79659],0)
	, [M7966]	=	isnull([M7966],0)
	, [M79661]	=	isnull([M79661],0)
	, [M79662]	=	isnull([M79662],0)
	, [M79669]	=	isnull([M79669],0)
	, [M7967]	=	isnull([M7967],0)
	, [M79671]	=	isnull([M79671],0)
	, [M79672]	=	isnull([M79672],0)
	, [M79673]	=	isnull([M79673],0)
	, [M79674]	=	isnull([M79674],0)
	, [M79675]	=	isnull([M79675],0)
	, [M79676]	=	isnull([M79676],0)
	, [M797]	=	isnull([M797],0)
	, [M913]	=	isnull([M913],0)
	, [M9130]	=	isnull([M9130],0)
	, [M9131]	=	isnull([M9131],0)
	, [M9132]	=	isnull([M9132],0)
	, [N50811]	=	isnull([N50811],0)
	, [N50812]	=	isnull([N50812],0)
	, [N50819]	=	isnull([N50819],0)
	, [N5082]	=	isnull([N5082],0)
	, [N5312]	=	isnull([N5312],0)
	, [N94]	=	isnull([N94],0)
	, [R07]	=	isnull([R07],0)
	, [R070]	=	isnull([R070],0)
	, [R071]	=	isnull([R071],0)
	, [R072]	=	isnull([R072],0)
	, [R078]	=	isnull([R078],0)
	, [R0782]	=	isnull([R0782],0)
	, [R0789]	=	isnull([R0789],0)
	, [R079]	=	isnull([R079],0)
	, [R10]	=	isnull([R10],0)
	, [R101]	=	isnull([R101],0)
	, [R1010]	=	isnull([R1010],0)
	, [R1011]	=	isnull([R1011],0)
	, [R1012]	=	isnull([R1012],0)
	, [R1013]	=	isnull([R1013],0)
	, [R102]	=	isnull([R102],0)
	, [R103]	=	isnull([R103],0)
	, [R1030]	=	isnull([R1030],0)
	, [R1031]	=	isnull([R1031],0)
	, [R1032]	=	isnull([R1032],0)
	, [R1033]	=	isnull([R1033],0)
	, [R108]	=	isnull([R108],0)
	, [R1084]	=	isnull([R1084],0)
	, [R109]	=	isnull([R109],0)
	, [R141]	=	isnull([R141],0)
	, [R30]	=	isnull([R30],0)
	, [R309]	=	isnull([R309],0)
	, [R3982]	=	isnull([R3982],0)
	, [R40212]	=	isnull([R40212],0)
	, [R402120]	=	isnull([R402120],0)
	, [R402121]	=	isnull([R402121],0)
	, [R402122]	=	isnull([R402122],0)
	, [R402123]	=	isnull([R402123],0)
	, [R402124]	=	isnull([R402124],0)
	, [R40235]	=	isnull([R40235],0)
	, [R402350]	=	isnull([R402350],0)
	, [R402351]	=	isnull([R402351],0)
	, [R402352]	=	isnull([R402352],0)
	, [R402353]	=	isnull([R402353],0)
	, [R402354]	=	isnull([R402354],0)
	, [R52]	=	isnull([R52],0)
	, [R6884]	=	isnull([R6884],0)
	, [T8284]	=	isnull([T8284],0)
	, [T82847]	=	isnull([T82847],0)
	, [T82847A]	=	isnull([T82847A],0)
	, [T82847D]	=	isnull([T82847D],0)
	, [T82847S]	=	isnull([T82847S],0)
	, [T82848]	=	isnull([T82848],0)
	, [T82848A]	=	isnull([T82848A],0)
	, [T82848D]	=	isnull([T82848D],0)
	, [T82848S]	=	isnull([T82848S],0)
	, [T8384]	=	isnull([T8384],0)
	, [T8384XA]	=	isnull([T8384XA],0)
	, [T8384XD]	=	isnull([T8384XD],0)
	, [T8384XS]	=	isnull([T8384XS],0)
	, [T8484]	=	isnull([T8484],0)
	, [T8484XA]	=	isnull([T8484XA],0)
	, [T8484XD]	=	isnull([T8484XD],0)
	, [T8484XS]	=	isnull([T8484XS],0)
	, [T8584]	=	isnull([T8584],0)
	, [T85840A]	=	isnull([T85840A],0)
	, [T85840D]	=	isnull([T85840D],0)
	, [T85840S]	=	isnull([T85840S],0)
	, [T85848A]	=	isnull([T85848A],0)
	, [T85848D]	=	isnull([T85848D],0)
	, [T85848S]	=	isnull([T85848S],0)
	, [T8584XA]	=	isnull([T8584XA],0)
	, [T8584XD]	=	isnull([T8584XD],0)
	, [T8584XS]	=	isnull([T8584XS],0)
into #Com_SRT_Memberspvt_Matt
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
left join pdb_VT_ChronicPain..Com_tmpPvtDiag_Matt		b on a.Indv_Sys_Id = b.Indv_Sys_Id
where wChronicPain = 1
--293,941

select top 1000 * from #Com_SRT_Memberspvt_Matt
select DIAG_CD, rtrim(ltrim(DIAG_CD)) from #tmp_mbrs where DIAG_CD = 'Z9103'
-----------------------------------------------------------------------------------------------

select count(*) from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 where wChronicPain = 1
select top 1000 * from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 where wChronicPain = 1
select top 1000 *  from MiniHPDM..Fact_Diagnosis	

--drop table pdb_VT_ChronicPain..Com_SRT_Memberspvt_Matt
select * into pdb_VT_ChronicPain..Com_SRT_Memberspvt_Matt from #Com_SRT_Memberspvt_Matt


/*Get the rates for each diagnosis codes then only include those who passes the criteria*/
--drop table pdb_VT_ChronicPain..Com_ChronicPain_type_app2 
select distinct DIAG_CD, DIAG_DESC, AHRQ_DIAG_DTL_CATGY_NM  into pdb_VT_ChronicPain..Com_ChronicPain_type_app2 from pdb_VT_ChronicPain..pain_types_v2 where DIAG_CD in (
'F4541',	'F4542',	'M2550',	'M25519',	'M25531',	'M25532',	'M25539',	'M25541',	'M25542',	'M25551',	'M25552',	'M25559',	'M25569',
'M25579',	'M54',	'M545',	'M546',	'M5481',	'M5489',	'M549',	'M79601',	'M79602',	'M79603',	'M79604',	'M79605',	'M79606',	'M79609',	
'M79621',	'M79622',	'M79629',	'M79631',	'M79641',	'M79642',	'M79643',	'M79646',	'M79651',	'M79661',	'M79662',	'M79669',	'M79671',	
'M79672',	'M79673',	'M797',	'R10',	'R1010',	'R1011',	'R1012',	'R1013',	'R102',	'R1030',	'R1031',	'R1032',	'R1084',	'R109',	'B0222',	
'E0843',	'E71522',	'G500',	'G501',	'G546',	'G5640',	'G5641',	'G5642',	'G5690',	'G5692',	'G5693',	'G5770',	'G5771',	'G5772',	'G5773',	
'G5793',	'G580',	'G589',	'G59',	'G602',	'G603',	'G609',	'G611',	'G6182',	'G621',	'G622',	'G6281',	'G6282',	'G629',	'G63',	'G890',	'G8928',	'G894',	
'G9050',	'G90511',	'G90512',	'G90513',	'G90519',	'G90521',	'G90522',	'G90523',	'G90529',	'G9059',	'G990',	'M792',	'I70421',	'I70423',	
'M791',	'I70222',	'I70223',	'I70229',	'I83811',	'I83812',	'I83813',	'I83819',	'M353',	'M5011',	'M5013',	'M5114',	'M5115',	'M5117',	
'M5411',	'M5412',	'M5416',	'M5417',	'M542',	'M5440'
)
--122


--drop table #mmbrSRT
select Indv_Sys_Id, Diag_CPInt_SRTFlag = 1
into #mmbrSRT
from (
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag = 1
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_1_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..Com_ChronicPain_type_app2		dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.Dt_Sys_Id = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag = 1
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_2_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..Com_ChronicPain_type_app2		dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.Dt_Sys_Id = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag = 1
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_3_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..Com_ChronicPain_type_app2		dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.Dt_Sys_Id = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag = 1
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_1_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..Com_ChronicPain_type_app2		dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag = 1
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_2_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..Com_ChronicPain_type_app2		dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag = 1
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_3_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..Com_ChronicPain_type_app2		dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag = 1
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_4_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..Com_ChronicPain_type_app2		dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag = 1
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_5_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	join pdb_VT_ChronicPain..Com_ChronicPain_type_app2		dc on d.DIAG_CD = dc.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
) a
--782,451

alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
add DiagV2_SRTFlag_1 smallint

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 set 
DiagV2_SRTFlag_1 = isnull(b.Diag_CPInt_SRTFlag,0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
left join #mmbrSRT									b on a.Indv_Sys_Id = b.Indv_Sys_Id
--where wChronicPain = 1
--3,411,943

-----------------------------------------------------------------------------
/*Flagging Medicare and SMA hybrid in Commercial Population*/
create unique index id_Dx on pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1 (DIAG_CD)
create unique index id_Dx on pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1 (DIAG_CD)

--drop table #mmbrSRT1
select Indv_Sys_Id
	, Diag_CPInt_SRTFlag_Med = max(Diag_CPInt_SRTFlag_Med)
	, Diag_CPInt_SRTFlag_SMA = max(Diag_CPInt_SRTFlag_SMA)
into #mmbrSRT1
from (
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag_Med = case when dc.DIAG_CD is not null then 1 else 0 end, Diag_CPInt_SRTFlag_SMA = case when dc1.DIAG_CD is not null then 1 else 0 end
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_1_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	left join pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1		dc on d.DIAG_CD = dc.DIAG_CD
	left join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1		dc1 on d.DIAG_CD = dc1.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.Dt_Sys_Id = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag_Med = case when dc.DIAG_CD is not null then 1 else 0 end, Diag_CPInt_SRTFlag_SMA = case when dc1.DIAG_CD is not null then 1 else 0 end
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_2_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	left join pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1		dc on d.DIAG_CD = dc.DIAG_CD
	left join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1		dc1 on d.DIAG_CD = dc1.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.Dt_Sys_Id = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag_Med = case when dc.DIAG_CD is not null then 1 else 0 end, Diag_CPInt_SRTFlag_SMA = case when dc1.DIAG_CD is not null then 1 else 0 end
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_3_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	left join pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1		dc on d.DIAG_CD = dc.DIAG_CD
	left join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1		dc1 on d.DIAG_CD = dc1.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.Dt_Sys_Id = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag_Med = case when dc.DIAG_CD is not null then 1 else 0 end, Diag_CPInt_SRTFlag_SMA = case when dc1.DIAG_CD is not null then 1 else 0 end
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_1_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	left join pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1		dc on d.DIAG_CD = dc.DIAG_CD
	left join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1		dc1 on d.DIAG_CD = dc1.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag_Med = case when dc.DIAG_CD is not null then 1 else 0 end, Diag_CPInt_SRTFlag_SMA = case when dc1.DIAG_CD is not null then 1 else 0 end
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_2_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	left join pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1		dc on d.DIAG_CD = dc.DIAG_CD
	left join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1		dc1 on d.DIAG_CD = dc1.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag_Med = case when dc.DIAG_CD is not null then 1 else 0 end, Diag_CPInt_SRTFlag_SMA = case when dc1.DIAG_CD is not null then 1 else 0 end
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_3_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	left join pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1		dc on d.DIAG_CD = dc.DIAG_CD
	left join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1		dc1 on d.DIAG_CD = dc1.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag_Med = case when dc.DIAG_CD is not null then 1 else 0 end, Diag_CPInt_SRTFlag_SMA = case when dc1.DIAG_CD is not null then 1 else 0 end
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_4_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	left join pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1		dc on d.DIAG_CD = dc.DIAG_CD
	left join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1		dc1 on d.DIAG_CD = dc1.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
	union
	select m.Indv_Sys_Id, Diag_CPInt_SRTFlag_Med = case when dc.DIAG_CD is not null then 1 else 0 end, Diag_CPInt_SRTFlag_SMA = case when dc1.DIAG_CD is not null then 1 else 0 end
	from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2			m
	join MiniHPDM..Fact_UBH_Claims								f  on m.Indv_Sys_Id = f.Indv_Sys_Id
	join MiniHPDM..Dim_Diagnosis_Code							d  on f.Diag_5_Cd_Sys_Id = d.Diag_Cd_Sys_Id
	left join pdb_VT_ChronicPain..Med_ChronicPain_type_app2_1		dc on d.DIAG_CD = dc.DIAG_CD
	left join pdb_VT_ChronicPain..SMA_ChronicPain_type_app2_1		dc1 on d.DIAG_CD = dc1.DIAG_CD
	join MiniHPDM..Dim_Date									dt on f.FST_SRVC_DT_SYS_ID = dt.DT_SYS_ID
	where YEAR_NBR = 2017
) a
group by Indv_Sys_Id
--2,879,045
create unique index id_Indv on #mmbrSRT1 (Indv_Sys_Id)


alter table pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
add DiagV2_SRTFlag_Med smallint
, DiagV2_SRTFlag_SMA smallint

update pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2 set 
DiagV2_SRTFlag_Med = isnull(b.Diag_CPInt_SRTFlag_Med,0)
, DiagV2_SRTFlag_SMA = isnull(b.Diag_CPInt_SRTFlag_SMA,0)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2		a
left join #mmbrSRT1									b on a.Indv_Sys_Id = b.Indv_Sys_Id
--3,411,943

select
CMS = count(distinct case when DiagV2_SRTFlag_1 = 1 and DiagV2_SRTFlag_Med = 1 and DiagV2_SRTFlag_SMA = 1 then Indv_Sys_Id end)
, CM  = count(distinct case when DiagV2_SRTFlag_1 = 1 and DiagV2_SRTFlag_Med = 1 and DiagV2_SRTFlag_SMA <> 1 then Indv_Sys_Id end)
, CS  = count(distinct case when DiagV2_SRTFlag_1 = 1 and DiagV2_SRTFlag_Med <> 1 and DiagV2_SRTFlag_SMA = 1 then Indv_Sys_Id end)
, MS  = count(distinct case when DiagV2_SRTFlag_1 <> 1 and DiagV2_SRTFlag_Med = 1 and DiagV2_SRTFlag_SMA = 1 then Indv_Sys_Id end)
, C  = count(distinct case when DiagV2_SRTFlag_1 = 1 then Indv_Sys_Id end)
, M  = count(distinct case when DiagV2_SRTFlag_Med = 1 then Indv_Sys_Id end)
, S  = count(distinct case when DiagV2_SRTFlag_SMA = 1 then Indv_Sys_Id end)
, C  = count(distinct case when DiagV2_SRTFlag_1 = 1 and DiagV2_SRTFlag_Med <> 1 and DiagV2_SRTFlag_SMA <> 1 then Indv_Sys_Id end)
, M  = count(distinct case when DiagV2_SRTFlag_1 <> 1 and DiagV2_SRTFlag_Med = 1 and DiagV2_SRTFlag_SMA <> 1 then Indv_Sys_Id end)
, S  = count(distinct case when DiagV2_SRTFlag_1 <> 1 and DiagV2_SRTFlag_Med <> 1 and DiagV2_SRTFlag_SMA = 1 then Indv_Sys_Id end)
from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2
where wchronicpain = 1