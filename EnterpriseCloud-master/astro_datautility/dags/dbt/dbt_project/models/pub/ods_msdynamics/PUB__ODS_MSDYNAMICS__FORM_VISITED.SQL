{{ config(
    materialized='view',
    alias='FORM_VISITED'
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__MSDYNAMICS__FORM_VISITED') }}
        
)
,transform_data as
(
    SELECT * FROM source_data
)

    select * from transform_data