/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.38"
*************/

{{ config(
      materialized='view',
      alias='TBL_AD_COMPUTERS',
      transient=false
) }}

with source_data as (
    SELECT
        AD_COMPUTER_ID,
        ASSET_ID,
        COMMENT,
        COMPANY,
        DESCRIPTION,
        LOCATION,
        OU,
        LAST_CHANGED,
        AD_OBJECT_ID,
        MANAGER_AD_OBJECT_ID,
        IS_ENABLED,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TBL_AD_COMPUTERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data