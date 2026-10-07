/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.58"
*************/

{{ config(
      materialized='view',
      alias='BUCODEMAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        BUCODEBYCONFIGURATION,
        BUCODETEA,
        BUCODETEL,
        BUCODEOLD_TEA,
        ISDEFAULT
    from {{ ref('COMMON__BAAN__BUCODEMAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data