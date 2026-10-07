{{ config(
      materialized='view',
      alias='SCR_CYCLE_TIME_GOALS_BY_GROUP',
      transient=false
) }}

with source_data as (
    SELECT
        _FILENAME,
        _FILEDATE,
        TITLE,
        DATE,
        CT_GOALS
    from {{ ref('COMMON__SHAREPOINT__SCR_CYCLE_TIME_GOALS_BY_GROUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data