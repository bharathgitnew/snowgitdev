/************
Model file generated from dbtGeneratePubViews: 03.09.2022.10.56.19"
*************/

{{ config(
      materialized='view',
      alias='METADATA',
      transient=false
) }}

with source_data as (
    SELECT
        DOCUMENTTYPE,
        FIELDNAME,
        DATATYPE,
        ISCUSTOMFIELD,
        FIELDDESCRIPTION,
        FIELDSIZE,
        PRECISION,
        SCALE
    from {{ source('ODS__ARIBA', 'METADATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data