{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='GROUPS'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename,
        _Filedate as _Filedate,
        jsonfield:"@odata.context"::string as Context,
        jsonfield:"@odata.count"::string as Count,
        r.value:"capacityId"::string as capacityId,
        r.value:"defaultDatasetStorageFormat"::string as defaultDatasetStorageFormat,
        r.value:"id"::string as id,
        r.value:"isOnDedicatedCapacity"::string as isOnDedicatedCapacity,
        r.value:"isReadOnly"::string as isReadOnly,
        r.value:"name"::string as name,
        r.value:"type"::string as type
    FROM {{ source("POWERBI", "GROUPS") }} Dt,
        lateral flatten ( input => dt.jsonfield:"value", outer => true) r
)
,transform_data as
(
    SELECT
        _FILENAME as _FILENAME,
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        Context as CONTEXT,
        Count as Count,
        capacityId as CAPACITY_ID,
        defaultDatasetStorageFormat as DEFAULT_DATASETSTORAGE_FORMAT,
        id as ID,
        isOnDedicatedCapacity as IS_ON_DEDICATED_CAPACITY,
        isReadOnly as IS_READONLY,
        name as NAME,
        type as TYPE
    FROM source_data
)
, type_data AS
(
    SELECT
        CAST(_Audit_Log_Id AS VARCHAR(128))  AS _Audit_Log_Id,
        CAST(_Row_Hash AS VARCHAR(128))  AS _Row_Hash,
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE,
        CONTEXT,
        Count,
        CAPACITY_ID,
        DEFAULT_DATASETSTORAGE_FORMAT,
        ID,
        IS_ON_DEDICATED_CAPACITY,
        IS_READONLY,
        NAME,
        TYPE
    FROM transform_data
)
select * from type_data