/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.29"
*************/

{{ config(
      materialized='view',
      alias='INCIDENT_STATUS',
      transient=false
) }}

with source_data as (
    SELECT
        INCIDENT_STATUS_ID,
        DESCRIPTION,
        SORT_ORDER,
        INACTIVE_DATE--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__INCIDENT_STATUS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data