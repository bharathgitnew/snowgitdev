/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\BaanOrderSeries.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\BaanOrderSeries.SQL
-materialized incremental
-alias BaanOrderSeries
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BaanOrderSeries',
    unique_key = ['OrderSeriesCode']
) }}


with source_data as
(
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,_Uploaddate as _Uploaddate
         ,JSonField:Code::STRING AS OrderSeriesCode
         ,JSonField:Name::STRING AS OrderSeries
         ,JSonField:"Order Group Code"::STRING AS OrderGroupCode
         ,JSonField:"Order Group Name"::STRING AS OrderGroupName
         ,JSonField:"Kronos Type of Work"::STRING AS KronosTypeOfWork
         ,JSonField:"Baan Product Type Code"::STRING AS BaanProductTypeCode
         ,JSonField:"Order Creator"::STRING AS OrderCreator
        FROM {{ source("MDM", "BAANORDERSERIES") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "BAANORDERSERIES") }})
        )
,transform_data as
(
    SELECT
        source_data.ORDERSERIES AS OrderSeries,
        source_data.ORDERSERIESCODE AS OrderSeriesCode,
        source_data.ORDERGROUPCODE AS OrderGroupCode,
        source_data.ORDERGROUPNAME AS OrderGroupName,
        source_data.KRONOSTYPEOFWORK AS KronosTypeOfWork,
        source_data.BAANPRODUCTTYPECODE AS BaanProductTypeCode,
        source_data.ORDERCREATOR AS OrderCreator,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(ORDERSERIES as VARCHAR(16777216)) as ORDERSERIES,
        cast(ORDERSERIESCODE as VARCHAR(16777216)) as ORDERSERIESCODE,
        cast(ORDERGROUPCODE as VARCHAR(16777216)) as ORDERGROUPCODE,
        cast(ORDERGROUPNAME as VARCHAR(16777216)) as ORDERGROUPNAME,
        cast(KRONOSTYPEOFWORK as VARCHAR(16777216)) as KRONOSTYPEOFWORK,
        cast(BAANPRODUCTTYPECODE as VARCHAR(16777216)) as BAANPRODUCTTYPECODE,
        cast(ORDERCREATOR as VARCHAR(16777216)) as ORDERCREATOR,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data