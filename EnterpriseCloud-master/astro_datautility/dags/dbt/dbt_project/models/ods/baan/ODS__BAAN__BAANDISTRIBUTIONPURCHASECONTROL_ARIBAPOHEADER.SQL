/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOHEADER.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOHEADER.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOHEADER 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOHEADER',
    unique_key = ['_COMPANYID',
    'PURCHASEORDERNO']
) }}


with source_data as 
(
    SELECT   
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ASNO)),'')                                                                                         AS ADVANCEDSHIPNOTICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLST)),'')                                                                                         AS CLOSEDPOSTATUS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COMM)),'')                                                                                         AS COMMENTS 
            ,CAST(T$NCMP AS INT)                                                                                                                 AS COMPANYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DDAT)),'')                                                                                         AS DELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EDAT)),'')                                                                                         AS EVENTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAT)),'')                                                                                         AS EVENTSTATUS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EVTY)),'')                                                                                         AS EVENTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS LASTMODIFIEDBY 
            ,CAST(CASE WHEN T$LMDT<= '1/1/1970' THEN NULL ELSE T$LMDT  END AS DATETIME) AS LASTMODIFIEDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORIG)),'')                                                                                         AS ORIGNATINGSYSTEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OSRF)),'')                                                                                         AS ORIGNATINGSYSTEMREFID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS PAYMENTTERMS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRUN)),'')                                                                                         AS PROCUREMENTUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PURCHASEORDERNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHIP)),'')                                                                                         AS SHIPMENTIDENTIFIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHDT)),'')                                                                                         AS SHIPNOTICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CARR)),'')                                                                                         AS SHIPPINGCARRIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUPP)),'')                                                                                         AS SUPPLIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                         AS SUPPLIERLOCATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TITL)),'')                                                                                         AS TITLE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$UNIQ)),'')                                                                                         AS UNIQUENAME 
            ,CAST(T$VERS AS BIGINT)                                                                                                              AS VERSION 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDPUR715200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ASNO)),'')                                                                                         AS ADVANCEDSHIPNOTICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLST)),'')                                                                                         AS CLOSEDPOSTATUS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COMM)),'')                                                                                         AS COMMENTS 
            ,CAST(T$NCMP AS INT)                                                                                                                 AS COMPANYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DDAT)),'')                                                                                         AS DELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EDAT)),'')                                                                                         AS EVENTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAT)),'')                                                                                         AS EVENTSTATUS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EVTY)),'')                                                                                         AS EVENTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS LASTMODIFIEDBY 
            ,CAST(CASE WHEN T$LMDT<= '1/1/1970' THEN NULL ELSE T$LMDT  END AS DATETIME) AS LASTMODIFIEDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORIG)),'')                                                                                         AS ORIGNATINGSYSTEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OSRF)),'')                                                                                         AS ORIGNATINGSYSTEMREFID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS PAYMENTTERMS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRUN)),'')                                                                                         AS PROCUREMENTUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PURCHASEORDERNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHIP)),'')                                                                                         AS SHIPMENTIDENTIFIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHDT)),'')                                                                                         AS SHIPNOTICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CARR)),'')                                                                                         AS SHIPPINGCARRIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUPP)),'')                                                                                         AS SUPPLIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                         AS SUPPLIERLOCATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TITL)),'')                                                                                         AS TITLE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$UNIQ)),'')                                                                                         AS UNIQUENAME 
            ,CAST(T$VERS AS BIGINT)                                                                                                              AS VERSION 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDPUR715201") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADVANCEDSHIPNOTICE AS ADVANCEDSHIPNOTICE, 
        source_data.CLOSEDPOSTATUS AS CLOSEDPOSTATUS, 
        source_data.COMMENTS AS COMMENTS, 
        source_data.COMPANYCODE AS COMPANYCODE, 
        source_data.DELIVERYDATE AS DELIVERYDATE, 
        source_data.EVENTDATE AS EVENTDATE, 
        source_data.EVENTSTATUS AS EVENTSTATUS, 
        source_data.EVENTTYPE AS EVENTTYPE, 
        source_data.LASTMODIFIEDBY AS LASTMODIFIEDBY, 
        source_data.LASTMODIFIEDDATE AS LASTMODIFIEDDATE, 
        source_data.ORIGNATINGSYSTEM AS ORIGNATINGSYSTEM, 
        source_data.ORIGNATINGSYSTEMREFID AS ORIGNATINGSYSTEMREFID, 
        source_data.PAYMENTTERMS AS PAYMENTTERMS, 
        source_data.PROCUREMENTUNIT AS PROCUREMENTUNIT, 
        source_data.PURCHASEORDERNO AS PURCHASEORDERNO, 
        source_data.SHIPMENTIDENTIFIER AS SHIPMENTIDENTIFIER, 
        source_data.SHIPNOTICEDATE AS SHIPNOTICEDATE, 
        source_data.SHIPPINGCARRIER AS SHIPPINGCARRIER, 
        source_data.SUPPLIER AS SUPPLIER, 
        source_data.SUPPLIERLOCATION AS SUPPLIERLOCATION, 
        source_data.TITLE AS TITLE, 
        source_data.UNIQUENAME AS UNIQUENAME, 
        source_data.VERSION AS VERSION
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADVANCEDSHIPNOTICE as VARCHAR(255)) as ADVANCEDSHIPNOTICE,
        cast(CLOSEDPOSTATUS as VARCHAR(100)) as CLOSEDPOSTATUS,
        cast(COMMENTS as VARCHAR(999)) as COMMENTS,
        cast(COMPANYCODE as NUMBER(38,0)) as COMPANYCODE,
        cast(DELIVERYDATE as VARCHAR(20)) as DELIVERYDATE,
        cast(EVENTDATE as VARCHAR(20)) as EVENTDATE,
        cast(EVENTSTATUS as VARCHAR(255)) as EVENTSTATUS,
        cast(EVENTTYPE as VARCHAR(255)) as EVENTTYPE,
        cast(LASTMODIFIEDBY as VARCHAR(16)) as LASTMODIFIEDBY,
        cast(LASTMODIFIEDDATE as TIMESTAMP_NTZ(9)) as LASTMODIFIEDDATE,
        cast(ORIGNATINGSYSTEM as VARCHAR(50)) as ORIGNATINGSYSTEM,
        cast(ORIGNATINGSYSTEMREFID as VARCHAR(50)) as ORIGNATINGSYSTEMREFID,
        cast(PAYMENTTERMS as VARCHAR(50)) as PAYMENTTERMS,
        cast(PROCUREMENTUNIT as VARCHAR(50)) as PROCUREMENTUNIT,
        cast(PURCHASEORDERNO as VARCHAR(50)) as PURCHASEORDERNO,
        cast(SHIPMENTIDENTIFIER as VARCHAR(255)) as SHIPMENTIDENTIFIER,
        cast(SHIPNOTICEDATE as VARCHAR(20)) as SHIPNOTICEDATE,
        cast(SHIPPINGCARRIER as VARCHAR(80)) as SHIPPINGCARRIER,
        cast(SUPPLIER as VARCHAR(9)) as SUPPLIER,
        cast(SUPPLIERLOCATION as VARCHAR(9)) as SUPPLIERLOCATION,
        cast(TITLE as VARCHAR(60)) as TITLE,
        cast(UNIQUENAME as VARCHAR(255)) as UNIQUENAME,
        cast(VERSION as NUMBER(38,0)) as VERSION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data