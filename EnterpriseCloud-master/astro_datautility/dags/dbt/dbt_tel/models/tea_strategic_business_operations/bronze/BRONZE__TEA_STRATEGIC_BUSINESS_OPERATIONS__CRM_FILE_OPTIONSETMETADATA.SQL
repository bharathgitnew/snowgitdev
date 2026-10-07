{{ config(
          materialized='tel_incremental',
          incremental_strategy='merge',
          alias='CRM_FILE_OPTIONSETMETADATA',
          unique_key=['ENTITYNAME',
     'OPTIONSETNAME',
     'OPTION',
     'ISUSERLOCALIZEDLABEL',
     'LOCALIZEDLABELLANGUAGECODE',
    'LOCALIZEDLABEL'],
          transient=false    
) }} 

    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'EntityName')::STRING AS "ENTITYNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'OptionSetName')::STRING AS "OPTIONSETNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'Option')::STRING AS "OPTION", 
 	 	get_ignore_case(to_object(JSONFIELD),'IsUserLocalizedLabel')::STRING AS "ISUSERLOCALIZEDLABEL", 
 	 	get_ignore_case(to_object(JSONFIELD),'LocalizedLabelLanguageCode')::STRING AS "LOCALIZEDLABELLANGUAGECODE", 
 	 	get_ignore_case(to_object(JSONFIELD),'LocalizedLabel')::STRING AS "LOCALIZEDLABEL",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
    FROM {{ source('CRM_FILE', 'OPTIONSETMETADATA') }} AS OPTIONSETMETADATA
    {% if is_tel_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY "ENTITYNAME", "OPTIONSETNAME", "OPTION", "ISUSERLOCALIZEDLABEL", "LOCALIZEDLABELLANGUAGECODE" ,
    "LOCALIZEDLABEL" ORDER BY _FILEDATE DESC,_UPLOADDATE DESC)) = 1),
    transform_data as (
        SELECT
        "ENTITYNAME", 
 	 	"OPTIONSETNAME", 
 	 	"OPTION", 
 	 	"ISUSERLOCALIZEDLABEL", 
 	 	"LOCALIZEDLABELLANGUAGECODE", 
 	 	"LOCALIZEDLABEL",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME as _FILENAME,
        _AUDIT_LOG_ID as _AUDIT_LOG_ID,
        _ROW_HASH as _ROW_HASH,
        "ENTITYNAME" AS "ENTITYNAME", 
 	 	"OPTIONSETNAME" AS "OPTIONSETNAME", 
 	 	"OPTION" AS "OPTION", 
 	 	"ISUSERLOCALIZEDLABEL" AS "ISUSERLOCALIZEDLABEL", 
 	 	"LOCALIZEDLABELLANGUAGECODE" AS "LOCALIZEDLABELLANGUAGECODE", 
 	 	"LOCALIZEDLABEL" AS "LOCALIZEDLABEL",
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE
        FROM transform_data
    )
    SELECT * FROM type_data