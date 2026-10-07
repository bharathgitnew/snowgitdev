{{ config(
        alias='FILE_FINANCE_ADJ_MAPPINGS',
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
        transient = false
) }}

with source_data as (
    select
    
        _FILENAME,
        _FILEDATE,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_CATEGORY_FIN_ADJ,
        END_USER_FIN_ADJ,
        FISCAL_YEAR,
        COMPANY_CODE
    from {{ source('FILE', 'FINANCE_ADJ_MAPPINGS') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source("FILE", "FINANCE_ADJ_MAPPINGS") }})
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY ACCOUNTING_DOCUMENT_LINE ORDER BY _FILEDATE DESC )) = 1
),

transform_data as (
    select 
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_CATEGORY_FIN_ADJ,
        END_USER_FIN_ADJ,
        FISCAL_YEAR,
        COMPANY_CODE,
        CONCAT(COMPANY_CODE,'_',FISCAL_YEAR,'_',ACCOUNTING_DOCUMENT_LINE) AS COMPANY_CODE_FISCAL_YEAR_ACCOUNTING_DOCUMENT_LINE
      
    from source_data
),

type_data as (
    select 
        cast(_FILENAME as VARCHAR(16777216)) as _FILENAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
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