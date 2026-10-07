/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_PROJECTREVENUEANDCOSTACCRUALS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_PROJECTREVENUEANDCOSTACCRUALS.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_PROJECTREVENUEANDCOSTACCRUALS 
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
    alias='BAANFINANCEGENERALLEDGER_PROJECTREVENUEANDCOSTACCRUALS',
    unique_key = ['_COMPANYID',
    'DOCUMENT',
    'LINENUMBER_LINO',
    'POSITION',
    'PROJECT',
    'SALESORDER',
    'SEQUENCENUMBER',
    'TRANSACTIONTYPE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                         AS COSTCOMPONENT 
            ,CAST(CASE WHEN T$CRDT<= '1/1/1970' THEN NULL ELSE T$CRDT  END AS DATETIME) AS CREATIONDATE 
            ,T$DBCR.CONSTANTDESCRIPTION                                                                                                          AS DEBITCREDITDESCRIPTION 
            ,CAST(T$DBCR AS INT)                                                                                                                 AS DEBITCREDITID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENT 
            ,T$FITR.CONSTANTDESCRIPTION                                                                                                          AS FINANCIALTRANSACTIONDESCRIPTION 
            ,CAST(T$FITR AS INT)                                                                                                                 AS FINANCIALTRANSACTIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER_LINO 
            ,CAST(T$RLIN AS BIGINT)                                                                                                              AS LINENUMBER_RLIN 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,CAST(CASE WHEN T$RDAT<= '1/1/1970' THEN NULL ELSE T$RDAT  END AS DATETIME) AS RECONCILIATIONDATE 
            ,CAST(T$RDOC AS BIGINT)                                                                                                              AS RECONCILIATIONDOCUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RECONCILIATIONTRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SALESORDER 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,T$TROR.CONSTANTDESCRIPTION                                                                                                          AS TRANSACTIONORIGINDESCRIPTION 
            ,CAST(T$TROR AS INT)                                                                                                                 AS TRANSACTIONORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD928201") }} AS SOURCETABLE  
            /*DEBITCREDIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DBCR 
             ON   T$DBCR.TABLENAME  = 'TFGLD928' 
              AND T$DBCR.COLUMNNAME = 'T$DBCR' 
              AND T$DBCR.CONSTANT   = SOURCETABLE.T$DBCR 
            /*FINANCIALTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FITR 
             ON   T$FITR.TABLENAME  = 'TFGLD928' 
              AND T$FITR.COLUMNNAME = 'T$FITR' 
              AND T$FITR.CONSTANT   = SOURCETABLE.T$FITR 
            /*TRANSACTIONORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TROR 
             ON   T$TROR.TABLENAME  = 'TFGLD928' 
              AND T$TROR.COLUMNNAME = 'T$TROR' 
              AND T$TROR.CONSTANT   = SOURCETABLE.T$TROR 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNT AS AMOUNT, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.CREATIONDATE AS CREATIONDATE, 
        source_data.DEBITCREDITDESCRIPTION AS DEBITCREDITDESCRIPTION, 
        source_data.DEBITCREDITID AS DEBITCREDITID, 
        source_data.DIMENSION1 AS DIMENSION1, 
        source_data.DIMENSION2 AS DIMENSION2, 
        source_data.DIMENSION3 AS DIMENSION3, 
        source_data.DIMENSION4 AS DIMENSION4, 
        source_data.DIMENSION5 AS DIMENSION5, 
        source_data.DOCUMENT AS DOCUMENT, 
        source_data.FINANCIALTRANSACTIONDESCRIPTION AS FINANCIALTRANSACTIONDESCRIPTION, 
        source_data.FINANCIALTRANSACTIONID AS FINANCIALTRANSACTIONID, 
        source_data.LEDGERACCOUNT AS LEDGERACCOUNT, 
        source_data.LINENUMBER_LINO AS LINENUMBER_LINO, 
        source_data.LINENUMBER_RLIN AS LINENUMBER_RLIN, 
        source_data.POSITION AS POSITION, 
        source_data.PROJECT AS PROJECT, 
        source_data.RECONCILIATIONDATE AS RECONCILIATIONDATE, 
        source_data.RECONCILIATIONDOCUMENT AS RECONCILIATIONDOCUMENT, 
        source_data.RECONCILIATIONTRANSACTIONTYPE AS RECONCILIATIONTRANSACTIONTYPE, 
        source_data.SALESORDER AS SALESORDER, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.TRANSACTIONORIGINDESCRIPTION AS TRANSACTIONORIGINDESCRIPTION, 
        source_data.TRANSACTIONORIGINID AS TRANSACTIONORIGINID, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AMOUNT as NUMBER(15,2)) as AMOUNT,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(CREATIONDATE as TIMESTAMP_NTZ(9)) as CREATIONDATE,
        cast(DEBITCREDITDESCRIPTION as VARCHAR(16777216)) as DEBITCREDITDESCRIPTION,
        cast(DEBITCREDITID as NUMBER(38,0)) as DEBITCREDITID,
        cast(DIMENSION1 as VARCHAR(6)) as DIMENSION1,
        cast(DIMENSION2 as VARCHAR(6)) as DIMENSION2,
        cast(DIMENSION3 as VARCHAR(6)) as DIMENSION3,
        cast(DIMENSION4 as VARCHAR(6)) as DIMENSION4,
        cast(DIMENSION5 as VARCHAR(6)) as DIMENSION5,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(FINANCIALTRANSACTIONDESCRIPTION as VARCHAR(16777216)) as FINANCIALTRANSACTIONDESCRIPTION,
        cast(FINANCIALTRANSACTIONID as NUMBER(38,0)) as FINANCIALTRANSACTIONID,
        cast(LEDGERACCOUNT as VARCHAR(12)) as LEDGERACCOUNT,
        cast(LINENUMBER_LINO as NUMBER(38,0)) as LINENUMBER_LINO,
        cast(LINENUMBER_RLIN as NUMBER(38,0)) as LINENUMBER_RLIN,
        cast(POSITION as NUMBER(38,0)) as POSITION,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(RECONCILIATIONDATE as TIMESTAMP_NTZ(9)) as RECONCILIATIONDATE,
        cast(RECONCILIATIONDOCUMENT as NUMBER(38,0)) as RECONCILIATIONDOCUMENT,
        cast(RECONCILIATIONTRANSACTIONTYPE as VARCHAR(3)) as RECONCILIATIONTRANSACTIONTYPE,
        cast(SALESORDER as VARCHAR(9)) as SALESORDER,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(TRANSACTIONORIGINDESCRIPTION as VARCHAR(16777216)) as TRANSACTIONORIGINDESCRIPTION,
        cast(TRANSACTIONORIGINID as NUMBER(38,0)) as TRANSACTIONORIGINID,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data