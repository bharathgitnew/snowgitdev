/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_BUSINESSPARTNERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_BUSINESSPARTNERS.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_BUSINESSPARTNERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:47 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCOMMONCOMMONDATA_BUSINESSPARTNERS',
    unique_key = ['BUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                         AS ADDRESSCODE 
            ,T$INRL.CONSTANTDESCRIPTION                                                                                                          AS AFFILIATEDCOMPANYDESCRIPTION 
            ,CAST(T$INRL AS INT)                                                                                                                 AS AFFILIATEDCOMPANYID 
            ,CAST(T$ISCN AS INT)                                                                                                                 AS AFFILIATEDCOMPANYNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BEID)),'')                                                                                         AS BUSINESSENTITYIDENTIFIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                         AS BUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPTX)),'')                                                                                         AS BUSINESSPARTNERFORTEXTS 
            ,T$PRST.CONSTANTDESCRIPTION                                                                                                          AS BUSINESSPARTNERSTATUSDESCRIPTION 
            ,CAST(T$PRST AS INT)                                                                                                                 AS BUSINESSPARTNERSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMID)),'')                                                                                         AS COMMERCIALIDENTIFICATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCNT)),'')                                                                                         AS CONTACTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,T$EDYN.CONSTANTDESCRIPTION                                                                                                          AS EDIDESCRIPTION 
            ,CAST(T$EDYN AS INT)                                                                                                                 AS EDIID 
            ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT  END AS DATETIME) AS ENDDATE 
            ,"T$FRSP$U".CONSTANTDESCRIPTION                                                                                                        AS FREIGHTSUPPLIERDESCRIPTION 
            ,CAST("T$FRSP$U" AS INT)                                                                                                               AS FREIGHTSUPPLIERID 
            ,CAST(T$XKEY AS NUMERIC(15,2))                                                                                                       AS FRONTOFFICENUMBER 
            ,T$CINT.CONSTANTDESCRIPTION                                                                                                          AS INTERNALBUSINESSPARTNERDESCRIPTION 
            ,CAST(T$CINT AS INT)                                                                                                                 AS INTERNALBUSINESSPARTNERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')                                                                                         AS LANGUAGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LGID)),'')                                                                                         AS LEGALIDENTIFICATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAMA)),'')                                                                                         AS NAME 
            ,T$SNDR.CONSTANTDESCRIPTION                                                                                                          AS ONE_TIMEBUSINESSPARTNERDESCRIPTION 
            ,CAST(T$SNDR AS INT)                                                                                                                 AS ONE_TIMEBUSINESSPARTNERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRBP)),'')                                                                                         AS PARENTBUSINESSPARTNER 
            ,"T$METH$U".CONSTANTDESCRIPTION                                                                                                        AS PREFERREDORDERING_percent_METHODDESCRIPTION 
            ,CAST("T$METH$U" AS INT)                                                                                                               AS PREFERREDORDERING_percent_METHODID 
            ,"T$RSTO$U".CONSTANTDESCRIPTION                                                                                                        AS REPAIRSHIPTODESCRIPTION 
            ,CAST("T$RSTO$U" AS INT)                                                                                                               AS REPAIRSHIPTOID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PBPD$U")),'')                                                                                       AS SAPPARENTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEY 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME) AS STARTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FOVN)),'')                                                                                         AS TAXNUMBER 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTIT)),'')                                                                                         AS TITLE 
            ,CAST(CASE WHEN T$LVDT<= '1/1/1970' THEN NULL ELSE T$LVDT  END AS DATETIME) AS VERIFICATIONDATE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM100200") }}  AS SOURCETABLE  
            /*AFFILIATEDCOMPANY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INRL 
             ON   T$INRL.TABLENAME  = 'TCCOM100' 
              AND T$INRL.COLUMNNAME = 'T$INRL' 
              AND T$INRL.CONSTANT   = SOURCETABLE.T$INRL 
            /*BUSINESSPARTNERSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PRST 
             ON   T$PRST.TABLENAME  = 'TCCOM100' 
              AND T$PRST.COLUMNNAME = 'T$PRST' 
              AND T$PRST.CONSTANT   = SOURCETABLE.T$PRST 
            /*EDI*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$EDYN 
             ON   T$EDYN.TABLENAME  = 'TCCOM100' 
              AND T$EDYN.COLUMNNAME = 'T$EDYN' 
              AND T$EDYN.CONSTANT   = SOURCETABLE.T$EDYN 
            /*FREIGHTSUPPLIERU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$FRSP$U" 
             ON   "T$FRSP$U".TABLENAME  = 'TCCOM100' 
              AND "T$FRSP$U".COLUMNNAME = 'T$FRSP.U' 
              AND "T$FRSP$U".CONSTANT   = SOURCETABLE."T$FRSP$U" 
            /*INTERNALBUSINESSPARTNER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CINT 
             ON   T$CINT.TABLENAME  = 'TCCOM100' 
              AND T$CINT.COLUMNNAME = 'T$CINT' 
              AND T$CINT.CONSTANT   = SOURCETABLE.T$CINT 
            /*ONE_TIMEBUSINESSPARTNER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SNDR 
             ON   T$SNDR.TABLENAME  = 'TCCOM100' 
              AND T$SNDR.COLUMNNAME = 'T$SNDR' 
              AND T$SNDR.CONSTANT   = SOURCETABLE.T$SNDR 
            /*PREFERREDORDERING_percent_METHODU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$METH$U" 
             ON   "T$METH$U".TABLENAME  = 'TCCOM100' 
              AND "T$METH$U".COLUMNNAME = 'T$METH.U' 
              AND "T$METH$U".CONSTANT   = SOURCETABLE."T$METH$U" 
            /*REPAIRSHIPTOU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$RSTO$U" 
             ON   "T$RSTO$U".TABLENAME  = 'TCCOM100' 
              AND "T$RSTO$U".COLUMNNAME = 'T$RSTO.U' 
              AND "T$RSTO$U".CONSTANT   = SOURCETABLE."T$RSTO$U" 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADDRESSCODE AS ADDRESSCODE, 
        source_data.AFFILIATEDCOMPANYDESCRIPTION AS AFFILIATEDCOMPANYDESCRIPTION, 
        source_data.AFFILIATEDCOMPANYID AS AFFILIATEDCOMPANYID, 
        source_data.AFFILIATEDCOMPANYNO AS AFFILIATEDCOMPANYNO, 
        source_data.BUSINESSENTITYIDENTIFIER AS BUSINESSENTITYIDENTIFIER, 
        source_data.BUSINESSPARTNER AS BUSINESSPARTNER, 
        source_data.BUSINESSPARTNERFORTEXTS AS BUSINESSPARTNERFORTEXTS, 
        source_data.BUSINESSPARTNERSTATUSDESCRIPTION AS BUSINESSPARTNERSTATUSDESCRIPTION, 
        source_data.BUSINESSPARTNERSTATUSID AS BUSINESSPARTNERSTATUSID, 
        source_data.COMMERCIALIDENTIFICATION AS COMMERCIALIDENTIFICATION, 
        source_data.CONTACTCODE AS CONTACTCODE, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.EDIDESCRIPTION AS EDIDESCRIPTION, 
        source_data.EDIID AS EDIID, 
        source_data.ENDDATE AS ENDDATE, 
        source_data.FREIGHTSUPPLIERDESCRIPTION AS FREIGHTSUPPLIERDESCRIPTION, 
        source_data.FREIGHTSUPPLIERID AS FREIGHTSUPPLIERID, 
        source_data.FRONTOFFICENUMBER AS FRONTOFFICENUMBER, 
        source_data.INTERNALBUSINESSPARTNERDESCRIPTION AS INTERNALBUSINESSPARTNERDESCRIPTION, 
        source_data.INTERNALBUSINESSPARTNERID AS INTERNALBUSINESSPARTNERID, 
        source_data.LANGUAGE AS LANGUAGE, 
        source_data.LEGALIDENTIFICATION AS LEGALIDENTIFICATION, 
        source_data.NAME AS NAME, 
        source_data.ONE_TIMEBUSINESSPARTNERDESCRIPTION AS ONE_TIMEBUSINESSPARTNERDESCRIPTION, 
        source_data.ONE_TIMEBUSINESSPARTNERID AS ONE_TIMEBUSINESSPARTNERID, 
        source_data.PARENTBUSINESSPARTNER AS PARENTBUSINESSPARTNER, 
        source_data.PREFERREDORDERING_PERCENT_METHODDESCRIPTION AS PREFERREDORDERING_PERCENT_METHODDESCRIPTION, 
        source_data.PREFERREDORDERING_PERCENT_METHODID AS PREFERREDORDERING_PERCENT_METHODID, 
        source_data.REPAIRSHIPTODESCRIPTION AS REPAIRSHIPTODESCRIPTION, 
        source_data.REPAIRSHIPTOID AS REPAIRSHIPTOID, 
        source_data.SAPPARENTCODE AS SAPPARENTCODE, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.STARTDATE AS STARTDATE, 
        source_data.TAXNUMBER AS TAXNUMBER, 
        source_data.TEXT AS TEXT, 
        source_data.TITLE AS TITLE, 
        source_data.VERIFICATIONDATE AS VERIFICATIONDATE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADDRESSCODE as VARCHAR(9)) as ADDRESSCODE,
        cast(AFFILIATEDCOMPANYDESCRIPTION as VARCHAR(16777216)) as AFFILIATEDCOMPANYDESCRIPTION,
        cast(AFFILIATEDCOMPANYID as NUMBER(38,0)) as AFFILIATEDCOMPANYID,
        cast(AFFILIATEDCOMPANYNO as NUMBER(38,0)) as AFFILIATEDCOMPANYNO,
        cast(BUSINESSENTITYIDENTIFIER as VARCHAR(15)) as BUSINESSENTITYIDENTIFIER,
        cast(BUSINESSPARTNER as VARCHAR(9)) as BUSINESSPARTNER,
        cast(BUSINESSPARTNERFORTEXTS as VARCHAR(9)) as BUSINESSPARTNERFORTEXTS,
        cast(BUSINESSPARTNERSTATUSDESCRIPTION as VARCHAR(16777216)) as BUSINESSPARTNERSTATUSDESCRIPTION,
        cast(BUSINESSPARTNERSTATUSID as NUMBER(38,0)) as BUSINESSPARTNERSTATUSID,
        cast(COMMERCIALIDENTIFICATION as VARCHAR(20)) as COMMERCIALIDENTIFICATION,
        cast(CONTACTCODE as VARCHAR(9)) as CONTACTCODE,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(EDIDESCRIPTION as VARCHAR(16777216)) as EDIDESCRIPTION,
        cast(EDIID as NUMBER(38,0)) as EDIID,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(FREIGHTSUPPLIERDESCRIPTION as VARCHAR(16777216)) as FREIGHTSUPPLIERDESCRIPTION,
        cast(FREIGHTSUPPLIERID as NUMBER(38,0)) as FREIGHTSUPPLIERID,
        cast(FRONTOFFICENUMBER as NUMBER(15,2)) as FRONTOFFICENUMBER,
        cast(INTERNALBUSINESSPARTNERDESCRIPTION as VARCHAR(16777216)) as INTERNALBUSINESSPARTNERDESCRIPTION,
        cast(INTERNALBUSINESSPARTNERID as NUMBER(38,0)) as INTERNALBUSINESSPARTNERID,
        cast(LANGUAGE as VARCHAR(3)) as LANGUAGE,
        cast(LEGALIDENTIFICATION as VARCHAR(20)) as LEGALIDENTIFICATION,
        cast(NAME as VARCHAR(35)) as NAME,
        cast(ONE_TIMEBUSINESSPARTNERDESCRIPTION as VARCHAR(16777216)) as ONE_TIMEBUSINESSPARTNERDESCRIPTION,
        cast(ONE_TIMEBUSINESSPARTNERID as NUMBER(38,0)) as ONE_TIMEBUSINESSPARTNERID,
        cast(PARENTBUSINESSPARTNER as VARCHAR(9)) as PARENTBUSINESSPARTNER,
        cast(PREFERREDORDERING_PERCENT_METHODDESCRIPTION as VARCHAR(16777216)) as PREFERREDORDERING_PERCENT_METHODDESCRIPTION,
        cast(PREFERREDORDERING_PERCENT_METHODID as NUMBER(38,0)) as PREFERREDORDERING_PERCENT_METHODID,
        cast(REPAIRSHIPTODESCRIPTION as VARCHAR(16777216)) as REPAIRSHIPTODESCRIPTION,
        cast(REPAIRSHIPTOID as NUMBER(38,0)) as REPAIRSHIPTOID,
        cast(SAPPARENTCODE as VARCHAR(9)) as SAPPARENTCODE,
        cast(SEARCHKEY as VARCHAR(16)) as SEARCHKEY,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(TAXNUMBER as VARCHAR(20)) as TAXNUMBER,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(TITLE as VARCHAR(3)) as TITLE,
        cast(VERIFICATIONDATE as TIMESTAMP_NTZ(9)) as VERIFICATIONDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data