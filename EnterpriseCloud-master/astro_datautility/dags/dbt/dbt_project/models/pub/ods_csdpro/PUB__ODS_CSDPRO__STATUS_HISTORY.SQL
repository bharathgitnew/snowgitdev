/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.29"
*************/

{{ config(
      materialized='view',
      alias='STATUS_HISTORY',
      transient=false
) }}

with source_data as (
    SELECT
        STATUS_HISTORY_ID,
        INCIDENT_ID,
        INCIDENT_STATUS_ID,
        IS_CURRENT_STATUS,
        MODIFIED_DATETIME,
        MODIFIED_BY--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__STATUS_HISTORY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data