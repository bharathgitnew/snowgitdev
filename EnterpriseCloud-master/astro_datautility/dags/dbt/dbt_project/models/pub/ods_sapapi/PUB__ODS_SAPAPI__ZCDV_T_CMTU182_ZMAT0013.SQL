/************
Model file generated from dbtGeneratePubViews: 03.17.2023.06.37.42"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU182_ZMAT0013',
      transient=false
) }}

with source_data as (
    SELECT
        PARTNER,
        ZDUTY,
        ZAJC,
        SEQNO,
        PRCSTS,
        ZCOMC,
        ZCOSTC,
        ZGPC,
        COUNTRY,
        ZJOBFG,
        ZJOBF,
        ZPOSITION,
        DELFLG,
        CDATE,
        CTIME,
        CUSER,
        CPGM,
        UTIME,
        UUSER,
        UPGM,
        UDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU182_ZMAT0013') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data