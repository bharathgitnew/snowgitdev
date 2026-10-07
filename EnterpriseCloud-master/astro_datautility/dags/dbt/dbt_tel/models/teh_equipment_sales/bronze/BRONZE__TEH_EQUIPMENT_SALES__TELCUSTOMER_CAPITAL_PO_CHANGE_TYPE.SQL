/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-TELCUSTOMER\CAPITAL_PO_CHANGE_TYPE__TELCustomer_CAPITAL_PO_CHANGE_TYPE.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\TELCUSTOMER\capital_po_change_type.SQL
-materialized incremental
-alias capital_po_change_type
-incremental_strategy insert_overwrite
-envVariable <<LZ>>
-sourceSchema TELCUSTOMER
-sourceDatabase LZ_DEV
-useDistinct $false
model file generated on: 1/14/2022 11:24:12 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELCUSTOMER_CAPITAL_PO_CHANGE_TYPE',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
        	_FILENAME
        	,_FILEDATE
        	,JSONFIELD:"CHANGE_TYPE_ID"::NUMBER AS CHANGE_TYPE_ID
        	,JSONFIELD:"DESCRIPTION"::STRING AS DESCRIPTION
        FROM {{ source("TELCUSTOMER", "CAPITAL_PO_CHANGE_TYPE") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_CHANGE_TYPE") }})
)
,transform_data as
(
    SELECT
        source_data._FILENAME,
        source_data._FILEDATE,
        source_data.CHANGE_TYPE_ID,
        source_data.DESCRIPTION,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH
        FROM source_data
)
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        _Filedate AS _FILEDATE,
        _Filename AS _FILENAME,
        cast(CHANGE_TYPE_ID as NUMBER(38,0)) as CHANGE_TYPE_ID,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION
    from transform_data
    )
select * from type_data