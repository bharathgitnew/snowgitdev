/************
Model file generated from dbtGeneratePubViews: 04.07.2023.03.06.47"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU201_BUT0ID',
      transient=false
) }}

with source_data as (
    SELECT
        CLIENT,
        PARTNER,
        TYPE,
        IDNUMBER,
        INSTITUTE,
        ENTRYDATE,
        VALIDDATEFROM,
        VALIDDATETO,
        COUNTRY,
        REGION,
        IDNUMBERGUID,
        BPEEWBUT0ID,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU201_BUT0ID') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data