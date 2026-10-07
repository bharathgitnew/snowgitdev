/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_DIMENSIONLEDGERACCOUNTTOTALS_DATAWAREHOUSE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_DIMENSIONLEDGERACCOUNTTOTALS_DATAWAREHOUSE.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_DIMENSIONLEDGERACCOUNTTOTALS_DATAWAREHOUSE 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 10:15:24 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='BAANFINANCEGENERALLEDGER_DIMENSIONLEDGERACCOUNTTOTALS_DATAWAREHOUSE',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,200                                                                       AS _COMPANYID 
            ,CAST(T$CBAL AS NUMERIC(15,2))                                           AS CLOSINGBALANCE 
            ,CAST(T$CONO AS INT)                                                     AS COMPANYNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                             AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                             AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                             AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                             AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                             AS DIMENSION5 
            ,T$DUAC.CONSTANTDESCRIPTION                                              AS DUALACCOUNTINGINDICATORDESCRIPTION 
            ,CAST(T$DUAC AS INT)                                                     AS DUALACCOUNTINGINDICATORID 
            ,CAST(T$FCCH AS NUMERIC(15,2))                                           AS FINLCRAMOUNTCURRQUARTER 
            ,CAST(T$FCPH AS NUMERIC(15,2))                                           AS FINLCRAMOUNTPREVQUARTER 
            ,CAST(T$FDCH AS NUMERIC(15,2))                                           AS FINLDRAMOUNTCURRQUARTER 
            ,CAST(T$FDPH AS NUMERIC(15,2))                                           AS FINLDRAMOUNTPREVQUARTER 
            ,CAST(T$YEAR AS INT)                                                     AS FISCALYEAR 
            ,CAST(CASE WHEN T$UPDT<= '1/1/1970' THEN NULL ELSE T$UPDT END AS DATE) AS LASTMAINTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USER)),'')                             AS LASTMODIFICATIONBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                             AS LEDGERACCOUNT 
            ,CAST(T$OBAH AS NUMERIC(15,2))                                           AS OPENINGBALANCE 
            ,CAST(T$PRNO AS INT)                                                     AS PERIODNUMBER 
            ,T$PTYP.CONSTANTDESCRIPTION                                              AS PERIODTYPEDESCRIPTION 
            ,CAST(T$PTYP AS INT)                                                     AS PERIODTYPEID 
        -- 
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD736200") }}
        AS SOURCETABLE  
            /*DUALACCOUNTINGINDICATOR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DUAC 
             ON   T$DUAC.TABLENAME  = 'TFGLD736' 
              AND T$DUAC.COLUMNNAME = 'T$DUAC' 
              AND T$DUAC.CONSTANT   = SOURCETABLE.T$DUAC 
            /*PERIODTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PTYP 
             ON   T$PTYP.TABLENAME  = 'TFGLD736' 
              AND T$PTYP.COLUMNNAME = 'T$PTYP' 
              AND T$PTYP.CONSTANT   = SOURCETABLE.T$PTYP 
      --  {% if is_incremental() %} WHERE SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,201                                                                       AS _COMPANYID 
            ,CAST(T$CBAL AS NUMERIC(15,2))                                           AS CLOSINGBALANCE 
            ,CAST(T$CONO AS INT)                                                     AS COMPANYNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                             AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                             AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                             AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                             AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                             AS DIMENSION5 
            ,T$DUAC.CONSTANTDESCRIPTION                                              AS DUALACCOUNTINGINDICATORDESCRIPTION 
            ,CAST(T$DUAC AS INT)                                                     AS DUALACCOUNTINGINDICATORID 
            ,CAST(T$FCCH AS NUMERIC(15,2))                                           AS FINLCRAMOUNTCURRQUARTER 
            ,CAST(T$FCPH AS NUMERIC(15,2))                                           AS FINLCRAMOUNTPREVQUARTER 
            ,CAST(T$FDCH AS NUMERIC(15,2))                                           AS FINLDRAMOUNTCURRQUARTER 
            ,CAST(T$FDPH AS NUMERIC(15,2))                                           AS FINLDRAMOUNTPREVQUARTER 
            ,CAST(T$YEAR AS INT)                                                     AS FISCALYEAR 
            ,CAST(CASE WHEN T$UPDT<= '1/1/1970' THEN NULL ELSE T$UPDT END AS DATE) AS LASTMAINTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USER)),'')                             AS LASTMODIFICATIONBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                             AS LEDGERACCOUNT 
            ,CAST(T$OBAH AS NUMERIC(15,2))                                           AS OPENINGBALANCE 
            ,CAST(T$PRNO AS INT)                                                     AS PERIODNUMBER 
            ,T$PTYP.CONSTANTDESCRIPTION                                              AS PERIODTYPEDESCRIPTION 
            ,CAST(T$PTYP AS INT)                                                     AS PERIODTYPEID 
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD736201") }} 
        AS SOURCETABLE  
            /*DUALACCOUNTINGINDICATOR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DUAC 
             ON   T$DUAC.TABLENAME  = 'TFGLD736' 
              AND T$DUAC.COLUMNNAME = 'T$DUAC' 
              AND T$DUAC.CONSTANT   = SOURCETABLE.T$DUAC 
            /*PERIODTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PTYP 
             ON   T$PTYP.TABLENAME  = 'TFGLD736' 
              AND T$PTYP.COLUMNNAME = 'T$PTYP' 
              AND T$PTYP.CONSTANT   = SOURCETABLE.T$PTYP 
       -- {% if is_incremental() %} WHERE SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data.CLOSINGBALANCE, 
        source_data.COMPANYNUMBER, 
        source_data.DIMENSION1, 
        source_data.DIMENSION2, 
        source_data.DIMENSION3, 
        source_data.DIMENSION4, 
        source_data.DIMENSION5, 
        source_data.DUALACCOUNTINGINDICATORDESCRIPTION, 
        source_data.DUALACCOUNTINGINDICATORID, 
        source_data.FINLCRAMOUNTCURRQUARTER, 
        source_data.FINLCRAMOUNTPREVQUARTER, 
        source_data.FINLDRAMOUNTCURRQUARTER, 
        source_data.FINLDRAMOUNTPREVQUARTER, 
        source_data.FISCALYEAR, 
        source_data.LASTMAINTDATE, 
        source_data.LASTMODIFICATIONBY, 
        source_data.LEDGERACCOUNT, 
        source_data.OPENINGBALANCE, 
        source_data.PERIODNUMBER, 
        source_data.PERIODTYPEDESCRIPTION, 
        source_data.PERIODTYPEID, 
        source_data._CAPTUREDATETIME, 
        source_data._COMPANYID 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CLOSINGBALANCE as NUMBER(15,2)) as CLOSINGBALANCE,
        cast(COMPANYNUMBER as NUMBER(38,0)) as COMPANYNUMBER,
        cast(DIMENSION1 as VARCHAR(6)) as DIMENSION1,
        cast(DIMENSION2 as VARCHAR(6)) as DIMENSION2,
        cast(DIMENSION3 as VARCHAR(6)) as DIMENSION3,
        cast(DIMENSION4 as VARCHAR(6)) as DIMENSION4,
        cast(DIMENSION5 as VARCHAR(6)) as DIMENSION5,
        cast(DUALACCOUNTINGINDICATORDESCRIPTION as VARCHAR(16777216)) as DUALACCOUNTINGINDICATORDESCRIPTION,
        cast(DUALACCOUNTINGINDICATORID as NUMBER(38,0)) as DUALACCOUNTINGINDICATORID,
        cast(FINLCRAMOUNTCURRQUARTER as NUMBER(15,2)) as FINLCRAMOUNTCURRQUARTER,
        cast(FINLCRAMOUNTPREVQUARTER as NUMBER(15,2)) as FINLCRAMOUNTPREVQUARTER,
        cast(FINLDRAMOUNTCURRQUARTER as NUMBER(15,2)) as FINLDRAMOUNTCURRQUARTER,
        cast(FINLDRAMOUNTPREVQUARTER as NUMBER(15,2)) as FINLDRAMOUNTPREVQUARTER,
        cast(FISCALYEAR as NUMBER(38,0)) as FISCALYEAR,
        cast(LASTMAINTDATE as DATE) as LASTMAINTDATE,
        cast(LASTMODIFICATIONBY as VARCHAR(16)) as LASTMODIFICATIONBY,
        cast(LEDGERACCOUNT as VARCHAR(12)) as LEDGERACCOUNT,
        cast(OPENINGBALANCE as NUMBER(15,2)) as OPENINGBALANCE,
        cast(PERIODNUMBER as NUMBER(38,0)) as PERIODNUMBER,
        cast(PERIODTYPEDESCRIPTION as VARCHAR(16777216)) as PERIODTYPEDESCRIPTION,
        cast(PERIODTYPEID as NUMBER(38,0)) as PERIODTYPEID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data