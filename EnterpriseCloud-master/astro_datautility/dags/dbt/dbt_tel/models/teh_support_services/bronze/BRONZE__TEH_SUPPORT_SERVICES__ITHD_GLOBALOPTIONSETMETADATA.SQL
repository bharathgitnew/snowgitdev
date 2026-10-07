{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='ITHD_GLOBALOPTIONSETMETADATA',
        tags=["metadata"],
        unique_key=[],
        transient=false
) }} 

with source_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:OptionSetName::STRING as OPTIONSETNAME,
        JSONFIELD:Option::STRING as OPTION,
        JSONFIELD:IsUserLocalizedLabel::STRING as ISUSERLOCALIZEDLABEL,
        JSONFIELD:LocalizedLabelLanguageCode::STRING as LOCALIZEDLABELLANGUAGECODE,
        JSONFIELD:LocalizedLabel::STRING as LOCALIZEDLABEL,
        JSONFIELD:GlobalOptionSetName::STRING as GLOBALOPTIONSETNAME,
        JSONFIELD:EntityName::STRING as ENTITYNAME
    FROM {{ source('ITHD', 'GLOBALOPTIONSETMETADATA') }}
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) from {{ source('ITHD', 'GLOBALOPTIONSETMETADATA') }})
),

transform_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        OPTIONSETNAME,
        OPTION,
        ISUSERLOCALIZEDLABEL,
        LOCALIZEDLABELLANGUAGECODE,
        LOCALIZEDLABEL,
        GLOBALOPTIONSETNAME,
        ENTITYNAME
    FROM source_data
),

type_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        AUDIT_LOG_ID,
        _ROW_HASH,
        cast(OPTIONSETNAME as VARCHAR(16777216)) as OPTIONSETNAME,
        cast(OPTION as VARCHAR(16777216)) as OPTION,
        cast(ISUSERLOCALIZEDLABEL as VARCHAR(16777216)) as ISUSERLOCALIZEDLABEL,
        cast(LOCALIZEDLABELLANGUAGECODE as VARCHAR(16777216)) as LOCALIZEDLABELLANGUAGECODE,
        cast(LOCALIZEDLABEL as VARCHAR(16777216)) as LOCALIZEDLABEL,
        cast(GLOBALOPTIONSETNAME as VARCHAR(16777216)) as GLOBALOPTIONSETNAME,
        cast(ENTITYNAME as VARCHAR(16777216)) as ENTITYNAME
    FROM transform_data
)

select * from type_data