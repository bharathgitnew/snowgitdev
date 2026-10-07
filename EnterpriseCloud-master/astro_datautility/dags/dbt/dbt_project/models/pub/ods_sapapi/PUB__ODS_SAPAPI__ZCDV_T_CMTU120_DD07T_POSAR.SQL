/************
Model file generated from dbtGeneratePubViews: 01.17.2023.05.02.31"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU120_DD07T_POSAR',
      transient=false
) }}

with source_data as (
    SELECT
        DOMNAME,
        DDLANGUAGE,
        AS4LOCAL,
        VALPOS,
        AS4VERS,
        DDTEXT,
        DOMVALLD,
        DOMVALHD,
        DOMVALUEL,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU120_DD07T_POSAR') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data