{{ config(
        alias='FINANCE_ADJ_MAPPINGS',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        tags=["finance"],
        transient = false
) }}

with source_data as (
    select
        ACCOUNTING_DOCUMENT_LINE,
        SALES_CATEGORY_FIN_ADJ,
        END_USER_FIN_ADJ,
        FISCAL_YEAR,
        COMPANY_CODE,
        COMPANY_CODE_FISCAL_YEAR_ACCOUNTING_DOCUMENT_LINE
    from {{ ref('BRONZE__TEH_REVENUE_COGS__FILE_FINANCE_ADJ_MAPPINGS') }} 
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        ACCOUNTING_DOCUMENT_LINE,
        SALES_CATEGORY_FIN_ADJ,
        END_USER_FIN_ADJ,
        FISCAL_YEAR,
        COMPANY_CODE,
        COMPANY_CODE_FISCAL_YEAR_ACCOUNTING_DOCUMENT_LINE
    from source_data
),

type_data as (
    select 
        cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        cast(ACCOUNTING_DOCUMENT_LINE as VARCHAR(16777216)) as ACCOUNTING_DOCUMENT_LINE,
        cast(SALES_CATEGORY_FIN_ADJ as VARCHAR(16777216)) as SALES_CATEGORY_FIN_ADJ,
        cast(END_USER_FIN_ADJ as VARCHAR(16777216)) as END_USER_FIN_ADJ,
        FISCAL_YEAR,
        COMPANY_CODE,
        COMPANY_CODE_FISCAL_YEAR_ACCOUNTING_DOCUMENT_LINE
    from transform_data
)

select * from type_data