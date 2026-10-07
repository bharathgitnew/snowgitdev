/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-File\ActiveAssetReport__File_ActiveAssetReport.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\file\ActiveAssetReport.SQL
-materialized incremental
-alias ActiveAssetReport
-incremental_strategy insert_overwrite
-envVariable <<LZ>>
-sourceSchema FILE
-sourceDatabase LZ_DEV
-useDistinct $false
model file generated on: 1/10/2022 11:56:58 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='ActiveAssetReport',
    unique_key = []
) }}


with source_data as
(
    SELECT
	    _FileDate,
	    CONTRACT_NUMBER,
	    COMMENCEMENT,
	    TERM,
	    TERMINATION,
	    DELL_ORDER_NUMBER,
	    ASSET_ID,
	    EQUIPMENT_DESCRIPTION,
	    SERVICE_TAG,
	    PURCHASE_ORDER_NUM
        from {{ source("FILE", "ACTIVEASSETREPORT") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) from {{ source("FILE", "ACTIVEASSETREPORT") }})

    )
,transform_data as
(
    SELECT
        ASSET_ID,
        COMMENCEMENT,
        CONTRACT_NUMBER,
        DELL_ORDER_NUMBER,
        EQUIPMENT_DESCRIPTION,
        PURCHASE_ORDER_NUM,
        SERVICE_TAG,
        TERM,
        TERMINATION,
        _FileDate,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(CONTRACT_NUMBER as VARCHAR(50)) as CONTRACT_NUMBER,
        cast(COMMENCEMENT as DATE) as COMMENCEMENT,
        cast(TERM as NUMBER(38,0)) as TERM,
        cast(TERMINATION as DATE) as TERMINATION,
        cast(DELL_ORDER_NUMBER as VARCHAR(50)) as DELL_ORDER_NUMBER,
        cast(ASSET_ID as VARCHAR(50)) as ASSET_ID,
        cast(EQUIPMENT_DESCRIPTION as VARCHAR(255)) as EQUIPMENT_DESCRIPTION,
        cast(SERVICE_TAG as VARCHAR(50)) as SERVICE_TAG,
        cast(PURCHASE_ORDER_NUM as VARCHAR(50)) as PURCHASE_ORDER_NUM,
        cast(_FileDate as Timestamp_NTZ) as _FileDate,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data