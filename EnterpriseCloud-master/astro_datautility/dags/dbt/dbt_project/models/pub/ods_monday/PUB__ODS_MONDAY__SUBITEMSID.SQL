{{ config(
    materialized='view',
    alias='SUBITEMSID'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MONDAY__SUBITEMSID') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data