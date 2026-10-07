{{ config(
        materialized='incremental'    ,
    incremental_strategy='insert_overwrite'    ,
    alias='AlertType'    ,
    unique_key = ['']    
) }}


with source_data as
(
    SELECT
         JSonField:AlertType::INTEGER AS AlertType
        ,JSonField:Event::INTEGER AS Event
        ,JSonField:Name::STRING AS Name
        ,JSonField:Description::STRING AS Description
        ,JSonField:ShortName::STRING AS ShortName
        ,JSonField:Priority::INTEGER AS Priority
        FROM {{ source("REDGATE", "ALERTTYPE") }}
     WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("REDGATE", "ALERTTYPE") }})  
)
,transform_data as
(
    SELECT
        source_data.ALERTTYPE AS AlertType,
        source_data.EVENT AS Event,
        source_data.NAME AS Name,
        source_data.DESCRIPTION AS Description,
        source_data.SHORTNAME AS ShortName,
        source_data.PRIORITY AS Priority,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(ALERTTYPE as NUMBER(38,0)) as ALERTTYPE,
        cast(EVENT as NUMBER(38,0)) as EVENT,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(SHORTNAME as VARCHAR(16777216)) as SHORTNAME,
        cast(PRIORITY as NUMBER(38,0)) as PRIORITY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data