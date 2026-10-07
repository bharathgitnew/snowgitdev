/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOLINEDETAILS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOLINEDETAILS.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOLINEDETAILS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:50 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOLINEDETAILS',
    unique_key = ['_COMPANYID',
    'LINENUMBER',
    'PURCHASEORDERNO']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACAT)),'')                                                                                         AS ACCOUNTCATERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BIAD)),'')                                                                                         AS BILLINGADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COMN)),'')                                                                                         AS COMMENTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COMM)),'')                                                                                         AS COMMODITYCODE 
            ,CAST(T$NCMP AS INT)                                                                                                                 AS COMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DELI)),'')                                                                                         AS DELIVERYTO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ECOM)),'')                                                                                         AS ERPCOMMODITYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ERSA)),'')                                                                                         AS ERSALLOWED 
            ,CAST(T$ELIN AS BIGINT)                                                                                                              AS EXTERNALLINENO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IDNO)),'')                                                                                         AS ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ISCO)),'')                                                                                         AS ISCOMPOSITE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TAXD)),'')                                                                                         AS ISTAXDEDUCTIBLE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ICAT)),'')                                                                                         AS ITEMCATERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS LASTMODIFIEDBY 
            ,CAST(CASE WHEN T$LMDT<= '1/1/1970' THEN NULL ELSE T$LMDT  END AS DATETIME) AS LASTMODIFIEDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'')                                                                                         AS LINEDESCRIPTION 
            ,CAST(T$PONO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LTYP)),'')                                                                                         AS LINETYPE 
            ,CAST(T$LCAT AS BIGINT)                                                                                                              AS LINETYPECATERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NDBY)),'')                                                                                         AS NEEDBY 
            ,CAST(T$NUSH AS NUMERIC(15,2))                                                                                                       AS NUMBERSHIPPED 
            ,CAST(T$PLIN AS BIGINT)                                                                                                              AS PARENTLINENO 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                       AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PCUR)),'')                                                                                         AS PRICECURRENCY 
            ,CAST(T$PRBC AS NUMERIC(15,2))                                                                                                       AS PRICEINBASECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PUNT)),'')                                                                                         AS PRICEUNIT 
            ,CAST(T$PRQT AS NUMERIC(15,2))                                                                                                       AS PRICEUNITQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRDS)),'')                                                                                         AS PRICINGDESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$POGR)),'')                                                                                         AS PURCHASEGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PURCHASEORDERNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PORG)),'')                                                                                         AS PURCHASEORG 
            ,CAST(T$QNTY AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RQID)),'')                                                                                         AS REQUISITIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RERE)),'')                                                                                         AS REQUISITIONREQUESTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHAD)),'')                                                                                         AS SHIPPINGADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SNAM)),'')                                                                                         AS SHORTNAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SPAD)),'')                                                                                         AS SUPPLIERPARTAUXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUIT)),'')                                                                                         AS SUPPLIERPARTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TAMT)),'')                                                                                         AS TAXABLEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXCU)),'')                                                                                         AS TAXABLEAMOUNTCURRENCY 
            ,CAST(T$TAXB AS NUMERIC(15,2))                                                                                                       AS TAXABLEAMOUNTINBASECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TCOD)),'')                                                                                         AS TAXCODE 
            ,CAST(T$TPER AS NUMERIC(15,2))                                                                                                       AS TAXPERCENT 
            ,CAST(T$TPUN AS NUMERIC(15,2))                                                                                                       AS TAXPERUNIT 
            ,CAST(T$UNIC AS NUMERIC(15,2))                                                                                                       AS UNITCONVERSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$UNIT)),'')                                                                                         AS UNITOFMEASURE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CURR)),'')                                                                                         AS UNITPRICECURRENCY 
            ,CAST(T$UNBC AS NUMERIC(15,2))                                                                                                       AS UNITPRICEINBASECURRENCY_UNBC 
            ,CAST(T$UNPR AS NUMERIC(15,2))                                                                                                       AS UNITPRICEINBASECURRENCY_UNPR 
            ,CAST(T$VERS AS BIGINT)                                                                                                              AS VERSION 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDPUR716200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACAT)),'')                                                                                         AS ACCOUNTCATERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BIAD)),'')                                                                                         AS BILLINGADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COMN)),'')                                                                                         AS COMMENTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COMM)),'')                                                                                         AS COMMODITYCODE 
            ,CAST(T$NCMP AS INT)                                                                                                                 AS COMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DELI)),'')                                                                                         AS DELIVERYTO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ECOM)),'')                                                                                         AS ERPCOMMODITYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ERSA)),'')                                                                                         AS ERSALLOWED 
            ,CAST(T$ELIN AS BIGINT)                                                                                                              AS EXTERNALLINENO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IDNO)),'')                                                                                         AS ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ISCO)),'')                                                                                         AS ISCOMPOSITE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TAXD)),'')                                                                                         AS ISTAXDEDUCTIBLE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ICAT)),'')                                                                                         AS ITEMCATERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS LASTMODIFIEDBY 
            ,CAST(CASE WHEN T$LMDT<= '1/1/1970' THEN NULL ELSE T$LMDT  END AS DATETIME) AS LASTMODIFIEDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'')                                                                                         AS LINEDESCRIPTION 
            ,CAST(T$PONO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LTYP)),'')                                                                                         AS LINETYPE 
            ,CAST(T$LCAT AS BIGINT)                                                                                                              AS LINETYPECATERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NDBY)),'')                                                                                         AS NEEDBY 
            ,CAST(T$NUSH AS NUMERIC(15,2))                                                                                                       AS NUMBERSHIPPED 
            ,CAST(T$PLIN AS BIGINT)                                                                                                              AS PARENTLINENO 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                       AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PCUR)),'')                                                                                         AS PRICECURRENCY 
            ,CAST(T$PRBC AS NUMERIC(15,2))                                                                                                       AS PRICEINBASECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PUNT)),'')                                                                                         AS PRICEUNIT 
            ,CAST(T$PRQT AS NUMERIC(15,2))                                                                                                       AS PRICEUNITQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRDS)),'')                                                                                         AS PRICINGDESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$POGR)),'')                                                                                         AS PURCHASEGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PURCHASEORDERNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PORG)),'')                                                                                         AS PURCHASEORG 
            ,CAST(T$QNTY AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RQID)),'')                                                                                         AS REQUISITIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RERE)),'')                                                                                         AS REQUISITIONREQUESTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHAD)),'')                                                                                         AS SHIPPINGADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SNAM)),'')                                                                                         AS SHORTNAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SPAD)),'')                                                                                         AS SUPPLIERPARTAUXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUIT)),'')                                                                                         AS SUPPLIERPARTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TAMT)),'')                                                                                         AS TAXABLEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXCU)),'')                                                                                         AS TAXABLEAMOUNTCURRENCY 
            ,CAST(T$TAXB AS NUMERIC(15,2))                                                                                                       AS TAXABLEAMOUNTINBASECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TCOD)),'')                                                                                         AS TAXCODE 
            ,CAST(T$TPER AS NUMERIC(15,2))                                                                                                       AS TAXPERCENT 
            ,CAST(T$TPUN AS NUMERIC(15,2))                                                                                                       AS TAXPERUNIT 
            ,CAST(T$UNIC AS NUMERIC(15,2))                                                                                                       AS UNITCONVERSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$UNIT)),'')                                                                                         AS UNITOFMEASURE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CURR)),'')                                                                                         AS UNITPRICECURRENCY 
            ,CAST(T$UNBC AS NUMERIC(15,2))                                                                                                       AS UNITPRICEINBASECURRENCY_UNBC 
            ,CAST(T$UNPR AS NUMERIC(15,2))                                                                                                       AS UNITPRICEINBASECURRENCY_UNPR 
            ,CAST(T$VERS AS BIGINT)                                                                                                              AS VERSION 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDPUR716201") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCOUNTCATERY AS ACCOUNTCATERY, 
        source_data.BILLINGADDRESS AS BILLINGADDRESS, 
        source_data.COMMENTS AS COMMENTS, 
        source_data.COMMODITYCODE AS COMMODITYCODE, 
        source_data.COMPANY AS COMPANY, 
        source_data.DELIVERYTO AS DELIVERYTO, 
        source_data.ERPCOMMODITYCODE AS ERPCOMMODITYCODE, 
        source_data.ERSALLOWED AS ERSALLOWED, 
        source_data.EXTERNALLINENO AS EXTERNALLINENO, 
        source_data.ID AS ID, 
        source_data.ISCOMPOSITE AS ISCOMPOSITE, 
        source_data.ISTAXDEDUCTIBLE AS ISTAXDEDUCTIBLE, 
        source_data.ITEMCATERY AS ITEMCATERY, 
        source_data.LASTMODIFIEDBY AS LASTMODIFIEDBY, 
        source_data.LASTMODIFIEDDATE AS LASTMODIFIEDDATE, 
        source_data.LINEDESCRIPTION AS LINEDESCRIPTION, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.LINETYPE AS LINETYPE, 
        source_data.LINETYPECATERY AS LINETYPECATERY, 
        source_data.NEEDBY AS NEEDBY, 
        source_data.NUMBERSHIPPED AS NUMBERSHIPPED, 
        source_data.PARENTLINENO AS PARENTLINENO, 
        source_data.PRICE AS PRICE, 
        source_data.PRICECURRENCY AS PRICECURRENCY, 
        source_data.PRICEINBASECURRENCY AS PRICEINBASECURRENCY, 
        source_data.PRICEUNIT AS PRICEUNIT, 
        source_data.PRICEUNITQUANTITY AS PRICEUNITQUANTITY, 
        source_data.PRICINGDESCRIPTION AS PRICINGDESCRIPTION, 
        source_data.PURCHASEGROUP AS PURCHASEGROUP, 
        source_data.PURCHASEORDERNO AS PURCHASEORDERNO, 
        source_data.PURCHASEORG AS PURCHASEORG, 
        source_data.QUANTITY AS QUANTITY, 
        source_data.REQUISITIONID AS REQUISITIONID, 
        source_data.REQUISITIONREQUESTER AS REQUISITIONREQUESTER, 
        source_data.SHIPPINGADDRESS AS SHIPPINGADDRESS, 
        source_data.SHORTNAME AS SHORTNAME, 
        source_data.SUPPLIERPARTAUXID AS SUPPLIERPARTAUXID, 
        source_data.SUPPLIERPARTNUMBER AS SUPPLIERPARTNUMBER, 
        source_data.TAXABLEAMOUNT AS TAXABLEAMOUNT, 
        source_data.TAXABLEAMOUNTCURRENCY AS TAXABLEAMOUNTCURRENCY, 
        source_data.TAXABLEAMOUNTINBASECURRENCY AS TAXABLEAMOUNTINBASECURRENCY, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.TAXPERCENT AS TAXPERCENT, 
        source_data.TAXPERUNIT AS TAXPERUNIT, 
        source_data.UNITCONVERSION AS UNITCONVERSION, 
        source_data.UNITOFMEASURE AS UNITOFMEASURE, 
        source_data.UNITPRICECURRENCY AS UNITPRICECURRENCY, 
        source_data.UNITPRICEINBASECURRENCY_UNBC AS UNITPRICEINBASECURRENCY_UNBC, 
        source_data.UNITPRICEINBASECURRENCY_UNPR AS UNITPRICEINBASECURRENCY_UNPR, 
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
        cast(ACCOUNTCATERY as VARCHAR(50)) as ACCOUNTCATERY,
        cast(BILLINGADDRESS as VARCHAR(50)) as BILLINGADDRESS,
        cast(COMMENTS as VARCHAR(50)) as COMMENTS,
        cast(COMMODITYCODE as VARCHAR(255)) as COMMODITYCODE,
        cast(COMPANY as NUMBER(38,0)) as COMPANY,
        cast(DELIVERYTO as VARCHAR(100)) as DELIVERYTO,
        cast(ERPCOMMODITYCODE as VARCHAR(50)) as ERPCOMMODITYCODE,
        cast(ERSALLOWED as VARCHAR(20)) as ERSALLOWED,
        cast(EXTERNALLINENO as NUMBER(38,0)) as EXTERNALLINENO,
        cast(ID as VARCHAR(50)) as ID,
        cast(ISCOMPOSITE as VARCHAR(20)) as ISCOMPOSITE,
        cast(ISTAXDEDUCTIBLE as VARCHAR(20)) as ISTAXDEDUCTIBLE,
        cast(ITEMCATERY as VARCHAR(50)) as ITEMCATERY,
        cast(LASTMODIFIEDBY as VARCHAR(16)) as LASTMODIFIEDBY,
        cast(LASTMODIFIEDDATE as TIMESTAMP_NTZ(9)) as LASTMODIFIEDDATE,
        cast(LINEDESCRIPTION as VARCHAR(255)) as LINEDESCRIPTION,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(LINETYPE as VARCHAR(50)) as LINETYPE,
        cast(LINETYPECATERY as NUMBER(38,0)) as LINETYPECATERY,
        cast(NEEDBY as VARCHAR(20)) as NEEDBY,
        cast(NUMBERSHIPPED as NUMBER(15,2)) as NUMBERSHIPPED,
        cast(PARENTLINENO as NUMBER(38,0)) as PARENTLINENO,
        cast(PRICE as NUMBER(15,2)) as PRICE,
        cast(PRICECURRENCY as VARCHAR(50)) as PRICECURRENCY,
        cast(PRICEINBASECURRENCY as NUMBER(15,2)) as PRICEINBASECURRENCY,
        cast(PRICEUNIT as VARCHAR(50)) as PRICEUNIT,
        cast(PRICEUNITQUANTITY as NUMBER(15,2)) as PRICEUNITQUANTITY,
        cast(PRICINGDESCRIPTION as VARCHAR(100)) as PRICINGDESCRIPTION,
        cast(PURCHASEGROUP as VARCHAR(50)) as PURCHASEGROUP,
        cast(PURCHASEORDERNO as VARCHAR(50)) as PURCHASEORDERNO,
        cast(PURCHASEORG as VARCHAR(50)) as PURCHASEORG,
        cast(QUANTITY as NUMBER(15,2)) as QUANTITY,
        cast(REQUISITIONID as VARCHAR(50)) as REQUISITIONID,
        cast(REQUISITIONREQUESTER as VARCHAR(50)) as REQUISITIONREQUESTER,
        cast(SHIPPINGADDRESS as VARCHAR(50)) as SHIPPINGADDRESS,
        cast(SHORTNAME as VARCHAR(80)) as SHORTNAME,
        cast(SUPPLIERPARTAUXID as VARCHAR(50)) as SUPPLIERPARTAUXID,
        cast(SUPPLIERPARTNUMBER as VARCHAR(255)) as SUPPLIERPARTNUMBER,
        cast(TAXABLEAMOUNT as VARCHAR(50)) as TAXABLEAMOUNT,
        cast(TAXABLEAMOUNTCURRENCY as VARCHAR(50)) as TAXABLEAMOUNTCURRENCY,
        cast(TAXABLEAMOUNTINBASECURRENCY as NUMBER(15,2)) as TAXABLEAMOUNTINBASECURRENCY,
        cast(TAXCODE as VARCHAR(50)) as TAXCODE,
        cast(TAXPERCENT as NUMBER(15,2)) as TAXPERCENT,
        cast(TAXPERUNIT as NUMBER(15,2)) as TAXPERUNIT,
        cast(UNITCONVERSION as NUMBER(15,2)) as UNITCONVERSION,
        cast(UNITOFMEASURE as VARCHAR(50)) as UNITOFMEASURE,
        cast(UNITPRICECURRENCY as VARCHAR(50)) as UNITPRICECURRENCY,
        cast(UNITPRICEINBASECURRENCY_UNBC as NUMBER(15,2)) as UNITPRICEINBASECURRENCY_UNBC,
        cast(UNITPRICEINBASECURRENCY_UNPR as NUMBER(15,2)) as UNITPRICEINBASECURRENCY_UNPR,
        cast(VERSION as NUMBER(38,0)) as VERSION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data