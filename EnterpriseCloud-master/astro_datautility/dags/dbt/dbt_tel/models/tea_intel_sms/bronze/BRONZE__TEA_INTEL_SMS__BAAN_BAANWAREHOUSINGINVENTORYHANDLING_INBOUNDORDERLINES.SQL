/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYHANDLING_INBOUNDORDERLINES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYHANDLING_INBOUNDORDERLINES.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYHANDLING_INBOUNDORDERLINES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:56 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANWAREHOUSINGINVENTORYHANDLING_INBOUNDORDERLINES',
    unique_key = ['ORDER_',
    'ORDER_ORIGINID',
    'POSITIONNUMBER',
    'SEQUENCENUMBER',
    '_SET']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACTI)),'')                                                                                         AS ACTIVITY 
            ,CAST(CASE WHEN T$ARDT<= '1/1/1970' THEN NULL ELSE T$ARDT  END AS DATETIME) AS ACTUALRECEIPTDATE 
            ,CAST(T$QADV AS NUMERIC(15,2))                                                                                                       AS ADVISEDQUANTITYININVENTORYUNIT 
            ,CAST(T$STKA AS NUMERIC(15,2))                                                                                                       AS APPROVEDQUANTITYININVENTORYUNIT 
            ,T$BLCK.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BLCK AS INT)                                                                                                                 AS BLOCKEDID 
            ,T$BTSP.CONSTANTDESCRIPTION                                                                                                          AS BOOKTOSTATUSDESCRIPTION 
            ,CAST(T$BTSP AS INT)                                                                                                                 AS BOOKTOSTATUSID 
            ,T$CONF.CONSTANTDESCRIPTION                                                                                                          AS CONFIRMEDDESCRIPTION 
            ,CAST(T$CONF AS INT)                                                                                                                 AS CONFIRMEDID 
            ,T$CDCK.CONSTANTDESCRIPTION                                                                                                          AS CROSSDOCKINGDESCRIPTION 
            ,CAST(T$CDCK AS INT)                                                                                                                 AS CROSSDOCKINGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS E_ITEMREVISION 
            ,T$FIRE.CONSTANTDESCRIPTION                                                                                                          AS FINALRECEIPTDESCRIPTION 
            ,CAST(T$FIRE AS INT)                                                                                                                 AS FINALRECEIPTID 
            ,SOURCETABLE.T$ITXT   /* TEXT */                                                                                                     AS INSPECTIONTEXT 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT  END AS DATETIME) AS INVENTORYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,T$LSTA.CONSTANTDESCRIPTION                                                                                                          AS LINESTATUSDESCRIPTION 
            ,CAST(T$LSTA AS INT)                                                                                                                 AS LINESTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                         AS LOT 
            ,T$LSEL.CONSTANTDESCRIPTION                                                                                                          AS LotSelectionDescription  
            ,CAST(T$LSEL AS INT)                                                                                                                 AS LotSelectionId  
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_ 
            ,CAST(T$QSTK AS NUMERIC(15,2))                                                                                                       AS ORDER_EDQUANTITYININVENTORYUNIT 
            ,CAST(T$QSTR AS NUMERIC(15,2))                                                                                                       AS ORDER_EDQUANTITYINSTORAGEUNIT 
            ,T$OORG.CONSTANTDESCRIPTION                                                                                                          AS ORDER_ORIGINDESCRIPTION 
            ,CAST(T$OORG AS INT)                                                                                                                 AS ORDER_ORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PKDF)),'')                                                                                         AS PACKAGEDEFINITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PSNO)),'')                                                                                         AS PACKINGSLIPNUMBER 
            ,CAST(T$PSQU AS NUMERIC(15,2))                                                                                                       AS PACKINGSLIPQUANTITYININVENTORYUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PSNR)),'')                                                                                         AS PACKINGSTRUCTURENUMBER 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PLANNEDRECEIPTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STUN)),'')                                                                                         AS PLANNEDSTORAGEUNIT 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMSK)),'')                                                                                         AS PROCEDUREMASK 
            ,CAST(T$QPUT AS NUMERIC(15,2))                                                                                                       AS PUTAWAYQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCNO)),'')                                                                                         AS RECEIPTNUMBER 
            ,CAST(T$RSTK AS NUMERIC(15,2))                                                                                                       AS RECEIPTQUANTITY 
            ,SOURCETABLE.T$TXTN   /* TEXT */                                                                                                     AS RECEIPTTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCUN)),'')                                                                                         AS RECEIPTUNIT 
            ,CAST(T$ASTK AS NUMERIC(15,2))                                                                                                       AS RECEIVEDQUANTITYININVENTORYUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOCA)),'')                                                                                         AS RECEIVINGLOCATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS RECEIVINGWAREHOUSE 
            ,CAST(T$STKR AS NUMERIC(15,2))                                                                                                       AS REJECTEDQUANTITYININVENTORYUNIT 
            ,CAST(T$QREL AS NUMERIC(15,2))                                                                                                       AS RELEASEDQUANTITYININVENTORYUNIT 
            ,CAST(T$SEQN AS BIGINT)                                                                                                              AS SEQUENCENUMBER 
            ,CAST(T$OSET AS INT)                                                                                                                 AS _SET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                         AS SHIPFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHID)),'')                                                                                         AS SHIPMENTIDENTIFICATION 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINH210201") }} AS SOURCETABLE  
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLCK 
             ON   T$BLCK.TABLENAME  = 'WHINH210' 
              AND T$BLCK.COLUMNNAME = 'T$BLCK' 
              AND T$BLCK.CONSTANT   = SOURCETABLE.T$BLCK 
            /*BOOKTOSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BTSP 
             ON   T$BTSP.TABLENAME  = 'WHINH210' 
              AND T$BTSP.COLUMNNAME = 'T$BTSP' 
              AND T$BTSP.CONSTANT   = SOURCETABLE.T$BTSP 
            /*CONFIRMED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CONF 
             ON   T$CONF.TABLENAME  = 'WHINH210' 
              AND T$CONF.COLUMNNAME = 'T$CONF' 
              AND T$CONF.CONSTANT   = SOURCETABLE.T$CONF 
            /*CROSSDOCKING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CDCK 
             ON   T$CDCK.TABLENAME  = 'WHINH210' 
              AND T$CDCK.COLUMNNAME = 'T$CDCK' 
              AND T$CDCK.CONSTANT   = SOURCETABLE.T$CDCK 
            /*FINALRECEIPT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FIRE 
             ON   T$FIRE.TABLENAME  = 'WHINH210' 
              AND T$FIRE.COLUMNNAME = 'T$FIRE' 
              AND T$FIRE.CONSTANT   = SOURCETABLE.T$FIRE 
            /*LINESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSTA 
             ON   T$LSTA.TABLENAME  = 'WHINH210' 
              AND T$LSTA.COLUMNNAME = 'T$LSTA' 
              AND T$LSTA.CONSTANT   = SOURCETABLE.T$LSTA 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'WHINH210' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*ORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OORG 
             ON   T$OORG.TABLENAME  = 'WHINH210' 
              AND T$OORG.COLUMNNAME = 'T$OORG' 
              AND T$OORG.CONSTANT   = SOURCETABLE.T$OORG 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,	transform_data as
(
    SELECT 
		source_data._CAPTUREDATETIME AS _CAPTUREDATETIME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		source_data.ACTIVITY AS ACTIVITY,
		source_data.ITEM AS ITEM,
		source_data.ORDER_ AS ORDER_,
		source_data.ORDER_ORIGINID AS ORDER_ORIGINID,
		source_data.POSITIONNUMBER AS POSITIONNUMBER,
		source_data.SEQUENCENUMBER AS SEQUENCENUMBER,
		source_data._SET AS _SET,
		source_data._COMPANYID AS _COMPANYID,
		source_data.ACTUALRECEIPTDATE AS ACTUALRECEIPTDATE,
		source_data.ADVISEDQUANTITYININVENTORYUNIT AS ADVISEDQUANTITYININVENTORYUNIT,
		source_data.APPROVEDQUANTITYININVENTORYUNIT AS APPROVEDQUANTITYININVENTORYUNIT,
		source_data.BLOCKEDDESCRIPTION AS BLOCKEDDESCRIPTION,
		source_data.BLOCKEDID AS BLOCKEDID,
		source_data.BOOKTOSTATUSDESCRIPTION AS BOOKTOSTATUSDESCRIPTION,
		source_data.BOOKTOSTATUSID AS BOOKTOSTATUSID,
		source_data.CONFIRMEDDESCRIPTION AS CONFIRMEDDESCRIPTION,
		source_data.CONFIRMEDID AS CONFIRMEDID,
		source_data.CROSSDOCKINGDESCRIPTION AS CROSSDOCKINGDESCRIPTION,
		source_data.CROSSDOCKINGID AS CROSSDOCKINGID,
		source_data.E_ITEMREVISION AS E_ITEMREVISION,
		source_data.FINALRECEIPTDESCRIPTION AS FINALRECEIPTDESCRIPTION,
		source_data.FINALRECEIPTID AS FINALRECEIPTID,
		source_data.INSPECTIONTEXT AS INSPECTIONTEXT,
		source_data.INVENTORYDATE AS INVENTORYDATE,
		source_data.LINESTATUSDESCRIPTION AS LINESTATUSDESCRIPTION,
		source_data.LINESTATUSID AS LINESTATUSID,
		source_data.LOT AS LOT,
		source_data.LOTSELECTIONDESCRIPTION AS LOTSELECTIONDESCRIPTION,
		source_data.LOTSELECTIONID AS LOTSELECTIONID,
		source_data.ORDER_EDQUANTITYININVENTORYUNIT AS ORDER_EDQUANTITYININVENTORYUNIT,
		source_data.ORDER_EDQUANTITYINSTORAGEUNIT AS ORDER_EDQUANTITYINSTORAGEUNIT,
		source_data.ORDER_ORIGINDESCRIPTION AS ORDER_ORIGINDESCRIPTION,
		source_data.PACKAGEDEFINITION AS PACKAGEDEFINITION,
		source_data.PACKINGSLIPNUMBER AS PACKINGSLIPNUMBER,
		source_data.PACKINGSLIPQUANTITYININVENTORYUNIT AS PACKINGSLIPQUANTITYININVENTORYUNIT,
		source_data.PACKINGSTRUCTURENUMBER AS PACKINGSTRUCTURENUMBER,
		source_data.PLANNEDRECEIPTDATE AS PLANNEDRECEIPTDATE,
		source_data.PLANNEDSTORAGEUNIT AS PLANNEDSTORAGEUNIT,
		source_data.PROCEDUREMASK AS PROCEDUREMASK,
		source_data.PUTAWAYQUANTITY AS PUTAWAYQUANTITY,
		source_data.RECEIPTNUMBER AS RECEIPTNUMBER,
		source_data.RECEIPTQUANTITY AS RECEIPTQUANTITY,
		source_data.RECEIPTTEXT AS RECEIPTTEXT,
		source_data.RECEIPTUNIT AS RECEIPTUNIT,
		source_data.RECEIVEDQUANTITYININVENTORYUNIT AS RECEIVEDQUANTITYININVENTORYUNIT,
		source_data.RECEIVINGLOCATION AS RECEIVINGLOCATION,
		source_data.RECEIVINGWAREHOUSE AS RECEIVINGWAREHOUSE,
		source_data.REJECTEDQUANTITYININVENTORYUNIT AS REJECTEDQUANTITYININVENTORYUNIT,
		source_data.RELEASEDQUANTITYININVENTORYUNIT AS RELEASEDQUANTITYININVENTORYUNIT,
		source_data.SHIPFROMBUSINESSPARTNER AS SHIPFROMBUSINESSPARTNER,
		source_data.SHIPMENTIDENTIFICATION AS SHIPMENTIDENTIFICATION   
        FROM source_data
        )
,	type_data as 
(
    select
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(ACTIVITY as VARCHAR(20)) as ACTIVITY,
		cast(ITEM as VARCHAR(47)) as ITEM,
		cast(ORDER_ as VARCHAR(9)) as ORDER_,
		cast(ORDER_ORIGINID as NUMBER(38,0)) as ORDER_ORIGINID,
		cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
		cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
		cast(_SET as NUMBER(38,0)) as _SET,
		cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
		cast(ACTUALRECEIPTDATE as TIMESTAMP_NTZ(9)) as ACTUALRECEIPTDATE,
		cast(ADVISEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as ADVISEDQUANTITYININVENTORYUNIT,
		cast(APPROVEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as APPROVEDQUANTITYININVENTORYUNIT,
		cast(BLOCKEDDESCRIPTION as VARCHAR(16777216)) as BLOCKEDDESCRIPTION,
		cast(BLOCKEDID as NUMBER(38,0)) as BLOCKEDID,
		cast(BOOKTOSTATUSDESCRIPTION as VARCHAR(16777216)) as BOOKTOSTATUSDESCRIPTION,
		cast(BOOKTOSTATUSID as NUMBER(38,0)) as BOOKTOSTATUSID,
		cast(CONFIRMEDDESCRIPTION as VARCHAR(16777216)) as CONFIRMEDDESCRIPTION,
		cast(CONFIRMEDID as NUMBER(38,0)) as CONFIRMEDID,
		cast(CROSSDOCKINGDESCRIPTION as VARCHAR(16777216)) as CROSSDOCKINGDESCRIPTION,
		cast(CROSSDOCKINGID as NUMBER(38,0)) as CROSSDOCKINGID,
		cast(E_ITEMREVISION as VARCHAR(6)) as E_ITEMREVISION,
		cast(FINALRECEIPTDESCRIPTION as VARCHAR(16777216)) as FINALRECEIPTDESCRIPTION,
		cast(FINALRECEIPTID as NUMBER(38,0)) as FINALRECEIPTID,
		cast(INSPECTIONTEXT as NUMBER(38,10)) as INSPECTIONTEXT,
		cast(INVENTORYDATE as TIMESTAMP_NTZ(9)) as INVENTORYDATE,
		cast(LINESTATUSDESCRIPTION as VARCHAR(16777216)) as LINESTATUSDESCRIPTION,
		cast(LINESTATUSID as NUMBER(38,0)) as LINESTATUSID,
		cast(LOT as VARCHAR(16)) as LOT,
		cast(LOTSELECTIONDESCRIPTION as VARCHAR(16777216)) as LOTSELECTIONDESCRIPTION,
		cast(LOTSELECTIONID as NUMBER(38,0)) as LOTSELECTIONID,
		cast(ORDER_EDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as ORDER_EDQUANTITYININVENTORYUNIT,
		cast(ORDER_EDQUANTITYINSTORAGEUNIT as NUMBER(15,2)) as ORDER_EDQUANTITYINSTORAGEUNIT,
		cast(ORDER_ORIGINDESCRIPTION as VARCHAR(16777216)) as ORDER_ORIGINDESCRIPTION,
		cast(PACKAGEDEFINITION as VARCHAR(6)) as PACKAGEDEFINITION,
		cast(PACKINGSLIPNUMBER as VARCHAR(30)) as PACKINGSLIPNUMBER,
		cast(PACKINGSLIPQUANTITYININVENTORYUNIT as NUMBER(15,2)) as PACKINGSLIPQUANTITYININVENTORYUNIT,
		cast(PACKINGSTRUCTURENUMBER as VARCHAR(15)) as PACKINGSTRUCTURENUMBER,
		cast(PLANNEDRECEIPTDATE as TIMESTAMP_NTZ(9)) as PLANNEDRECEIPTDATE,
		cast(PLANNEDSTORAGEUNIT as VARCHAR(3)) as PLANNEDSTORAGEUNIT,
		cast(PROCEDUREMASK as VARCHAR(20)) as PROCEDUREMASK,
		cast(PUTAWAYQUANTITY as NUMBER(15,2)) as PUTAWAYQUANTITY,
		cast(RECEIPTNUMBER as VARCHAR(9)) as RECEIPTNUMBER,
		cast(RECEIPTQUANTITY as NUMBER(15,2)) as RECEIPTQUANTITY,
		cast(RECEIPTTEXT as NUMBER(38,10)) as RECEIPTTEXT,
		cast(RECEIPTUNIT as VARCHAR(3)) as RECEIPTUNIT,
		cast(RECEIVEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as RECEIVEDQUANTITYININVENTORYUNIT,
		cast(RECEIVINGLOCATION as VARCHAR(10)) as RECEIVINGLOCATION,
		cast(RECEIVINGWAREHOUSE as VARCHAR(6)) as RECEIVINGWAREHOUSE,
		cast(REJECTEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as REJECTEDQUANTITYININVENTORYUNIT,
		cast(RELEASEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as RELEASEDQUANTITYININVENTORYUNIT,
		cast(SHIPFROMBUSINESSPARTNER as VARCHAR(9)) as SHIPFROMBUSINESSPARTNER,
		cast(SHIPMENTIDENTIFICATION as VARCHAR(9)) as SHIPMENTIDENTIFICATION
    from transform_data
    )
select * from type_data