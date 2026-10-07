/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_CONTRACTCHANGES.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_CONTRACTCHANGES.SQL
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_CONTRACTCHANGES
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANSERVICECONTRACTMANAGEMENT_CONTRACTCHANGES',
    unique_key = ['CHANGEEXECUTEDON',
    'SERVICECONTRACT_CSCO']
) }}


with source_data as
(
    SELECT
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME
            ,201                                                                                                                                   AS _COMPANYID
            ,CAST(T$AMDY AS NUMERIC(15,2))                                                                                                       AS AMOUNTPERDAY
            ,CAST(CASE WHEN T$CETM<= '1/1/1970' THEN NULL ELSE T$CETM  END AS DATETIME) AS CHANGEEFFECTIVETIME
            ,CAST(T$ACDT AS DATETIME)                                                                                                            AS CHANGEEXECUTEDON
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS CHANGETEXT
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QUOT)),'')                                                                                         AS CONTRACTQUOTATION
            ,CAST(T$TERM AS BIGINT)                                                                                                              AS CONTRACTTERMS
            ,CAST(T$ERFA AS NUMERIC(15,2))                                                                                                       AS EARNEDREVENUEFACTOR
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CIND)),'')                                                                                         AS INDEXATIONTEMPLATE
            ,CAST(T$NRPE AS BIGINT)                                                                                                              AS NUMBEROFPERIODS
            ,CAST(T$ICPN AS NUMERIC(15,2))                                                                                                       AS PENALTY
            ,CAST(T$INNP AS BIGINT)                                                                                                              AS PERIOD
            ,T$CRPU.CONSTANTDESCRIPTION                                                                                                          AS PERIODUNIT_CRPUDESCRIPTION
            ,CAST(T$CRPU AS INT)                                                                                                                 AS PERIODUNIT_CRPUID
            ,T$INPU.CONSTANTDESCRIPTION                                                                                                          AS PERIODUNIT_INPUDESCRIPTION
            ,CAST(T$INPU AS INT)                                                                                                                 AS PERIODUNIT_INPUID
            ,T$PERU.CONSTANTDESCRIPTION                                                                                                          AS PERIODUNIT_PERUDESCRIPTION
            ,CAST(T$PERU AS INT)                                                                                                                 AS PERIODUNIT_PERUID
            ,T$CRPR.CONSTANTDESCRIPTION                                                                                                          AS PROCEDUREFORCONTRACTRENEWALDESCRIPTION
            ,CAST(T$CRPR AS INT)                                                                                                                 AS PROCEDUREFORCONTRACTRENEWALID
            ,T$ICPR.CONSTANTDESCRIPTION                                                                                                          AS PROCEDUREFORINCIDENTALCHANGESDESCRIPTION
            ,CAST(T$ICPR AS INT)                                                                                                                 AS PROCEDUREFORINCIDENTALCHANGESID
            ,T$INPR.CONSTANTDESCRIPTION                                                                                                          AS PROCEDUREFORPRICEINDEXATIONDESCRIPTION
            ,CAST(T$INPR AS INT)                                                                                                                 AS PROCEDUREFORPRICEINDEXATIONID
            ,CAST(T$CRNP AS BIGINT)                                                                                                              AS RENEWALPERIOD
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CONT)),'')                                                                                         AS SERVICECONTRACT_CONT
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                                                                                         AS SERVICECONTRACT_CSCO
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS STATUSOFCHANGEDESCRIPTION
            ,CAST(T$STAT AS INT)                                                                                                                 AS STATUSOFCHANGEID
            ,T$ACTN.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFCHANGEDESCRIPTION
            ,CAST(T$ACTN AS INT)                                                                                                                 AS TYPEOFCHANGEID

        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM320201") }} AS SOURCETABLE
            /*PERIODUNIT*/
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CRPU
             ON   T$CRPU.TABLENAME  = 'TSCTM320'
              AND T$CRPU.COLUMNNAME = 'T$CRPU'
              AND T$CRPU.CONSTANT   = SOURCETABLE.T$CRPU
            /*PERIODUNIT*/
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INPU
             ON   T$INPU.TABLENAME  = 'TSCTM320'
              AND T$INPU.COLUMNNAME = 'T$INPU'
              AND T$INPU.CONSTANT   = SOURCETABLE.T$INPU
            /*PERIODUNIT*/
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PERU
             ON   T$PERU.TABLENAME  = 'TSCTM320'
              AND T$PERU.COLUMNNAME = 'T$PERU'
              AND T$PERU.CONSTANT   = SOURCETABLE.T$PERU
            /*PROCEDUREFORCONTRACTRENEWAL*/
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CRPR
             ON   T$CRPR.TABLENAME  = 'TSCTM320'
              AND T$CRPR.COLUMNNAME = 'T$CRPR'
              AND T$CRPR.CONSTANT   = SOURCETABLE.T$CRPR
            /*PROCEDUREFORINCIDENTALCHANGES*/
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ICPR
             ON   T$ICPR.TABLENAME  = 'TSCTM320'
              AND T$ICPR.COLUMNNAME = 'T$ICPR'
              AND T$ICPR.CONSTANT   = SOURCETABLE.T$ICPR
            /*PROCEDUREFORPRICEINDEXATION*/
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INPR
             ON   T$INPR.TABLENAME  = 'TSCTM320'
              AND T$INPR.COLUMNNAME = 'T$INPR'
              AND T$INPR.CONSTANT   = SOURCETABLE.T$INPR
            /*STATUSOFCHANGE*/
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT
             ON   T$STAT.TABLENAME  = 'TSCTM320'
              AND T$STAT.COLUMNNAME = 'T$STAT'
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT
            /*TYPEOFCHANGE*/
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACTN
             ON   T$ACTN.TABLENAME  = 'TSCTM320'
              AND T$ACTN.COLUMNNAME = 'T$ACTN'
              AND T$ACTN.CONSTANT   = SOURCETABLE.T$ACTN
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        )
,transform_data as
(
    SELECT
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME,
        source_data._COMPANYID AS _COMPANYID,
        source_data.AMOUNTPERDAY AS AMOUNTPERDAY,
        source_data.CHANGEEFFECTIVETIME AS CHANGEEFFECTIVETIME,
        source_data.CHANGEEXECUTEDON AS CHANGEEXECUTEDON,
        source_data.CHANGETEXT AS CHANGETEXT,
        source_data.CONTRACTQUOTATION AS CONTRACTQUOTATION,
        source_data.CONTRACTTERMS AS CONTRACTTERMS,
        source_data.EARNEDREVENUEFACTOR AS EARNEDREVENUEFACTOR,
        source_data.INDEXATIONTEMPLATE AS INDEXATIONTEMPLATE,
        source_data.NUMBEROFPERIODS AS NUMBEROFPERIODS,
        source_data.PENALTY AS PENALTY,
        source_data.PERIOD AS PERIOD,
        source_data.PERIODUNIT_CRPUDESCRIPTION AS PERIODUNIT_CRPUDESCRIPTION,
        source_data.PERIODUNIT_CRPUID AS PERIODUNIT_CRPUID,
        source_data.PERIODUNIT_INPUDESCRIPTION AS PERIODUNIT_INPUDESCRIPTION,
        source_data.PERIODUNIT_INPUID AS PERIODUNIT_INPUID,
        source_data.PERIODUNIT_PERUDESCRIPTION AS PERIODUNIT_PERUDESCRIPTION,
        source_data.PERIODUNIT_PERUID AS PERIODUNIT_PERUID,
        source_data.PROCEDUREFORCONTRACTRENEWALDESCRIPTION AS PROCEDUREFORCONTRACTRENEWALDESCRIPTION,
        source_data.PROCEDUREFORCONTRACTRENEWALID AS PROCEDUREFORCONTRACTRENEWALID,
        source_data.PROCEDUREFORINCIDENTALCHANGESDESCRIPTION AS PROCEDUREFORINCIDENTALCHANGESDESCRIPTION,
        source_data.PROCEDUREFORINCIDENTALCHANGESID AS PROCEDUREFORINCIDENTALCHANGESID,
        source_data.PROCEDUREFORPRICEINDEXATIONDESCRIPTION AS PROCEDUREFORPRICEINDEXATIONDESCRIPTION,
        source_data.PROCEDUREFORPRICEINDEXATIONID AS PROCEDUREFORPRICEINDEXATIONID,
        source_data.RENEWALPERIOD AS RENEWALPERIOD,
        source_data.SERVICECONTRACT_CONT AS SERVICECONTRACT_CONT,
        source_data.SERVICECONTRACT_CSCO AS SERVICECONTRACT_CSCO,
        source_data.STATUSOFCHANGEDESCRIPTION AS STATUSOFCHANGEDESCRIPTION,
        source_data.STATUSOFCHANGEID AS STATUSOFCHANGEID,
        source_data.TYPEOFCHANGEDESCRIPTION AS TYPEOFCHANGEDESCRIPTION,
        source_data.TYPEOFCHANGEID AS TYPEOFCHANGEID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AMOUNTPERDAY as NUMBER(15,2)) as AMOUNTPERDAY,
        cast(CHANGEEFFECTIVETIME as TIMESTAMP_NTZ(9)) as CHANGEEFFECTIVETIME,
        cast(CHANGEEXECUTEDON as TIMESTAMP_NTZ(9)) as CHANGEEXECUTEDON,
        cast(CHANGETEXT as NUMBER(38,10)) as CHANGETEXT,
        cast(CONTRACTQUOTATION as VARCHAR(9)) as CONTRACTQUOTATION,
        cast(CONTRACTTERMS as NUMBER(38,0)) as CONTRACTTERMS,
        cast(EARNEDREVENUEFACTOR as NUMBER(15,2)) as EARNEDREVENUEFACTOR,
        cast(INDEXATIONTEMPLATE as VARCHAR(3)) as INDEXATIONTEMPLATE,
        cast(NUMBEROFPERIODS as NUMBER(38,0)) as NUMBEROFPERIODS,
        cast(PENALTY as NUMBER(15,2)) as PENALTY,
        cast(PERIOD as NUMBER(38,0)) as PERIOD,
        cast(PERIODUNIT_CRPUDESCRIPTION as VARCHAR(16777216)) as PERIODUNIT_CRPUDESCRIPTION,
        cast(PERIODUNIT_CRPUID as NUMBER(38,0)) as PERIODUNIT_CRPUID,
        cast(PERIODUNIT_INPUDESCRIPTION as VARCHAR(16777216)) as PERIODUNIT_INPUDESCRIPTION,
        cast(PERIODUNIT_INPUID as NUMBER(38,0)) as PERIODUNIT_INPUID,
        cast(PERIODUNIT_PERUDESCRIPTION as VARCHAR(16777216)) as PERIODUNIT_PERUDESCRIPTION,
        cast(PERIODUNIT_PERUID as NUMBER(38,0)) as PERIODUNIT_PERUID,
        cast(PROCEDUREFORCONTRACTRENEWALDESCRIPTION as VARCHAR(16777216)) as PROCEDUREFORCONTRACTRENEWALDESCRIPTION,
        cast(PROCEDUREFORCONTRACTRENEWALID as NUMBER(38,0)) as PROCEDUREFORCONTRACTRENEWALID,
        cast(PROCEDUREFORINCIDENTALCHANGESDESCRIPTION as VARCHAR(16777216)) as PROCEDUREFORINCIDENTALCHANGESDESCRIPTION,
        cast(PROCEDUREFORINCIDENTALCHANGESID as NUMBER(38,0)) as PROCEDUREFORINCIDENTALCHANGESID,
        cast(PROCEDUREFORPRICEINDEXATIONDESCRIPTION as VARCHAR(16777216)) as PROCEDUREFORPRICEINDEXATIONDESCRIPTION,
        cast(PROCEDUREFORPRICEINDEXATIONID as NUMBER(38,0)) as PROCEDUREFORPRICEINDEXATIONID,
        cast(RENEWALPERIOD as NUMBER(38,0)) as RENEWALPERIOD,
        cast(SERVICECONTRACT_CONT as VARCHAR(9)) as SERVICECONTRACT_CONT,
        cast(SERVICECONTRACT_CSCO as VARCHAR(9)) as SERVICECONTRACT_CSCO,
        cast(STATUSOFCHANGEDESCRIPTION as VARCHAR(16777216)) as STATUSOFCHANGEDESCRIPTION,
        cast(STATUSOFCHANGEID as NUMBER(38,0)) as STATUSOFCHANGEID,
        cast(TYPEOFCHANGEDESCRIPTION as VARCHAR(16777216)) as TYPEOFCHANGEDESCRIPTION,
        cast(TYPEOFCHANGEID as NUMBER(38,0)) as TYPEOFCHANGEID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data