{{ config(
        alias = 'FINANCE_ADJ_MAPPINGS',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        ACCOUNTING_DOCUMENT_LINE,
        SALES_CATEGORY_FIN_ADJ,
        END_USER_FIN_ADJ,
        FISCAL_YEAR,
        COMPANY_CODE,
        _FILENAME,
        _FILEDATE
    from {{ source('FILE', 'FINANCE_ADJ_MAPPINGS') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source("FILE", "FINANCE_ADJ_MAPPINGS") }})
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY CONCAT(COMPANY_CODE,'_',FISCAL_YEAR,'_',ACCOUNTING_DOCUMENT_LINE) ORDER BY _FILEDATE DESC )) = 1
),

transform_data as (
    select 
        ACCOUNTING_DOCUMENT_LINE,
        SALES_CATEGORY_FIN_ADJ,
        END_USER_FIN_ADJ,
        FISCAL_YEAR,
        COMPANY_CODE,
        CONCAT(COMPANY_CODE,'_',FISCAL_YEAR,'_',ACCOUNTING_DOCUMENT_LINE) AS COMPANY_CODE_FISCAL_YEAR_ACCOUNTING_DOCUMENT_LINE,
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
    from source_data
),

type_data as (
    select 
        cast(ACCOUNTING_DOCUMENT_LINE as VARCHAR(16777216)) as ACCOUNTING_DOCUMENT_LINE,
        cast(SALES_CATEGORY_FIN_ADJ as VARCHAR(16777216)) as SALES_CATEGORY_FIN_ADJ,
        cast(END_USER_FIN_ADJ as VARCHAR(16777216)) as END_USER_FIN_ADJ,
        FISCAL_YEAR,
        COMPANY_CODE,
        COMPANY_CODE_FISCAL_YEAR_ACCOUNTING_DOCUMENT_LINE,
        cast(_FILENAME as VARCHAR(16777216)) as _FILENAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
    from transform_data
)

select * from type_data