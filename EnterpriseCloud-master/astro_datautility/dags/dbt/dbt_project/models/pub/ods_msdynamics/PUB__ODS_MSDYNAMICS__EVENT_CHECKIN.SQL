{{ config(
    materialized='view',
    alias='EVENT_CHECKIN'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MSDYNAMICS__EVENT_CHECKIN') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data