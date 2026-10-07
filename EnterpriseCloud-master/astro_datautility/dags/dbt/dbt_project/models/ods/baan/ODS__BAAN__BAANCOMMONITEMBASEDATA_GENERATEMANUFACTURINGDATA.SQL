/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONITEMBASEDATA_GENERATEMANUFACTURINGDATA.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONITEMBASEDATA_GENERATEMANUFACTURINGDATA.SQL 
-materialized incremental
-alias BAANCOMMONITEMBASEDATA_GENERATEMANUFACTURINGDATA 
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
    alias='BAANCOMMONITEMBASEDATA_GENERATEMANUFACTURINGDATA',
    unique_key = ['GENERATEDDATE',
    'REPAIRPROGRAMID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$ADAT<= '1/1/1970' THEN NULL ELSE T$ADAT  END AS DATETIME) AS ACTUALDELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                         AS CUSTOMER 
            ,CAST(T$INLA AS NUMERIC(15,2))                                                                                                       AS ESTINHOUSELABOR 
            ,T$OPER.CONSTANTDESCRIPTION                                                                                                          AS FIRSTOPERATIONDESCRIPTION 
            ,CAST(T$OPER AS INT)                                                                                                                 AS FIRSTOPERATIONID 
            ,CAST(CASE WHEN T$GDAT<= '1/1/1970' THEN NULL ELSE T$GDAT  END AS DATETIME) AS GENERATEDDATE 
            ,T$INHO.CONSTANTDESCRIPTION                                                                                                          AS IN_HOUSEREPAIRDESCRIPTION 
            ,CAST(T$INHO AS INT)                                                                                                                 AS IN_HOUSEREPAIRID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEMBEINGREPAIRED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT1)),'')                                                                                         AS KITPART_hash__KIT1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT10)),'')                                                                                        AS KITPART_hash__KIT10 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT2)),'')                                                                                         AS KITPART_hash__KIT2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT3)),'')                                                                                         AS KITPART_hash__KIT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT4)),'')                                                                                         AS KITPART_hash__KIT4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT5)),'')                                                                                         AS KITPART_hash__KIT5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT6)),'')                                                                                         AS KITPART_hash__KIT6 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT7)),'')                                                                                         AS KITPART_hash__KIT7 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT8)),'')                                                                                         AS KITPART_hash__KIT8 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$KIT9)),'')                                                                                         AS KITPART_hash__KIT9 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS LOGINCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$GITM)),'')                                                                                         AS MAINITEM 
            ,CAST(CASE WHEN T$DDAT<= '1/1/1970' THEN NULL ELSE T$DDAT  END AS DATETIME) AS PLANNEDDELIVERYDATEETA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PDNO)),'')                                                                                         AS PRODUCTIONORDER 
            ,T$CPRE.CONSTANTDESCRIPTION                                                                                                          AS REPAIRPROGRAMDESCRIPTION 
            ,CAST(T$CPRE AS INT)                                                                                                                 AS REPAIRPROGRAMID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RMAN)),'')                                                                                         AS RMANUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SORN)),'')                                                                                         AS SALESORDER 
            ,T$SOUR.CONSTANTDESCRIPTION                                                                                                          AS SOURCEITEMTYPEDESCRIPTION 
            ,CAST(T$SOUR AS INT)                                                                                                                 AS SOURCEITEMTYPEID 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS STATUSID 
            ,T$SUBO.CONSTANTDESCRIPTION                                                                                                          AS SUBCONTRACTDESCRIPTION 
            ,CAST(T$SUBO AS INT)                                                                                                                 AS SUBCONTRACTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUBC)),'')                                                                                         AS SUBCONTRACTING 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PORN)),'')                                                                                         AS SUBCONTRACTINGPO 
            ,CAST(T$SURA AS NUMERIC(15,2))                                                                                                       AS SUBCONTRACTRATE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCIBD904201") }} AS SOURCETABLE  
            /*FIRSTOPERATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPER 
             ON   T$OPER.TABLENAME  = 'TCIBD904' 
              AND T$OPER.COLUMNNAME = 'T$OPER' 
              AND T$OPER.CONSTANT   = SOURCETABLE.T$OPER 
            /*IN_HOUSEREPAIR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INHO 
             ON   T$INHO.TABLENAME  = 'TCIBD904' 
              AND T$INHO.COLUMNNAME = 'T$INHO' 
              AND T$INHO.CONSTANT   = SOURCETABLE.T$INHO 
            /*REPAIRPROGRAM*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CPRE 
             ON   T$CPRE.TABLENAME  = 'TCIBD904' 
              AND T$CPRE.COLUMNNAME = 'T$CPRE' 
              AND T$CPRE.CONSTANT   = SOURCETABLE.T$CPRE 
            /*SOURCEITEMTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SOUR 
             ON   T$SOUR.TABLENAME  = 'TCIBD904' 
              AND T$SOUR.COLUMNNAME = 'T$SOUR' 
              AND T$SOUR.CONSTANT   = SOURCETABLE.T$SOUR 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'TCIBD904' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
            /*SUBCONTRACT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SUBO 
             ON   T$SUBO.TABLENAME  = 'TCIBD904' 
              AND T$SUBO.COLUMNNAME = 'T$SUBO' 
              AND T$SUBO.CONSTANT   = SOURCETABLE.T$SUBO 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTUALDELIVERYDATE AS ACTUALDELIVERYDATE, 
        source_data.CUSTOMER AS CUSTOMER, 
        source_data.ESTINHOUSELABOR AS ESTINHOUSELABOR, 
        source_data.FIRSTOPERATIONDESCRIPTION AS FIRSTOPERATIONDESCRIPTION, 
        source_data.FIRSTOPERATIONID AS FIRSTOPERATIONID, 
        source_data.GENERATEDDATE AS GENERATEDDATE, 
        source_data.IN_HOUSEREPAIRDESCRIPTION AS IN_HOUSEREPAIRDESCRIPTION, 
        source_data.IN_HOUSEREPAIRID AS IN_HOUSEREPAIRID, 
        source_data.ITEMBEINGREPAIRED AS ITEMBEINGREPAIRED, 
        source_data.KITPART_HASH__KIT1 AS KITPART_HASH__KIT1, 
        source_data.KITPART_HASH__KIT10 AS KITPART_HASH__KIT10, 
        source_data.KITPART_HASH__KIT2 AS KITPART_HASH__KIT2, 
        source_data.KITPART_HASH__KIT3 AS KITPART_HASH__KIT3, 
        source_data.KITPART_HASH__KIT4 AS KITPART_HASH__KIT4, 
        source_data.KITPART_HASH__KIT5 AS KITPART_HASH__KIT5, 
        source_data.KITPART_HASH__KIT6 AS KITPART_HASH__KIT6, 
        source_data.KITPART_HASH__KIT7 AS KITPART_HASH__KIT7, 
        source_data.KITPART_HASH__KIT8 AS KITPART_HASH__KIT8, 
        source_data.KITPART_HASH__KIT9 AS KITPART_HASH__KIT9, 
        source_data.LOGINCODE AS LOGINCODE, 
        source_data.MAINITEM AS MAINITEM, 
        source_data.PLANNEDDELIVERYDATEETA AS PLANNEDDELIVERYDATEETA, 
        source_data.PRODUCTIONORDER AS PRODUCTIONORDER, 
        source_data.REPAIRPROGRAMDESCRIPTION AS REPAIRPROGRAMDESCRIPTION, 
        source_data.REPAIRPROGRAMID AS REPAIRPROGRAMID, 
        source_data.RMANUMBER AS RMANUMBER, 
        source_data.SALESORDER AS SALESORDER, 
        source_data.SOURCEITEMTYPEDESCRIPTION AS SOURCEITEMTYPEDESCRIPTION, 
        source_data.SOURCEITEMTYPEID AS SOURCEITEMTYPEID, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.SUBCONTRACTDESCRIPTION AS SUBCONTRACTDESCRIPTION, 
        source_data.SUBCONTRACTID AS SUBCONTRACTID, 
        source_data.SUBCONTRACTING AS SUBCONTRACTING, 
        source_data.SUBCONTRACTINGPO AS SUBCONTRACTINGPO, 
        source_data.SUBCONTRACTRATE AS SUBCONTRACTRATE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTUALDELIVERYDATE as TIMESTAMP_NTZ(9)) as ACTUALDELIVERYDATE,
        cast(CUSTOMER as VARCHAR(9)) as CUSTOMER,
        cast(ESTINHOUSELABOR as NUMBER(15,2)) as ESTINHOUSELABOR,
        cast(FIRSTOPERATIONDESCRIPTION as VARCHAR(16777216)) as FIRSTOPERATIONDESCRIPTION,
        cast(FIRSTOPERATIONID as NUMBER(38,0)) as FIRSTOPERATIONID,
        cast(GENERATEDDATE as TIMESTAMP_NTZ(9)) as GENERATEDDATE,
        cast(IN_HOUSEREPAIRDESCRIPTION as VARCHAR(16777216)) as IN_HOUSEREPAIRDESCRIPTION,
        cast(IN_HOUSEREPAIRID as NUMBER(38,0)) as IN_HOUSEREPAIRID,
        cast(ITEMBEINGREPAIRED as VARCHAR(47)) as ITEMBEINGREPAIRED,
        cast(KITPART_HASH__KIT1 as VARCHAR(47)) as KITPART_HASH__KIT1,
        cast(KITPART_HASH__KIT10 as VARCHAR(47)) as KITPART_HASH__KIT10,
        cast(KITPART_HASH__KIT2 as VARCHAR(47)) as KITPART_HASH__KIT2,
        cast(KITPART_HASH__KIT3 as VARCHAR(47)) as KITPART_HASH__KIT3,
        cast(KITPART_HASH__KIT4 as VARCHAR(47)) as KITPART_HASH__KIT4,
        cast(KITPART_HASH__KIT5 as VARCHAR(47)) as KITPART_HASH__KIT5,
        cast(KITPART_HASH__KIT6 as VARCHAR(47)) as KITPART_HASH__KIT6,
        cast(KITPART_HASH__KIT7 as VARCHAR(47)) as KITPART_HASH__KIT7,
        cast(KITPART_HASH__KIT8 as VARCHAR(47)) as KITPART_HASH__KIT8,
        cast(KITPART_HASH__KIT9 as VARCHAR(47)) as KITPART_HASH__KIT9,
        cast(LOGINCODE as VARCHAR(16)) as LOGINCODE,
        cast(MAINITEM as VARCHAR(47)) as MAINITEM,
        cast(PLANNEDDELIVERYDATEETA as TIMESTAMP_NTZ(9)) as PLANNEDDELIVERYDATEETA,
        cast(PRODUCTIONORDER as VARCHAR(9)) as PRODUCTIONORDER,
        cast(REPAIRPROGRAMDESCRIPTION as VARCHAR(16777216)) as REPAIRPROGRAMDESCRIPTION,
        cast(REPAIRPROGRAMID as NUMBER(38,0)) as REPAIRPROGRAMID,
        cast(RMANUMBER as VARCHAR(8)) as RMANUMBER,
        cast(SALESORDER as VARCHAR(9)) as SALESORDER,
        cast(SOURCEITEMTYPEDESCRIPTION as VARCHAR(16777216)) as SOURCEITEMTYPEDESCRIPTION,
        cast(SOURCEITEMTYPEID as NUMBER(38,0)) as SOURCEITEMTYPEID,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(SUBCONTRACTDESCRIPTION as VARCHAR(16777216)) as SUBCONTRACTDESCRIPTION,
        cast(SUBCONTRACTID as NUMBER(38,0)) as SUBCONTRACTID,
        cast(SUBCONTRACTING as VARCHAR(9)) as SUBCONTRACTING,
        cast(SUBCONTRACTINGPO as VARCHAR(9)) as SUBCONTRACTINGPO,
        cast(SUBCONTRACTRATE as NUMBER(15,2)) as SUBCONTRACTRATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data