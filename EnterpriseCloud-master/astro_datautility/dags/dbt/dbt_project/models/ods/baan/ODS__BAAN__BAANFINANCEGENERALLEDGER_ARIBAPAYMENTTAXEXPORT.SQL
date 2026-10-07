/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTTAXEXPORT.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTTAXEXPORT.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_ARIBAPAYMENTTAXEXPORT 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:53 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTTAXEXPORT',
    unique_key = ['PAYMENTID',
    'POSITIONNUMBER',
    'SEQUENCE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AINS)),'')                                                                                         AS ACCOUNTINSTRUCTION 
            ,T$ACCR.CONSTANTDESCRIPTION                                                                                                          AS ACCRUALDESCRIPTION 
            ,CAST(T$ACCR AS INT)                                                                                                                 AS ACCRUALID 
            ,CAST(T$AAMT AS NUMERIC(15,2))                                                                                                       AS ACCURALTAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TREG)),'')                                                                                         AS BUYERTAXREGISTRATIONNUMBER 
            ,T$DEDU.CONSTANTDESCRIPTION                                                                                                          AS DEDUCTIBLEDESCRIPTION 
            ,CAST(T$DEDU AS INT)                                                                                                                 AS DEDUCTIBLEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DBCR)),'')                                                                                         AS DRCR 
            ,CAST(T$RATE AS NUMERIC(15,2))                                                                                                       AS EXPECTEDTAXRATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ICIT)),'')                                                                                         AS INVOICECITATION 
            ,CAST(T$ILIN AS INT)                                                                                                                 AS INVOICELINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITXT)),'')                                                                                         AS ITEMTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LNUM)),'')                                                                                         AS REFERENCELINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SREG)),'')                                                                                         AS SELLERTAXREGISTRATIONNUMBER 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,CAST(T$TXAM AS NUMERIC(15,2))                                                                                                       AS TAXABLEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKEY)),'')                                                                                         AS TAXACCOUNTKEY 
            ,CAST(T$TARD AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTINERPPRECISION 
            ,CAST(T$TAMT AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTINPAYMENTCURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TAXA)),'')                                                                                         AS TAXAUTHORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD718200") }} AS SOURCETABLE  
            /*ACCRUAL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACCR 
             ON   T$ACCR.TABLENAME  = 'TFGLD718' 
              AND T$ACCR.COLUMNNAME = 'T$ACCR' 
              AND T$ACCR.CONSTANT   = SOURCETABLE.T$ACCR 
            /*DEDUCTIBLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEDU 
             ON   T$DEDU.TABLENAME  = 'TFGLD718' 
              AND T$DEDU.COLUMNNAME = 'T$DEDU' 
              AND T$DEDU.CONSTANT   = SOURCETABLE.T$DEDU 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD718' 
              AND T$STUS.COLUMNNAME = 'T$STUS' 
              AND T$STUS.CONSTANT   = SOURCETABLE.T$STUS 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AINS)),'')                                                                                         AS ACCOUNTINSTRUCTION 
            ,T$ACCR.CONSTANTDESCRIPTION                                                                                                          AS ACCRUALDESCRIPTION 
            ,CAST(T$ACCR AS INT)                                                                                                                 AS ACCRUALID 
            ,CAST(T$AAMT AS NUMERIC(15,2))                                                                                                       AS ACCURALTAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TREG)),'')                                                                                         AS BUYERTAXREGISTRATIONNUMBER 
            ,T$DEDU.CONSTANTDESCRIPTION                                                                                                          AS DEDUCTIBLEDESCRIPTION 
            ,CAST(T$DEDU AS INT)                                                                                                                 AS DEDUCTIBLEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DBCR)),'')                                                                                         AS DRCR 
            ,CAST(T$RATE AS NUMERIC(15,2))                                                                                                       AS EXPECTEDTAXRATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ICIT)),'')                                                                                         AS INVOICECITATION 
            ,CAST(T$ILIN AS INT)                                                                                                                 AS INVOICELINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITXT)),'')                                                                                         AS ITEMTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LNUM)),'')                                                                                         AS REFERENCELINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SREG)),'')                                                                                         AS SELLERTAXREGISTRATIONNUMBER 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,CAST(T$TXAM AS NUMERIC(15,2))                                                                                                       AS TAXABLEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKEY)),'')                                                                                         AS TAXACCOUNTKEY 
            ,CAST(T$TARD AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTINERPPRECISION 
            ,CAST(T$TAMT AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTINPAYMENTCURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TAXA)),'')                                                                                         AS TAXAUTHORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD718201") }} AS SOURCETABLE  
            /*ACCRUAL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACCR 
             ON   T$ACCR.TABLENAME  = 'TFGLD718' 
              AND T$ACCR.COLUMNNAME = 'T$ACCR' 
              AND T$ACCR.CONSTANT   = SOURCETABLE.T$ACCR 
            /*DEDUCTIBLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEDU 
             ON   T$DEDU.TABLENAME  = 'TFGLD718' 
              AND T$DEDU.COLUMNNAME = 'T$DEDU' 
              AND T$DEDU.CONSTANT   = SOURCETABLE.T$DEDU 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD718' 
              AND T$STUS.COLUMNNAME = 'T$STUS' 
              AND T$STUS.CONSTANT   = SOURCETABLE.T$STUS 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCOUNTINSTRUCTION AS ACCOUNTINSTRUCTION, 
        source_data.ACCRUALDESCRIPTION AS ACCRUALDESCRIPTION, 
        source_data.ACCRUALID AS ACCRUALID, 
        source_data.ACCURALTAXAMOUNT AS ACCURALTAXAMOUNT, 
        source_data.BUYERTAXREGISTRATIONNUMBER AS BUYERTAXREGISTRATIONNUMBER, 
        source_data.DEDUCTIBLEDESCRIPTION AS DEDUCTIBLEDESCRIPTION, 
        source_data.DEDUCTIBLEID AS DEDUCTIBLEID, 
        source_data.DRCR AS DRCR, 
        source_data.EXPECTEDTAXRATE AS EXPECTEDTAXRATE, 
        source_data.INVOICECITATION AS INVOICECITATION, 
        source_data.INVOICELINENUMBER AS INVOICELINENUMBER, 
        source_data.ITEMTEXT AS ITEMTEXT, 
        source_data.PAYMENTID AS PAYMENTID, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.PROCESSDATE AS PROCESSDATE, 
        source_data.REFERENCELINENUMBER AS REFERENCELINENUMBER, 
        source_data.SELLERTAXREGISTRATIONNUMBER AS SELLERTAXREGISTRATIONNUMBER, 
        source_data.SEQUENCE AS SEQUENCE, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.TAXABLEAMOUNT AS TAXABLEAMOUNT, 
        source_data.TAXACCOUNTKEY AS TAXACCOUNTKEY, 
        source_data.TAXAMOUNTINERPPRECISION AS TAXAMOUNTINERPPRECISION, 
        source_data.TAXAMOUNTINPAYMENTCURRENCY AS TAXAMOUNTINPAYMENTCURRENCY, 
        source_data.TAXAUTHORITY AS TAXAUTHORITY, 
        source_data.TAXCODE AS TAXCODE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACCOUNTINSTRUCTION as VARCHAR(50)) as ACCOUNTINSTRUCTION,
        cast(ACCRUALDESCRIPTION as VARCHAR(16777216)) as ACCRUALDESCRIPTION,
        cast(ACCRUALID as NUMBER(38,0)) as ACCRUALID,
        cast(ACCURALTAXAMOUNT as NUMBER(15,2)) as ACCURALTAXAMOUNT,
        cast(BUYERTAXREGISTRATIONNUMBER as VARCHAR(50)) as BUYERTAXREGISTRATIONNUMBER,
        cast(DEDUCTIBLEDESCRIPTION as VARCHAR(16777216)) as DEDUCTIBLEDESCRIPTION,
        cast(DEDUCTIBLEID as NUMBER(38,0)) as DEDUCTIBLEID,
        cast(DRCR as VARCHAR(10)) as DRCR,
        cast(EXPECTEDTAXRATE as NUMBER(15,2)) as EXPECTEDTAXRATE,
        cast(INVOICECITATION as VARCHAR(50)) as INVOICECITATION,
        cast(INVOICELINENUMBER as NUMBER(38,0)) as INVOICELINENUMBER,
        cast(ITEMTEXT as VARCHAR(999)) as ITEMTEXT,
        cast(PAYMENTID as VARCHAR(50)) as PAYMENTID,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(PROCESSDATE as TIMESTAMP_NTZ(9)) as PROCESSDATE,
        cast(REFERENCELINENUMBER as VARCHAR(50)) as REFERENCELINENUMBER,
        cast(SELLERTAXREGISTRATIONNUMBER as VARCHAR(50)) as SELLERTAXREGISTRATIONNUMBER,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(TAXABLEAMOUNT as NUMBER(15,2)) as TAXABLEAMOUNT,
        cast(TAXACCOUNTKEY as VARCHAR(50)) as TAXACCOUNTKEY,
        cast(TAXAMOUNTINERPPRECISION as NUMBER(15,2)) as TAXAMOUNTINERPPRECISION,
        cast(TAXAMOUNTINPAYMENTCURRENCY as NUMBER(15,2)) as TAXAMOUNTINPAYMENTCURRENCY,
        cast(TAXAUTHORITY as VARCHAR(50)) as TAXAUTHORITY,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data