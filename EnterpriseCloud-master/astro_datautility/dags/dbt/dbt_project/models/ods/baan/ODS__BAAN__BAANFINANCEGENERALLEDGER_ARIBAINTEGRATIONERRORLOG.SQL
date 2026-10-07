/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_ARIBAINTEGRATIONERRORLOG.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_ARIBAINTEGRATIONERRORLOG.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_ARIBAINTEGRATIONERRORLOG 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:52 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEGENERALLEDGER_ARIBAINTEGRATIONERRORLOG',
    unique_key = ['LINETYPEID',
    'MESSAGESEQUENCENUMBER',
    'PAYMENTID',
    'POSITIONNUMBER',
    'SEQUENCENUMBER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,T$LTYP.CONSTANTDESCRIPTION                                                                                                          AS LINETYPEDESCRIPTION 
            ,CAST(T$LTYP AS INT)                                                                                                                 AS LINETYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MESS)),'')                                                                                         AS MESSAGEDESCRIPTION 
            ,CAST(T$MESN AS TINYINT)                                                                                                             AS MESSAGESEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS TRANSACTIONDATE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD720200") }} AS SOURCETABLE  
            /*LINETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LTYP 
             ON   T$LTYP.TABLENAME  = 'TFGLD720' 
              AND T$LTYP.COLUMNNAME = 'T$LTYP' 
              AND T$LTYP.CONSTANT   = SOURCETABLE.T$LTYP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,T$LTYP.CONSTANTDESCRIPTION                                                                                                          AS LINETYPEDESCRIPTION 
            ,CAST(T$LTYP AS INT)                                                                                                                 AS LINETYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MESS)),'')                                                                                         AS MESSAGEDESCRIPTION 
            ,CAST(T$MESN AS TINYINT)                                                                                                             AS MESSAGESEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS TRANSACTIONDATE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD720201") }} AS SOURCETABLE  
            /*LINETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LTYP 
             ON   T$LTYP.TABLENAME  = 'TFGLD720' 
              AND T$LTYP.COLUMNNAME = 'T$LTYP' 
              AND T$LTYP.CONSTANT   = SOURCETABLE.T$LTYP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.LINETYPEDESCRIPTION AS LINETYPEDESCRIPTION, 
        source_data.LINETYPEID AS LINETYPEID, 
        source_data.MESSAGEDESCRIPTION AS MESSAGEDESCRIPTION, 
        source_data.MESSAGESEQUENCENUMBER AS MESSAGESEQUENCENUMBER, 
        source_data.PAYMENTID AS PAYMENTID, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(LINETYPEDESCRIPTION as VARCHAR(16777216)) as LINETYPEDESCRIPTION,
        cast(LINETYPEID as NUMBER(38,0)) as LINETYPEID,
        cast(MESSAGEDESCRIPTION as VARCHAR(132)) as MESSAGEDESCRIPTION,
        cast(MESSAGESEQUENCENUMBER as NUMBER(38,0)) as MESSAGESEQUENCENUMBER,
        cast(PAYMENTID as VARCHAR(50)) as PAYMENTID,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data