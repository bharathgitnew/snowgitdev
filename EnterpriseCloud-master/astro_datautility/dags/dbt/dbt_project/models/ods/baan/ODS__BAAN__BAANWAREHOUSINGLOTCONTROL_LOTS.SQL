/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGLOTCONTROL_LOTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGLOTCONTROL_LOTS.SQL 
-materialized incremental
-alias BAANWAREHOUSINGLOTCONTROL_LOTS 
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
    alias='BAANWAREHOUSINGLOTCONTROL_LOTS',
    unique_key = ['ITEM',
    'LOT']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LTBP)),'')                                                                                         AS BUSINESSPARTNERSLOTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BFBP)),'')                                                                                         AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CERT)),'')                                                                                         AS CERTIFICATENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS E_ITEMREVISION 
            ,CAST(CASE WHEN T$FIDT<= '1/1/1970' THEN NULL ELSE T$FIDT  END AS DATETIME) AS FIRSTISSUEDATE 
            ,CAST(CASE WHEN T$FRDT<= '1/1/1970' THEN NULL ELSE T$FRDT  END AS DATETIME) AS FIRSTRECEIPTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                         AS LOT 
            ,CAST(CASE WHEN T$LDAT<= '1/1/1970' THEN NULL ELSE T$LDAT  END AS DATETIME) AS LOTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEL1)),'')                                                                                         AS LotSelectionDescription  
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEL2)),'')                                                                                         AS LotSelectionId  
            ,CAST(T$QUAM AS NUMERIC(15,2))                                                                                                       AS LOTSIZE 
            ,T$OLOT.CONSTANTDESCRIPTION                                                                                                          AS LOTTYPEDESCRIPTION 
            ,CAST(T$OLOT AS INT)                                                                                                                 AS LOTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_ 
            ,CAST(T$POTC AS NUMERIC(15,2))                                                                                                       AS POTENCY 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHLTC100201") }} AS SOURCETABLE  
            /*LOTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OLOT 
             ON   T$OLOT.TABLENAME  = 'WHLTC100' 
              AND T$OLOT.COLUMNNAME = 'T$OLOT' 
              AND T$OLOT.CONSTANT   = SOURCETABLE.T$OLOT 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.BUSINESSPARTNERSLOTCODE AS BUSINESSPARTNERSLOTCODE, 
        source_data.BUYFROMBUSINESSPARTNER AS BUYFROMBUSINESSPARTNER, 
        source_data.CERTIFICATENUMBER AS CERTIFICATENUMBER, 
        source_data.E_ITEMREVISION AS E_ITEMREVISION, 
        source_data.FIRSTISSUEDATE AS FIRSTISSUEDATE, 
        source_data.FIRSTRECEIPTDATE AS FIRSTRECEIPTDATE, 
        source_data.ITEM AS ITEM, 
        source_data.LOT AS LOT, 
        source_data.LOTDATE AS LOTDATE, 
        source_data.LOTSELECTIONDESCRIPTION AS LOTSELECTIONDESCRIPTION, 
        source_data.LOTSELECTIONID AS LOTSELECTIONID, 
        source_data.LOTSIZE AS LOTSIZE, 
        source_data.LOTTYPEDESCRIPTION AS LOTTYPEDESCRIPTION, 
        source_data.LOTTYPEID AS LOTTYPEID, 
        source_data.ORDER_ AS ORDER_, 
        source_data.POTENCY AS POTENCY, 
        source_data.TEXT AS TEXT
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(BUSINESSPARTNERSLOTCODE as VARCHAR(30)) as BUSINESSPARTNERSLOTCODE,
        cast(BUYFROMBUSINESSPARTNER as VARCHAR(9)) as BUYFROMBUSINESSPARTNER,
        cast(CERTIFICATENUMBER as VARCHAR(16)) as CERTIFICATENUMBER,
        cast(E_ITEMREVISION as VARCHAR(6)) as E_ITEMREVISION,
        cast(FIRSTISSUEDATE as TIMESTAMP_NTZ(9)) as FIRSTISSUEDATE,
        cast(FIRSTRECEIPTDATE as TIMESTAMP_NTZ(9)) as FIRSTRECEIPTDATE,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LOT as VARCHAR(16)) as LOT,
        cast(LOTDATE as TIMESTAMP_NTZ(9)) as LOTDATE,
        cast(LOTSELECTIONDESCRIPTION as VARCHAR(3)) as LOTSELECTIONDESCRIPTION,
        cast(LOTSELECTIONID as VARCHAR(3)) as LOTSELECTIONID,
        cast(LOTSIZE as NUMBER(15,2)) as LOTSIZE,
        cast(LOTTYPEDESCRIPTION as VARCHAR(16777216)) as LOTTYPEDESCRIPTION,
        cast(LOTTYPEID as NUMBER(38,0)) as LOTTYPEID,
        cast(ORDER_ as VARCHAR(9)) as ORDER_,
        cast(POTENCY as NUMBER(15,2)) as POTENCY,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data