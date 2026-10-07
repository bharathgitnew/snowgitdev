/************
Model file generated from dbtGeneratePubViews: 08.30.2022.06.46.46"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_SDT_EV_LIKP',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('ODS__SAPH__SAP_US_SDT_EV_LIKP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data