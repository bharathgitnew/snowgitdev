/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.28"
*************/

{{ config(
      materialized='view',
      alias='INCIDENT_CLASSIFICATION',
      transient=false
) }}

with source_data as (
    SELECT
        INCIDENT_CLASSIFICATION_ID,
        DESCRIPTION,
        SORT_ORDER,
        INACTIVE_DATE,
        CLASSIFICATION_TYPE--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__INCIDENT_CLASSIFICATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data