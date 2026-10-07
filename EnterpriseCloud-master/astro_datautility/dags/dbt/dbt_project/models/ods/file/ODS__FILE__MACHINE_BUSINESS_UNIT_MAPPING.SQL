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
    alias='MACHINE_BUSINESS_UNIT_MAPPING',
    unique_key = []
) }}


with source_data as
(
    SELECT
	    _FileDate,
	    MACHINE_BU_KEY,
	    MACHINE_BU_NAME,
	    TEL_GROUP_BU,
	    FS_BU_NAME,
	    BAAN_CONFIG_PREFIX,
	    ACTIVE_BU_FLAG,
	    CHANGE_COMMENTS
        from {{ source("FILE", "MACHINE_BUSINESS_UNIT_MAPPING") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) from {{ source("FILE", "MACHINE_BUSINESS_UNIT_MAPPING") }})

    )
,transform_data as
(
    SELECT
	    MACHINE_BU_KEY,
	    MACHINE_BU_NAME,
	    TEL_GROUP_BU,
	    FS_BU_NAME,
	    BAAN_CONFIG_PREFIX,
	    ACTIVE_BU_FLAG,
	    CHANGE_COMMENTS,
        _FileDate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_FileDate as Timestamp_NTZ) as _FileDate,
	    MACHINE_BU_KEY,
	    MACHINE_BU_NAME,
	    TEL_GROUP_BU,
	    FS_BU_NAME,
	    BAAN_CONFIG_PREFIX,
	    ACTIVE_BU_FLAG,
	    CHANGE_COMMENTS
    from transform_data
    )
select * from type_data