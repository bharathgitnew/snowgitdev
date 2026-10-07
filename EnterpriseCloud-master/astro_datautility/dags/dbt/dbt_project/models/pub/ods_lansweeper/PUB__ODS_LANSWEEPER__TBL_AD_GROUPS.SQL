/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.38"
*************/

{{ config(
      materialized='view',
      alias='TBL_AD_GROUPS',
      transient=false
) }}

with source_data as (
    SELECT
        AD_GROUP_ID,
        AD_OBJECT_ID,
        MANAGER_AD_OBJECT_ID,
        GROUP_TYPE,
        LAST_CHANGED,
        DESCRIPTION,
        NAME,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TBL_AD_GROUPS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data