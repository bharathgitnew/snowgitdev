/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDORDERLINES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDORDERLINES.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDORDERLINES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:57 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDORDERLINES',
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
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$ADDT<= '1/1/1970' THEN NULL ELSE T$ADDT  END AS DATETIME) AS ACTUALDELIVERYDATE 
            ,CAST(T$QADV AS NUMERIC(15,2))                                                                                                       AS ADVISEDQUANTITYININVENTORYUNIT 
            ,CAST(T$STKA AS NUMERIC(15,2))                                                                                                       AS APPROVEDQUANTITYININVENTORYUNIT 
            ,T$BLCK.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BLCK AS INT)                                                                                                                 AS BLOCKEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS E_ITEMREVISION 
            ,T$ISSS.CONSTANTDESCRIPTION                                                                                                          AS INVENTORYISSUESTATUSDESCRIPTION 
            ,CAST(T$ISSS AS INT)                                                                                                                 AS INVENTORYISSUESTATUSID 
            ,SOURCETABLE.T$TXTN   /* TEXT */                                                                                                     AS ISSUETEXT 
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
            ,CAST(T$PRIO AS BIGINT)                                                                                                              AS ORDER_PRIORITY 
            ,CAST(T$QPIC AS NUMERIC(15,2))                                                                                                       AS PICKEDQUANTITY 
            ,CAST(CASE WHEN T$PDDT<= '1/1/1970' THEN NULL ELSE T$PDDT  END AS DATETIME) AS PLANNEDDELIVERYDATETIME 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PLANNEDRECEIPTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STUN)),'')                                                                                         AS PLANNEDSTORAGEUNIT 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$STKR AS NUMERIC(15,2))                                                                                                       AS REJECTEDQUANTITYININVENTORYUNIT 
            ,CAST(T$QREL AS NUMERIC(15,2))                                                                                                       AS RELEASEDQUANTITYININVENTORYUNIT 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(T$OSET AS INT)                                                                                                                 AS _SET 
            ,CAST(T$QSHP AS NUMERIC(15,2))                                                                                                       AS SHIPPEDQUANTITYININVENTORYUNIT 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINH220200") }} AS SOURCETABLE  
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLCK 
             ON   T$BLCK.TABLENAME  = 'WHINH220' 
              AND T$BLCK.COLUMNNAME = 'T$BLCK' 
              AND T$BLCK.CONSTANT   = SOURCETABLE.T$BLCK 
            /*INVENTORYISSUESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISSS 
             ON   T$ISSS.TABLENAME  = 'WHINH220' 
              AND T$ISSS.COLUMNNAME = 'T$ISSS' 
              AND T$ISSS.CONSTANT   = SOURCETABLE.T$ISSS 
            /*LINESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSTA 
             ON   T$LSTA.TABLENAME  = 'WHINH220' 
              AND T$LSTA.COLUMNNAME = 'T$LSTA' 
              AND T$LSTA.CONSTANT   = SOURCETABLE.T$LSTA 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'WHINH220' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*ORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OORG 
             ON   T$OORG.TABLENAME  = 'WHINH220' 
              AND T$OORG.COLUMNNAME = 'T$OORG' 
              AND T$OORG.CONSTANT   = SOURCETABLE.T$OORG 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$ADDT<= '1/1/1970' THEN NULL ELSE T$ADDT  END AS DATETIME) AS ACTUALDELIVERYDATE 
            ,CAST(T$QADV AS NUMERIC(15,2))                                                                                                       AS ADVISEDQUANTITYININVENTORYUNIT 
            ,CAST(T$STKA AS NUMERIC(15,2))                                                                                                       AS APPROVEDQUANTITYININVENTORYUNIT 
            ,T$BLCK.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BLCK AS INT)                                                                                                                 AS BLOCKEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS E_ITEMREVISION 
            ,T$ISSS.CONSTANTDESCRIPTION                                                                                                          AS INVENTORYISSUESTATUSDESCRIPTION 
            ,CAST(T$ISSS AS INT)                                                                                                                 AS INVENTORYISSUESTATUSID 
            ,SOURCETABLE.T$TXTN   /* TEXT */                                                                                                     AS ISSUETEXT 
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
            ,CAST(T$PRIO AS BIGINT)                                                                                                              AS ORDER_PRIORITY 
            ,CAST(T$QPIC AS NUMERIC(15,2))                                                                                                       AS PICKEDQUANTITY 
            ,CAST(CASE WHEN T$PDDT<= '1/1/1970' THEN NULL ELSE T$PDDT  END AS DATETIME) AS PLANNEDDELIVERYDATETIME 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PLANNEDRECEIPTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STUN)),'')                                                                                         AS PLANNEDSTORAGEUNIT 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$STKR AS NUMERIC(15,2))                                                                                                       AS REJECTEDQUANTITYININVENTORYUNIT 
            ,CAST(T$QREL AS NUMERIC(15,2))                                                                                                       AS RELEASEDQUANTITYININVENTORYUNIT 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(T$OSET AS INT)                                                                                                                 AS _SET 
            ,CAST(T$QSHP AS NUMERIC(15,2))                                                                                                       AS SHIPPEDQUANTITYININVENTORYUNIT 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINH220201") }} AS SOURCETABLE  
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLCK 
             ON   T$BLCK.TABLENAME  = 'WHINH220' 
              AND T$BLCK.COLUMNNAME = 'T$BLCK' 
              AND T$BLCK.CONSTANT   = SOURCETABLE.T$BLCK 
            /*INVENTORYISSUESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISSS 
             ON   T$ISSS.TABLENAME  = 'WHINH220' 
              AND T$ISSS.COLUMNNAME = 'T$ISSS' 
              AND T$ISSS.CONSTANT   = SOURCETABLE.T$ISSS 
            /*LINESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSTA 
             ON   T$LSTA.TABLENAME  = 'WHINH220' 
              AND T$LSTA.COLUMNNAME = 'T$LSTA' 
              AND T$LSTA.CONSTANT   = SOURCETABLE.T$LSTA 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'WHINH220' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*ORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OORG 
             ON   T$OORG.TABLENAME  = 'WHINH220' 
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
		source_data.ITEM AS ITEM,
		source_data.ORDER_ AS ORDER_,
		source_data.ORDER_ORIGINID AS ORDER_ORIGINID,
		source_data.POSITIONNUMBER AS POSITIONNUMBER,
		source_data.SEQUENCENUMBER AS SEQUENCENUMBER,
		source_data._SET AS _SET,
		source_data._COMPANYID AS _COMPANYID,
		source_data.ACTUALDELIVERYDATE AS ACTUALDELIVERYDATE,
		source_data.ADVISEDQUANTITYININVENTORYUNIT AS ADVISEDQUANTITYININVENTORYUNIT,
		source_data.APPROVEDQUANTITYININVENTORYUNIT AS APPROVEDQUANTITYININVENTORYUNIT,
		source_data.BLOCKEDDESCRIPTION AS BLOCKEDDESCRIPTION,
		source_data.BLOCKEDID AS BLOCKEDID,
		source_data.E_ITEMREVISION AS E_ITEMREVISION,
		source_data.INVENTORYISSUESTATUSDESCRIPTION AS INVENTORYISSUESTATUSDESCRIPTION,
		source_data.INVENTORYISSUESTATUSID AS INVENTORYISSUESTATUSID,
		source_data.ISSUETEXT AS ISSUETEXT,
		source_data.LINESTATUSDESCRIPTION AS LINESTATUSDESCRIPTION,
		source_data.LINESTATUSID AS LINESTATUSID,
		source_data.LOT AS LOT,
		source_data.LOTSELECTIONDESCRIPTION AS LOTSELECTIONDESCRIPTION,
		source_data.LOTSELECTIONID AS LOTSELECTIONID,
		source_data.ORDER_EDQUANTITYININVENTORYUNIT AS ORDER_EDQUANTITYININVENTORYUNIT,
		source_data.ORDER_EDQUANTITYINSTORAGEUNIT AS ORDER_EDQUANTITYINSTORAGEUNIT,
		source_data.ORDER_ORIGINDESCRIPTION AS ORDER_ORIGINDESCRIPTION,
		source_data.ORDER_PRIORITY AS ORDER_PRIORITY,
		source_data.PICKEDQUANTITY AS PICKEDQUANTITY,
		source_data.PLANNEDDELIVERYDATETIME AS PLANNEDDELIVERYDATETIME,
		source_data.PLANNEDRECEIPTDATE AS PLANNEDRECEIPTDATE,
		source_data.PLANNEDSTORAGEUNIT AS PLANNEDSTORAGEUNIT,
		source_data.REJECTEDQUANTITYININVENTORYUNIT AS REJECTEDQUANTITYININVENTORYUNIT,
		source_data.RELEASEDQUANTITYININVENTORYUNIT AS RELEASEDQUANTITYININVENTORYUNIT,
		source_data.SHIPPEDQUANTITYININVENTORYUNIT AS SHIPPEDQUANTITYININVENTORYUNIT   
        FROM source_data
        )
,	type_data as 
(
    select
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(ITEM as VARCHAR(47)) as ITEM,
		cast(ORDER_ as VARCHAR(9)) as ORDER_,
		cast(ORDER_ORIGINID as NUMBER(38,0)) as ORDER_ORIGINID,
		cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
		cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
		cast(_SET as NUMBER(38,0)) as _SET,
		cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
		cast(ACTUALDELIVERYDATE as TIMESTAMP_NTZ(9)) as ACTUALDELIVERYDATE,
		cast(ADVISEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as ADVISEDQUANTITYININVENTORYUNIT,
		cast(APPROVEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as APPROVEDQUANTITYININVENTORYUNIT,
		cast(BLOCKEDDESCRIPTION as VARCHAR(16777216)) as BLOCKEDDESCRIPTION,
		cast(BLOCKEDID as NUMBER(38,0)) as BLOCKEDID,
		cast(E_ITEMREVISION as VARCHAR(6)) as E_ITEMREVISION,
		cast(INVENTORYISSUESTATUSDESCRIPTION as VARCHAR(16777216)) as INVENTORYISSUESTATUSDESCRIPTION,
		cast(INVENTORYISSUESTATUSID as NUMBER(38,0)) as INVENTORYISSUESTATUSID,
		cast(ISSUETEXT as NUMBER(38,10)) as ISSUETEXT,
		cast(LINESTATUSDESCRIPTION as VARCHAR(16777216)) as LINESTATUSDESCRIPTION,
		cast(LINESTATUSID as NUMBER(38,0)) as LINESTATUSID,
		cast(LOT as VARCHAR(16)) as LOT,
		cast(LOTSELECTIONDESCRIPTION as VARCHAR(16777216)) as LOTSELECTIONDESCRIPTION,
		cast(LOTSELECTIONID as NUMBER(38,0)) as LOTSELECTIONID,
		cast(ORDER_EDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as ORDER_EDQUANTITYININVENTORYUNIT,
		cast(ORDER_EDQUANTITYINSTORAGEUNIT as NUMBER(15,2)) as ORDER_EDQUANTITYINSTORAGEUNIT,
		cast(ORDER_ORIGINDESCRIPTION as VARCHAR(16777216)) as ORDER_ORIGINDESCRIPTION,
		cast(ORDER_PRIORITY as NUMBER(38,0)) as ORDER_PRIORITY,
		cast(PICKEDQUANTITY as NUMBER(15,2)) as PICKEDQUANTITY,
		cast(PLANNEDDELIVERYDATETIME as TIMESTAMP_NTZ(9)) as PLANNEDDELIVERYDATETIME,
		cast(PLANNEDRECEIPTDATE as TIMESTAMP_NTZ(9)) as PLANNEDRECEIPTDATE,
		cast(PLANNEDSTORAGEUNIT as VARCHAR(3)) as PLANNEDSTORAGEUNIT,
		cast(REJECTEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as REJECTEDQUANTITYININVENTORYUNIT,
		cast(RELEASEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as RELEASEDQUANTITYININVENTORYUNIT,
		cast(SHIPPEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as SHIPPEDQUANTITYININVENTORYUNIT
    from transform_data
    )
select * from type_data