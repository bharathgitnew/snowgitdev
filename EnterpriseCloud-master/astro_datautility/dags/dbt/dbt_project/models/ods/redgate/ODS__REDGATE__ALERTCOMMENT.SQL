{{ config(
        materialized='incremental'    ,
    incremental_strategy='insert_overwrite'    ,
    alias='AlertComment'    ,
    unique_key = []    
) }}


with source_data as
(
    SELECT
        JSonField:CommentId::INTEGER AS CommentId
        ,JSonField:AlertId::INTEGER AS AlertId
        ,JSonField:Author::STRING AS Author
        ,try_to_timestamp_ltz(to_varchar(round(div0( JSonField:Date::INTEGER- 621355968000000000, 10000000)))) AS Date
        ,JSonField:CommentText::STRING AS CommentText
        FROM {{ source("REDGATE", "ALERTCOMMENT") }} 
             WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("REDGATE", "ALERTCOMMENT") }}) 
)
,transform_data as
(
    SELECT
        source_data.COMMENTID AS CommentId,
        source_data.ALERTID AS AlertId,
        source_data.AUTHOR AS Author,
        REGEXP_REPLACE ( source_data.DATE , '\/Date\\(|\\)\/' , '' ) ::TIMESTAMP_LTZ AS Date,
        source_data.COMMENTTEXT AS CommentText,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(COMMENTID as NUMBER(38,0)) as COMMENTID,
        cast(ALERTID as NUMBER(38,0)) as ALERTID,
        cast(AUTHOR as VARCHAR(16777216)) as AUTHOR,
        cast(DATE as TIMESTAMP_LTZ(9)) as DATE,
        cast(COMMENTTEXT as VARCHAR(16777216)) as COMMENTTEXT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data