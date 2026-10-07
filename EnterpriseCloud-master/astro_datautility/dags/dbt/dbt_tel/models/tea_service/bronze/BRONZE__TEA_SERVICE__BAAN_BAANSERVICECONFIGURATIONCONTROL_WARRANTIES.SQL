/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONFIGURATIONCONTROL_WARRANTIES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONFIGURATIONCONTROL_WARRANTIES.SQL 
-materialized incremental
-alias BAANSERVICECONFIGURATIONCONTROL_WARRANTIES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANSERVICECONFIGURATIONCONTROL_WARRANTIES',
    unique_key = ['WARRANTY']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,201                                                                       AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS DESCRIPTION 
            ,CAST(T$NRPE AS BIGINT)                                                  AS NUMBEROFPERIODS 
            ,CAST(CASE WHEN T$TFDT<= '1/1/1970' THEN NULL ELSE T$TFDT END AS DATE) AS PERIODOFVALIDITYFROM 
            ,CAST(CASE WHEN T$TXDT<= '1/1/1970' THEN NULL ELSE T$TXDT END AS DATE) AS PERIODOFVALIDITYTO 
            ,T$PERU.CONSTANTDESCRIPTION                                              AS PERIODUNITDESCRIPTION 
            ,CAST(T$PERU AS INT)                                                     AS PERIODUNITID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                             AS SALESREP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAR)),'')                             AS SEARCHARGUMENT 
            ,CAST(T$TERM AS BIGINT)                                                  AS TERMID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWTE)),'')                             AS WARRANTY 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                         AS WARRANTYTEXT 
            ,T$WTTP.CONSTANTDESCRIPTION                                              AS WARRANTYTYPEDESCRIPTION 
            ,CAST(T$WTTP AS INT)                                                     AS WARRANTYTYPEID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCFG020201") }} AS SOURCETABLE  
            /*PERIODUNIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PERU 
             ON   T$PERU.TABLENAME  = 'TSCFG020' 
              AND T$PERU.COLUMNNAME = 'T$PERU' 
              AND T$PERU.CONSTANT   = SOURCETABLE.T$PERU 
            /*WARRANTYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$WTTP 
             ON   T$WTTP.TABLENAME  = 'TSCFG020' 
              AND T$WTTP.COLUMNNAME = 'T$WTTP' 
              AND T$WTTP.CONSTANT   = SOURCETABLE.T$WTTP 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.NUMBEROFPERIODS AS NUMBEROFPERIODS, 
        source_data.PERIODOFVALIDITYFROM AS PERIODOFVALIDITYFROM, 
        source_data.PERIODOFVALIDITYTO AS PERIODOFVALIDITYTO, 
        source_data.PERIODUNITDESCRIPTION AS PERIODUNITDESCRIPTION, 
        source_data.PERIODUNITID AS PERIODUNITID, 
        source_data.SALESREP AS SALESREP, 
        source_data.SEARCHARGUMENT AS SEARCHARGUMENT, 
        source_data.TERMID AS TERMID, 
        source_data.WARRANTY AS WARRANTY, 
        source_data.WARRANTYTEXT AS WARRANTYTEXT, 
        source_data.WARRANTYTYPEDESCRIPTION AS WARRANTYTYPEDESCRIPTION, 
        source_data.WARRANTYTYPEID AS WARRANTYTYPEID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(NUMBEROFPERIODS as NUMBER(38,0)) as NUMBEROFPERIODS,
        cast(PERIODOFVALIDITYFROM as DATE) as PERIODOFVALIDITYFROM,
        cast(PERIODOFVALIDITYTO as DATE) as PERIODOFVALIDITYTO,
        cast(PERIODUNITDESCRIPTION as VARCHAR(16777216)) as PERIODUNITDESCRIPTION,
        cast(PERIODUNITID as NUMBER(38,0)) as PERIODUNITID,
        cast(SALESREP as VARCHAR(6)) as SALESREP,
        cast(SEARCHARGUMENT as VARCHAR(16)) as SEARCHARGUMENT,
        cast(TERMID as NUMBER(38,0)) as TERMID,
        cast(WARRANTY as VARCHAR(16)) as WARRANTY,
        cast(WARRANTYTEXT as NUMBER(38,10)) as WARRANTYTEXT,
        cast(WARRANTYTYPEDESCRIPTION as VARCHAR(16777216)) as WARRANTYTYPEDESCRIPTION,
        cast(WARRANTYTYPEID as NUMBER(38,0)) as WARRANTYTYPEID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data