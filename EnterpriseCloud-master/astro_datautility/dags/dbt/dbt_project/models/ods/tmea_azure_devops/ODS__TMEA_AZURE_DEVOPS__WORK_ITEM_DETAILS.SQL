{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='WORK_ITEM_DETAILS',
    unique_key = ['ID']
) }}
with source_data as
(
    SELECT
        _filename, 
		_filedate,
		parse_json(jsonfield) as work_items,
		json_extract_path_text(work_items, 'id')::number as Id,
		json_extract_path_text(work_items,'fields."System.WorkItemType"')::varchar as WorkItemType,
		json_extract_path_text(work_items,'fields."System.Title"')::varchar as Title,
		json_extract_path_text(work_items,'fields."System.State"')::varchar as State,
		json_extract_path_text(work_items,'fields."System.AssignedTo"."displayName"')::varchar as AssignedTo,
		json_extract_path_text(work_items,'fields."System.CreatedBy"')::varchar as CreatedBy,
		json_extract_path_text(work_items,'fields."System.CreatedDate"')::timestamp as CreatedDate,
		json_extract_path_text(work_items,'fields."System.ChangedDate"')::timestamp as ChangedDate,
		json_extract_path_text(work_items,'fields."System.IterationPath"')::varchar as IterationPath,
		json_extract_path_text(work_items,'fields."System.AreaPath"')::varchar as AreaPath,
		json_extract_path_text(work_items,'fields."System.Reason"')::varchar as Reason,
		json_extract_path_text(work_items,'fields."System.Tags"')::varchar as Tags,
		json_extract_path_text(work_items,'fields."System.TeamProject"')::varchar as TeamProject,
		json_extract_path_text(work_items,'fields."System.Description"')::varchar as Description,
		json_extract_path_text(work_items,'fields."System.History"')::varchar as History,
		json_extract_path_text(work_items, 'fields."FSI.WorkItem.PatchVersion"')::varchar as PatchVersion,
		json_extract_path_text(work_items, 'fields."FSI.WorkItem.RequestedBy"')::varchar as RequestedBy,
		json_extract_path_text(work_items, 'fields."FSI.WorkItem.CommittedDate"')::timestamp as CommittedDate,
		json_extract_path_text(work_items, 'fields."FSI.WorkItem.DeliveryDate"')::varchar as DeliveryDate,
		json_extract_path_text(work_items, 'fields."FSI.WorkItem.KPIOntimeDelivery"')::varchar as KPIOntimeDelivery,
		json_extract_path_text(work_items, 'fields."FSI.WorkItem.CommittedDateMet"')::varchar as CommittedDateMet,
		json_extract_path_text(work_items, 'fields."FSI.WorkItem.DefectExposure"')::varchar as DefectExposure,
		json_extract_path_text(work_items, 'fields."FSI.WorkItem.ReportDate"')::timestamp as DefectReportDate,
		json_extract_path_text(work_items, 'url') as URL
    FROM {{ source("TMEA_AZURE_DEVOPS", "WORK_ITEM_DETAILS") }}
    --WHERE _Filename NOT IN (SELECT  _Filename FROM {{ this }})
    {% if is_incremental() %}
    where _FILEDATE > ifnull((select max(_FILEDATE) from {{this}}), '1970-01-01')
    {% endif %}
    qualify row_number() over (partition by Id order by _FILEDATE desc) = 1
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        _Filename AS _FILENAME,
        _Filedate AS _FILEDATE,
		Id,
		WorkItemType,
		Title,
		State,
		replace(nullif(AssignedTo,'None'),'"','') as AssignedTo,
		replace(nullif(CreatedBy,'None'),'"','') as CreatedBy,
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
		url  
    FROM source_data
)
,type_data AS
(
    SELECT
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _Filename AS _FILENAME,
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
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
		cast( CommittedDate as DATE) as CommittedDate,
		cast( DeliveryDate as DATE) as  DeliveryDate,
		KPIOntimeDelivery,
		CommittedDateMet,
		DefectExposure,
		cast( DefectReportDate as DATE) as DefectReportDate,
		url 
    FROM transform_data
)
select
    *
from type_data