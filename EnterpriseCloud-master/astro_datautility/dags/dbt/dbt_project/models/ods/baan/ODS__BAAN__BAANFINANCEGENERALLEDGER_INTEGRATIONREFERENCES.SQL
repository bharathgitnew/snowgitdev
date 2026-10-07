/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_INTEGRATIONREFERENCES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_INTEGRATIONREFERENCES.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_INTEGRATIONREFERENCES 
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
    alias='BAANFINANCEGENERALLEDGER_INTEGRATIONREFERENCES',
    unique_key = ['FINANCIALTRANSACTIONID',
    'FROMTOID',
    'ORIGINALCOMPANY',
    'SEQUENCENUMBER_SERN',
    'TRANSACTIONORIGINID',
    'TRANSACTIONTIME']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$DAPR AS BIGINT)                                                                                                              AS APPROVALDOCUMENT 
            ,CAST(T$LAPR AS BIGINT)                                                                                                              AS APPROVALDOCUMENTLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TAPR)),'')                                                                                         AS APPROVALTRANSACTIONTYPE 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS BATCHNUMBER 
            ,CAST(CASE WHEN T$CRDT<= '1/1/1970' THEN NULL ELSE T$CRDT  END AS DATETIME) AS CREATIONDATE 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENT 
            ,CAST(T$FCOM AS INT)                                                                                                                 AS FINANCECOMPANY 
            ,T$FITR.CONSTANTDESCRIPTION                                                                                                          AS FINANCIALTRANSACTIONDESCRIPTION 
            ,CAST(T$FITR AS INT)                                                                                                                 AS FINANCIALTRANSACTIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USGR)),'')                                                                                         AS FINANCIALUSERGROUP 
            ,T$FROT.CONSTANTDESCRIPTION                                                                                                          AS FROMTODESCRIPTION 
            ,CAST(T$FROT AS INT)                                                                                                                 AS FROMTOID 
            ,T$SINT.CONSTANTDESCRIPTION                                                                                                          AS INTEGRATIONTRANSACTIONSTATUSDESCRIPTION 
            ,CAST(T$SINT AS INT)                                                                                                                 AS INTEGRATIONTRANSACTIONSTATUSID 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_ 
            ,CAST(T$PONO AS INT)                                                                                                                 AS ORDER_POSITION 
            ,CAST(T$OCOM AS INT)                                                                                                                 AS ORIGINALCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$POUS)),'')                                                                                         AS POSTEDBYUSER 
            ,CAST(CASE WHEN T$PODT<= '1/1/1970' THEN NULL ELSE T$PODT  END AS DATETIME) AS POSTINGDATE 
            ,T$PRIN.CONSTANTDESCRIPTION                                                                                                          AS PRINTEDDESCRIPTION 
            ,CAST(T$PRIN AS INT)                                                                                                                 AS PRINTEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCNO)),'')                                                                                         AS RECEIPTNUMBER 
            ,CAST(T$SEQN AS BIGINT)                                                                                                              AS RECEIPTSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RORN)),'')                                                                                         AS RELATEDORDER 
            ,CAST(T$RPON AS INT)                                                                                                                 AS RELATEDORDERPOSITION 
            ,CAST(T$RSQN AS INT)                                                                                                                 AS RELATEDORDERSEQUENCE 
            ,CAST(T$SERN AS INT)                                                                                                                 AS SEQUENCENUMBER_SERN 
            ,CAST(T$SQNB AS BIGINT)                                                                                                              AS SEQUENCENUMBER_SQNB 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TMPK)),'')                                                                                         AS TEMPORARYFIELDFORUNIQUEKEY 
            ,T$TROR.CONSTANTDESCRIPTION                                                                                                          AS TRANSACTIONORIGINDESCRIPTION 
            ,CAST(T$TROR AS INT)                                                                                                                 AS TRANSACTIONORIGINID 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRUS)),'')                                                                                         AS USER 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD418200") }} AS SOURCETABLE  
            /*FINANCIALTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FITR 
             ON   T$FITR.TABLENAME  = 'TFGLD418' 
              AND T$FITR.COLUMNNAME = 'T$FITR' 
              AND T$FITR.CONSTANT   = SOURCETABLE.T$FITR 
            /*FROMTO*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FROT 
             ON   T$FROT.TABLENAME  = 'TFGLD418' 
              AND T$FROT.COLUMNNAME = 'T$FROT' 
              AND T$FROT.CONSTANT   = SOURCETABLE.T$FROT 
            /*INTEGRATIONTRANSACTIONSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SINT 
             ON   T$SINT.TABLENAME  = 'TFGLD418' 
              AND T$SINT.COLUMNNAME = 'T$SINT' 
              AND T$SINT.CONSTANT   = SOURCETABLE.T$SINT 
            /*PRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PRIN 
             ON   T$PRIN.TABLENAME  = 'TFGLD418' 
              AND T$PRIN.COLUMNNAME = 'T$PRIN' 
              AND T$PRIN.CONSTANT   = SOURCETABLE.T$PRIN 
            /*TRANSACTIONORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TROR 
             ON   T$TROR.TABLENAME  = 'TFGLD418' 
              AND T$TROR.COLUMNNAME = 'T$TROR' 
              AND T$TROR.CONSTANT   = SOURCETABLE.T$TROR 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.APPROVALDOCUMENT AS APPROVALDOCUMENT, 
        source_data.APPROVALDOCUMENTLINE AS APPROVALDOCUMENTLINE, 
        source_data.APPROVALTRANSACTIONTYPE AS APPROVALTRANSACTIONTYPE, 
        source_data.BATCHNUMBER AS BATCHNUMBER, 
        source_data.CREATIONDATE AS CREATIONDATE, 
        source_data.DOCUMENT AS DOCUMENT, 
        source_data.FINANCECOMPANY AS FINANCECOMPANY, 
        source_data.FINANCIALTRANSACTIONDESCRIPTION AS FINANCIALTRANSACTIONDESCRIPTION, 
        source_data.FINANCIALTRANSACTIONID AS FINANCIALTRANSACTIONID, 
        source_data.FINANCIALUSERGROUP AS FINANCIALUSERGROUP, 
        source_data.FROMTODESCRIPTION AS FROMTODESCRIPTION, 
        source_data.FROMTOID AS FROMTOID, 
        source_data.INTEGRATIONTRANSACTIONSTATUSDESCRIPTION AS INTEGRATIONTRANSACTIONSTATUSDESCRIPTION, 
        source_data.INTEGRATIONTRANSACTIONSTATUSID AS INTEGRATIONTRANSACTIONSTATUSID, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.ORDER_ AS ORDER_, 
        source_data.ORDER_POSITION AS ORDER_POSITION, 
        source_data.ORIGINALCOMPANY AS ORIGINALCOMPANY, 
        source_data.POSTEDBYUSER AS POSTEDBYUSER, 
        source_data.POSTINGDATE AS POSTINGDATE, 
        source_data.PRINTEDDESCRIPTION AS PRINTEDDESCRIPTION, 
        source_data.PRINTEDID AS PRINTEDID, 
        source_data.PROJECT AS PROJECT, 
        source_data.RECEIPTNUMBER AS RECEIPTNUMBER, 
        source_data.RECEIPTSEQUENCE AS RECEIPTSEQUENCE, 
        source_data.RELATEDORDER AS RELATEDORDER, 
        source_data.RELATEDORDERPOSITION AS RELATEDORDERPOSITION, 
        source_data.RELATEDORDERSEQUENCE AS RELATEDORDERSEQUENCE, 
        source_data.SEQUENCENUMBER_SERN AS SEQUENCENUMBER_SERN, 
        source_data.SEQUENCENUMBER_SQNB AS SEQUENCENUMBER_SQNB, 
        source_data.TEMPORARYFIELDFORUNIQUEKEY AS TEMPORARYFIELDFORUNIQUEKEY, 
        source_data.TRANSACTIONORIGINDESCRIPTION AS TRANSACTIONORIGINDESCRIPTION, 
        source_data.TRANSACTIONORIGINID AS TRANSACTIONORIGINID, 
        source_data.TRANSACTIONTIME AS TRANSACTIONTIME, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE, 
        source_data.USER AS USER
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(APPROVALDOCUMENT as NUMBER(38,0)) as APPROVALDOCUMENT,
        cast(APPROVALDOCUMENTLINE as NUMBER(38,0)) as APPROVALDOCUMENTLINE,
        cast(APPROVALTRANSACTIONTYPE as VARCHAR(3)) as APPROVALTRANSACTIONTYPE,
        cast(BATCHNUMBER as NUMBER(38,0)) as BATCHNUMBER,
        cast(CREATIONDATE as TIMESTAMP_NTZ(9)) as CREATIONDATE,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(FINANCECOMPANY as NUMBER(38,0)) as FINANCECOMPANY,
        cast(FINANCIALTRANSACTIONDESCRIPTION as VARCHAR(16777216)) as FINANCIALTRANSACTIONDESCRIPTION,
        cast(FINANCIALTRANSACTIONID as NUMBER(38,0)) as FINANCIALTRANSACTIONID,
        cast(FINANCIALUSERGROUP as VARCHAR(6)) as FINANCIALUSERGROUP,
        cast(FROMTODESCRIPTION as VARCHAR(16777216)) as FROMTODESCRIPTION,
        cast(FROMTOID as NUMBER(38,0)) as FROMTOID,
        cast(INTEGRATIONTRANSACTIONSTATUSDESCRIPTION as VARCHAR(16777216)) as INTEGRATIONTRANSACTIONSTATUSDESCRIPTION,
        cast(INTEGRATIONTRANSACTIONSTATUSID as NUMBER(38,0)) as INTEGRATIONTRANSACTIONSTATUSID,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(ORDER_ as VARCHAR(9)) as ORDER_,
        cast(ORDER_POSITION as NUMBER(38,0)) as ORDER_POSITION,
        cast(ORIGINALCOMPANY as NUMBER(38,0)) as ORIGINALCOMPANY,
        cast(POSTEDBYUSER as VARCHAR(16)) as POSTEDBYUSER,
        cast(POSTINGDATE as TIMESTAMP_NTZ(9)) as POSTINGDATE,
        cast(PRINTEDDESCRIPTION as VARCHAR(16777216)) as PRINTEDDESCRIPTION,
        cast(PRINTEDID as NUMBER(38,0)) as PRINTEDID,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(RECEIPTNUMBER as VARCHAR(9)) as RECEIPTNUMBER,
        cast(RECEIPTSEQUENCE as NUMBER(38,0)) as RECEIPTSEQUENCE,
        cast(RELATEDORDER as VARCHAR(9)) as RELATEDORDER,
        cast(RELATEDORDERPOSITION as NUMBER(38,0)) as RELATEDORDERPOSITION,
        cast(RELATEDORDERSEQUENCE as NUMBER(38,0)) as RELATEDORDERSEQUENCE,
        cast(SEQUENCENUMBER_SERN as NUMBER(38,0)) as SEQUENCENUMBER_SERN,
        cast(SEQUENCENUMBER_SQNB as NUMBER(38,0)) as SEQUENCENUMBER_SQNB,
        cast(TEMPORARYFIELDFORUNIQUEKEY as VARCHAR(9)) as TEMPORARYFIELDFORUNIQUEKEY,
        cast(TRANSACTIONORIGINDESCRIPTION as VARCHAR(16777216)) as TRANSACTIONORIGINDESCRIPTION,
        cast(TRANSACTIONORIGINID as NUMBER(38,0)) as TRANSACTIONORIGINID,
        cast(TRANSACTIONTIME as TIMESTAMP_NTZ(9)) as TRANSACTIONTIME,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(USER as VARCHAR(16)) as USER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data