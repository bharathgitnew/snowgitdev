/************
Model file generated from dbtGeneratePubViews: 04.21.2023.06.07.31"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU209_BUT020',
      transient=false
) }}

with source_data as (
    SELECT
        CLIENT,
        PARTNER,
        ADDRNUMBER,
        XDFADR,
        ADEXT,
        NATION,
        GUID,
        MOVEADDR,
        DATEFROM,
        ADDRESSGUID,
        ADDRVALIDFROM,
        ADDRVALIDTO,
        ADDRMOVEDATE,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU209_BUT020') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data