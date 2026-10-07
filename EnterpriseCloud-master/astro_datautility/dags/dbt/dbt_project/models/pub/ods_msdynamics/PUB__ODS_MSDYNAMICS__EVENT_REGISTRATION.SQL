{{ config(
    materialized='view',
    alias='EVENT_REGISTRATION'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MSDYNAMICS__EVENT_REGISTRATION') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data