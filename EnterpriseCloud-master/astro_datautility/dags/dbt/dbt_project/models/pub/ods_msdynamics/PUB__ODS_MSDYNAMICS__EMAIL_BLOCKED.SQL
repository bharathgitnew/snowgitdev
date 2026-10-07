{{ config(
    materialized='view',
    alias='EMAIL_BLOCKED'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MSDYNAMICS__EMAIL_BLOCKED') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data