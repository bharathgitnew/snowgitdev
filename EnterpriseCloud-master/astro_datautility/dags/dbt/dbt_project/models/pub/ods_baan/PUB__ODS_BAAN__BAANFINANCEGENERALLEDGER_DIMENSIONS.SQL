/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.12"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_DIMENSIONS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCOUNTTYPEDESCRIPTION,
        ACCOUNTTYPEID,
        BLOCKINGEFFECTIVEFROM,
        BLOCKINGEFFECTIVETO,
        DIMENSIONCODE,
        DIMENSIONDESCRIPTION,
        DIMENSIONTYPE,
        DISPLAYUNIT1DESCRIPTION,
        DISPLAYUNIT1ID,
        DISPLAYUNIT2DESCRIPTION,
        DISPLAYUNIT2ID,
        PARENTDIMENSION,
        PERSONRESPONSIBLE,
        PRINTSEQUENCE,
        SEARCHKEY,
        STATUSDESCRIPTION,
        STATUSID,
        SUBLEVEL,
        UNIT1,
        UNIT2
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_DIMENSIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data