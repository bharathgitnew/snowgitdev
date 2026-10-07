/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_PERIODS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_PERIODS.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_PERIODS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:54 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEGENERALLEDGER_PERIODS',
    unique_key = ['PERIOD',
    'PERIODTYPEID',
    'YEAR']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,200                                                                       AS _COMPANYID 
            ,T$CORR.CONSTANTDESCRIPTION                                              AS CORRECTIONPERIODDESCRIPTION 
            ,CAST(T$CORR AS INT)                                                     AS CORRECTIONPERIODID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS DESCRIPTION 
            ,CAST(T$PRNO AS INT)                                                     AS PERIOD 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT END AS DATE) AS PERIODSTARTDATE 
            ,T$PTYP.CONSTANTDESCRIPTION                                              AS PERIODTYPEDESCRIPTION 
            ,CAST(T$PTYP AS INT)                                                     AS PERIODTYPEID 
            ,CAST(T$YEAR AS INT)                                                     AS YEAR 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD005200") }} AS SOURCETABLE  
            /*CORRECTIONPERIOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CORR 
             ON   T$CORR.TABLENAME  = 'TFGLD005' 
              AND T$CORR.COLUMNNAME = 'T$CORR' 
              AND T$CORR.CONSTANT   = SOURCETABLE.T$CORR 
            /*PERIODTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PTYP 
             ON   T$PTYP.TABLENAME  = 'TFGLD005' 
              AND T$PTYP.COLUMNNAME = 'T$PTYP' 
              AND T$PTYP.CONSTANT   = SOURCETABLE.T$PTYP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CORRECTIONPERIODDESCRIPTION AS CORRECTIONPERIODDESCRIPTION, 
        source_data.CORRECTIONPERIODID AS CORRECTIONPERIODID, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.PERIOD AS PERIOD, 
        source_data.PERIODSTARTDATE AS PERIODSTARTDATE, 
        source_data.PERIODTYPEDESCRIPTION AS PERIODTYPEDESCRIPTION, 
        source_data.PERIODTYPEID AS PERIODTYPEID, 
        source_data.YEAR AS YEAR
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CORRECTIONPERIODDESCRIPTION as VARCHAR(16777216)) as CORRECTIONPERIODDESCRIPTION,
        cast(CORRECTIONPERIODID as NUMBER(38,0)) as CORRECTIONPERIODID,
        cast(DESCRIPTION as VARCHAR(15)) as DESCRIPTION,
        cast(PERIOD as NUMBER(38,0)) as PERIOD,
        cast(PERIODSTARTDATE as DATE) as PERIODSTARTDATE,
        cast(PERIODTYPEDESCRIPTION as VARCHAR(16777216)) as PERIODTYPEDESCRIPTION,
        cast(PERIODTYPEID as NUMBER(38,0)) as PERIODTYPEID,
        cast(YEAR as NUMBER(38,0)) as YEAR,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data