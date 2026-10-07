/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.01"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDT_EV_ZSDT0013_GMX',
      transient=false,
      enabled=false
) }}

with source_data as (
    SELECT
        * EXCLUDE(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('ODS__SAPH__SAP_SDT_EV_ZSDT0013_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data