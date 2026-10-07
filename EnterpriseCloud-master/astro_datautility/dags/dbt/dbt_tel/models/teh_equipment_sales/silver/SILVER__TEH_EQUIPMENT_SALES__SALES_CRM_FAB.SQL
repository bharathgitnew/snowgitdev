{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SALES_CRM_FAB',
    unique_key = []
) }}

with source_data as
(
    select
    ID                          as FAB_Line_Id,
    sm_account_name             as Account_Id,
    sm_fab_line_cd              as FAB_Line_Code,
    sm_account_cd               as Account_Code,
    sm_name                     as FAB_LINE,
    split_part(sm_name, '_', 1) as FAB
from {{ ref('BRONZE__TEH_EQUIPMENT_SALES__CRM_FILE_SM_FAB_LINE') }}
),

transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        FAB_LINE_ID,
	    ACCOUNT_ID,
	    FAB_LINE_CODE,
	    ACCOUNT_CODE,
	    FAB_LINE,
	    FAB
    FROM source_data
)

,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        FAB_LINE_ID,
	    ACCOUNT_ID,
	    FAB_LINE_CODE,
	    ACCOUNT_CODE,
	    FAB_LINE,
	    FAB
from transform_data
    )
select * from type_data