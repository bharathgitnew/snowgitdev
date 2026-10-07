/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICESERVICEORDERCONTROL_SERVICEORDER_POLINK.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICESERVICEORDERCONTROL_SERVICEORDER_POLINK.SQL 
-materialized incremental
-alias BAANSERVICESERVICEORDERCONTROL_SERVICEORDER_POLINK 
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
    alias='BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDER_POLINK',
    unique_key = ['ACTIVITY',
    'COSTLINE',
    'SERVICEORDER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,CAST(T$ACLN AS INT)                         AS ACTIVITY 
            ,CAST(T$LINO AS INT)                         AS COSTLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'') AS ITEM 
            ,CAST(T$OQUA AS NUMERIC(15,2))               AS ORDER_QTY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRAN)),'') AS POADVICE 
            ,CAST(T$PPON AS INT)                         AS POSITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PORN)),'') AS PURCHASEORDER 
            ,CAST(T$RQUA AS NUMERIC(15,2))               AS RECEIVEDQUANTITY 
            ,CAST(T$PSEQ AS INT)                         AS SEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'') AS SERVICEORDER 
            ,SOURCETABLE.T$TXTA   /* TEXT */             AS SERVICEORDERTEXT 
            ,T$STATUS.CONSTANTDESCRIPTION                AS STATUSDESCRIPTION 
            ,CAST(T$STATUS AS INT)                       AS STATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$UNIT)),'') AS UNIT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC903201") }} AS SOURCETABLE 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STATUS 
             ON   T$STATUS.TABLENAME  = 'TSSOC903' 
              AND T$STATUS.COLUMNNAME = 'T$STATUS' 
              AND T$STATUS.CONSTANT   = SOURCETABLE.T$STATUS 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.COSTLINE AS COSTLINE, 
        source_data.ITEM AS ITEM, 
        source_data.ORDER_QTY AS ORDER_QTY, 
        source_data.POADVICE AS POADVICE, 
        source_data.POSITION AS POSITION, 
        source_data.PURCHASEORDER AS PURCHASEORDER, 
        source_data.RECEIVEDQUANTITY AS RECEIVEDQUANTITY, 
        source_data.SEQUENCE AS SEQUENCE, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.SERVICEORDERTEXT AS SERVICEORDERTEXT, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.UNIT AS UNIT
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTIVITY as NUMBER(38,0)) as ACTIVITY,
        cast(COSTLINE as NUMBER(38,0)) as COSTLINE,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ORDER_QTY as NUMBER(15,2)) as ORDER_QTY,
        cast(POADVICE as VARCHAR(9)) as POADVICE,
        cast(POSITION as NUMBER(38,0)) as POSITION,
        cast(PURCHASEORDER as VARCHAR(9)) as PURCHASEORDER,
        cast(RECEIVEDQUANTITY as NUMBER(15,2)) as RECEIVEDQUANTITY,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(SERVICEORDER as VARCHAR(9)) as SERVICEORDER,
        cast(SERVICEORDERTEXT as NUMBER(38,10)) as SERVICEORDERTEXT,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(UNIT as VARCHAR(3)) as UNIT
    from transform_data
    )
select * from type_data