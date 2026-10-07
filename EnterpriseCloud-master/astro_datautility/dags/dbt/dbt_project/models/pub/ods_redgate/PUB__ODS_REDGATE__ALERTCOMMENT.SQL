/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.41.10"
*************/

{{ config(
      materialized='view',
      alias='ALERTCOMMENT',
      transient=false
) }}

with source_data as (
    SELECT
        COMMENTID,
        ALERTID,
        AUTHOR,
        DATE,
        COMMENTTEXT
    from {{ ref('ODS__REDGATE__ALERTCOMMENT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data