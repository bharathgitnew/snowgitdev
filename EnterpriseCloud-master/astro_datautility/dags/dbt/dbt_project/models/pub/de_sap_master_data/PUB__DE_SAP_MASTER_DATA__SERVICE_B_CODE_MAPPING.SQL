{{ config(
      materialized='view',
      schema='de_sap_master_data',
      alias='SERVICE_B_CODE_MAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        B_CODE,
        LEGACY_OFFICE,
        LEGACY_OFFICE_CODE,
        SAP_DESCRIPTION,
        SAP_CODE,
        B_CODE_LOCATION,
        SAP_TECHNICAL_ID
    from {{ ref('COMMON__SAPH__SERVICE_B_CODE_MAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data