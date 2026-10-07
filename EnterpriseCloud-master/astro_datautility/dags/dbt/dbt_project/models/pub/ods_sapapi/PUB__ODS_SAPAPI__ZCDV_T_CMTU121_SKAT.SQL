/************
Model file generated from dbtGeneratePubViews: 03.24.2023.05.34.26"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU121_SKAT',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        KTOPL,
        SAKNR,
        TXT20,
        TXT50,
        MCOD1,
        LASTCHANGEDTS,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU121_SKAT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data