{{ config(
    materialized='view',
    alias='WORKSPACE'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MONDAY__WORKSPACE') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data