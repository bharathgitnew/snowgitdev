{{ config(
        materialized='incremental'    ,
    incremental_strategy='insert_overwrite'    ,
    alias='LastBackup'    ,
    unique_key = []    
) }}


with source_data as
(
    SELECT
        JSonField:ClusterName::STRING AS ClusterName
        ,JSonField:InstanceName::STRING AS InstanceName
        ,JSonField:DatabaseName::STRING AS DatabaseName
        ,try_to_timestamp_ltz(to_varchar(round(div0(JSonField:StartDate::STRING-621355968000000000,10000000)))) AS StartDate
        ,try_to_timestamp_ltz(to_varchar(round(div0(JSonField:FinishDate::STRING-621355968000000000,10000000)))) AS FinishDate
        ,JSonField:Size::INTEGER AS Size
        ,JSonField:BackupType::STRING AS BackupType
        ,JSonField:IsNativeBackup::INTEGER AS IsNativeBackup
        ,JSonField:BackupDevice::STRING AS BackupDevice
        FROM {{ source("REDGATE", "LASTBACKUP") }} AS LZData
            WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("REDGATE", "LASTBACKUP") }}) 
        )
,transform_data as
(
    SELECT
        source_data.CLUSTERNAME AS ClusterName,
        source_data.INSTANCENAME AS InstanceName,
        source_data.DATABASENAME AS DatabaseName,
        REGEXP_REPLACE ( source_data.STARTDATE , '\/Date\\(|\\)\/' , '' ) ::TIMESTAMP_LTZ AS StartDate,
        REGEXP_REPLACE ( source_data.FINISHDATE , '\/Date\\(|\\)\/' , '' ) ::TIMESTAMP_LTZ AS FinishDate,
        source_data.SIZE AS Size,
        source_data.BACKUPTYPE AS BackupType,
        source_data.ISNATIVEBACKUP AS IsNativeBackup,
        source_data.BACKUPDEVICE AS BackupDevice,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(CLUSTERNAME as VARCHAR(16777216)) as CLUSTERNAME,
        cast(INSTANCENAME as VARCHAR(16777216)) as INSTANCENAME,
        cast(DATABASENAME as VARCHAR(16777216)) as DATABASENAME,
        cast(STARTDATE as TIMESTAMP_LTZ(9)) as STARTDATE,
        cast(FINISHDATE as TIMESTAMP_LTZ(9)) as FINISHDATE,
        cast(SIZE as NUMBER(38,0)) as SIZE,
        cast(BACKUPTYPE as VARCHAR(16777216)) as BACKUPTYPE,
        cast(ISNATIVEBACKUP as NUMBER(38,0)) as ISNATIVEBACKUP,
        cast(BACKUPDEVICE as VARCHAR(16777216)) as BACKUPDEVICE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data