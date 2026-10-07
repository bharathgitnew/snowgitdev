{{ config(
        alias = 'FCN_ANNOUNCEMENT_EVIDENCE_US',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select 
        BU_NAME,
        CUSTOMER_CODE,
        CUSTOMER_NAME,
        FCN_NO,
        FCN_NAME,
        CATEGORY,
        EXPLANATION_CUSTOMER_NAME,
        EXPLANATION_CUSTOMER_DEPT,
        EXPLANATION_DATE,
        EXPLANATION_FILE,
        SIGNATURE_CUSTOMER_NAME,
        SIGNATURE_CUSTOMER_DEPT,
        SIGNATURE_DATE,
        SIGNATURE_FILE,
        EXPLANATION_SIGNATURE_COMMENT, 
    from {{ ref('ODS__WISDOM__UG_EXPLAIN_US') }}
    union all
    select 
        BU_NAME,
        CUSTOMER_CODE,
        CUSTOMER_NAME,
        FCN_NO,
        FCN_NAME,
        CATEGORY,
        EXPLANATION_CUSTOMER_NAME,
        EXPLANATION_CUSTOMER_DEPT,
        EXPLANATION_DATE,
        EXPLANATION_FILE,
        SIGNATURE_CUSTOMER_NAME,
        SIGNATURE_CUSTOMER_DEPT,
        SIGNATURE_DATE,
        SIGNATURE_FILE,
        EXPLANATION_SIGNATURE_COMMENT,
    from {{ ref('ODS__WISDOM__UG_EXPLAIN_TI_US') }}
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        BU_NAME,
        CUSTOMER_CODE,
        CUSTOMER_NAME,
        FCN_NO,
        FCN_NAME,
        CATEGORY,
        EXPLANATION_CUSTOMER_NAME,
        EXPLANATION_CUSTOMER_DEPT,
        EXPLANATION_DATE,
        EXPLANATION_FILE,
        SIGNATURE_CUSTOMER_NAME,
        SIGNATURE_CUSTOMER_DEPT,
        SIGNATURE_DATE,
        SIGNATURE_FILE,
        EXPLANATION_SIGNATURE_COMMENT,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        BU_NAME,
        CUSTOMER_CODE,
        CUSTOMER_NAME,
        FCN_NO,
        FCN_NAME,
        CATEGORY,
        EXPLANATION_CUSTOMER_NAME,
        EXPLANATION_CUSTOMER_DEPT,
        to_varchar(EXPLANATION_DATE::DATE,'YYYY/MM/DD HH:MI:SS') AS EXPLANATION_DATE,
        EXPLANATION_FILE,
        SIGNATURE_CUSTOMER_NAME,
        SIGNATURE_CUSTOMER_DEPT,
        to_varchar(SIGNATURE_DATE::DATE,'YYYY/MM/DD HH:MI:SS') AS SIGNATURE_DATE,
        SIGNATURE_FILE,
        EXPLANATION_SIGNATURE_COMMENT,
    from transform_data
)

select * from type_data