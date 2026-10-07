{{ config(
    materialized='view',
    alias='EMAIL_OPENED'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MSDYNAMICS__EMAIL_OPENED') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data