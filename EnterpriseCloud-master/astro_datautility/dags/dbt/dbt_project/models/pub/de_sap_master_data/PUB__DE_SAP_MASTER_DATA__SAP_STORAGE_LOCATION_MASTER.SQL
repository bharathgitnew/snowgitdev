{{ config(
      materialized='view',
      schema='de_sap_master_data',
      alias='SAP_STORAGE_LOCATION_MASTER',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(_AUDIT_LOG_ID,_ROW_HASH,_FILENAME,_FILEDATE)
    from {{ ref('COMMON__SAPH__SAP_STORAGE_LOCATION_MASTER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data