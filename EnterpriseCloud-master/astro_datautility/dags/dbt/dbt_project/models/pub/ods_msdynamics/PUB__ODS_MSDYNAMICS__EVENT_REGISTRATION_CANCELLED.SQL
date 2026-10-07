{{ config(
    materialized='view',
    alias='EVENT_REGISTRATION_CANCELLED'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MSDYNAMICS__EVENT_REGISTRATION_CANCELLED') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data