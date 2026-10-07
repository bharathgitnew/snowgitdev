/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_COVERAGETERMS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_COVERAGETERMS.SQL 
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_COVERAGETERMS 
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
    alias='BAANSERVICECONTRACTMANAGEMENT_COVERAGETERMS',
    unique_key = ['CONFIGURATION',
    'COSTTYPEID',
    'COVERAGETERMNUMBER',
    'SERVICETYPE',
    'TERMID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,201                                                                       AS _COMPANYID 
            ,CAST("T$ALCO$1" AS NUMERIC(15,2))                                         AS ALLOCATEDCOSTS1 
            ,CAST("T$ALCO$2" AS NUMERIC(15,2))                                         AS ALLOCATEDCOSTS2 
            ,CAST("T$ALCO$3" AS NUMERIC(15,2))                                         AS ALLOCATEDCOSTS3 
            ,CAST(T$ALDI AS NUMERIC(15,2))                                           AS ALLOCATEDDISCOUNT 
            ,CAST(T$ALSA AS NUMERIC(15,2))                                           AS ALLOCATEDSALES 
            ,CAST(T$CEIL AS NUMERIC(15,2))                                           AS CEILINGAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                             AS CONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COTM)),'')                             AS CONTRACTTERM 
            ,CAST("T$CAMT$1" AS NUMERIC(15,2))                                         AS COSTAMOUNT1 
            ,CAST("T$CAMT$2" AS NUMERIC(15,2))                                         AS COSTAMOUNT2 
            ,CAST("T$CAMT$3" AS NUMERIC(15,2))                                         AS COSTAMOUNT3 
            ,T$CCOV.CONSTANTDESCRIPTION                                              AS COSTCOVERINGMETHODDESCRIPTION 
            ,CAST(T$CCOV AS INT)                                                     AS COSTCOVERINGMETHODID 
            ,T$COTP.CONSTANTDESCRIPTION                                              AS COSTTYPEDESCRIPTION 
            ,CAST(T$COTP AS INT)                                                     AS COSTTYPEID 
            ,CAST(T$NRBT AS INT)                                                     AS COVERAGETERMNUMBER 
            ,CAST(T$DISC AS NUMERIC(15,2))                                           AS DISCOUNT 
            ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT END AS DATE) AS ENDDATE 
            ,CAST(T$LIMI AS NUMERIC(15,2))                                           AS LIMITINGCOUNTERVALUE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMDL)),'')                             AS MODELITEM 
            ,CAST(T$NRPE AS BIGINT)                                                  AS NUMBEROFPERIODS 
            ,T$PERU.CONSTANTDESCRIPTION                                              AS PERIODUNITDESCRIPTION 
            ,CAST(T$PERU AS INT)                                                     AS PERIODUNITID 
            ,CAST("T$RQCO$1" AS NUMERIC(15,2))                                         AS REQUIREDCOST1 
            ,CAST("T$RQCO$2" AS NUMERIC(15,2))                                         AS REQUIREDCOST2 
            ,CAST("T$RQCO$3" AS NUMERIC(15,2))                                         AS REQUIREDCOST3 
            ,CAST(T$RQSA AS NUMERIC(15,2))                                           AS REQUIREDSALES 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                           AS SALESAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTP)),'')                             AS SERVICETYPE 
            ,CAST("T$SPCO$1" AS NUMERIC(15,2))                                         AS SPENTCOSTS1 
            ,CAST("T$SPCO$2" AS NUMERIC(15,2))                                         AS SPENTCOSTS2 
            ,CAST("T$SPCO$3" AS NUMERIC(15,2))                                         AS SPENTCOSTS3 
            ,CAST(T$SPDI AS NUMERIC(15,2))                                           AS SPENTDISCOUNT 
            ,CAST(T$SPSA AS NUMERIC(15,2))                                           AS SPENTSALES 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT END AS DATE) AS STATISTICALDATA 
            ,CAST(T$TERM AS BIGINT)                                                  AS TERMID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                         AS TEXT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM120201") }} AS SOURCETABLE  
            /*COSTCOVERINGMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CCOV 
             ON   T$CCOV.TABLENAME  = 'TSCTM120' 
              AND T$CCOV.COLUMNNAME = 'T$CCOV' 
              AND T$CCOV.CONSTANT   = SOURCETABLE.T$CCOV 
            /*COSTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COTP 
             ON   T$COTP.TABLENAME  = 'TSCTM120' 
              AND T$COTP.COLUMNNAME = 'T$COTP' 
              AND T$COTP.CONSTANT   = SOURCETABLE.T$COTP 
            /*PERIODUNIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PERU 
             ON   T$PERU.TABLENAME  = 'TSCTM120' 
              AND T$PERU.COLUMNNAME = 'T$PERU' 
              AND T$PERU.CONSTANT   = SOURCETABLE.T$PERU 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ALLOCATEDCOSTS1 AS ALLOCATEDCOSTS1, 
        source_data.ALLOCATEDCOSTS2 AS ALLOCATEDCOSTS2, 
        source_data.ALLOCATEDCOSTS3 AS ALLOCATEDCOSTS3, 
        source_data.ALLOCATEDDISCOUNT AS ALLOCATEDDISCOUNT, 
        source_data.ALLOCATEDSALES AS ALLOCATEDSALES, 
        source_data.CEILINGAMOUNT AS CEILINGAMOUNT, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONTRACTTERM AS CONTRACTTERM, 
        source_data.COSTAMOUNT1 AS COSTAMOUNT1, 
        source_data.COSTAMOUNT2 AS COSTAMOUNT2, 
        source_data.COSTAMOUNT3 AS COSTAMOUNT3, 
        source_data.COSTCOVERINGMETHODDESCRIPTION AS COSTCOVERINGMETHODDESCRIPTION, 
        source_data.COSTCOVERINGMETHODID AS COSTCOVERINGMETHODID, 
        source_data.COSTTYPEDESCRIPTION AS COSTTYPEDESCRIPTION, 
        source_data.COSTTYPEID AS COSTTYPEID, 
        source_data.COVERAGETERMNUMBER AS COVERAGETERMNUMBER, 
        source_data.DISCOUNT AS DISCOUNT, 
        source_data.ENDDATE AS ENDDATE, 
        source_data.LIMITINGCOUNTERVALUE AS LIMITINGCOUNTERVALUE, 
        source_data.MODELITEM AS MODELITEM, 
        source_data.NUMBEROFPERIODS AS NUMBEROFPERIODS, 
        source_data.PERIODUNITDESCRIPTION AS PERIODUNITDESCRIPTION, 
        source_data.PERIODUNITID AS PERIODUNITID, 
        source_data.REQUIREDCOST1 AS REQUIREDCOST1, 
        source_data.REQUIREDCOST2 AS REQUIREDCOST2, 
        source_data.REQUIREDCOST3 AS REQUIREDCOST3, 
        source_data.REQUIREDSALES AS REQUIREDSALES, 
        source_data.SALESAMOUNT AS SALESAMOUNT, 
        source_data.SERVICETYPE AS SERVICETYPE, 
        source_data.SPENTCOSTS1 AS SPENTCOSTS1, 
        source_data.SPENTCOSTS2 AS SPENTCOSTS2, 
        source_data.SPENTCOSTS3 AS SPENTCOSTS3, 
        source_data.SPENTDISCOUNT AS SPENTDISCOUNT, 
        source_data.SPENTSALES AS SPENTSALES, 
        source_data.STATISTICALDATA AS STATISTICALDATA, 
        source_data.TERMID AS TERMID, 
        source_data.TEXT AS TEXT
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ALLOCATEDCOSTS1 as NUMBER(15,2)) as ALLOCATEDCOSTS1,
        cast(ALLOCATEDCOSTS2 as NUMBER(15,2)) as ALLOCATEDCOSTS2,
        cast(ALLOCATEDCOSTS3 as NUMBER(15,2)) as ALLOCATEDCOSTS3,
        cast(ALLOCATEDDISCOUNT as NUMBER(15,2)) as ALLOCATEDDISCOUNT,
        cast(ALLOCATEDSALES as NUMBER(15,2)) as ALLOCATEDSALES,
        cast(CEILINGAMOUNT as NUMBER(15,2)) as CEILINGAMOUNT,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONTRACTTERM as VARCHAR(3)) as CONTRACTTERM,
        cast(COSTAMOUNT1 as NUMBER(15,2)) as COSTAMOUNT1,
        cast(COSTAMOUNT2 as NUMBER(15,2)) as COSTAMOUNT2,
        cast(COSTAMOUNT3 as NUMBER(15,2)) as COSTAMOUNT3,
        cast(COSTCOVERINGMETHODDESCRIPTION as VARCHAR(16777216)) as COSTCOVERINGMETHODDESCRIPTION,
        cast(COSTCOVERINGMETHODID as NUMBER(38,0)) as COSTCOVERINGMETHODID,
        cast(COSTTYPEDESCRIPTION as VARCHAR(16777216)) as COSTTYPEDESCRIPTION,
        cast(COSTTYPEID as NUMBER(38,0)) as COSTTYPEID,
        cast(COVERAGETERMNUMBER as NUMBER(38,0)) as COVERAGETERMNUMBER,
        cast(DISCOUNT as NUMBER(15,2)) as DISCOUNT,
        cast(ENDDATE as DATE) as ENDDATE,
        cast(LIMITINGCOUNTERVALUE as NUMBER(15,2)) as LIMITINGCOUNTERVALUE,
        cast(MODELITEM as VARCHAR(47)) as MODELITEM,
        cast(NUMBEROFPERIODS as NUMBER(38,0)) as NUMBEROFPERIODS,
        cast(PERIODUNITDESCRIPTION as VARCHAR(16777216)) as PERIODUNITDESCRIPTION,
        cast(PERIODUNITID as NUMBER(38,0)) as PERIODUNITID,
        cast(REQUIREDCOST1 as NUMBER(15,2)) as REQUIREDCOST1,
        cast(REQUIREDCOST2 as NUMBER(15,2)) as REQUIREDCOST2,
        cast(REQUIREDCOST3 as NUMBER(15,2)) as REQUIREDCOST3,
        cast(REQUIREDSALES as NUMBER(15,2)) as REQUIREDSALES,
        cast(SALESAMOUNT as NUMBER(15,2)) as SALESAMOUNT,
        cast(SERVICETYPE as VARCHAR(3)) as SERVICETYPE,
        cast(SPENTCOSTS1 as NUMBER(15,2)) as SPENTCOSTS1,
        cast(SPENTCOSTS2 as NUMBER(15,2)) as SPENTCOSTS2,
        cast(SPENTCOSTS3 as NUMBER(15,2)) as SPENTCOSTS3,
        cast(SPENTDISCOUNT as NUMBER(15,2)) as SPENTDISCOUNT,
        cast(SPENTSALES as NUMBER(15,2)) as SPENTSALES,
        cast(STATISTICALDATA as DATE) as STATISTICALDATA,
        cast(TERMID as NUMBER(38,0)) as TERMID,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data