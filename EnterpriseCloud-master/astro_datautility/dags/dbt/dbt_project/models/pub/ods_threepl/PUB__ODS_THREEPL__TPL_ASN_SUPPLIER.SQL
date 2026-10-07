{{ config(
      materialized='view',
      alias='TPL_ASN_Supplier',
      transient=false
) }}

with source_data as (
    SELECT
        SUPPLIER,
        ASN_ENABLED,
        _FILEDATE,
        AUDIT_LOG_ID,
        _ROW_HASH
    from {{ ref('ODS__THREEPL__TPL_ASN_SUPPLIER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data