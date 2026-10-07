/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_WAREHOUSES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_WAREHOUSES.SQL 
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_WAREHOUSES 
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
    alias='BAANCOMMONSYSTEMTABLES_WAREHOUSES',
    unique_key = ['WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,"T$RMTR$U".CONSTANTDESCRIPTION                AS ADDRECEIPTMTRDESCRIPTION 
            ,CAST("T$RMTR$U" AS INT)                       AS ADDRECEIPTMTRID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'') AS ADDRESSCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'') AS BUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION 
            ,CAST(T$COMP AS INT)                         AS FINCOMP 
            ,T$NWRH.CONSTANTDESCRIPTION                  AS NETTABLEWAREHOUSEDESCRIPTION 
            ,CAST(T$NWRH AS INT)                         AS NETTABLEWAREHOUSEID 
            ,"T$REFE$U".CONSTANTDESCRIPTION                AS NONBLANKREFERENCEDESCRIPTION 
            ,CAST("T$REFE$U" AS INT)                       AS NONBLANKREFERENCEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'') AS PROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'') AS WAREHOUSE 
            ,"T$WHCT$U".CONSTANTDESCRIPTION                AS WAREHOUSECATERYDESCRIPTION 
            ,CAST("T$WHCT$U" AS INT)                       AS WAREHOUSECATERYID 
            ,T$TYPW.CONSTANTDESCRIPTION                  AS WAREHOUSETYPEDESCRIPTION 
            ,CAST(T$TYPW AS INT)                         AS WAREHOUSETYPEID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS003200") }} AS SOURCETABLE  
            /*ADDRECEIPTMTRU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$RMTR$U" 
             ON   "T$RMTR$U".TABLENAME  = 'TCMCS003' 
              AND "T$RMTR$U".COLUMNNAME = 'T$RMTR.U' 
              AND "T$RMTR$U".CONSTANT   = SOURCETABLE."T$RMTR$U" 
            /*NETTABLEWAREHOUSE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$NWRH 
             ON   T$NWRH.TABLENAME  = 'TCMCS003' 
              AND T$NWRH.COLUMNNAME = 'T$NWRH' 
              AND T$NWRH.CONSTANT   = SOURCETABLE.T$NWRH 
            /*NONBLANKREFERENCEU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$REFE$U" 
             ON   "T$REFE$U".TABLENAME  = 'TCMCS003' 
              AND "T$REFE$U".COLUMNNAME = 'T$REFE.U' 
              AND "T$REFE$U".CONSTANT   = SOURCETABLE."T$REFE$U" 
            /*WAREHOUSECATERYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$WHCT$U" 
             ON   "T$WHCT$U".TABLENAME  = 'TCMCS003' 
              AND "T$WHCT$U".COLUMNNAME = 'T$WHCT.U' 
              AND "T$WHCT$U".CONSTANT   = SOURCETABLE."T$WHCT$U" 
            /*WAREHOUSETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TYPW 
             ON   T$TYPW.TABLENAME  = 'TCMCS003' 
              AND T$TYPW.COLUMNNAME = 'T$TYPW' 
              AND T$TYPW.CONSTANT   = SOURCETABLE.T$TYPW 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADDRECEIPTMTRDESCRIPTION AS ADDRECEIPTMTRDESCRIPTION, 
        source_data.ADDRECEIPTMTRID AS ADDRECEIPTMTRID, 
        source_data.ADDRESSCODE AS ADDRESSCODE, 
        source_data.BUSINESSPARTNER AS BUSINESSPARTNER, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.FINCOMP AS FINCOMP, 
        source_data.NETTABLEWAREHOUSEDESCRIPTION AS NETTABLEWAREHOUSEDESCRIPTION, 
        source_data.NETTABLEWAREHOUSEID AS NETTABLEWAREHOUSEID, 
        source_data.NONBLANKREFERENCEDESCRIPTION AS NONBLANKREFERENCEDESCRIPTION, 
        source_data.NONBLANKREFERENCEID AS NONBLANKREFERENCEID, 
        source_data.PROJECT AS PROJECT, 
        source_data.WAREHOUSE AS WAREHOUSE, 
        source_data.WAREHOUSECATERYDESCRIPTION AS WAREHOUSECATERYDESCRIPTION, 
        source_data.WAREHOUSECATERYID AS WAREHOUSECATERYID, 
        source_data.WAREHOUSETYPEDESCRIPTION AS WAREHOUSETYPEDESCRIPTION, 
        source_data.WAREHOUSETYPEID AS WAREHOUSETYPEID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADDRECEIPTMTRDESCRIPTION as VARCHAR(16777216)) as ADDRECEIPTMTRDESCRIPTION,
        cast(ADDRECEIPTMTRID as NUMBER(38,0)) as ADDRECEIPTMTRID,
        cast(ADDRESSCODE as VARCHAR(9)) as ADDRESSCODE,
        cast(BUSINESSPARTNER as VARCHAR(9)) as BUSINESSPARTNER,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(FINCOMP as NUMBER(38,0)) as FINCOMP,
        cast(NETTABLEWAREHOUSEDESCRIPTION as VARCHAR(16777216)) as NETTABLEWAREHOUSEDESCRIPTION,
        cast(NETTABLEWAREHOUSEID as NUMBER(38,0)) as NETTABLEWAREHOUSEID,
        cast(NONBLANKREFERENCEDESCRIPTION as VARCHAR(16777216)) as NONBLANKREFERENCEDESCRIPTION,
        cast(NONBLANKREFERENCEID as NUMBER(38,0)) as NONBLANKREFERENCEID,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(WAREHOUSECATERYDESCRIPTION as VARCHAR(16777216)) as WAREHOUSECATERYDESCRIPTION,
        cast(WAREHOUSECATERYID as NUMBER(38,0)) as WAREHOUSECATERYID,
        cast(WAREHOUSETYPEDESCRIPTION as VARCHAR(16777216)) as WAREHOUSETYPEDESCRIPTION,
        cast(WAREHOUSETYPEID as NUMBER(38,0)) as WAREHOUSETYPEID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data