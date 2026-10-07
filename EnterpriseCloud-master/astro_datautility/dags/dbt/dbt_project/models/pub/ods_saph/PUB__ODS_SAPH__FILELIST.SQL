/************
Model file generated from dbtGeneratePubViews: 07.18.2022.18.18.49"
*************/

{{ config(
      materialized='view',
      alias='FILELIST',
      transient=false
) }}

with source_data as (
    SELECT
        RECORDCOUNT,
        TABLEORVIEWNAME,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__FILELIST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data