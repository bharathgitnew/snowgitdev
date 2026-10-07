/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGEDILOGISTICS_USAREGN_TELSHIPPINGADVICEDATA.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGEDILOGISTICS_USAREGN_TELSHIPPINGADVICEDATA.SQL 
-materialized incremental
-alias BAANWAREHOUSINGEDILOGISTICS_USAREGN_TELSHIPPINGADVICEDATA 
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
    alias='BAANWAREHOUSINGEDILOGISTICS_USAREGN_TELSHIPPINGADVICEDATA',
    unique_key = ['MESSAGEID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$CRDT<= '1/1/1970' THEN NULL ELSE T$CRDT  END AS DATETIME) AS CREATEDDATE 
            ,CAST(T$DQUA AS NUMERIC(15,2))                                                                                                       AS DELIVEREDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMES)),'')                                                                                         AS ERRORMESSAGE 
            ,CAST(CASE WHEN T$ETAD<= '1/1/1970' THEN NULL ELSE T$ETAD  END AS DATETIME) AS ETADATE 
            ,CAST(CASE WHEN T$EXDT<= '1/1/1970' THEN NULL ELSE T$EXDT  END AS DATETIME) AS EXTRACTTIME 
            ,CAST(CASE WHEN T$FOBN<= '1/1/1970' THEN NULL ELSE T$FOBN  END AS DATETIME) AS FOBNARITADATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$HAWB)),'')                                                                                         AS HOUSEWAYBILLNO 
            ,CAST(CASE WHEN T$INDT<= '1/1/1970' THEN NULL ELSE T$INDT  END AS DATETIME) AS INVOICEDATE 
            ,CAST(T$IPOS AS INT)                                                                                                                 AS INVOICELINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVN)),'')                                                                                         AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(T$MSID AS BIGINT)                                                                                                              AS MESSAGEID 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PROCESSEDDATE 
            ,T$PFLG.CONSTANTDESCRIPTION                                                                                                          AS PROCESSEDFLAGDESCRIPTION 
            ,CAST(T$PFLG AS INT)                                                                                                                 AS PROCESSEDFLAGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PURCHASEORDER 
            ,CAST(T$PONO AS INT)                                                                                                                 AS PURCHASEORDERLINE 
            ,CAST(T$SPOS AS INT)                                                                                                                 AS SALESORDERLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SONO)),'')                                                                                         AS SALESORDERNO 
            ,CAST(CASE WHEN T$ETDT<= '1/1/1970' THEN NULL ELSE T$ETDT  END AS DATETIME) AS SHIPDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DEST)),'')                                                                                         AS SHIPTO 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHEDI201201") }} AS SOURCETABLE  
            /*PROCESSEDFLAG*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PFLG 
             ON   T$PFLG.TABLENAME  = 'WHEDI201' 
              AND T$PFLG.COLUMNNAME = 'T$PFLG' 
              AND T$PFLG.CONSTANT   = SOURCETABLE.T$PFLG 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CREATEDDATE AS CREATEDDATE, 
        source_data.DELIVEREDQUANTITY AS DELIVEREDQUANTITY, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.ERRORMESSAGE AS ERRORMESSAGE, 
        source_data.ETADATE AS ETADATE, 
        source_data.EXTRACTTIME AS EXTRACTTIME, 
        source_data.FOBNARITADATE AS FOBNARITADATE, 
        source_data.HOUSEWAYBILLNO AS HOUSEWAYBILLNO, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICELINE AS INVOICELINE, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.ITEM AS ITEM, 
        source_data.MESSAGEID AS MESSAGEID, 
        source_data.PROCESSEDDATE AS PROCESSEDDATE, 
        source_data.PROCESSEDFLAGDESCRIPTION AS PROCESSEDFLAGDESCRIPTION, 
        source_data.PROCESSEDFLAGID AS PROCESSEDFLAGID, 
        source_data.PURCHASEORDER AS PURCHASEORDER, 
        source_data.PURCHASEORDERLINE AS PURCHASEORDERLINE, 
        source_data.SALESORDERLINE AS SALESORDERLINE, 
        source_data.SALESORDERNO AS SALESORDERNO, 
        source_data.SHIPDATE AS SHIPDATE, 
        source_data.SHIPTO AS SHIPTO
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CREATEDDATE as TIMESTAMP_NTZ(9)) as CREATEDDATE,
        cast(DELIVEREDQUANTITY as NUMBER(15,2)) as DELIVEREDQUANTITY,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(ERRORMESSAGE as VARCHAR(100)) as ERRORMESSAGE,
        cast(ETADATE as TIMESTAMP_NTZ(9)) as ETADATE,
        cast(EXTRACTTIME as TIMESTAMP_NTZ(9)) as EXTRACTTIME,
        cast(FOBNARITADATE as TIMESTAMP_NTZ(9)) as FOBNARITADATE,
        cast(HOUSEWAYBILLNO as VARCHAR(20)) as HOUSEWAYBILLNO,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICELINE as NUMBER(38,0)) as INVOICELINE,
        cast(INVOICENUMBER as VARCHAR(9)) as INVOICENUMBER,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(MESSAGEID as NUMBER(38,0)) as MESSAGEID,
        cast(PROCESSEDDATE as TIMESTAMP_NTZ(9)) as PROCESSEDDATE,
        cast(PROCESSEDFLAGDESCRIPTION as VARCHAR(16777216)) as PROCESSEDFLAGDESCRIPTION,
        cast(PROCESSEDFLAGID as NUMBER(38,0)) as PROCESSEDFLAGID,
        cast(PURCHASEORDER as VARCHAR(9)) as PURCHASEORDER,
        cast(PURCHASEORDERLINE as NUMBER(38,0)) as PURCHASEORDERLINE,
        cast(SALESORDERLINE as NUMBER(38,0)) as SALESORDERLINE,
        cast(SALESORDERNO as VARCHAR(9)) as SALESORDERNO,
        cast(SHIPDATE as TIMESTAMP_NTZ(9)) as SHIPDATE,
        cast(SHIPTO as VARCHAR(35)) as SHIPTO,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data