{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='WORK_ITEM_DETAILS'
) }}
with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
		Id,
		WorkItemType,
		Title,
		State,
		AssignedTo,
		CreatedBy,
		CreatedDate,
		ChangedDate,
		IterationPath,
		AreaPath,
		Reason,
		Tags,
		TeamProject,
		Description,
		History,
		PatchVersion,
		RequestedBy,
		CommittedDate,
		DeliveryDate,
		KPIOntimeDelivery,
		CommittedDateMet,
		DefectExposure,
		DefectReportDate,
		url,
		QVICS,
		Customer,
		DefectAge,
		DefectFailure,
		DefectSeverity,
		DefectSource  
    FROM {{ ref('BRONZE__TMEA_ENGINEERING__TMEA_AZURE_DEVOPS_WORK_ITEM_DETAILS') }}
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        _FILENAME,
        _FILEDATE,
		Id,
		WorkItemType,
		Title,
		State,
		AssignedTo,
		CreatedBy,
		CreatedDate,
		ChangedDate,
		IterationPath,
		AreaPath,
		Reason,
		Tags,
		TeamProject,
		Description,
		History,
		PatchVersion,
		RequestedBy,
		CommittedDate,
		DeliveryDate,
		KPIOntimeDelivery,
		CommittedDateMet,
		DefectExposure,
		DefectReportDate,
		url,
		QVICS,
		Customer,
		DefectAge,
		DefectFailure,
		DefectSeverity,
		DefectSource  
    FROM source_data
)
,type_data AS
(
    SELECT
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _Filename AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		Id,
		WorkItemType,
		Title,
		State,
		AssignedTo,
		CreatedBy,
		CreatedDate,
		ChangedDate,
		IterationPath,
		AreaPath,
		Reason,
		Tags,
		TeamProject,
		Description,
		History,
		PatchVersion,
		RequestedBy,
		CommittedDate,
		DeliveryDate,
		KPIOntimeDelivery,
		CommittedDateMet,
		DefectExposure,
		DefectReportDate,
		url,
		QVICS,
		Customer,
		DefectAge,
		DefectFailure,
		DefectSeverity,
		DefectSource
    FROM transform_data
)
select
    *
from type_data