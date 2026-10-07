{{ config(
    materialized='view',
    alias='EMAIL_CLICKED'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MSDYNAMICS__EMAIL_CLICKED') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data