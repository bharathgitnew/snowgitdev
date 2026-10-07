/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONDISTRIBUTIONITEMDATA_ITEMSUPPLIERINFORMATION.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONDISTRIBUTIONITEMDATA_ITEMSUPPLIERINFORMATION.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONDISTRIBUTIONITEMDATA_ITEMSUPPLIERINFORMATION 
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
    alias='BAANDISTRIBUTIONDISTRIBUTIONITEMDATA_ITEMSUPPLIERINFORMATION',
    unique_key = ['BUYFROM_PERCENT_BUSINESSPARTNER',
    'EFFECTIVEDATE',
    'ITEM',
    'ITEMGROUP',
    'SHIPFROMBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,T$APPR.CONSTANTDESCRIPTION                                                                                                          AS APPROVEDDESCRIPTION 
            ,CAST(T$APPR AS INT)                                                                                                                 AS APPROVEDID 
            ,T$AUTH.CONSTANTDESCRIPTION                                                                                                          AS AUTHORIZATIONSDESCRIPTION 
            ,CAST(T$AUTH AS INT)                                                                                                                 AS AUTHORIZATIONSID 
            ,T$BLCK.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BLCK AS INT)                                                                                                                 AS BLOCKEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BREA)),'')                                                                                         AS BLOCKINGREASON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                         AS BUYFROM_percent_BUSINESSPARTNER 
            ,CAST(T$CLDT AS BIGINT)                                                                                                              AS CALCLEADTIME 
            ,T$CAPT.CONSTANTDESCRIPTION                                                                                                          AS CAPACITYTIMEUNITDESCRIPTION 
            ,CAST(T$CAPT AS INT)                                                                                                                 AS CAPACITYTIMEUNITID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                         AS CARRIER 
            ,T$CONS.CONSTANTDESCRIPTION                                                                                                          AS CONSIGNEDDESCRIPTION 
            ,CAST(T$CONS AS INT)                                                                                                                 AS CONSIGNEDID 
            ,T$CUMS.CONSTANTDESCRIPTION                                                                                                          AS CUMULATIVESDESCRIPTION 
            ,CAST(T$CUMS AS INT)                                                                                                                 AS CUMULATIVESID 
            ,CAST(T$RTDM AS INT)                                                                                                                 AS DELIVERYDATETOLERANCE_ 
            ,CAST(T$RTDP AS INT)                                                                                                                 AS DELIVERYDATETOLERANCE_PLUS 
            ,CAST(T$ECOQ AS NUMERIC(15,2))                                                                                                       AS ECONOMICORDERQUANTITY 
            ,CAST(CASE WHEN T$EFDT<= '1/1/1970' THEN NULL ELSE T$EFDT  END AS DATETIME) AS EFFECTIVEDATE 
            ,CAST(CASE WHEN T$EXDT<= '1/1/1970' THEN NULL ELSE T$EXDT  END AS DATETIME) AS EXPIRATIONDATE 
            ,CAST(T$FIOQ AS NUMERIC(15,2))                                                                                                       AS FIXEDORDERQUANTITY 
            ,CAST(T$FREL AS INT)                                                                                                                 AS FREEZINGTIMEREDUCEREQ 
            ,CAST(T$FREH AS INT)                                                                                                                 AS FREEZTIMEINCREASEREQ 
            ,T$QUAL.CONSTANTDESCRIPTION                                                                                                          AS INSPECTIONDESCRIPTION 
            ,CAST(T$QUAL AS INT)                                                                                                                 AS INSPECTIONID 
            ,CAST(T$IPTI AS INT)                                                                                                                 AS INTERNALPROCESSINGTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITG)),'')                                                                                         AS ITEMGROUP 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS ITEMPURCHASETEXT 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ITEMPURCHASETEXTINTERNAL 
            ,CAST(T$OLTF AS INT)                                                                                                                 AS LEADTIMEHORIZON 
            ,T$MATR.CONSTANTDESCRIPTION                                                                                                          AS MATERIALRELEASETYPEDESCRIPTION 
            ,CAST(T$MATR AS INT)                                                                                                                 AS MATERIALRELEASETYPEID 
            ,CAST(T$CAPU AS NUMERIC(15,2))                                                                                                       AS MAXIMUMCAPACITYTOLERANCE 
            ,CAST(T$MAOQ AS NUMERIC(15,2))                                                                                                       AS MAXIMUMORDERQUANTITY 
            ,CAST(T$CAPD AS NUMERIC(15,2))                                                                                                       AS MINIMUMCAPACITYTOLERANCE 
            ,CAST(T$MIOQ AS NUMERIC(15,2))                                                                                                       AS MINIMUMORDERQUANTITY 
            ,T$NSCH.CONSTANTDESCRIPTION                                                                                                          AS NEWSCHEDULERELEASEDESCRIPTION 
            ,CAST(T$NSCH AS INT)                                                                                                                 AS NEWSCHEDULERELEASEID 
            ,CAST(T$OQMF AS NUMERIC(15,2))                                                                                                       AS ORDER_QUANTITYMULTIPLEOF 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PCOD)),'')                                                                                         AS PATTERNCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPDT)),'')                                                                                         AS PERIODTABLECODE 
            ,T$PREF.CONSTANTDESCRIPTION                                                                                                          AS PREFERREDDESCRIPTION 
            ,CAST(T$PREF AS INT)                                                                                                                 AS PREFERREDID 
            ,CAST(T$PRIO AS BIGINT)                                                                                                              AS PRIORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS PURCHASEOFFICE 
            ,CAST(T$RTQM AS NUMERIC(15,2))                                                                                                       AS QUANTITYTOLERANCE_ 
            ,CAST(T$RTQP AS NUMERIC(15,2))                                                                                                       AS QUANTITYTOLERANCE_PLUS 
            ,T$DEMR.CONSTANTDESCRIPTION                                                                                                          AS RELEASEEDIMESSAGESDIRECTLYDESCRIPTION 
            ,CAST(T$DEMR AS INT)                                                                                                                 AS RELEASEEDIMESSAGESDIRECTLYID 
            ,CAST(T$SFTI AS INT)                                                                                                                 AS SAFETYTIME 
            ,T$FORM.CONSTANTDESCRIPTION                                                                                                          AS SCHEDULEFORMATDESCRIPTION 
            ,CAST(T$FORM AS INT)                                                                                                                 AS SCHEDULEFORMATID 
            ,T$SCFU.CONSTANTDESCRIPTION                                                                                                          AS SCHEDULEORDERTYPEDESCRIPTION 
            ,CAST(T$SCFU AS INT)                                                                                                                 AS SCHEDULEORDERTYPEID 
            ,T$SCRD.CONSTANTDESCRIPTION                                                                                                          AS SCHEDULERELEASEDETAILDESCRIPTION 
            ,CAST(T$SCRD AS INT)                                                                                                                 AS SCHEDULERELEASEDETAILID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEGS)),'')                                                                                         AS SEGMENTSET 
            ,T$SBIM.CONSTANTDESCRIPTION                                                                                                          AS SELFBILLEDINVOICEDESCRIPTION 
            ,CAST(T$SBIM AS INT)                                                                                                                 AS SELFBILLEDINVOICEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFBP)),'')                                                                                         AS SHIPFROMBUSINESSPARTNER 
            ,T$DEPU.CONSTANTDESCRIPTION                                                                                                          AS SHIPMENTORDELIVERYBASEDDESCRIPTION 
            ,CAST(T$DEPU AS INT)                                                                                                                 AS SHIPMENTORDELIVERYBASEDID 
            ,CAST(T$SRCP AS NUMERIC(15,2))                                                                                                       AS SOURCINGPERCENTAGE 
            ,CAST(T$CAPQ AS NUMERIC(15,2))                                                                                                       AS SUPPLIERCAPACITY 
            ,CAST(T$SUTI AS INT)                                                                                                                 AS SUPPLYTIME 
            ,T$IPTU.CONSTANTDESCRIPTION                                                                                                          AS UNITFORINTERNALPROCESSINGTIMEDESCRIPTION 
            ,CAST(T$IPTU AS INT)                                                                                                                 AS UNITFORINTERNALPROCESSINGTIMEID 
            ,T$SFTU.CONSTANTDESCRIPTION                                                                                                          AS UNITFORSAFETYTIMEDESCRIPTION 
            ,CAST(T$SFTU AS INT)                                                                                                                 AS UNITFORSAFETYTIMEID 
            ,T$SUTU.CONSTANTDESCRIPTION                                                                                                          AS UNITFORSUPPLYTIMEDESCRIPTION 
            ,CAST(T$SUTU AS INT)                                                                                                                 AS UNITFORSUPPLYTIMEID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDIPU010201") }} AS SOURCETABLE  
            /*APPROVED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$APPR 
             ON   T$APPR.TABLENAME  = 'TDIPU010' 
              AND T$APPR.COLUMNNAME = 'T$APPR' 
              AND T$APPR.CONSTANT   = SOURCETABLE.T$APPR 
            /*AUTHORIZATIONS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$AUTH 
             ON   T$AUTH.TABLENAME  = 'TDIPU010' 
              AND T$AUTH.COLUMNNAME = 'T$AUTH' 
              AND T$AUTH.CONSTANT   = SOURCETABLE.T$AUTH 
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLCK 
             ON   T$BLCK.TABLENAME  = 'TDIPU010' 
              AND T$BLCK.COLUMNNAME = 'T$BLCK' 
              AND T$BLCK.CONSTANT   = SOURCETABLE.T$BLCK 
            /*CAPACITYTIMEUNIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CAPT 
             ON   T$CAPT.TABLENAME  = 'TDIPU010' 
              AND T$CAPT.COLUMNNAME = 'T$CAPT' 
              AND T$CAPT.CONSTANT   = SOURCETABLE.T$CAPT 
            /*CONSIGNED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CONS 
             ON   T$CONS.TABLENAME  = 'TDIPU010' 
              AND T$CONS.COLUMNNAME = 'T$CONS' 
              AND T$CONS.CONSTANT   = SOURCETABLE.T$CONS 
            /*CUMULATIVES*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CUMS 
             ON   T$CUMS.TABLENAME  = 'TDIPU010' 
              AND T$CUMS.COLUMNNAME = 'T$CUMS' 
              AND T$CUMS.CONSTANT   = SOURCETABLE.T$CUMS 
            /*INSPECTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QUAL 
             ON   T$QUAL.TABLENAME  = 'TDIPU010' 
              AND T$QUAL.COLUMNNAME = 'T$QUAL' 
              AND T$QUAL.CONSTANT   = SOURCETABLE.T$QUAL 
            /*MATERIALRELEASETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MATR 
             ON   T$MATR.TABLENAME  = 'TDIPU010' 
              AND T$MATR.COLUMNNAME = 'T$MATR' 
              AND T$MATR.CONSTANT   = SOURCETABLE.T$MATR 
            /*NEWSCHEDULERELEASE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$NSCH 
             ON   T$NSCH.TABLENAME  = 'TDIPU010' 
              AND T$NSCH.COLUMNNAME = 'T$NSCH' 
              AND T$NSCH.CONSTANT   = SOURCETABLE.T$NSCH 
            /*PREFERRED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PREF 
             ON   T$PREF.TABLENAME  = 'TDIPU010' 
              AND T$PREF.COLUMNNAME = 'T$PREF' 
              AND T$PREF.CONSTANT   = SOURCETABLE.T$PREF 
            /*RELEASEEDIMESSAGESDIRECTLY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEMR 
             ON   T$DEMR.TABLENAME  = 'TDIPU010' 
              AND T$DEMR.COLUMNNAME = 'T$DEMR' 
              AND T$DEMR.CONSTANT   = SOURCETABLE.T$DEMR 
            /*SCHEDULEFORMAT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FORM 
             ON   T$FORM.TABLENAME  = 'TDIPU010' 
              AND T$FORM.COLUMNNAME = 'T$FORM' 
              AND T$FORM.CONSTANT   = SOURCETABLE.T$FORM 
            /*SCHEDULEORDERTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCFU 
             ON   T$SCFU.TABLENAME  = 'TDIPU010' 
              AND T$SCFU.COLUMNNAME = 'T$SCFU' 
              AND T$SCFU.CONSTANT   = SOURCETABLE.T$SCFU 
            /*SCHEDULERELEASEDETAIL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCRD 
             ON   T$SCRD.TABLENAME  = 'TDIPU010' 
              AND T$SCRD.COLUMNNAME = 'T$SCRD' 
              AND T$SCRD.CONSTANT   = SOURCETABLE.T$SCRD 
            /*SELFBILLEDINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SBIM 
             ON   T$SBIM.TABLENAME  = 'TDIPU010' 
              AND T$SBIM.COLUMNNAME = 'T$SBIM' 
              AND T$SBIM.CONSTANT   = SOURCETABLE.T$SBIM 
            /*SHIPMENTORDELIVERYBASED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEPU 
             ON   T$DEPU.TABLENAME  = 'TDIPU010' 
              AND T$DEPU.COLUMNNAME = 'T$DEPU' 
              AND T$DEPU.CONSTANT   = SOURCETABLE.T$DEPU 
            /*UNITFORINTERNALPROCESSINGTIME*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$IPTU 
             ON   T$IPTU.TABLENAME  = 'TDIPU010' 
              AND T$IPTU.COLUMNNAME = 'T$IPTU' 
              AND T$IPTU.CONSTANT   = SOURCETABLE.T$IPTU 
            /*UNITFORSAFETYTIME*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SFTU 
             ON   T$SFTU.TABLENAME  = 'TDIPU010' 
              AND T$SFTU.COLUMNNAME = 'T$SFTU' 
              AND T$SFTU.CONSTANT   = SOURCETABLE.T$SFTU 
            /*UNITFORSUPPLYTIME*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SUTU 
             ON   T$SUTU.TABLENAME  = 'TDIPU010' 
              AND T$SUTU.COLUMNNAME = 'T$SUTU' 
              AND T$SUTU.CONSTANT   = SOURCETABLE.T$SUTU 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.APPROVEDDESCRIPTION AS APPROVEDDESCRIPTION, 
        source_data.APPROVEDID AS APPROVEDID, 
        source_data.AUTHORIZATIONSDESCRIPTION AS AUTHORIZATIONSDESCRIPTION, 
        source_data.AUTHORIZATIONSID AS AUTHORIZATIONSID, 
        source_data.BLOCKEDDESCRIPTION AS BLOCKEDDESCRIPTION, 
        source_data.BLOCKEDID AS BLOCKEDID, 
        source_data.BLOCKINGREASON AS BLOCKINGREASON, 
        source_data.BUYFROM_PERCENT_BUSINESSPARTNER AS BUYFROM_PERCENT_BUSINESSPARTNER, 
        source_data.CALCLEADTIME AS CALCLEADTIME, 
        source_data.CAPACITYTIMEUNITDESCRIPTION AS CAPACITYTIMEUNITDESCRIPTION, 
        source_data.CAPACITYTIMEUNITID AS CAPACITYTIMEUNITID, 
        source_data.CARRIER AS CARRIER, 
        source_data.CONSIGNEDDESCRIPTION AS CONSIGNEDDESCRIPTION, 
        source_data.CONSIGNEDID AS CONSIGNEDID, 
        source_data.CUMULATIVESDESCRIPTION AS CUMULATIVESDESCRIPTION, 
        source_data.CUMULATIVESID AS CUMULATIVESID, 
        source_data.DELIVERYDATETOLERANCE_ AS DELIVERYDATETOLERANCE_, 
        source_data.DELIVERYDATETOLERANCE_PLUS AS DELIVERYDATETOLERANCE_PLUS, 
        source_data.ECONOMICORDERQUANTITY AS ECONOMICORDERQUANTITY, 
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.EXPIRATIONDATE AS EXPIRATIONDATE, 
        source_data.FIXEDORDERQUANTITY AS FIXEDORDERQUANTITY, 
        source_data.FREEZINGTIMEREDUCEREQ AS FREEZINGTIMEREDUCEREQ, 
        source_data.FREEZTIMEINCREASEREQ AS FREEZTIMEINCREASEREQ, 
        source_data.INSPECTIONDESCRIPTION AS INSPECTIONDESCRIPTION, 
        source_data.INSPECTIONID AS INSPECTIONID, 
        source_data.INTERNALPROCESSINGTIME AS INTERNALPROCESSINGTIME, 
        source_data.ITEM AS ITEM, 
        source_data.ITEMGROUP AS ITEMGROUP, 
        source_data.ITEMPURCHASETEXT AS ITEMPURCHASETEXT, 
        source_data.ITEMPURCHASETEXTINTERNAL AS ITEMPURCHASETEXTINTERNAL, 
        source_data.LEADTIMEHORIZON AS LEADTIMEHORIZON, 
        source_data.MATERIALRELEASETYPEDESCRIPTION AS MATERIALRELEASETYPEDESCRIPTION, 
        source_data.MATERIALRELEASETYPEID AS MATERIALRELEASETYPEID, 
        source_data.MAXIMUMCAPACITYTOLERANCE AS MAXIMUMCAPACITYTOLERANCE, 
        source_data.MAXIMUMORDERQUANTITY AS MAXIMUMORDERQUANTITY, 
        source_data.MINIMUMCAPACITYTOLERANCE AS MINIMUMCAPACITYTOLERANCE, 
        source_data.MINIMUMORDERQUANTITY AS MINIMUMORDERQUANTITY, 
        source_data.NEWSCHEDULERELEASEDESCRIPTION AS NEWSCHEDULERELEASEDESCRIPTION, 
        source_data.NEWSCHEDULERELEASEID AS NEWSCHEDULERELEASEID, 
        source_data.ORDER_QUANTITYMULTIPLEOF AS ORDER_QUANTITYMULTIPLEOF, 
        source_data.PATTERNCODE AS PATTERNCODE, 
        source_data.PERIODTABLECODE AS PERIODTABLECODE, 
        source_data.PREFERREDDESCRIPTION AS PREFERREDDESCRIPTION, 
        source_data.PREFERREDID AS PREFERREDID, 
        source_data.PRIORITY AS PRIORITY, 
        source_data.PURCHASEOFFICE AS PURCHASEOFFICE, 
        source_data.QUANTITYTOLERANCE_ AS QUANTITYTOLERANCE_, 
        source_data.QUANTITYTOLERANCE_PLUS AS QUANTITYTOLERANCE_PLUS, 
        source_data.RELEASEEDIMESSAGESDIRECTLYDESCRIPTION AS RELEASEEDIMESSAGESDIRECTLYDESCRIPTION, 
        source_data.RELEASEEDIMESSAGESDIRECTLYID AS RELEASEEDIMESSAGESDIRECTLYID, 
        source_data.SAFETYTIME AS SAFETYTIME, 
        source_data.SCHEDULEFORMATDESCRIPTION AS SCHEDULEFORMATDESCRIPTION, 
        source_data.SCHEDULEFORMATID AS SCHEDULEFORMATID, 
        source_data.SCHEDULEORDERTYPEDESCRIPTION AS SCHEDULEORDERTYPEDESCRIPTION, 
        source_data.SCHEDULEORDERTYPEID AS SCHEDULEORDERTYPEID, 
        source_data.SCHEDULERELEASEDETAILDESCRIPTION AS SCHEDULERELEASEDETAILDESCRIPTION, 
        source_data.SCHEDULERELEASEDETAILID AS SCHEDULERELEASEDETAILID, 
        source_data.SEGMENTSET AS SEGMENTSET, 
        source_data.SELFBILLEDINVOICEDESCRIPTION AS SELFBILLEDINVOICEDESCRIPTION, 
        source_data.SELFBILLEDINVOICEID AS SELFBILLEDINVOICEID, 
        source_data.SHIPFROMBUSINESSPARTNER AS SHIPFROMBUSINESSPARTNER, 
        source_data.SHIPMENTORDELIVERYBASEDDESCRIPTION AS SHIPMENTORDELIVERYBASEDDESCRIPTION, 
        source_data.SHIPMENTORDELIVERYBASEDID AS SHIPMENTORDELIVERYBASEDID, 
        source_data.SOURCINGPERCENTAGE AS SOURCINGPERCENTAGE, 
        source_data.SUPPLIERCAPACITY AS SUPPLIERCAPACITY, 
        source_data.SUPPLYTIME AS SUPPLYTIME, 
        source_data.UNITFORINTERNALPROCESSINGTIMEDESCRIPTION AS UNITFORINTERNALPROCESSINGTIMEDESCRIPTION, 
        source_data.UNITFORINTERNALPROCESSINGTIMEID AS UNITFORINTERNALPROCESSINGTIMEID, 
        source_data.UNITFORSAFETYTIMEDESCRIPTION AS UNITFORSAFETYTIMEDESCRIPTION, 
        source_data.UNITFORSAFETYTIMEID AS UNITFORSAFETYTIMEID, 
        source_data.UNITFORSUPPLYTIMEDESCRIPTION AS UNITFORSUPPLYTIMEDESCRIPTION, 
        source_data.UNITFORSUPPLYTIMEID AS UNITFORSUPPLYTIMEID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(APPROVEDDESCRIPTION as VARCHAR(16777216)) as APPROVEDDESCRIPTION,
        cast(APPROVEDID as NUMBER(38,0)) as APPROVEDID,
        cast(AUTHORIZATIONSDESCRIPTION as VARCHAR(16777216)) as AUTHORIZATIONSDESCRIPTION,
        cast(AUTHORIZATIONSID as NUMBER(38,0)) as AUTHORIZATIONSID,
        cast(BLOCKEDDESCRIPTION as VARCHAR(16777216)) as BLOCKEDDESCRIPTION,
        cast(BLOCKEDID as NUMBER(38,0)) as BLOCKEDID,
        cast(BLOCKINGREASON as VARCHAR(6)) as BLOCKINGREASON,
        cast(BUYFROM_PERCENT_BUSINESSPARTNER as VARCHAR(9)) as BUYFROM_PERCENT_BUSINESSPARTNER,
        cast(CALCLEADTIME as NUMBER(38,0)) as CALCLEADTIME,
        cast(CAPACITYTIMEUNITDESCRIPTION as VARCHAR(16777216)) as CAPACITYTIMEUNITDESCRIPTION,
        cast(CAPACITYTIMEUNITID as NUMBER(38,0)) as CAPACITYTIMEUNITID,
        cast(CARRIER as VARCHAR(3)) as CARRIER,
        cast(CONSIGNEDDESCRIPTION as VARCHAR(16777216)) as CONSIGNEDDESCRIPTION,
        cast(CONSIGNEDID as NUMBER(38,0)) as CONSIGNEDID,
        cast(CUMULATIVESDESCRIPTION as VARCHAR(16777216)) as CUMULATIVESDESCRIPTION,
        cast(CUMULATIVESID as NUMBER(38,0)) as CUMULATIVESID,
        cast(DELIVERYDATETOLERANCE_ as NUMBER(38,0)) as DELIVERYDATETOLERANCE_,
        cast(DELIVERYDATETOLERANCE_PLUS as NUMBER(38,0)) as DELIVERYDATETOLERANCE_PLUS,
        cast(ECONOMICORDERQUANTITY as NUMBER(15,2)) as ECONOMICORDERQUANTITY,
        cast(EFFECTIVEDATE as TIMESTAMP_NTZ(9)) as EFFECTIVEDATE,
        cast(EXPIRATIONDATE as TIMESTAMP_NTZ(9)) as EXPIRATIONDATE,
        cast(FIXEDORDERQUANTITY as NUMBER(15,2)) as FIXEDORDERQUANTITY,
        cast(FREEZINGTIMEREDUCEREQ as NUMBER(38,0)) as FREEZINGTIMEREDUCEREQ,
        cast(FREEZTIMEINCREASEREQ as NUMBER(38,0)) as FREEZTIMEINCREASEREQ,
        cast(INSPECTIONDESCRIPTION as VARCHAR(16777216)) as INSPECTIONDESCRIPTION,
        cast(INSPECTIONID as NUMBER(38,0)) as INSPECTIONID,
        cast(INTERNALPROCESSINGTIME as NUMBER(38,0)) as INTERNALPROCESSINGTIME,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ITEMGROUP as VARCHAR(6)) as ITEMGROUP,
        cast(ITEMPURCHASETEXT as NUMBER(38,10)) as ITEMPURCHASETEXT,
        cast(ITEMPURCHASETEXTINTERNAL as NUMBER(38,10)) as ITEMPURCHASETEXTINTERNAL,
        cast(LEADTIMEHORIZON as NUMBER(38,0)) as LEADTIMEHORIZON,
        cast(MATERIALRELEASETYPEDESCRIPTION as VARCHAR(16777216)) as MATERIALRELEASETYPEDESCRIPTION,
        cast(MATERIALRELEASETYPEID as NUMBER(38,0)) as MATERIALRELEASETYPEID,
        cast(MAXIMUMCAPACITYTOLERANCE as NUMBER(15,2)) as MAXIMUMCAPACITYTOLERANCE,
        cast(MAXIMUMORDERQUANTITY as NUMBER(15,2)) as MAXIMUMORDERQUANTITY,
        cast(MINIMUMCAPACITYTOLERANCE as NUMBER(15,2)) as MINIMUMCAPACITYTOLERANCE,
        cast(MINIMUMORDERQUANTITY as NUMBER(15,2)) as MINIMUMORDERQUANTITY,
        cast(NEWSCHEDULERELEASEDESCRIPTION as VARCHAR(16777216)) as NEWSCHEDULERELEASEDESCRIPTION,
        cast(NEWSCHEDULERELEASEID as NUMBER(38,0)) as NEWSCHEDULERELEASEID,
        cast(ORDER_QUANTITYMULTIPLEOF as NUMBER(15,2)) as ORDER_QUANTITYMULTIPLEOF,
        cast(PATTERNCODE as VARCHAR(3)) as PATTERNCODE,
        cast(PERIODTABLECODE as VARCHAR(6)) as PERIODTABLECODE,
        cast(PREFERREDDESCRIPTION as VARCHAR(16777216)) as PREFERREDDESCRIPTION,
        cast(PREFERREDID as NUMBER(38,0)) as PREFERREDID,
        cast(PRIORITY as NUMBER(38,0)) as PRIORITY,
        cast(PURCHASEOFFICE as VARCHAR(6)) as PURCHASEOFFICE,
        cast(QUANTITYTOLERANCE_ as NUMBER(15,2)) as QUANTITYTOLERANCE_,
        cast(QUANTITYTOLERANCE_PLUS as NUMBER(15,2)) as QUANTITYTOLERANCE_PLUS,
        cast(RELEASEEDIMESSAGESDIRECTLYDESCRIPTION as VARCHAR(16777216)) as RELEASEEDIMESSAGESDIRECTLYDESCRIPTION,
        cast(RELEASEEDIMESSAGESDIRECTLYID as NUMBER(38,0)) as RELEASEEDIMESSAGESDIRECTLYID,
        cast(SAFETYTIME as NUMBER(38,0)) as SAFETYTIME,
        cast(SCHEDULEFORMATDESCRIPTION as VARCHAR(16777216)) as SCHEDULEFORMATDESCRIPTION,
        cast(SCHEDULEFORMATID as NUMBER(38,0)) as SCHEDULEFORMATID,
        cast(SCHEDULEORDERTYPEDESCRIPTION as VARCHAR(16777216)) as SCHEDULEORDERTYPEDESCRIPTION,
        cast(SCHEDULEORDERTYPEID as NUMBER(38,0)) as SCHEDULEORDERTYPEID,
        cast(SCHEDULERELEASEDETAILDESCRIPTION as VARCHAR(16777216)) as SCHEDULERELEASEDETAILDESCRIPTION,
        cast(SCHEDULERELEASEDETAILID as NUMBER(38,0)) as SCHEDULERELEASEDETAILID,
        cast(SEGMENTSET as VARCHAR(3)) as SEGMENTSET,
        cast(SELFBILLEDINVOICEDESCRIPTION as VARCHAR(16777216)) as SELFBILLEDINVOICEDESCRIPTION,
        cast(SELFBILLEDINVOICEID as NUMBER(38,0)) as SELFBILLEDINVOICEID,
        cast(SHIPFROMBUSINESSPARTNER as VARCHAR(9)) as SHIPFROMBUSINESSPARTNER,
        cast(SHIPMENTORDELIVERYBASEDDESCRIPTION as VARCHAR(16777216)) as SHIPMENTORDELIVERYBASEDDESCRIPTION,
        cast(SHIPMENTORDELIVERYBASEDID as NUMBER(38,0)) as SHIPMENTORDELIVERYBASEDID,
        cast(SOURCINGPERCENTAGE as NUMBER(15,2)) as SOURCINGPERCENTAGE,
        cast(SUPPLIERCAPACITY as NUMBER(15,2)) as SUPPLIERCAPACITY,
        cast(SUPPLYTIME as NUMBER(38,0)) as SUPPLYTIME,
        cast(UNITFORINTERNALPROCESSINGTIMEDESCRIPTION as VARCHAR(16777216)) as UNITFORINTERNALPROCESSINGTIMEDESCRIPTION,
        cast(UNITFORINTERNALPROCESSINGTIMEID as NUMBER(38,0)) as UNITFORINTERNALPROCESSINGTIMEID,
        cast(UNITFORSAFETYTIMEDESCRIPTION as VARCHAR(16777216)) as UNITFORSAFETYTIMEDESCRIPTION,
        cast(UNITFORSAFETYTIMEID as NUMBER(38,0)) as UNITFORSAFETYTIMEID,
        cast(UNITFORSUPPLYTIMEDESCRIPTION as VARCHAR(16777216)) as UNITFORSUPPLYTIMEDESCRIPTION,
        cast(UNITFORSUPPLYTIMEID as NUMBER(38,0)) as UNITFORSUPPLYTIMEID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data