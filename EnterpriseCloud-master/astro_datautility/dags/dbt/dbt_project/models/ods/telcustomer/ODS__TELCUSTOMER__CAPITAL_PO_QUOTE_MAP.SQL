{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Capital_PO_Quote_Map',
    unique_key = []
) }}


with source_data as
(
    SELECT
        	_FILENAME
        	,_FILEDATE
        	,JSONFIELD:"QUOTE_PREFIX"::STRING AS QUOTE_PREFIX
        	,JSONFIELD:"BU"::STRING AS BU
        	,JSONFIELD:"SUB_BU"::STRING AS SUB_BU
        FROM {{ source("TELCUSTOMER", "CAPITAL_PO_QUOTE_MAP") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_QUOTE_MAP") }})
)
,transform_data as
(
    SELECT
        QUOTE_PREFIX,
        BU,
        SUB_BU
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
)
,type_data as 
(
    select
        cast(QUOTE_PREFIX as VARCHAR(16777216)) as QUOTE_PREFIX,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data