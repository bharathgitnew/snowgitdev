{{ config(
    materialized='view',
    alias='ITEMS'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MONDAY__ITEMS') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data