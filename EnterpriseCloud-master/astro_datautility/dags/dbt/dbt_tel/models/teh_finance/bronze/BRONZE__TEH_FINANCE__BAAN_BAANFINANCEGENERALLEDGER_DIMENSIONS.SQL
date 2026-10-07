/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_DIMENSIONS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_DIMENSIONS.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_DIMENSIONS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:53 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANFINANCEGENERALLEDGER_DIMENSIONS',
    unique_key = ['_COMPANYID',
    'DIMENSIONCODE',
    'DIMENSIONTYPE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,200                                                                       AS _COMPANYID 
            ,T$ATYP.CONSTANTDESCRIPTION                                              AS ACCOUNTTYPEDESCRIPTION 
            ,CAST(SOURCETABLE.T$ATYP AS INT)                                                     AS ACCOUNTTYPEID 
            ,CAST(CASE WHEN SOURCETABLE.T$BFDT<= '1/1/1970' THEN NULL ELSE SOURCETABLE.T$BFDT END AS DATE) AS BLOCKINGEFFECTIVEFROM 
            ,CAST(CASE WHEN SOURCETABLE.T$BUDT<= '1/1/1970' THEN NULL ELSE SOURCETABLE.T$BUDT END AS DATE) AS BLOCKINGEFFECTIVETO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIMX)),'')                             AS DIMENSIONCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS DIMENSIONDESCRIPTION 
            ,CAST(SOURCETABLE.T$DTYP AS TINYINT)                                                 AS DIMENSIONTYPE 
            ,T$UNI1.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT1DESCRIPTION 
            ,CAST(SOURCETABLE.T$UNI1 AS INT)                                                     AS DISPLAYUNIT1ID 
            ,T$UNI2.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT2DESCRIPTION 
            ,CAST(SOURCETABLE.T$UNI2 AS INT)                                                     AS DISPLAYUNIT2ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PDIX)),'')                             AS PARENTDIMENSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                             AS PERSONRESPONSIBLE 
            ,CAST(SOURCETABLE.T$PSEQ AS BIGINT)                                                  AS PRINTSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKEY)),'')                             AS SEARCHKEY 
            ,T$BLOC.CONSTANTDESCRIPTION                                              AS STATUSDESCRIPTION 
            ,CAST(SOURCETABLE.T$BLOC AS INT)                                                     AS STATUSID 
            ,CAST(SOURCETABLE.T$SUBL AS TINYINT)                                                 AS SUBLEVEL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN1)),'')                             AS UNIT1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN2)),'')                             AS UNIT2 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD010200") }} AS SOURCETABLE  
            /*ACCOUNTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ATYP 
             ON   T$ATYP.TABLENAME  = 'TFGLD010' 
              AND T$ATYP.COLUMNNAME = 'T$ATYP' 
              AND T$ATYP.CONSTANT   = SOURCETABLE.T$ATYP 
            /*DISPLAYUNIT1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI1 
             ON   T$UNI1.TABLENAME  = 'TFGLD010' 
              AND T$UNI1.COLUMNNAME = 'T$UNI1' 
              AND T$UNI1.CONSTANT   = SOURCETABLE.T$UNI1 
            /*DISPLAYUNIT2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI2 
             ON   T$UNI2.TABLENAME  = 'TFGLD010' 
              AND T$UNI2.COLUMNNAME = 'T$UNI2' 
              AND T$UNI2.CONSTANT   = SOURCETABLE.T$UNI2 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLOC 
             ON   T$BLOC.TABLENAME  = 'TFGLD010' 
              AND T$BLOC.COLUMNNAME = 'T$BLOC' 
              AND T$BLOC.CONSTANT   = SOURCETABLE.T$BLOC 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,201                                                                       AS _COMPANYID 
            ,T$ATYP.CONSTANTDESCRIPTION                                              AS ACCOUNTTYPEDESCRIPTION 
            ,CAST(T$ATYP AS INT)                                                     AS ACCOUNTTYPEID 
            ,CAST(CASE WHEN T$BFDT<= '1/1/1970' THEN NULL ELSE T$BFDT END AS DATE) AS BLOCKINGEFFECTIVEFROM 
            ,CAST(CASE WHEN T$BUDT<= '1/1/1970' THEN NULL ELSE T$BUDT END AS DATE) AS BLOCKINGEFFECTIVETO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIMX)),'')                             AS DIMENSIONCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS DIMENSIONDESCRIPTION 
            ,CAST(T$DTYP AS TINYINT)                                                 AS DIMENSIONTYPE 
            ,T$UNI1.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT1DESCRIPTION 
            ,CAST(T$UNI1 AS INT)                                                     AS DISPLAYUNIT1ID 
            ,T$UNI2.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT2DESCRIPTION 
            ,CAST(T$UNI2 AS INT)                                                     AS DISPLAYUNIT2ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PDIX)),'')                             AS PARENTDIMENSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                             AS PERSONRESPONSIBLE 
            ,CAST(T$PSEQ AS BIGINT)                                                  AS PRINTSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKEY)),'')                             AS SEARCHKEY 
            ,T$BLOC.CONSTANTDESCRIPTION                                              AS STATUSDESCRIPTION 
            ,CAST(T$BLOC AS INT)                                                     AS STATUSID 
            ,CAST(T$SUBL AS TINYINT)                                                 AS SUBLEVEL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN1)),'')                             AS UNIT1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN2)),'')                             AS UNIT2 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD010201") }} AS SOURCETABLE  
            /*ACCOUNTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ATYP 
             ON   T$ATYP.TABLENAME  = 'TFGLD010' 
              AND T$ATYP.COLUMNNAME = 'T$ATYP' 
              AND T$ATYP.CONSTANT   = SOURCETABLE.T$ATYP 
            /*DISPLAYUNIT1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI1 
             ON   T$UNI1.TABLENAME  = 'TFGLD010' 
              AND T$UNI1.COLUMNNAME = 'T$UNI1' 
              AND T$UNI1.CONSTANT   = SOURCETABLE.T$UNI1 
            /*DISPLAYUNIT2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI2 
             ON   T$UNI2.TABLENAME  = 'TFGLD010' 
              AND T$UNI2.COLUMNNAME = 'T$UNI2' 
              AND T$UNI2.CONSTANT   = SOURCETABLE.T$UNI2 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLOC 
             ON   T$BLOC.TABLENAME  = 'TFGLD010' 
              AND T$BLOC.COLUMNNAME = 'T$BLOC' 
              AND T$BLOC.CONSTANT   = SOURCETABLE.T$BLOC 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,203                                                                       AS _COMPANYID 
            ,T$ATYP.CONSTANTDESCRIPTION                                              AS ACCOUNTTYPEDESCRIPTION 
            ,CAST(T$ATYP AS INT)                                                     AS ACCOUNTTYPEID 
            ,CAST(CASE WHEN T$BFDT<= '1/1/1970' THEN NULL ELSE T$BFDT END AS DATE) AS BLOCKINGEFFECTIVEFROM 
            ,CAST(CASE WHEN T$BUDT<= '1/1/1970' THEN NULL ELSE T$BUDT END AS DATE) AS BLOCKINGEFFECTIVETO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIMX)),'')                             AS DIMENSIONCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS DIMENSIONDESCRIPTION 
            ,CAST(T$DTYP AS TINYINT)                                                 AS DIMENSIONTYPE 
            ,T$UNI1.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT1DESCRIPTION 
            ,CAST(T$UNI1 AS INT)                                                     AS DISPLAYUNIT1ID 
            ,T$UNI2.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT2DESCRIPTION 
            ,CAST(T$UNI2 AS INT)                                                     AS DISPLAYUNIT2ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PDIX)),'')                             AS PARENTDIMENSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                             AS PERSONRESPONSIBLE 
            ,CAST(T$PSEQ AS BIGINT)                                                  AS PRINTSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKEY)),'')                             AS SEARCHKEY 
            ,T$BLOC.CONSTANTDESCRIPTION                                              AS STATUSDESCRIPTION 
            ,CAST(T$BLOC AS INT)                                                     AS STATUSID 
            ,CAST(T$SUBL AS TINYINT)                                                 AS SUBLEVEL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN1)),'')                             AS UNIT1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN2)),'')                             AS UNIT2 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD010203") }} AS SOURCETABLE  
            /*ACCOUNTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ATYP 
             ON   T$ATYP.TABLENAME  = 'TFGLD010' 
              AND T$ATYP.COLUMNNAME = 'T$ATYP' 
              AND T$ATYP.CONSTANT   = SOURCETABLE.T$ATYP 
            /*DISPLAYUNIT1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI1 
             ON   T$UNI1.TABLENAME  = 'TFGLD010' 
              AND T$UNI1.COLUMNNAME = 'T$UNI1' 
              AND T$UNI1.CONSTANT   = SOURCETABLE.T$UNI1 
            /*DISPLAYUNIT2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI2 
             ON   T$UNI2.TABLENAME  = 'TFGLD010' 
              AND T$UNI2.COLUMNNAME = 'T$UNI2' 
              AND T$UNI2.CONSTANT   = SOURCETABLE.T$UNI2 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLOC 
             ON   T$BLOC.TABLENAME  = 'TFGLD010' 
              AND T$BLOC.COLUMNNAME = 'T$BLOC' 
              AND T$BLOC.CONSTANT   = SOURCETABLE.T$BLOC 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,204                                                                       AS _COMPANYID 
            ,T$ATYP.CONSTANTDESCRIPTION                                              AS ACCOUNTTYPEDESCRIPTION 
            ,CAST(T$ATYP AS INT)                                                     AS ACCOUNTTYPEID 
            ,CAST(CASE WHEN T$BFDT<= '1/1/1970' THEN NULL ELSE T$BFDT END AS DATE) AS BLOCKINGEFFECTIVEFROM 
            ,CAST(CASE WHEN T$BUDT<= '1/1/1970' THEN NULL ELSE T$BUDT END AS DATE) AS BLOCKINGEFFECTIVETO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIMX)),'')                             AS DIMENSIONCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS DIMENSIONDESCRIPTION 
            ,CAST(T$DTYP AS TINYINT)                                                 AS DIMENSIONTYPE 
            ,T$UNI1.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT1DESCRIPTION 
            ,CAST(T$UNI1 AS INT)                                                     AS DISPLAYUNIT1ID 
            ,T$UNI2.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT2DESCRIPTION 
            ,CAST(T$UNI2 AS INT)                                                     AS DISPLAYUNIT2ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PDIX)),'')                             AS PARENTDIMENSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                             AS PERSONRESPONSIBLE 
            ,CAST(T$PSEQ AS BIGINT)                                                  AS PRINTSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKEY)),'')                             AS SEARCHKEY 
            ,T$BLOC.CONSTANTDESCRIPTION                                              AS STATUSDESCRIPTION 
            ,CAST(T$BLOC AS INT)                                                     AS STATUSID 
            ,CAST(T$SUBL AS TINYINT)                                                 AS SUBLEVEL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN1)),'')                             AS UNIT1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN2)),'')                             AS UNIT2 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD010204") }} AS SOURCETABLE  
            /*ACCOUNTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ATYP 
             ON   T$ATYP.TABLENAME  = 'TFGLD010' 
              AND T$ATYP.COLUMNNAME = 'T$ATYP' 
              AND T$ATYP.CONSTANT   = SOURCETABLE.T$ATYP 
            /*DISPLAYUNIT1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI1 
             ON   T$UNI1.TABLENAME  = 'TFGLD010' 
              AND T$UNI1.COLUMNNAME = 'T$UNI1' 
              AND T$UNI1.CONSTANT   = SOURCETABLE.T$UNI1 
            /*DISPLAYUNIT2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI2 
             ON   T$UNI2.TABLENAME  = 'TFGLD010' 
              AND T$UNI2.COLUMNNAME = 'T$UNI2' 
              AND T$UNI2.CONSTANT   = SOURCETABLE.T$UNI2 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLOC 
             ON   T$BLOC.TABLENAME  = 'TFGLD010' 
              AND T$BLOC.COLUMNNAME = 'T$BLOC' 
              AND T$BLOC.CONSTANT   = SOURCETABLE.T$BLOC 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,260                                                                       AS _COMPANYID 
            ,T$ATYP.CONSTANTDESCRIPTION                                              AS ACCOUNTTYPEDESCRIPTION 
            ,CAST(T$ATYP AS INT)                                                     AS ACCOUNTTYPEID 
            ,CAST(CASE WHEN T$BFDT<= '1/1/1970' THEN NULL ELSE T$BFDT END AS DATE) AS BLOCKINGEFFECTIVEFROM 
            ,CAST(CASE WHEN T$BUDT<= '1/1/1970' THEN NULL ELSE T$BUDT END AS DATE) AS BLOCKINGEFFECTIVETO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIMX)),'')                             AS DIMENSIONCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS DIMENSIONDESCRIPTION 
            ,CAST(T$DTYP AS TINYINT)                                                 AS DIMENSIONTYPE 
            ,T$UNI1.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT1DESCRIPTION 
            ,CAST(T$UNI1 AS INT)                                                     AS DISPLAYUNIT1ID 
            ,T$UNI2.CONSTANTDESCRIPTION                                              AS DISPLAYUNIT2DESCRIPTION 
            ,CAST(T$UNI2 AS INT)                                                     AS DISPLAYUNIT2ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PDIX)),'')                             AS PARENTDIMENSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                             AS PERSONRESPONSIBLE 
            ,CAST(T$PSEQ AS BIGINT)                                                  AS PRINTSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKEY)),'')                             AS SEARCHKEY 
            ,T$BLOC.CONSTANTDESCRIPTION                                              AS STATUSDESCRIPTION 
            ,CAST(T$BLOC AS INT)                                                     AS STATUSID 
            ,CAST(T$SUBL AS TINYINT)                                                 AS SUBLEVEL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN1)),'')                             AS UNIT1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QAN2)),'')                             AS UNIT2 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD010260") }} AS SOURCETABLE  
            /*ACCOUNTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ATYP 
             ON   T$ATYP.TABLENAME  = 'TFGLD010' 
              AND T$ATYP.COLUMNNAME = 'T$ATYP' 
              AND T$ATYP.CONSTANT   = SOURCETABLE.T$ATYP 
            /*DISPLAYUNIT1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI1 
             ON   T$UNI1.TABLENAME  = 'TFGLD010' 
              AND T$UNI1.COLUMNNAME = 'T$UNI1' 
              AND T$UNI1.CONSTANT   = SOURCETABLE.T$UNI1 
            /*DISPLAYUNIT2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UNI2 
             ON   T$UNI2.TABLENAME  = 'TFGLD010' 
              AND T$UNI2.COLUMNNAME = 'T$UNI2' 
              AND T$UNI2.CONSTANT   = SOURCETABLE.T$UNI2 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLOC 
             ON   T$BLOC.TABLENAME  = 'TFGLD010' 
              AND T$BLOC.COLUMNNAME = 'T$BLOC' 
              AND T$BLOC.CONSTANT   = SOURCETABLE.T$BLOC 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCOUNTTYPEDESCRIPTION AS ACCOUNTTYPEDESCRIPTION, 
        source_data.ACCOUNTTYPEID AS ACCOUNTTYPEID, 
        source_data.BLOCKINGEFFECTIVEFROM AS BLOCKINGEFFECTIVEFROM, 
        source_data.BLOCKINGEFFECTIVETO AS BLOCKINGEFFECTIVETO, 
        source_data.DIMENSIONCODE AS DIMENSIONCODE, 
        source_data.DIMENSIONDESCRIPTION AS DIMENSIONDESCRIPTION, 
        source_data.DIMENSIONTYPE AS DIMENSIONTYPE, 
        source_data.DISPLAYUNIT1DESCRIPTION AS DISPLAYUNIT1DESCRIPTION, 
        source_data.DISPLAYUNIT1ID AS DISPLAYUNIT1ID, 
        source_data.DISPLAYUNIT2DESCRIPTION AS DISPLAYUNIT2DESCRIPTION, 
        source_data.DISPLAYUNIT2ID AS DISPLAYUNIT2ID, 
        source_data.PARENTDIMENSION AS PARENTDIMENSION, 
        source_data.PERSONRESPONSIBLE AS PERSONRESPONSIBLE, 
        source_data.PRINTSEQUENCE AS PRINTSEQUENCE, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.SUBLEVEL AS SUBLEVEL, 
        source_data.UNIT1 AS UNIT1, 
        source_data.UNIT2 AS UNIT2
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACCOUNTTYPEDESCRIPTION as VARCHAR(16777216)) as ACCOUNTTYPEDESCRIPTION,
        cast(ACCOUNTTYPEID as NUMBER(38,0)) as ACCOUNTTYPEID,
        cast(BLOCKINGEFFECTIVEFROM as DATE) as BLOCKINGEFFECTIVEFROM,
        cast(BLOCKINGEFFECTIVETO as DATE) as BLOCKINGEFFECTIVETO,
        cast(DIMENSIONCODE as VARCHAR(6)) as DIMENSIONCODE,
        cast(DIMENSIONDESCRIPTION as VARCHAR(30)) as DIMENSIONDESCRIPTION,
        cast(DIMENSIONTYPE as NUMBER(38,0)) as DIMENSIONTYPE,
        cast(DISPLAYUNIT1DESCRIPTION as VARCHAR(16777216)) as DISPLAYUNIT1DESCRIPTION,
        cast(DISPLAYUNIT1ID as NUMBER(38,0)) as DISPLAYUNIT1ID,
        cast(DISPLAYUNIT2DESCRIPTION as VARCHAR(16777216)) as DISPLAYUNIT2DESCRIPTION,
        cast(DISPLAYUNIT2ID as NUMBER(38,0)) as DISPLAYUNIT2ID,
        cast(PARENTDIMENSION as VARCHAR(6)) as PARENTDIMENSION,
        cast(PERSONRESPONSIBLE as VARCHAR(6)) as PERSONRESPONSIBLE,
        cast(PRINTSEQUENCE as NUMBER(38,0)) as PRINTSEQUENCE,
        cast(SEARCHKEY as VARCHAR(16)) as SEARCHKEY,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(SUBLEVEL as NUMBER(38,0)) as SUBLEVEL,
        cast(UNIT1 as VARCHAR(3)) as UNIT1,
        cast(UNIT2 as VARCHAR(3)) as UNIT2,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data

