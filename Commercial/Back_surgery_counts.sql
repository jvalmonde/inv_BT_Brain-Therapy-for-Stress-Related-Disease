select [Final Category],diag_desc, PROC_CD, PROC_DESC,AHRQ_PROC_DTL_CATGY_DESC, cnt = count(distinct indv_sys_id), Allow_amt = sum(ALLW_AMT)
from (
			Select  a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_1_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			group by a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			union
			Select  a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_2_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			group by a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			union
			Select  a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.Dt_Sys_Id   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_3_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			group by a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc , [Final Category], ALLW_AMT
			union
			--UBH claims
			Select  a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_1_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			group by a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			union
			Select  a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_2_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			group by a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			union
			Select  a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_3_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			group by a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			union
			Select  a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_4_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			group by a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			union
			Select  a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			from pdb_VT_ChronicPain..Com_MemberSummary_TTL_v2	a
			inner join MiniHPDM..Fact_UBH_Claims		b	on	a.Indv_Sys_Id = b.Indv_Sys_Id
			inner join MiniHPDM..Dim_Date			c	on	b.FST_SRVC_DT_SYS_ID   = c.DT_SYS_ID
			inner join MiniHPDM..Dim_Procedure_Code	d	on	b.Proc_Cd_Sys_Id = d.PROC_CD_SYS_ID
			inner join pdb_VT_ChronicPain..pain_types_v2	e on b.Diag_5_Cd_Sys_Id = e.diag_cd_sys_id
			where c.YEAR_NBR = 2017 and wChronicPain = 1
				and Ahrq_Proc_Dtl_Catgy_Desc in ('EXCISION DESTRUCTION OR RESECT', 'SPINAL FUSION')
			group by a.Indv_Sys_Id, PROC_CD,PROC_DESC, AHRQ_PROC_DTL_CATGY_DESC,diag_desc, [Final Category], ALLW_AMT
			) a
group by [Final Category],diag_desc, PROC_CD, PROC_DESC,AHRQ_PROC_DTL_CATGY_DESC
order by 2,6 desc