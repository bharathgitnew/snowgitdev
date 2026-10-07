{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCOMMONCOMMONDATA_LINKAGEBETWEENBUSINESSPARTNER',
    unique_key = ['NEWBUSINESSPARTNER',
    'OLDBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                          AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$BPID$N")),'') AS NEWBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$BPID$O")),'') AS OLDBUSINESSPARTNER
         --   FROM "LZ_HVR"."BAAN_ORACLE_LIVE"."TTCCOM961201" SOURCETABLE
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM961201") }} SOURCETABLE WHERE FALSE
        )
,transform_data as
(
    SELECT 
         _CAPTUREDATETIME, 
         _COMPANYID, 
        NEWBUSINESSPARTNER, 
        OLDBUSINESSPARTNER,       
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(NEWBUSINESSPARTNER as VARCHAR(16777216)) as NEWBUSINESSPARTNER,
        cast(OLDBUSINESSPARTNER as VARCHAR(16777216)) as OLDBUSINESSPARTNER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data