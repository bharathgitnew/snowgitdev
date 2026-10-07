{{ config(
        materialized='incremental'    ,
    incremental_strategy='insert_overwrite'    ,
    alias='AlertSeverity'    ,
    unique_key = []    
) }}


with source_data as
(
    SELECT
         JSonField:AlertId::INTEGER AS AlertId
        ,try_to_timestamp_ltz(to_varchar(round(div0(JSonField:Date::STRING-621355968000000000,10000000)))) AS Date
        ,JSonField:Severity::INTEGER AS Severity
    FROM {{ source("REDGATE", "ALERTSEVERITY") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("REDGATE", "ALERTSEVERITY") }}) 
        )
,transform_data as
(
    SELECT
        source_data.ALERTID AS AlertId,
        source_data.DATE AS Date,
        source_data.SEVERITY AS Severity,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(ALERTID as NUMBER(38,0)) as ALERTID,
        cast(DATE as TIMESTAMP_LTZ(9)) as DATE,
        cast(SEVERITY as NUMBER(38,0)) as SEVERITY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data