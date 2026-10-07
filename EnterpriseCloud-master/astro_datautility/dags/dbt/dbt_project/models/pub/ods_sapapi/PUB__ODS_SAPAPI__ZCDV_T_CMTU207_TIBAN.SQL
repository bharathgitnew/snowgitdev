/************
Model file generated from dbtGeneratePubViews: 04.21.2023.06.07.31"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU207_TIBAN',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        BANKS,
        BANKL,
        BANKN,
        BKONT,
        IBAN,
        VALIDFROM,
        ERNAM,
        ERDAT,
        TABNAME,
        TABKEY,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU207_TIBAN') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data