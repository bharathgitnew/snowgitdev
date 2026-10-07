{{ config(
      materialized='view',
      schema='de_sap_master_data',
      alias='SAP_SEGMENT',
      transient=false
) }}

with source_data as (
    SELECT
        * EXCLUDE(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__SAPH__SAP_SEGMENT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data