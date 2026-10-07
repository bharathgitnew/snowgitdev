/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICE_AND_SHIPMENTIDLINKAGE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICE_AND_SHIPMENTIDLINKAGE.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICE_AND_SHIPMENTIDLINKAGE 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:56 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICE_AND_SHIPMENTIDLINKAGE',
    unique_key = ['_COMPANYID',
    'COMMERCIALINVOICE',
    'SHIPMENTIDENTIFICATION']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COIN)),'')                                                                                         AS COMMERCIALINVOICE 
            ,CAST(CASE WHEN T$CDTE<= '1/1/1970' THEN NULL ELSE T$CDTE  END AS DATETIME) AS CREATEDATE 
            ,T$FINV.CONSTANTDESCRIPTION                                                                                                          AS FINALINVOICEDESCRIPTION 
            ,CAST(T$FINV AS INT)                                                                                                                 AS FINALINVOICEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                         AS SHIPMENTIDENTIFICATION 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINH915201") }} AS SOURCETABLE  
            /*FINALINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FINV 
             ON   T$FINV.TABLENAME  = 'WHINH915' 
              AND T$FINV.COLUMNNAME = 'T$FINV' 
              AND T$FINV.CONSTANT   = SOURCETABLE.T$FINV 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.COMMERCIALINVOICE AS COMMERCIALINVOICE, 
        source_data.CREATEDATE AS CREATEDATE, 
        source_data.FINALINVOICEDESCRIPTION AS FINALINVOICEDESCRIPTION, 
        source_data.FINALINVOICEID AS FINALINVOICEID, 
        source_data.SHIPMENTIDENTIFICATION AS SHIPMENTIDENTIFICATION
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(COMMERCIALINVOICE as VARCHAR(10)) as COMMERCIALINVOICE,
        cast(CREATEDATE as TIMESTAMP_NTZ(9)) as CREATEDATE,
        cast(FINALINVOICEDESCRIPTION as VARCHAR(16777216)) as FINALINVOICEDESCRIPTION,
        cast(FINALINVOICEID as NUMBER(38,0)) as FINALINVOICEID,
        cast(SHIPMENTIDENTIFICATION as VARCHAR(9)) as SHIPMENTIDENTIFICATION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data