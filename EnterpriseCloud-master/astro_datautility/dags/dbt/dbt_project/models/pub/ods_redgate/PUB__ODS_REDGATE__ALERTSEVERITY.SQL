/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.41.10"
*************/

{{ config(
      materialized='view',
      alias='ALERTSEVERITY',
      transient=false
) }}

with source_data as (
    SELECT
        ALERTID,
        DATE,
        SEVERITY
    from {{ ref('ODS__REDGATE__ALERTSEVERITY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data