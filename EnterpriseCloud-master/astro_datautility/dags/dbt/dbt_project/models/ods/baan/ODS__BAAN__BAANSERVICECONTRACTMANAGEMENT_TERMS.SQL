/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_TERMS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_TERMS.SQL 
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_TERMS 
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
    alias='BAANSERVICECONTRACTMANAGEMENT_TERMS',
    unique_key = ['CONFIGURATION',
    'COSTTYPEID',
    'SERVICETYPE',
    'TERMID',
    'TYPEOFLINEID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'') AS CONFIGURATION 
            ,CAST("T$CAMT$1" AS NUMERIC(15,2))             AS COSTAMOUNT1 
            ,CAST("T$CAMT$2" AS NUMERIC(15,2))             AS COSTAMOUNT2 
            ,CAST("T$CAMT$3" AS NUMERIC(15,2))             AS COSTAMOUNT3 
            ,T$COTP.CONSTANTDESCRIPTION                  AS COSTTYPEDESCRIPTION 
            ,CAST(T$COTP AS INT)                         AS COSTTYPEID 
            ,CAST(T$GRMG AS NUMERIC(15,2))               AS GROSSMARGIN 
            ,CAST("T$RQCO$1" AS NUMERIC(15,2))             AS REQUIREDCOST1 
            ,CAST("T$RQCO$2" AS NUMERIC(15,2))             AS REQUIREDCOST2 
            ,CAST("T$RQCO$3" AS NUMERIC(15,2))             AS REQUIREDCOST3 
            ,CAST(T$RQSA AS NUMERIC(15,2))               AS REQUIREDSALES 
            ,CAST(T$AMNT AS NUMERIC(15,2))               AS SALESAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTP)),'') AS SERVICETYPE 
            ,CAST("T$SPCO$1" AS NUMERIC(15,2))             AS SPENTCOSTS1 
            ,CAST("T$SPCO$2" AS NUMERIC(15,2))             AS SPENTCOSTS2 
            ,CAST("T$SPCO$3" AS NUMERIC(15,2))             AS SPENTCOSTS3 
            ,CAST(T$SPSA AS NUMERIC(15,2))               AS SPENTSALES 
            ,CAST(T$TERM AS BIGINT)                      AS TERMID 
            ,CAST(T$TWDA AS NUMERIC(15,2))               AS TOTALWARRANTYDISCOUNTAMOUNT 
            ,T$TYPE.CONSTANTDESCRIPTION                  AS TYPEOFLINEDESCRIPTION 
            ,CAST(T$TYPE AS INT)                         AS TYPEOFLINEID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM100201") }} AS SOURCETABLE  
            /*COSTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COTP 
             ON   T$COTP.TABLENAME  = 'TSCTM100' 
              AND T$COTP.COLUMNNAME = 'T$COTP' 
              AND T$COTP.CONSTANT   = SOURCETABLE.T$COTP 
            /*TYPEOFLINE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TYPE 
             ON   T$TYPE.TABLENAME  = 'TSCTM100' 
              AND T$TYPE.COLUMNNAME = 'T$TYPE' 
              AND T$TYPE.CONSTANT   = SOURCETABLE.T$TYPE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.COSTAMOUNT1 AS COSTAMOUNT1, 
        source_data.COSTAMOUNT2 AS COSTAMOUNT2, 
        source_data.COSTAMOUNT3 AS COSTAMOUNT3, 
        source_data.COSTTYPEDESCRIPTION AS COSTTYPEDESCRIPTION, 
        source_data.COSTTYPEID AS COSTTYPEID, 
        source_data.GROSSMARGIN AS GROSSMARGIN, 
        source_data.REQUIREDCOST1 AS REQUIREDCOST1, 
        source_data.REQUIREDCOST2 AS REQUIREDCOST2, 
        source_data.REQUIREDCOST3 AS REQUIREDCOST3, 
        source_data.REQUIREDSALES AS REQUIREDSALES, 
        source_data.SALESAMOUNT AS SALESAMOUNT, 
        source_data.SERVICETYPE AS SERVICETYPE, 
        source_data.SPENTCOSTS1 AS SPENTCOSTS1, 
        source_data.SPENTCOSTS2 AS SPENTCOSTS2, 
        source_data.SPENTCOSTS3 AS SPENTCOSTS3, 
        source_data.SPENTSALES AS SPENTSALES, 
        source_data.TERMID AS TERMID, 
        source_data.TOTALWARRANTYDISCOUNTAMOUNT AS TOTALWARRANTYDISCOUNTAMOUNT, 
        source_data.TYPEOFLINEDESCRIPTION AS TYPEOFLINEDESCRIPTION, 
        source_data.TYPEOFLINEID AS TYPEOFLINEID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(COSTAMOUNT1 as NUMBER(15,2)) as COSTAMOUNT1,
        cast(COSTAMOUNT2 as NUMBER(15,2)) as COSTAMOUNT2,
        cast(COSTAMOUNT3 as NUMBER(15,2)) as COSTAMOUNT3,
        cast(COSTTYPEDESCRIPTION as VARCHAR(16777216)) as COSTTYPEDESCRIPTION,
        cast(COSTTYPEID as NUMBER(38,0)) as COSTTYPEID,
        cast(GROSSMARGIN as NUMBER(15,2)) as GROSSMARGIN,
        cast(REQUIREDCOST1 as NUMBER(15,2)) as REQUIREDCOST1,
        cast(REQUIREDCOST2 as NUMBER(15,2)) as REQUIREDCOST2,
        cast(REQUIREDCOST3 as NUMBER(15,2)) as REQUIREDCOST3,
        cast(REQUIREDSALES as NUMBER(15,2)) as REQUIREDSALES,
        cast(SALESAMOUNT as NUMBER(15,2)) as SALESAMOUNT,
        cast(SERVICETYPE as VARCHAR(3)) as SERVICETYPE,
        cast(SPENTCOSTS1 as NUMBER(15,2)) as SPENTCOSTS1,
        cast(SPENTCOSTS2 as NUMBER(15,2)) as SPENTCOSTS2,
        cast(SPENTCOSTS3 as NUMBER(15,2)) as SPENTCOSTS3,
        cast(SPENTSALES as NUMBER(15,2)) as SPENTSALES,
        cast(TERMID as NUMBER(38,0)) as TERMID,
        cast(TOTALWARRANTYDISCOUNTAMOUNT as NUMBER(15,2)) as TOTALWARRANTYDISCOUNTAMOUNT,
        cast(TYPEOFLINEDESCRIPTION as VARCHAR(16777216)) as TYPEOFLINEDESCRIPTION,
        cast(TYPEOFLINEID as NUMBER(38,0)) as TYPEOFLINEID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data