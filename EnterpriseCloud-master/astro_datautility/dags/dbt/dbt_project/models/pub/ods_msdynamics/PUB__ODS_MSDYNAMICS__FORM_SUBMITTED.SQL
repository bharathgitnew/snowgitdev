{{ config(
    materialized='view',
    alias='FORM_SUBMITTED'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MSDYNAMICS__FORM_SUBMITTED') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data