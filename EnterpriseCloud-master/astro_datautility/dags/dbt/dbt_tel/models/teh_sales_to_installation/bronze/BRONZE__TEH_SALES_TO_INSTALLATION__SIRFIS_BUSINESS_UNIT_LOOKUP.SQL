{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SIRFIS_BUSINESS_UNIT_LOOKUP',
    unique_key = ['BUSINESS_UNIT_LOOKUP_ID']
) }}


with source_data as
(
    SELECT
    	_FILEDATE,
		_FILENAME,
        jsonfield:fields.BUSINESS_UNIT_LOOKUP_ID::NUMBER(38,0) as BUSINESS_UNIT_LOOKUP_ID,
        TO_TIMESTAMP_NTZ(TRIM(jsonfield:fields.CREATED_ON::STRING,'/Date()/')) as Created_On,
        jsonfield:fields.LOOKUP_TYPE::STRING as Type,
        jsonfield:fields.MATCH_VALUE::STRING as Match_Value,
        jsonfield:fields.BUSINESS_UNIT::STRING as Business_Unit,
        jsonfield:fields.ACRONYM::STRING as Acronym
    FROM {{ source("SIRFIS", "BUSINESS_UNIT_LOOKUP") }}
    WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("SIRFIS", "BUSINESS_UNIT_LOOKUP") }})
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
    	_FILEDATE,
		_FILENAME,
        source_data.Business_Unit_Lookup_ID AS Business_Unit_Lookup_ID,
        source_data.Created_On AS Created_On,
        source_data.Type AS Type,
        source_data.Match_Value AS Match_Value,
        source_data.Business_Unit AS Business_Unit,
        source_data.Acronym AS Acronym
    FROM source_data
)
,type_data as
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
        cast(BUSINESS_UNIT_LOOKUP_ID as NUMBER(38,0)) as BUSINESS_UNIT_LOOKUP_ID,
        cast(CREATED_ON as TIMESTAMP_NTZ(9)) as CREATED_ON,
        TYPE,
        MATCH_VALUE,
        BUSINESS_UNIT,
        ACRONYM
    from transform_data
    )
select * from type_data
