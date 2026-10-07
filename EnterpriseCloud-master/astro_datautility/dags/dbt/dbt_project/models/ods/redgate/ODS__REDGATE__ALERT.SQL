{{ config(
        materialized='incremental'    ,
    incremental_strategy='insert_overwrite'    ,
    alias='Alert'    ,
    unique_key = []    
) }}


with source_data as
(
    SELECT
        JSonField:AlertId::INTEGER AS AlertId
        ,JSonField:AlertType::INTEGER AS AlertType
        ,JSonField:TargetObject::STRING AS TargetObject
        ,JSonField:Read::INTEGER AS Read
        ,try_to_timestamp_ltz(to_varchar(round(div0( JSonField:ReadDate::INTEGER - 621355968000000000, 10000000)))) AS ReadDate
        ,JSonField:SubType::INTEGER AS SubType
        ,try_to_timestamp_ltz(to_varchar(round(div0( JSonField:LastUpdate::INTEGER - 621355968000000000, 10000000))))  AS LastUpdateDate
        ,try_to_timestamp_ltz(to_varchar(round(div0( JSonField:Raised::INTEGER - 621355968000000000, 10000000)))) AS RaisedDate
        ,JSonField:LastSeverity::INTEGER AS LastSeverity
        ,JSonField:WorstSeverity::INTEGER AS WorstSeverity
        ,JSonField:Cleared::INTEGER AS Cleared
        ,try_to_timestamp_ltz(to_varchar(round(div0( JSonField:ClearedDate::INTEGER- 621355968000000000, 10000000)))) AS ClearedDate
        ,JSonField:LastComment::STRING AS LastComment
        ,JSonField:RootCir::STRING AS RootCir
        ,JSonField:GroupCir::STRING AS GroupCir
        FROM {{ source("REDGATE", "ALERT") }} AS LZData
            WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("REDGATE", "ALERT") }})
) 
,transform_data as
(
    SELECT
        source_data.ALERTID AS AlertId,
        source_data.ALERTTYPE AS AlertType,
        source_data.CLEARED AS Cleared,
        REGEXP_REPLACE ( source_data.CLEAREDDATE , '\/Date\\(|\\)\/' , '' ) ::TIMESTAMP_LTZ AS CLEAREDDATE,
        source_data.GROUPCIR AS GroupCir,
        source_data.LASTCOMMENT AS LastComment,
        source_data.LASTSEVERITY AS LastSeverity,
        REGEXP_REPLACE ( source_data.LASTUPDATEDATE , '\/Date\\(|\\)\/' , '' ) ::TIMESTAMP_LTZ AS LastUpdate,
        REGEXP_REPLACE ( source_data.RAISEDDATE , '\/Date\\(|\\)\/' , '' ) ::TIMESTAMP_LTZ AS Raised,
        source_data.READ AS Read,
        REGEXP_REPLACE ( source_data.ReadDate , '\/Date\\(|\\)\/' , '' ) ::TIMESTAMP_LTZ AS ReadDate,
        source_data.ROOTCIR AS RootCir,
        source_data.SUBTYPE AS SubType,
        source_data.TARGETOBJECT AS TargetObject,
        source_data.WORSTSEVERITY AS WorstSeverity,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(ALERTID as NUMBER(38,0)) as ALERTID,
        cast(ALERTTYPE as NUMBER(38,0)) as ALERTTYPE,
        cast(CLEARED as BOOLEAN) as CLEARED,
        cast(CLEAREDDATE as TIMESTAMP_LTZ(9)) as CLEAREDDATE,
        cast(GROUPCIR as VARCHAR(16777216)) as GROUPCIR,
        cast(LASTCOMMENT as VARCHAR(16777216)) as LASTCOMMENT,
        cast(LASTSEVERITY as NUMBER(38,0)) as LASTSEVERITY,
        cast(LASTUPDATE as TIMESTAMP_LTZ(9)) as LASTUPDATE,
        cast(RAISED as TIMESTAMP_LTZ(9)) as RAISED,
        cast(READ as BOOLEAN) as READ,
        cast(READDATE as TIMESTAMP_LTZ(9)) as READDATE,
        cast(ROOTCIR as VARCHAR(16777216)) as ROOTCIR,
        cast(SUBTYPE as NUMBER(38,0)) as SUBTYPE,
        cast(TARGETOBJECT as VARCHAR(16777216)) as TARGETOBJECT,
        cast(WORSTSEVERITY as NUMBER(38,0)) as WORSTSEVERITY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data