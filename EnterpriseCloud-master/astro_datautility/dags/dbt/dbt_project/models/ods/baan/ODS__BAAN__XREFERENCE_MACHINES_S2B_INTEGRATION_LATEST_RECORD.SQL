{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='XREFERENCE_MACHINES_S2B_INTEGRATION_LATEST_RECORD',
    unique_key = ['']
) }}

with source_data as
(
SELECT
_FILEDATE,
_FILENAME,
JSONFIELD:"Latest Trans Dt"::STRING AS "Latest Trans Dt",
JSONFIELD:"Trans ID"::STRING AS "Trans ID",
JSONFIELD:"BU"::STRING AS "BU",
JSONFIELD:"SN"::STRING AS "SN",
JSONFIELD:"SWLH Model"::STRING AS "SWLH Model",
JSONFIELD:"MPI Model Name"::STRING AS "MPI Model Name",
JSONFIELD:"TEL Model Code"::STRING AS "TEL Model Code",
JSONFIELD:"TEL Model Name"::STRING AS "TEL Model Name",
JSONFIELD:"Supplier Code"::STRING AS "Supplier Code",
JSONFIELD:"Revenue Method Code"::STRING AS "Revenue Method Code",
JSONFIELD:"Revenue Method Desc"::STRING AS "Revenue Method Desc",
JSONFIELD:"Cluster Flag"::STRING AS "Cluster Flag",
JSONFIELD:"Machine Module Type"::STRING AS "Machine Module Type",
JSONFIELD:"Parent SN"::STRING AS "Parent SN",
JSONFIELD:"Chamber Install Position"::STRING AS "Chamber Install Position",
JSONFIELD:"Customer Tool ID"::STRING AS "Customer Tool ID",
JSONFIELD:"Wafer Size"::STRING AS "Wafer Size",
JSONFIELD:"Table Refresh Date"::STRING AS "Table Refresh Date",
JSONFIELD:"Acceptance Comment"::STRING AS "Acceptance Comment",
JSONFIELD:"TEL Sales Order"::STRING AS "TEL Sales Order",
JSONFIELD:"Wisdom System Name"::STRING AS "Wisdom System Name",
JSONFIELD:"First Integration"::STRING AS "First Integration"
FROM {{ source('LEGACY93', 'XREFERENCE_MACHINES_S2B_INTEGRATION_LATEST_RECORD') }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('LEGACY93', 'XREFERENCE_MACHINES_S2B_INTEGRATION_LATEST_RECORD') }})
)

,transform_data as
(
SELECT
_FILEDATE,
_FILENAME,
'{{ invocation_id }}' AS _AUDIT_LOG_ID,
 SHA2('hash_me') AS _ROW_HASH,
"Latest Trans Dt",
"Trans ID",
"BU",
"SN",
"SWLH Model",
"MPI Model Name",
"TEL Model Code",
"TEL Model Name",
"Supplier Code",
"Revenue Method Code",
"Revenue Method Desc",
"Cluster Flag",
"Machine Module Type",
"Parent SN",
"Chamber Install Position",
"Customer Tool ID",
"Wafer Size",
"Table Refresh Date",
"Acceptance Comment",
"TEL Sales Order",
"Wisdom System Name",
"First Integration"
FROM source_data
)

,type_data as 
(
SELECT
CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
"Latest Trans Dt",
"Trans ID",
"BU",
"SN",
"SWLH Model",
"MPI Model Name",
"TEL Model Code",
"TEL Model Name",
"Supplier Code",
"Revenue Method Code",
"Revenue Method Desc",
"Cluster Flag",
"Machine Module Type",
"Parent SN",
"Chamber Install Position",
"Customer Tool ID",
"Wafer Size",
"Table Refresh Date",
"Acceptance Comment",
"TEL Sales Order",
"Wisdom System Name",
"First Integration"
from transform_data 
)
SELECT * FROM type_data