/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\TEAItems.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\TEAItems.SQL
-materialized incremental
-alias TEAItems
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 7:25:01 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_TEAITEMS',
    unique_key = ['ItemId']
) }}


with source_data as
(
    SELECT
         _Filedate as _FILEDATE,
         _Filename as _FILENAME         
         ,JSonField:Code::STRING AS ItemId
         ,JSonField:Classification::STRING AS Classification
    {%- if is_tel_incremental() %}
        FROM {{ source("MDM", "TEAITEMS") }}
        WHERE _Filedate = (SELECT COALESCE(MAX(_FileDate),'1900-01-01') FROM {{ source("MDM", "TEAITEMS") }} )
    {%- else %}
        FROM {{ source("MDM", "TEAITEMS") }}
        QUALIFY (ROW_NUMBER() OVER ( PARTITION BY JSonField:Code::STRING ORDER BY _Filedate DESC )) = 1
    {%- endif %}
        )
,transform_data as
(
    SELECT
         _FILEDATE,
         _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        source_data.ITEMID AS ItemId,
        source_data.CLASSIFICATION AS Classification
        FROM source_data
        )
,type_data as
(
    select
         _FILEDATE,
         _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        ITEMID,
        CLASSIFICATION
    from transform_data
    )
select * from type_data