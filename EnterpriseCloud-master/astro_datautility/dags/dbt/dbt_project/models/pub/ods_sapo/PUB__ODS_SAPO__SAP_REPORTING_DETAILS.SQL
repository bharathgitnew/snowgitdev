/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.48"
*************/

{{ config(
      materialized='view',
      alias='SAP_REPORTING_DETAILS',
      transient=false
) }}

with source_data as (
    SELECT
        REPID,
        RPT_DATE,
        RPT_TIME,
        USER_ID,
        NOTE,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__SAP_REPORTING_DETAILS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data