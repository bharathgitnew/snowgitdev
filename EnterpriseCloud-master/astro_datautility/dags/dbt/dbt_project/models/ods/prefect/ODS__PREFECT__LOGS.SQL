{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='LOGS'
) }}

with source_data as
(
    SELECT
         src._FILENAME as _FILENAME
        ,src._FILEDATE as _FILEDATE
        ,src.ID as ID
        ,LISTAGG(src.DETAILED_LOGS, '\n') WITHIN GROUP(ORDER BY src.ID,src.created) AS DETAILED_LOGS
    FROM 
        (
            SELECT 
                BASEDATA._FILENAME as _FILENAME
                ,BASEDATA._FILEDATE as _FILEDATE
                ,BASEDATA.ID as ID
                ,LogLevel.value:created::VARIANT AS CREATED
                ,concat(LogLevel.value:created::VARIANT,' ',LogLevel.value:message::VARIANT) as DETAILED_LOGS
            FROM 
                (
                    SELECT
                        _Filename as _FILENAME
                        ,_Filedate as _FILEDATE
                        ,FlowRunLevel.value:id::STRING AS ID
                        ,FlowRunLevel.value:logs::VARIANT as logs
                    FROM {{ source("PREFECT", "LOGS") }}
                        ,LATERAL FLATTEN (input => JsonField:data.flow_run) FlowRunLevel
                        where _Filedate not in (select _Filedate from {{ this }})
                ) as BASEDATA
                ,LATERAL FLATTEN (input => LOGS) LogLevel
                ORDER BY LogLevel.value:created
            ) as src
        GROUP BY ID,_FILEDATE,_FILENAME
)
,transform_data as
(
    SELECT
        _FILENAME as _FILENAME
        ,_FILEDATE as _FILEDATE
        ,ID AS ID
        ,DETAILED_LOGS AS DETAILED_LOGS
        ,'{{ invocation_id }}' AS Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash
    FROM source_data
)
, type_data AS
(
    SELECT
         CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME
        ,CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE
        ,CAST(ID AS VARCHAR(16777216))  AS ID
        ,CAST(DETAILED_LOGS AS VARCHAR(16777216))  AS DETAILED_LOGS
        ,CAST(Audit_Log_Id AS VARCHAR(128))  AS Audit_Log_Id
        ,CAST(_Row_Hash AS VARCHAR(128))  AS _Row_Hash
    FROM transform_data
)
select * from type_data