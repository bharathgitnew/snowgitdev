/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.27"
*************/

{{ config(
      materialized='view',
      alias='PERSON_CLASSIFICATION',
      transient=false
) }}

with source_data as (
    SELECT
        PERSON_CLASSIFICATION_ID,
        DESCRIPTION,
        IS_EMPLOYEE_TYPE,
        SORT_ORDER,
        INACTIVE_DATE--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__PERSON_CLASSIFICATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data