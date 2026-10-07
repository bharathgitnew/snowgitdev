/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.59"
*************/

{{ config(
      materialized='view',
      alias='DIMENSION',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCOUNTTYPEID,
        ACCOUNTTYPE,
        BLOCKINGFROMDATE,
        BLOCKINGTODATE,
        DIMENSIONTYPE,
        DIMENSIONID,
        DESCRIPTION,
        DIMENSIONTYPEID,
        DIMENSIONTYPEDESCRIPTION,
        DISPLAYUNIT1DESCRIPTION,
        DISPLAYUNIT1ID,
        DISPLAYUNIT2DESCRIPTION,
        DISPLAYUNIT2ID,
        PARENTDIMENSION,
        RESPONSIBLEEMPLOYEEID,
        PRINTSEQUENCE,
        SEARCHKEY,
        BLOCKINGSTATUS,
        STATUSID,
        SUBLEVEL,
        UNIT1,
        UNIT2
    from {{ ref('COMMON__BAAN__DIMENSION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data