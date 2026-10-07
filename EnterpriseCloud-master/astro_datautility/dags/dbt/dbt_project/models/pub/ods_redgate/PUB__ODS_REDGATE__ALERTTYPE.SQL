/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.41.10"
*************/

{{ config(
      materialized='view',
      alias='ALERTTYPE',
      transient=false
) }}

with source_data as (
    SELECT
        ALERTTYPE,
        EVENT,
        NAME,
        DESCRIPTION,
        SHORTNAME,
        PRIORITY
    from {{ ref('ODS__REDGATE__ALERTTYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data