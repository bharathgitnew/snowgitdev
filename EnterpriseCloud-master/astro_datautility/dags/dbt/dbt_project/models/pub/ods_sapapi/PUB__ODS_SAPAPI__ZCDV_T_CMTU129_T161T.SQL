/************
Model file generated from dbtGeneratePubViews: 03.09.2023.04.53.24"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU129_T161T',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        BSART,
        BSTYP,
        BATXT,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU129_T161T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data