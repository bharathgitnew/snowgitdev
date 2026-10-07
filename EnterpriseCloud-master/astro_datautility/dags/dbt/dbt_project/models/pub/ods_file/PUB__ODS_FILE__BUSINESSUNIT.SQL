{{ config(
      materialized='view',
      alias='BUSINESSUNIT',
      transient=false
) }}

with source_data as (
    SELECT
    BU_CODE,
    BU_NAME,
    _FILEDATE
    from {{ ref('ODS__FILE__BUSINESSUNIT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data