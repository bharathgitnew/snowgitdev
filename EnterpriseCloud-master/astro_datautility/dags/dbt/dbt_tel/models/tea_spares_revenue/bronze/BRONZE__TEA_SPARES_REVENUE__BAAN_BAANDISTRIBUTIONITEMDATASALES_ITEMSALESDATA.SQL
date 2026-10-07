/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONITEMDATASALES_ITEMSALESDATA.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONITEMDATASALES_ITEMSALESDATA.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONITEMDATASALES_ITEMSALESDATA 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:49 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANDISTRIBUTIONITEMDATASALES_ITEMSALESDATA',
    unique_key = ['ITEM']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,T$ACCI.CONSTANTDESCRIPTION                                                                                                          AS ACCESSORIESALLOWEDDESCRIPTION 
            ,CAST(T$ACCI AS INT)                                                                                                                 AS ACCESSORIESALLOWEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMGP)),'')                                                                                         AS COMMISSIONGROUP 
            ,T$ACOM.CONSTANTDESCRIPTION                                                                                                          AS COMMITMENTPOLICYDESCRIPTION 
            ,CAST(T$ACOM AS INT)                                                                                                                 AS COMMITMENTPOLICYID 
            ,CAST(T$DDFQ AS NUMERIC(15,2))                                                                                                       AS DIRECTDELIVERYFROMQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,SOURCETABLE.T$TXTS   /* TEXT */                                                                                                     AS ITEMSALESTEXT 
            ,CAST(CASE WHEN T$LTSP<= '1/1/1970' THEN NULL ELSE T$LTSP  END AS DATETIME) AS LASTSALESPRICETRANSACTIONDATE 
            ,CAST(T$LMSP AS NUMERIC(15,2))                                                                                                       AS LOWERMARGIN 
            ,CAST(T$MNQO AS NUMERIC(15,2))                                                                                                       AS MINIMUMORDERQUANTITY 
            ,CAST(T$MNQA AS NUMERIC(15,2))                                                                                                       AS MINIMUMQUANTITYTOCOMMIT 
            ,CAST(T$MNRA AS NUMERIC(15,2))                                                                                                       AS MINIMUMRATEFORCOMMITMENT 
            ,T$RETW.CONSTANTDESCRIPTION                                                                                                          AS RELEASETOWAREHOUSEDESCRIPTION 
            ,CAST(T$RETW AS INT)                                                                                                                 AS RELEASETOWAREHOUSEID 
            ,T$RCOM.CONSTANTDESCRIPTION                                                                                                          AS RETURNCOMPONENTSDESCRIPTION 
            ,CAST(T$RCOM AS INT)                                                                                                                 AS RETURNCOMPONENTSID 
            ,CAST(T$PRIS AS NUMERIC(15,2))                                                                                                       AS SALESPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPGS)),'')                                                                                         AS SALESPRICEGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RBGP)),'')                                                                                         AS SALESREBATEGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGS)),'')                                                                                         AS SALESSTATISTICSGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS SALESUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEYI 
            ,CAST(T$PRIR AS NUMERIC(15,2))                                                                                                       AS SUGGESTEDRETAILPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,CAST(T$UMSP AS NUMERIC(15,2))                                                                                                       AS UPPERMARGIN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDISA001200") }} AS SOURCETABLE  
            /*ACCESSORIESALLOWED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACCI 
             ON   T$ACCI.TABLENAME  = 'TDISA001' 
              AND T$ACCI.COLUMNNAME = 'T$ACCI' 
              AND T$ACCI.CONSTANT   = SOURCETABLE.T$ACCI 
            /*COMMITMENTPOLICY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACOM 
             ON   T$ACOM.TABLENAME  = 'TDISA001' 
              AND T$ACOM.COLUMNNAME = 'T$ACOM' 
              AND T$ACOM.CONSTANT   = SOURCETABLE.T$ACOM 
            /*RELEASETOWAREHOUSE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RETW 
             ON   T$RETW.TABLENAME  = 'TDISA001' 
              AND T$RETW.COLUMNNAME = 'T$RETW' 
              AND T$RETW.CONSTANT   = SOURCETABLE.T$RETW 
            /*RETURNCOMPONENTS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RCOM 
             ON   T$RCOM.TABLENAME  = 'TDISA001' 
              AND T$RCOM.COLUMNNAME = 'T$RCOM' 
              AND T$RCOM.CONSTANT   = SOURCETABLE.T$RCOM 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,T$ACCI.CONSTANTDESCRIPTION                                                                                                          AS ACCESSORIESALLOWEDDESCRIPTION 
            ,CAST(T$ACCI AS INT)                                                                                                                 AS ACCESSORIESALLOWEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMGP)),'')                                                                                         AS COMMISSIONGROUP 
            ,T$ACOM.CONSTANTDESCRIPTION                                                                                                          AS COMMITMENTPOLICYDESCRIPTION 
            ,CAST(T$ACOM AS INT)                                                                                                                 AS COMMITMENTPOLICYID 
            ,CAST(T$DDFQ AS NUMERIC(15,2))                                                                                                       AS DIRECTDELIVERYFROMQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,SOURCETABLE.T$TXTS   /* TEXT */                                                                                                     AS ITEMSALESTEXT 
            ,CAST(CASE WHEN T$LTSP<= '1/1/1970' THEN NULL ELSE T$LTSP  END AS DATETIME) AS LASTSALESPRICETRANSACTIONDATE 
            ,CAST(T$LMSP AS NUMERIC(15,2))                                                                                                       AS LOWERMARGIN 
            ,CAST(T$MNQO AS NUMERIC(15,2))                                                                                                       AS MINIMUMORDERQUANTITY 
            ,CAST(T$MNQA AS NUMERIC(15,2))                                                                                                       AS MINIMUMQUANTITYTOCOMMIT 
            ,CAST(T$MNRA AS NUMERIC(15,2))                                                                                                       AS MINIMUMRATEFORCOMMITMENT 
            ,T$RETW.CONSTANTDESCRIPTION                                                                                                          AS RELEASETOWAREHOUSEDESCRIPTION 
            ,CAST(T$RETW AS INT)                                                                                                                 AS RELEASETOWAREHOUSEID 
            ,T$RCOM.CONSTANTDESCRIPTION                                                                                                          AS RETURNCOMPONENTSDESCRIPTION 
            ,CAST(T$RCOM AS INT)                                                                                                                 AS RETURNCOMPONENTSID 
            ,CAST(T$PRIS AS NUMERIC(15,2))                                                                                                       AS SALESPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPGS)),'')                                                                                         AS SALESPRICEGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RBGP)),'')                                                                                         AS SALESREBATEGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGS)),'')                                                                                         AS SALESSTATISTICSGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS SALESUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEYI 
            ,CAST(T$PRIR AS NUMERIC(15,2))                                                                                                       AS SUGGESTEDRETAILPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,CAST(T$UMSP AS NUMERIC(15,2))                                                                                                       AS UPPERMARGIN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDISA001201") }} AS SOURCETABLE  
            /*ACCESSORIESALLOWED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACCI 
             ON   T$ACCI.TABLENAME  = 'TDISA001' 
              AND T$ACCI.COLUMNNAME = 'T$ACCI' 
              AND T$ACCI.CONSTANT   = SOURCETABLE.T$ACCI 
            /*COMMITMENTPOLICY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACOM 
             ON   T$ACOM.TABLENAME  = 'TDISA001' 
              AND T$ACOM.COLUMNNAME = 'T$ACOM' 
              AND T$ACOM.CONSTANT   = SOURCETABLE.T$ACOM 
            /*RELEASETOWAREHOUSE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RETW 
             ON   T$RETW.TABLENAME  = 'TDISA001' 
              AND T$RETW.COLUMNNAME = 'T$RETW' 
              AND T$RETW.CONSTANT   = SOURCETABLE.T$RETW 
            /*RETURNCOMPONENTS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RCOM 
             ON   T$RCOM.TABLENAME  = 'TDISA001' 
              AND T$RCOM.COLUMNNAME = 'T$RCOM' 
              AND T$RCOM.CONSTANT   = SOURCETABLE.T$RCOM 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCESSORIESALLOWEDDESCRIPTION AS ACCESSORIESALLOWEDDESCRIPTION, 
        source_data.ACCESSORIESALLOWEDID AS ACCESSORIESALLOWEDID, 
        source_data.COMMISSIONGROUP AS COMMISSIONGROUP, 
        source_data.COMMITMENTPOLICYDESCRIPTION AS COMMITMENTPOLICYDESCRIPTION, 
        source_data.COMMITMENTPOLICYID AS COMMITMENTPOLICYID, 
        source_data.DIRECTDELIVERYFROMQUANTITY AS DIRECTDELIVERYFROMQUANTITY, 
        source_data.ITEM AS ITEM, 
        source_data.ITEMSALESTEXT AS ITEMSALESTEXT, 
        source_data.LASTSALESPRICETRANSACTIONDATE AS LASTSALESPRICETRANSACTIONDATE, 
        source_data.LOWERMARGIN AS LOWERMARGIN, 
        source_data.MINIMUMORDERQUANTITY AS MINIMUMORDERQUANTITY, 
        source_data.MINIMUMQUANTITYTOCOMMIT AS MINIMUMQUANTITYTOCOMMIT, 
        source_data.MINIMUMRATEFORCOMMITMENT AS MINIMUMRATEFORCOMMITMENT, 
        source_data.RELEASETOWAREHOUSEDESCRIPTION AS RELEASETOWAREHOUSEDESCRIPTION, 
        source_data.RELEASETOWAREHOUSEID AS RELEASETOWAREHOUSEID, 
        source_data.RETURNCOMPONENTSDESCRIPTION AS RETURNCOMPONENTSDESCRIPTION, 
        source_data.RETURNCOMPONENTSID AS RETURNCOMPONENTSID, 
        source_data.SALESPRICE AS SALESPRICE, 
        source_data.SALESPRICEGROUP AS SALESPRICEGROUP, 
        source_data.SALESPRICEUNIT AS SALESPRICEUNIT, 
        source_data.SALESREBATEGROUP AS SALESREBATEGROUP, 
        source_data.SALESSTATISTICSGROUP AS SALESSTATISTICSGROUP, 
        source_data.SALESUNIT AS SALESUNIT, 
        source_data.SEARCHKEYI AS SEARCHKEYI, 
        source_data.SUGGESTEDRETAILPRICE AS SUGGESTEDRETAILPRICE, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.UPPERMARGIN AS UPPERMARGIN, 
        source_data.WAREHOUSE AS WAREHOUSE
        FROM source_data
        )
,type_data as 
(
    select 
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        ACCESSORIESALLOWEDDESCRIPTION,
        cast(ACCESSORIESALLOWEDID as NUMBER(38,0)) as ACCESSORIESALLOWEDID,
        COMMISSIONGROUP,
        COMMITMENTPOLICYDESCRIPTION,
        cast(COMMITMENTPOLICYID as NUMBER(38,0)) as COMMITMENTPOLICYID,
        cast(DIRECTDELIVERYFROMQUANTITY as NUMBER(15,2)) as DIRECTDELIVERYFROMQUANTITY,
        ITEM,
        cast(ITEMSALESTEXT as NUMBER(38,10)) as ITEMSALESTEXT,
        cast(LASTSALESPRICETRANSACTIONDATE as TIMESTAMP_NTZ(9)) as LASTSALESPRICETRANSACTIONDATE,
        cast(LOWERMARGIN as NUMBER(15,2)) as LOWERMARGIN,
        cast(MINIMUMORDERQUANTITY as NUMBER(15,2)) as MINIMUMORDERQUANTITY,
        cast(MINIMUMQUANTITYTOCOMMIT as NUMBER(15,2)) as MINIMUMQUANTITYTOCOMMIT,
        cast(MINIMUMRATEFORCOMMITMENT as NUMBER(15,2)) as MINIMUMRATEFORCOMMITMENT,
        RELEASETOWAREHOUSEDESCRIPTION,
        cast(RELEASETOWAREHOUSEID as NUMBER(38,0)) as RELEASETOWAREHOUSEID,
        RETURNCOMPONENTSDESCRIPTION,
        cast(RETURNCOMPONENTSID as NUMBER(38,0)) as RETURNCOMPONENTSID,
        cast(SALESPRICE as NUMBER(15,2)) as SALESPRICE,
        SALESPRICEGROUP,
        SALESPRICEUNIT,
        SALESREBATEGROUP,
        SALESSTATISTICSGROUP,
        SALESUNIT,
        SEARCHKEYI,
        cast(SUGGESTEDRETAILPRICE as NUMBER(15,2)) as SUGGESTEDRETAILPRICE,
        TAXCODE,
        cast(UPPERMARGIN as NUMBER(15,2)) as UPPERMARGIN,
        WAREHOUSE
    from transform_data
    )
select * from type_data