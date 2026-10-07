{{ config(
      materialized='view',
      alias='WBS_CODE_DESCRIPTION',
      transient=false
) }}

with source_data as (
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        WBS_CODE,
        WBS_1,
        WBS_13,
        WBS_CODE_DESC
    from {{ ref('ODS__FILE__WBS_CODE_DESCRIPTION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data