{{ config(
    materialized='view',
    alias='WEBSITE_CLICKED'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MSDYNAMICS__WEBSITE_CLICKED') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data