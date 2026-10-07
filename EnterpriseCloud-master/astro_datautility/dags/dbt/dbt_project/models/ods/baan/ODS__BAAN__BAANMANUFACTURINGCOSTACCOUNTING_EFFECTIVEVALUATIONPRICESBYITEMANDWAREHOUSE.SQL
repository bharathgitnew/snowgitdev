/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANMANUFACTURINGCOSTACCOUNTING_EFFECTIVEVALUATIONPRICESBYITEMANDWAREHOUSE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANMANUFACTURINGCOSTACCOUNTING_EFFECTIVEVALUATIONPRICESBYITEMANDWAREHOUSE.SQL 
-materialized incremental
-alias BAANMANUFACTURINGCOSTACCOUNTING_EFFECTIVEVALUATIONPRICESBYITEMANDWAREHOUSE 
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
    alias='BAANMANUFACTURINGCOSTACCOUNTING_EFFECTIVEVALUATIONPRICESBYITEMANDWAREHOUSE',
    unique_key = ['COSTCOMPONENT',
    'EFFECTIVEDATE',
    'ITEM',
    'WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                         AS COSTCOMPONENT 
            ,CAST(CASE WHEN T$INDT<= '1/1/1970' THEN NULL ELSE T$INDT  END AS DATETIME) AS EFFECTIVEDATE 
            ,CAST("T$ISSF$1" AS NUMERIC(15,2))                                                                                                     AS FIXEDISSUEVALUATIONPRICE1 
            ,CAST("T$ISSF$2" AS NUMERIC(15,2))                                                                                                     AS FIXEDISSUEVALUATIONPRICE2 
            ,CAST("T$ISSF$3" AS NUMERIC(15,2))                                                                                                     AS FIXEDISSUEVALUATIONPRICE3 
            ,CAST("T$RECF$1" AS NUMERIC(15,2))                                                                                                     AS FIXEDRECEIPTVALUATIONPRICE1 
            ,CAST("T$RECF$2" AS NUMERIC(15,2))                                                                                                     AS FIXEDRECEIPTVALUATIONPRICE2 
            ,CAST("T$RECF$3" AS NUMERIC(15,2))                                                                                                     AS FIXEDRECEIPTVALUATIONPRICE3 
            ,CAST("T$ISSA$1" AS NUMERIC(15,2))                                                                                                     AS ISSUEAMOUNT1 
            ,CAST("T$ISSA$2" AS NUMERIC(15,2))                                                                                                     AS ISSUEAMOUNT2 
            ,CAST("T$ISSA$3" AS NUMERIC(15,2))                                                                                                     AS ISSUEAMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(T$NUNI AS NUMERIC(15,2))                                                                                                       AS NUMBEROFUNITS 
            ,CAST("T$RECA$1" AS NUMERIC(15,2))                                                                                                     AS RECEIPTAMOUNT1 
            ,CAST("T$RECA$2" AS NUMERIC(15,2))                                                                                                     AS RECEIPTAMOUNT2 
            ,CAST("T$RECA$3" AS NUMERIC(15,2))                                                                                                     AS RECEIPTAMOUNT3 
            ,CAST("T$ISSV$1" AS NUMERIC(15,2))                                                                                                     AS VARIABLEISSUEVALUATIONPRICE1 
            ,CAST("T$ISSV$2" AS NUMERIC(15,2))                                                                                                     AS VARIABLEISSUEVALUATIONPRICE2 
            ,CAST("T$ISSV$3" AS NUMERIC(15,2))                                                                                                     AS VARIABLEISSUEVALUATIONPRICE3 
            ,CAST("T$RECV$1" AS NUMERIC(15,2))                                                                                                     AS VARIABLERECEIPTVALUATIONPRICE1 
            ,CAST("T$RECV$2" AS NUMERIC(15,2))                                                                                                     AS VARIABLERECEIPTVALUATIONPRICE2 
            ,CAST("T$RECV$3" AS NUMERIC(15,2))                                                                                                     AS VARIABLERECEIPTVALUATIONPRICE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTICPR340201") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.FIXEDISSUEVALUATIONPRICE1 AS FIXEDISSUEVALUATIONPRICE1, 
        source_data.FIXEDISSUEVALUATIONPRICE2 AS FIXEDISSUEVALUATIONPRICE2, 
        source_data.FIXEDISSUEVALUATIONPRICE3 AS FIXEDISSUEVALUATIONPRICE3, 
        source_data.FIXEDRECEIPTVALUATIONPRICE1 AS FIXEDRECEIPTVALUATIONPRICE1, 
        source_data.FIXEDRECEIPTVALUATIONPRICE2 AS FIXEDRECEIPTVALUATIONPRICE2, 
        source_data.FIXEDRECEIPTVALUATIONPRICE3 AS FIXEDRECEIPTVALUATIONPRICE3, 
        source_data.ISSUEAMOUNT1 AS ISSUEAMOUNT1, 
        source_data.ISSUEAMOUNT2 AS ISSUEAMOUNT2, 
        source_data.ISSUEAMOUNT3 AS ISSUEAMOUNT3, 
        source_data.ITEM AS ITEM, 
        source_data.NUMBEROFUNITS AS NUMBEROFUNITS, 
        source_data.RECEIPTAMOUNT1 AS RECEIPTAMOUNT1, 
        source_data.RECEIPTAMOUNT2 AS RECEIPTAMOUNT2, 
        source_data.RECEIPTAMOUNT3 AS RECEIPTAMOUNT3, 
        source_data.VARIABLEISSUEVALUATIONPRICE1 AS VARIABLEISSUEVALUATIONPRICE1, 
        source_data.VARIABLEISSUEVALUATIONPRICE2 AS VARIABLEISSUEVALUATIONPRICE2, 
        source_data.VARIABLEISSUEVALUATIONPRICE3 AS VARIABLEISSUEVALUATIONPRICE3, 
        source_data.VARIABLERECEIPTVALUATIONPRICE1 AS VARIABLERECEIPTVALUATIONPRICE1, 
        source_data.VARIABLERECEIPTVALUATIONPRICE2 AS VARIABLERECEIPTVALUATIONPRICE2, 
        source_data.VARIABLERECEIPTVALUATIONPRICE3 AS VARIABLERECEIPTVALUATIONPRICE3, 
        source_data.WAREHOUSE AS WAREHOUSE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(EFFECTIVEDATE as TIMESTAMP_NTZ(9)) as EFFECTIVEDATE,
        cast(FIXEDISSUEVALUATIONPRICE1 as NUMBER(15,2)) as FIXEDISSUEVALUATIONPRICE1,
        cast(FIXEDISSUEVALUATIONPRICE2 as NUMBER(15,2)) as FIXEDISSUEVALUATIONPRICE2,
        cast(FIXEDISSUEVALUATIONPRICE3 as NUMBER(15,2)) as FIXEDISSUEVALUATIONPRICE3,
        cast(FIXEDRECEIPTVALUATIONPRICE1 as NUMBER(15,2)) as FIXEDRECEIPTVALUATIONPRICE1,
        cast(FIXEDRECEIPTVALUATIONPRICE2 as NUMBER(15,2)) as FIXEDRECEIPTVALUATIONPRICE2,
        cast(FIXEDRECEIPTVALUATIONPRICE3 as NUMBER(15,2)) as FIXEDRECEIPTVALUATIONPRICE3,
        cast(ISSUEAMOUNT1 as NUMBER(15,2)) as ISSUEAMOUNT1,
        cast(ISSUEAMOUNT2 as NUMBER(15,2)) as ISSUEAMOUNT2,
        cast(ISSUEAMOUNT3 as NUMBER(15,2)) as ISSUEAMOUNT3,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(NUMBEROFUNITS as NUMBER(15,2)) as NUMBEROFUNITS,
        cast(RECEIPTAMOUNT1 as NUMBER(15,2)) as RECEIPTAMOUNT1,
        cast(RECEIPTAMOUNT2 as NUMBER(15,2)) as RECEIPTAMOUNT2,
        cast(RECEIPTAMOUNT3 as NUMBER(15,2)) as RECEIPTAMOUNT3,
        cast(VARIABLEISSUEVALUATIONPRICE1 as NUMBER(15,2)) as VARIABLEISSUEVALUATIONPRICE1,
        cast(VARIABLEISSUEVALUATIONPRICE2 as NUMBER(15,2)) as VARIABLEISSUEVALUATIONPRICE2,
        cast(VARIABLEISSUEVALUATIONPRICE3 as NUMBER(15,2)) as VARIABLEISSUEVALUATIONPRICE3,
        cast(VARIABLERECEIPTVALUATIONPRICE1 as NUMBER(15,2)) as VARIABLERECEIPTVALUATIONPRICE1,
        cast(VARIABLERECEIPTVALUATIONPRICE2 as NUMBER(15,2)) as VARIABLERECEIPTVALUATIONPRICE2,
        cast(VARIABLERECEIPTVALUATIONPRICE3 as NUMBER(15,2)) as VARIABLERECEIPTVALUATIONPRICE3,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data