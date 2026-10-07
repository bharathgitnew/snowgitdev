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
    materialized='incremental',
    incremental_strategy='merge',
    alias='TEAItems',
    unique_key = ['ItemId']
) }}


with source_data as
(
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:Code::STRING AS ItemId
         ,JSonField:Classification::STRING AS Classification
    {%- if is_incremental() %}
        FROM {{ source("MDM", "TEAITEMS") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "TEAITEMS") }} )
    {%- else %}
        FROM {{ source("MDM", "TEAITEMS") }}
        QUALIFY (ROW_NUMBER() OVER ( PARTITION BY JSonField:Code::STRING ORDER BY _Filedate DESC )) = 1
    {%- endif %}
        )
,transform_data as
(
    SELECT
        source_data.ITEMID AS ItemId,
        source_data.CLASSIFICATION AS Classification,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(ITEMID as VARCHAR(16777216)) as ITEMID,
        cast(CLASSIFICATION as VARCHAR(16777216)) as CLASSIFICATION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data