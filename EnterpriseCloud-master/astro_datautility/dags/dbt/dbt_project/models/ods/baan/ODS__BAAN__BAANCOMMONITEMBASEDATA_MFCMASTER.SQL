/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONITEMBASEDATA_MFCMASTER.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONITEMBASEDATA_MFCMASTER.SQL 
-materialized incremental
-alias BAANCOMMONITEMBASEDATA_MFCMASTER 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCOMMONITEMBASEDATA_MFCMASTER',
    unique_key = ['ITEM']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,201                                                                       AS _COMPANYID 
            ,CAST(T$PLBF AS NUMERIC(15,2))                                           AS BAAN4_CUSTOMERPRICELIST 
            ,CAST(T$INBF AS NUMERIC(15,2))                                           AS BAAN4_INTELPRICELIST 
            ,CAST(T$ITBF AS NUMERIC(15,2))                                           AS BAAN4_ITEMMASTERPRICE 
            ,CAST(T$IPBF AS NUMERIC(15,2))                                           AS BAAN4_ITEMPRICELIST 
            ,CAST(T$SOBF AS NUMERIC(15,2))                                           AS BAAN4_SALESORDERPRICE 
            ,CAST(T$SQBF AS NUMERIC(15,2))                                           AS BAAN4_SALESQUOTEPRICE 
            ,CAST(T$SVBF AS NUMERIC(15,2))                                           AS BAAN4_SERVICEORDERPRICE 
            ,CAST(T$CURP AS NUMERIC(15,2))                                           AS CURRENTITEMMASTERPRICE 
            ,T$INFL.CONSTANTDESCRIPTION                                              AS INTELFLAGDESCRIPTION 
            ,CAST(T$INFL AS INT)                                                     AS INTELFLAGID 
            ,CAST(T$INPL AS NUMERIC(15,2))                                           AS INTELPRICEBOOKPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                             AS ITEM 
            ,CAST(T$LOWP AS NUMERIC(15,2))                                           AS LOWESTPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CONO)),'')                             AS SALESCONTRACT 
            ,CAST(T$SCLP AS NUMERIC(15,2))                                           AS SALESCONTRACTLOWPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                             AS SALESORDER 
            ,CAST(T$SOLP AS NUMERIC(15,2))                                           AS SALESORDERLOWPRICE 
            ,CAST(T$PBLP AS NUMERIC(15,2))                                           AS SALESPRICEBOOKLOWPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QONO)),'')                             AS SALESQUOTATION 
            ,CAST(T$SQLP AS NUMERIC(15,2))                                           AS SALESQUOTELOWPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SVCN)),'')                             AS SERVICECONTRACT 
            ,CAST(T$SVCP AS NUMERIC(15,2))                                           AS SERVICECONTRACTLOWPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SVNO)),'')                             AS SERVICEORDER 
            ,CAST(T$SVLP AS NUMERIC(15,2))                                           AS SERVICEORDERLOWPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SQNO)),'')                             AS SERVICEQUOTATION 
            ,CAST(T$SVQP AS NUMERIC(15,2))                                           AS SERVICEQUOTELOWPRICE 
            ,CAST(CASE WHEN T$UPDT<= '1/1/1970' THEN NULL ELSE T$UPDT END AS DATE) AS UPDATEDATE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCIBD902201") }} AS SOURCETABLE  
            /*INTELFLAG*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INFL 
             ON   T$INFL.TABLENAME  = 'TCIBD902' 
              AND T$INFL.COLUMNNAME = 'T$INFL' 
              AND T$INFL.CONSTANT   = SOURCETABLE.T$INFL 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.BAAN4_CUSTOMERPRICELIST AS BAAN4_CUSTOMERPRICELIST, 
        source_data.BAAN4_INTELPRICELIST AS BAAN4_INTELPRICELIST, 
        source_data.BAAN4_ITEMMASTERPRICE AS BAAN4_ITEMMASTERPRICE, 
        source_data.BAAN4_ITEMPRICELIST AS BAAN4_ITEMPRICELIST, 
        source_data.BAAN4_SALESORDERPRICE AS BAAN4_SALESORDERPRICE, 
        source_data.BAAN4_SALESQUOTEPRICE AS BAAN4_SALESQUOTEPRICE, 
        source_data.BAAN4_SERVICEORDERPRICE AS BAAN4_SERVICEORDERPRICE, 
        source_data.CURRENTITEMMASTERPRICE AS CURRENTITEMMASTERPRICE, 
        source_data.INTELFLAGDESCRIPTION AS INTELFLAGDESCRIPTION, 
        source_data.INTELFLAGID AS INTELFLAGID, 
        source_data.INTELPRICEBOOKPRICE AS INTELPRICEBOOKPRICE, 
        source_data.ITEM AS ITEM, 
        source_data.LOWESTPRICE AS LOWESTPRICE, 
        source_data.SALESCONTRACT AS SALESCONTRACT, 
        source_data.SALESCONTRACTLOWPRICE AS SALESCONTRACTLOWPRICE, 
        source_data.SALESORDER AS SALESORDER, 
        source_data.SALESORDERLOWPRICE AS SALESORDERLOWPRICE, 
        source_data.SALESPRICEBOOKLOWPRICE AS SALESPRICEBOOKLOWPRICE, 
        source_data.SALESQUOTATION AS SALESQUOTATION, 
        source_data.SALESQUOTELOWPRICE AS SALESQUOTELOWPRICE, 
        source_data.SERVICECONTRACT AS SERVICECONTRACT, 
        source_data.SERVICECONTRACTLOWPRICE AS SERVICECONTRACTLOWPRICE, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.SERVICEORDERLOWPRICE AS SERVICEORDERLOWPRICE, 
        source_data.SERVICEQUOTATION AS SERVICEQUOTATION, 
        source_data.SERVICEQUOTELOWPRICE AS SERVICEQUOTELOWPRICE, 
        source_data.UPDATEDATE AS UPDATEDATE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(BAAN4_CUSTOMERPRICELIST as NUMBER(15,2)) as BAAN4_CUSTOMERPRICELIST,
        cast(BAAN4_INTELPRICELIST as NUMBER(15,2)) as BAAN4_INTELPRICELIST,
        cast(BAAN4_ITEMMASTERPRICE as NUMBER(15,2)) as BAAN4_ITEMMASTERPRICE,
        cast(BAAN4_ITEMPRICELIST as NUMBER(15,2)) as BAAN4_ITEMPRICELIST,
        cast(BAAN4_SALESORDERPRICE as NUMBER(15,2)) as BAAN4_SALESORDERPRICE,
        cast(BAAN4_SALESQUOTEPRICE as NUMBER(15,2)) as BAAN4_SALESQUOTEPRICE,
        cast(BAAN4_SERVICEORDERPRICE as NUMBER(15,2)) as BAAN4_SERVICEORDERPRICE,
        cast(CURRENTITEMMASTERPRICE as NUMBER(15,2)) as CURRENTITEMMASTERPRICE,
        cast(INTELFLAGDESCRIPTION as VARCHAR(16777216)) as INTELFLAGDESCRIPTION,
        cast(INTELFLAGID as NUMBER(38,0)) as INTELFLAGID,
        cast(INTELPRICEBOOKPRICE as NUMBER(15,2)) as INTELPRICEBOOKPRICE,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LOWESTPRICE as NUMBER(15,2)) as LOWESTPRICE,
        cast(SALESCONTRACT as VARCHAR(9)) as SALESCONTRACT,
        cast(SALESCONTRACTLOWPRICE as NUMBER(15,2)) as SALESCONTRACTLOWPRICE,
        cast(SALESORDER as VARCHAR(9)) as SALESORDER,
        cast(SALESORDERLOWPRICE as NUMBER(15,2)) as SALESORDERLOWPRICE,
        cast(SALESPRICEBOOKLOWPRICE as NUMBER(15,2)) as SALESPRICEBOOKLOWPRICE,
        cast(SALESQUOTATION as VARCHAR(9)) as SALESQUOTATION,
        cast(SALESQUOTELOWPRICE as NUMBER(15,2)) as SALESQUOTELOWPRICE,
        cast(SERVICECONTRACT as VARCHAR(9)) as SERVICECONTRACT,
        cast(SERVICECONTRACTLOWPRICE as NUMBER(15,2)) as SERVICECONTRACTLOWPRICE,
        cast(SERVICEORDER as VARCHAR(9)) as SERVICEORDER,
        cast(SERVICEORDERLOWPRICE as NUMBER(15,2)) as SERVICEORDERLOWPRICE,
        cast(SERVICEQUOTATION as VARCHAR(9)) as SERVICEQUOTATION,
        cast(SERVICEQUOTELOWPRICE as NUMBER(15,2)) as SERVICEQUOTELOWPRICE,
        cast(UPDATEDATE as DATE) as UPDATEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data