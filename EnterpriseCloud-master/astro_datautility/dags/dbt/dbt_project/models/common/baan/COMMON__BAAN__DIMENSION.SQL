{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='DIMENSION',
    unique_key = ['DimensionType',
    'DimensionId',
    '_COMPANYID']
) }}

with source_data as
(
    SELECT 
        Dimensions._CAPTUREDATETIME,
        Dimensions._COMPANYID,
        Dimensions.ACCOUNTTYPEID,
        Dimensions.ACCOUNTTYPEDESCRIPTION AS AccountType,
        Dimensions.BLOCKINGEFFECTIVEFROM AS BlockingFromDate,
        Dimensions.BLOCKINGEFFECTIVETO AS BlockingToDate,
        Dimensions.DIMENSIONTYPE,
        Dimensions.DIMENSIONCODE AS DIMENSIONID,
        Dimensions.DIMENSIONDESCRIPTION AS DESCRIPTION,
        Dimensions.DIMENSIONTYPE AS DIMENSIONTYPEID,
        DimensionDescriptions.DIMENSIONDESCRIPTION AS DIMENSIONTYPEDESCRIPTION,
        Dimensions.DISPLAYUNIT1DESCRIPTION,
        Dimensions.DISPLAYUNIT1ID,
        Dimensions.DISPLAYUNIT2DESCRIPTION,
        Dimensions.DISPLAYUNIT2ID,
        Dimensions.PARENTDIMENSION,
        Dimensions.PERSONRESPONSIBLE AS ResponsibleEmployeeId,
        Dimensions.PRINTSEQUENCE,
        Dimensions.SEARCHKEY,
        Dimensions.STATUSDESCRIPTION AS BLOCKINGSTATUS,
        Dimensions.STATUSID,
        Dimensions.SUBLEVEL,
        Dimensions.UNIT1,
        Dimensions.UNIT2
    FROM {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_DIMENSIONS') }} Dimensions
    INNER JOIN {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS') }} DimensionDescriptions
    ON DimensionDescriptions.DIMENSIONTYPE = Dimensions.DIMENSIONTYPE
)

,transform_data as
(
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCOUNTTYPEID,   
        AccountType,
        BlockingFromDate,
        BlockingToDate,
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
        ResponsibleEmployeeId,
        PRINTSEQUENCE,
        SEARCHKEY,
		BLOCKINGSTATUS,
        STATUSID,
        SUBLEVEL,
        UNIT1,
        UNIT2,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACCOUNTTYPEID as NUMBER(38,0)) as ACCOUNTTYPEID,
        cast(ACCOUNTTYPE as VARCHAR(16777216)) as ACCOUNTTYPE,
        cast(BLOCKINGFROMDATE as DATE) as BLOCKINGFROMDATE,
        cast(BLOCKINGTODATE as DATE) as BLOCKINGTODATE,
        cast(DIMENSIONTYPE as NUMBER(38,0)) as DIMENSIONTYPE,
        cast(DIMENSIONID as VARCHAR(16777216)) as DIMENSIONID,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(DIMENSIONTYPEID as NUMBER(38,0)) as DIMENSIONTYPEID,
        cast(DIMENSIONTYPEDESCRIPTION as VARCHAR(16777216)) as DIMENSIONTYPEDESCRIPTION,
        cast(DISPLAYUNIT1DESCRIPTION as VARCHAR(16777216)) as DISPLAYUNIT1DESCRIPTION,
        cast(DISPLAYUNIT1ID as NUMBER(38,0)) as DISPLAYUNIT1ID,
        cast(DISPLAYUNIT2DESCRIPTION as VARCHAR(16777216)) as DISPLAYUNIT2DESCRIPTION,
        cast(DISPLAYUNIT2ID as NUMBER(38,0)) as DISPLAYUNIT2ID,
        cast(PARENTDIMENSION as VARCHAR(16777216)) as PARENTDIMENSION,
        cast(RESPONSIBLEEMPLOYEEID as VARCHAR(16777216)) as RESPONSIBLEEMPLOYEEID,
        cast(PRINTSEQUENCE as NUMBER(38,0)) as PRINTSEQUENCE,
        cast(SEARCHKEY as VARCHAR(16777216)) as SEARCHKEY,
        cast(BLOCKINGSTATUS as VARCHAR(16777216)) as BLOCKINGSTATUS,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(SUBLEVEL as NUMBER(38,0)) as SUBLEVEL,
        cast(UNIT1 as VARCHAR(16777216)) as UNIT1,
        cast(UNIT2 as VARCHAR(16777216)) as UNIT2,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data