/************
Model file generated from dbtGeneratePubViews: 03.09.2023.04.53.35"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU099_LFBK',
      transient=false
) }}

with source_data as (
    SELECT
        LIFNR,
        BANKS,
        BANKL,
        BANKN,
        BKONT,
        BVTYP,
        XEZER,
        BKREF,
        KOINH,
        EBPPACCNAME,
        EBPPBVSTATUS,
        KOVON,
        KOBIS,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU099_LFBK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data