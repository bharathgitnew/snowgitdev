{{ config(
    materialized='view',
    alias='SUBITEMS'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MONDAY__SUBITEMS') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data