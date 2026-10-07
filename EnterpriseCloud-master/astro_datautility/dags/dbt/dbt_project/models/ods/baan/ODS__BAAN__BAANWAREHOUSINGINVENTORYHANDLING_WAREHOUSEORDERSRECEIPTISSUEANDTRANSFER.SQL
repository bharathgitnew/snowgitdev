/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYHANDLING_WAREHOUSEORDERSRECEIPTISSUEANDTRANSFER.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYHANDLING_WAREHOUSEORDERSRECEIPTISSUEANDTRANSFER.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYHANDLING_WAREHOUSEORDERSRECEIPTISSUEANDTRANSFER 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:57 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANWAREHOUSINGINVENTORYHANDLING_WAREHOUSEORDERSRECEIPTISSUEANDTRANSFER',
    unique_key = ['ORDER_',
    'ORDER_ORIGINID',
    '_SET']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$APPL$C")),'')                                                                                       AS APPLICATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CARR)),'')                                                                                         AS CARRIER 
            ,CAST("T$CASE$U" AS BIGINT)                                                                                                            AS CASENO 
            ,T$CONS.CONSTANTDESCRIPTION                                                                                                          AS CONSIGNMENTDESCRIPTION 
            ,CAST(T$CONS AS INT)                                                                                                                 AS CONSIGNMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRMC$U")),'')                                                                                       AS CRM_CASE_hash_ 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS FOOTERTEXT 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS HEADERTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INFO)),'')                                                                                         AS INFORMATION 
            ,T$ITTP.CONSTANTDESCRIPTION                                                                                                          AS INVENTORYTRANSACTIONTYPEDESCRIPTION 
            ,CAST(T$ITTP AS INT)                                                                                                                 AS INVENTORYTRANSACTIONTYPEID 
            ,T$INVC.CONSTANTDESCRIPTION                                                                                                          AS INVOICINGDESCRIPTION 
            ,CAST(T$INVC AS INT)                                                                                                                 AS INVOICINGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')                                                                                         AS LANGUAGE 
            ,CAST(T$MAXT AS NUMERIC(15,2))                                                                                                       AS MAXIMUMQUANTITY 
            ,CAST(T$MINT AS NUMERIC(15,2))                                                                                                       AS MINIMUMQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WDEP)),'')                                                                                         AS OFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_ 
            ,T$OAST.CONSTANTDESCRIPTION                                                                                                          AS ORDER_ACKNOWLEDGEMENTSTATUSDESCRIPTION 
            ,CAST(T$OAST AS INT)                                                                                                                 AS ORDER_ACKNOWLEDGEMENTSTATUSID 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME) AS ORDER_DATE 
            ,T$OORG.CONSTANTDESCRIPTION                                                                                                          AS ORDER_ORIGINDESCRIPTION 
            ,CAST(T$OORG AS INT)                                                                                                                 AS ORDER_ORIGINID 
            ,CAST(T$SETN AS INT)                                                                                                                 AS ORDER_SETSALES 
            ,CAST(CASE WHEN T$PDDT<= '1/1/1970' THEN NULL ELSE T$PDDT  END AS DATETIME) AS PLANNEDDELIVERYDATETIME 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PLANNEDRECEIPTDATE 
            ,"T$MADO$C".CONSTANTDESCRIPTION                                                                                                        AS PRIORITYDESCRIPTION 
            ,CAST("T$MADO$C" AS INT)                                                                                                               AS PRIORITYID 
            ,"T$REAS$C".CONSTANTDESCRIPTION                                                                                                        AS REASONDESCRIPTION 
            ,CAST("T$REAS$C" AS INT)                                                                                                               AS REASONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFE)),'')                                                                                         AS REFERENCE 
            ,T$RTRN.CONSTANTDESCRIPTION                                                                                                          AS RETURNORDERDESCRIPTION 
            ,CAST(T$RTRN AS INT)                                                                                                                 AS RETURNORDERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTE)),'')                                                                                         AS ROUTE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SERI$C")),'')                                                                                       AS SERIALNUMBER 
            ,CAST(T$OSET AS INT)                                                                                                                 AS _SET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFAD)),'')                                                                                         AS SHIPFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFCO)),'')                                                                                         AS SHIPFROMCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFIT)),'')                                                                                         AS SHIPFROMITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFLO)),'')                                                                                         AS SHIPFROMLOCATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFRV)),'')                                                                                         AS SHIPFROMREVISIONCODE 
            ,T$SFTY.CONSTANTDESCRIPTION                                                                                                          AS SHIPFROMTYPEDESCRIPTION 
            ,CAST(T$SFTY AS INT)                                                                                                                 AS SHIPFROMTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCO)),'')                                                                                         AS SHIPTOCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STIT)),'')                                                                                         AS SHIPTOITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STLO)),'')                                                                                         AS SHIPTOLOCATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STRV)),'')                                                                                         AS SHIPTOREVISIONCODE 
            ,T$STTY.CONSTANTDESCRIPTION                                                                                                          AS SHIPTOTYPEDESCRIPTION 
            ,CAST(T$STTY AS INT)                                                                                                                 AS SHIPTOTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDEC)),'')                                                                                         AS TERMSOFDELIVERY 
            ,CAST(T$TRPR AS NUMERIC(15,2))                                                                                                       AS TRANSFERPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTYP)),'')                                                                                         AS WAREHOUSINRDERTYPE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINH200201") }} AS SOURCETABLE  
            /*CONSIGNMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CONS 
             ON   T$CONS.TABLENAME  = 'WHINH200' 
              AND T$CONS.COLUMNNAME = 'T$CONS' 
              AND T$CONS.CONSTANT   = SOURCETABLE.T$CONS 
            /*INVENTORYTRANSACTIONTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ITTP 
             ON   T$ITTP.TABLENAME  = 'WHINH200' 
              AND T$ITTP.COLUMNNAME = 'T$ITTP' 
              AND T$ITTP.CONSTANT   = SOURCETABLE.T$ITTP 
            /*INVOICING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INVC 
             ON   T$INVC.TABLENAME  = 'WHINH200' 
              AND T$INVC.COLUMNNAME = 'T$INVC' 
              AND T$INVC.CONSTANT   = SOURCETABLE.T$INVC 
            /*ORDERACKNOWLEDGEMENTSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OAST 
             ON   T$OAST.TABLENAME  = 'WHINH200' 
              AND T$OAST.COLUMNNAME = 'T$OAST' 
              AND T$OAST.CONSTANT   = SOURCETABLE.T$OAST 
            /*ORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OORG 
             ON   T$OORG.TABLENAME  = 'WHINH200' 
              AND T$OORG.COLUMNNAME = 'T$OORG' 
              AND T$OORG.CONSTANT   = SOURCETABLE.T$OORG 
            /*PRIORITYC*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$MADO$C" 
             ON   "T$MADO$C".TABLENAME  = 'WHINH200' 
              AND "T$MADO$C".COLUMNNAME = 'T$MADO.C' 
              AND "T$MADO$C".CONSTANT   = SOURCETABLE."T$MADO$C" 
            /*REASONC*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$REAS$C" 
             ON   "T$REAS$C".TABLENAME  = 'WHINH200' 
              AND "T$REAS$C".COLUMNNAME = 'T$REAS.C' 
              AND "T$REAS$C".CONSTANT   = SOURCETABLE."T$REAS$C" 
            /*RETURNORDER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RTRN 
             ON   T$RTRN.TABLENAME  = 'WHINH200' 
              AND T$RTRN.COLUMNNAME = 'T$RTRN' 
              AND T$RTRN.CONSTANT   = SOURCETABLE.T$RTRN 
            /*SHIPFROMTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SFTY 
             ON   T$SFTY.TABLENAME  = 'WHINH200' 
              AND T$SFTY.COLUMNNAME = 'T$SFTY' 
              AND T$SFTY.CONSTANT   = SOURCETABLE.T$SFTY 
            /*SHIPTOTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STTY 
             ON   T$STTY.TABLENAME  = 'WHINH200' 
              AND T$STTY.COLUMNNAME = 'T$STTY' 
              AND T$STTY.CONSTANT   = SOURCETABLE.T$STTY 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.APPLICATION AS APPLICATION, 
        source_data.CARRIER AS CARRIER, 
        source_data.CASENO AS CASENO, 
        source_data.CONSIGNMENTDESCRIPTION AS CONSIGNMENTDESCRIPTION, 
        source_data.CONSIGNMENTID AS CONSIGNMENTID, 
        source_data.CRM_CASE_HASH_ AS CRM_CASE_HASH_, 
        source_data.FOOTERTEXT AS FOOTERTEXT, 
        source_data.HEADERTEXT AS HEADERTEXT, 
        source_data.INFORMATION AS INFORMATION, 
        source_data.INVENTORYTRANSACTIONTYPEDESCRIPTION AS INVENTORYTRANSACTIONTYPEDESCRIPTION, 
        source_data.INVENTORYTRANSACTIONTYPEID AS INVENTORYTRANSACTIONTYPEID, 
        source_data.INVOICINGDESCRIPTION AS INVOICINGDESCRIPTION, 
        source_data.INVOICINGID AS INVOICINGID, 
        source_data.LANGUAGE AS LANGUAGE, 
        source_data.MAXIMUMQUANTITY AS MAXIMUMQUANTITY, 
        source_data.MINIMUMQUANTITY AS MINIMUMQUANTITY, 
        source_data.OFFICE AS OFFICE, 
        source_data.ORDER_ AS ORDER_, 
        source_data.ORDER_ACKNOWLEDGEMENTSTATUSDESCRIPTION AS ORDER_ACKNOWLEDGEMENTSTATUSDESCRIPTION, 
        source_data.ORDER_ACKNOWLEDGEMENTSTATUSID AS ORDER_ACKNOWLEDGEMENTSTATUSID, 
        source_data.ORDER_DATE AS ORDER_DATE, 
        source_data.ORDER_ORIGINDESCRIPTION AS ORDER_ORIGINDESCRIPTION, 
        source_data.ORDER_ORIGINID AS ORDER_ORIGINID, 
        source_data.ORDER_SETSALES AS ORDER_SETSALES, 
        source_data.PLANNEDDELIVERYDATETIME AS PLANNEDDELIVERYDATETIME, 
        source_data.PLANNEDRECEIPTDATE AS PLANNEDRECEIPTDATE, 
        source_data.PRIORITYDESCRIPTION AS PRIORITYDESCRIPTION, 
        source_data.PRIORITYID AS PRIORITYID, 
        source_data.REASONDESCRIPTION AS REASONDESCRIPTION, 
        source_data.REASONID AS REASONID, 
        source_data.REFERENCE AS REFERENCE, 
        source_data.RETURNORDERDESCRIPTION AS RETURNORDERDESCRIPTION, 
        source_data.RETURNORDERID AS RETURNORDERID, 
        source_data.ROUTE AS ROUTE, 
        source_data.SERIALNUMBER AS SERIALNUMBER, 
        source_data._SET AS _SET, 
        source_data.SHIPFROMADDRESS AS SHIPFROMADDRESS, 
        source_data.SHIPFROMCODE AS SHIPFROMCODE, 
        source_data.SHIPFROMITEM AS SHIPFROMITEM, 
        source_data.SHIPFROMLOCATION AS SHIPFROMLOCATION, 
        source_data.SHIPFROMREVISIONCODE AS SHIPFROMREVISIONCODE, 
        source_data.SHIPFROMTYPEDESCRIPTION AS SHIPFROMTYPEDESCRIPTION, 
        source_data.SHIPFROMTYPEID AS SHIPFROMTYPEID, 
        source_data.SHIPTOADDRESS AS SHIPTOADDRESS, 
        source_data.SHIPTOCODE AS SHIPTOCODE, 
        source_data.SHIPTOITEM AS SHIPTOITEM, 
        source_data.SHIPTOLOCATION AS SHIPTOLOCATION, 
        source_data.SHIPTOREVISIONCODE AS SHIPTOREVISIONCODE, 
        source_data.SHIPTOTYPEDESCRIPTION AS SHIPTOTYPEDESCRIPTION, 
        source_data.SHIPTOTYPEID AS SHIPTOTYPEID, 
        source_data.TERMSOFDELIVERY AS TERMSOFDELIVERY, 
        source_data.TRANSFERPRICE AS TRANSFERPRICE, 
        source_data.WAREHOUSINRDERTYPE AS WAREHOUSINRDERTYPE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(APPLICATION as VARCHAR(12)) as APPLICATION,
        cast(CARRIER as VARCHAR(3)) as CARRIER,
        cast(CASENO as NUMBER(38,0)) as CASENO,
        cast(CONSIGNMENTDESCRIPTION as VARCHAR(16777216)) as CONSIGNMENTDESCRIPTION,
        cast(CONSIGNMENTID as NUMBER(38,0)) as CONSIGNMENTID,
        cast(CRM_CASE_HASH_ as VARCHAR(18)) as CRM_CASE_HASH_,
        cast(FOOTERTEXT as NUMBER(38,10)) as FOOTERTEXT,
        cast(HEADERTEXT as NUMBER(38,10)) as HEADERTEXT,
        cast(INFORMATION as VARCHAR(30)) as INFORMATION,
        cast(INVENTORYTRANSACTIONTYPEDESCRIPTION as VARCHAR(16777216)) as INVENTORYTRANSACTIONTYPEDESCRIPTION,
        cast(INVENTORYTRANSACTIONTYPEID as NUMBER(38,0)) as INVENTORYTRANSACTIONTYPEID,
        cast(INVOICINGDESCRIPTION as VARCHAR(16777216)) as INVOICINGDESCRIPTION,
        cast(INVOICINGID as NUMBER(38,0)) as INVOICINGID,
        cast(LANGUAGE as VARCHAR(3)) as LANGUAGE,
        cast(MAXIMUMQUANTITY as NUMBER(15,2)) as MAXIMUMQUANTITY,
        cast(MINIMUMQUANTITY as NUMBER(15,2)) as MINIMUMQUANTITY,
        cast(OFFICE as VARCHAR(6)) as OFFICE,
        cast(ORDER_ as VARCHAR(9)) as ORDER_,
        cast(ORDER_ACKNOWLEDGEMENTSTATUSDESCRIPTION as VARCHAR(16777216)) as ORDER_ACKNOWLEDGEMENTSTATUSDESCRIPTION,
        cast(ORDER_ACKNOWLEDGEMENTSTATUSID as NUMBER(38,0)) as ORDER_ACKNOWLEDGEMENTSTATUSID,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_ORIGINDESCRIPTION as VARCHAR(16777216)) as ORDER_ORIGINDESCRIPTION,
        cast(ORDER_ORIGINID as NUMBER(38,0)) as ORDER_ORIGINID,
        cast(ORDER_SETSALES as NUMBER(38,0)) as ORDER_SETSALES,
        cast(PLANNEDDELIVERYDATETIME as TIMESTAMP_NTZ(9)) as PLANNEDDELIVERYDATETIME,
        cast(PLANNEDRECEIPTDATE as TIMESTAMP_NTZ(9)) as PLANNEDRECEIPTDATE,
        cast(PRIORITYDESCRIPTION as VARCHAR(16777216)) as PRIORITYDESCRIPTION,
        cast(PRIORITYID as NUMBER(38,0)) as PRIORITYID,
        cast(REASONDESCRIPTION as VARCHAR(16777216)) as REASONDESCRIPTION,
        cast(REASONID as NUMBER(38,0)) as REASONID,
        cast(REFERENCE as VARCHAR(30)) as REFERENCE,
        cast(RETURNORDERDESCRIPTION as VARCHAR(16777216)) as RETURNORDERDESCRIPTION,
        cast(RETURNORDERID as NUMBER(38,0)) as RETURNORDERID,
        cast(ROUTE as VARCHAR(5)) as ROUTE,
        cast(SERIALNUMBER as VARCHAR(20)) as SERIALNUMBER,
        cast(_SET as NUMBER(38,0)) as _SET,
        cast(SHIPFROMADDRESS as VARCHAR(9)) as SHIPFROMADDRESS,
        cast(SHIPFROMCODE as VARCHAR(9)) as SHIPFROMCODE,
        cast(SHIPFROMITEM as VARCHAR(47)) as SHIPFROMITEM,
        cast(SHIPFROMLOCATION as VARCHAR(10)) as SHIPFROMLOCATION,
        cast(SHIPFROMREVISIONCODE as VARCHAR(6)) as SHIPFROMREVISIONCODE,
        cast(SHIPFROMTYPEDESCRIPTION as VARCHAR(16777216)) as SHIPFROMTYPEDESCRIPTION,
        cast(SHIPFROMTYPEID as NUMBER(38,0)) as SHIPFROMTYPEID,
        cast(SHIPTOADDRESS as VARCHAR(9)) as SHIPTOADDRESS,
        cast(SHIPTOCODE as VARCHAR(9)) as SHIPTOCODE,
        cast(SHIPTOITEM as VARCHAR(47)) as SHIPTOITEM,
        cast(SHIPTOLOCATION as VARCHAR(10)) as SHIPTOLOCATION,
        cast(SHIPTOREVISIONCODE as VARCHAR(6)) as SHIPTOREVISIONCODE,
        cast(SHIPTOTYPEDESCRIPTION as VARCHAR(16777216)) as SHIPTOTYPEDESCRIPTION,
        cast(SHIPTOTYPEID as NUMBER(38,0)) as SHIPTOTYPEID,
        cast(TERMSOFDELIVERY as VARCHAR(3)) as TERMSOFDELIVERY,
        cast(TRANSFERPRICE as NUMBER(15,2)) as TRANSFERPRICE,
        cast(WAREHOUSINRDERTYPE as VARCHAR(3)) as WAREHOUSINRDERTYPE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data