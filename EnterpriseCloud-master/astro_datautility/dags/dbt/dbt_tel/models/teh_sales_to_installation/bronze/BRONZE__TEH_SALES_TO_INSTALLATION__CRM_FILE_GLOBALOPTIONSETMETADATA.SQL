{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='CRM_FILE_GLOBALOPTIONSETMETADATA',
    unique_key=[
        'OPTIONSETNAME',
        'OPTION',
        'ISUSERLOCALIZEDLABEL',
        'LOCALIZEDLABELLANGUAGECODE',
        'GLOBALOPTIONSETNAME',
        'ENTITYNAME'
    ],
) }} 

with source_data as (
    SELECT
        get_ignore_case(to_object(JSONFIELD),'OptionSetName')::STRING AS "OPTIONSETNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'Option')::STRING AS "OPTION", 
 	 	get_ignore_case(to_object(JSONFIELD),'IsUserLocalizedLabel')::STRING AS "ISUSERLOCALIZEDLABEL", 
 	 	get_ignore_case(to_object(JSONFIELD),'LocalizedLabelLanguageCode')::STRING AS "LOCALIZEDLABELLANGUAGECODE", 
 	 	get_ignore_case(to_object(JSONFIELD),'LocalizedLabel')::STRING AS "LOCALIZEDLABEL", 
 	 	get_ignore_case(to_object(JSONFIELD),'GlobalOptionSetName')::STRING AS "GLOBALOPTIONSETNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'EntityName')::STRING AS "ENTITYNAME",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
    FROM {{ source('CRM_FILE', 'GLOBALOPTIONSETMETADATA') }} AS GLOBALOPTIONSETMETADATA
    {% if is_tel_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY "OPTIONSETNAME","OPTION","ISUSERLOCALIZEDLABEL","LOCALIZEDLABELLANGUAGECODE","GLOBALOPTIONSETNAME","ENTITYNAME" ORDER BY _FILEDATE DESC,_UPLOADDATE DESC)) = 1
),

transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        "OPTIONSETNAME", 
 	 	"OPTION", 
 	 	"ISUSERLOCALIZEDLABEL", 
 	 	"LOCALIZEDLABELLANGUAGECODE", 
 	 	"LOCALIZEDLABEL", 
 	 	"GLOBALOPTIONSETNAME", 
 	 	"ENTITYNAME",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
    FROM source_data
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        "OPTIONSETNAME", 
 	 	"OPTION", 
 	 	"ISUSERLOCALIZEDLABEL", 
 	 	"LOCALIZEDLABELLANGUAGECODE", 
 	 	"LOCALIZEDLABEL", 
 	 	"GLOBALOPTIONSETNAME", 
 	 	"ENTITYNAME",
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE
    FROM transform_data
)
SELECT * FROM type_data