/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\FinancialSegment.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\FinancialSegment.SQL
-materialized incremental
-alias FinancialSegment
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='FinancialSegment',
    unique_key = ['SEGMENTCODE']
) }}


with source_data as
(
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:Code::STRING AS SegmentCode
         ,JSonField:FinancialSegmentAlternateName::STRING AS AlternateName
         ,JSonField:FinancialSegmentShortName::STRING AS ShortName
         ,JSonField:FinancialSegmentGroup::STRING AS GroupName
        FROM {{ source("MDM", "FINANCIALSEGMENT") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "FINANCIALSEGMENT") }})
        )
,transform_data as
(
    SELECT
        source_data.SEGMENTCODE AS SEGMENTCODE,
        source_data.ALTERNATENAME AS ALTERNATENAME,
        source_data.SHORTNAME AS SHORTNAME,
        source_data.GROUPNAME AS GROUPNAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(SEGMENTCODE as VARCHAR(16777216)) as SEGMENTCODE,
        cast(ALTERNATENAME as VARCHAR(16777216)) as ALTERNATENAME,
        cast(SHORTNAME as VARCHAR(16777216)) as SHORTNAME,
        cast(GROUPNAME as VARCHAR(16777216)) as GROUPNAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data