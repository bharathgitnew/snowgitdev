{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TIRS_ACCIDENTWORKFLOWPROGRESSFORUS_NOLOCK'
) }}


WITH SOURCE_DATA AS 
(
    SELECT
        TIRS_No,
        Task_Name,
        Recipient_To,
        Recipient_Cc,
        Performed_By,
        Execution_Date,
        Company_Id
    FROM {{ ref('BRONZE__TEA_TECHNICAL_SUPPORT__TIRS_ACCIDENTWORKFLOWPROGRESSFORUS_NOLOCK') }} 
)

,TRANSFORM_DATA AS 
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        TIRS_No as TIRS_NO,
        Task_Name as TASK_NAME,
        Recipient_To as RECIPIENT_TO,
        Recipient_Cc as RECIPIENT_CC,
        Performed_By as PERFORMED_BY,
        Execution_Date as EXECUTION_DATE,
        Company_Id as COMPANY_ID
    FROM SOURCE_DATA 
),
TYPE_DATA AS 
(
    SELECT
        _AUDIT_LOG_ID,
        _ROW_HASH,
        TIRS_NO,
        TASK_NAME,
        RECIPIENT_TO,
        RECIPIENT_CC,
        PERFORMED_BY,
        EXECUTION_DATE,
        COMPANY_ID
    FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA