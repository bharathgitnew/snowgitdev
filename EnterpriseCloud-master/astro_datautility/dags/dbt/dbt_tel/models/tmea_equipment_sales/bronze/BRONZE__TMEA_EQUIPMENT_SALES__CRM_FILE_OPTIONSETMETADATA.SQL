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
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        "ENTITYNAME",
        "OPTIONSETNAME",
        "OPTION",
        "ISUSERLOCALIZEDLABEL",
        "LOCALIZEDLABELLANGUAGECODE",
        "LOCALIZEDLABEL",
        _UPLOADDATE
FROM source_data
    ),
    type_data as (
        SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST("ENTITYNAME" AS VARCHAR(16777216)) AS "ENTITYNAME",
        CAST("OPTIONSETNAME" AS VARCHAR(16777216)) AS "OPTIONSETNAME",
        CAST("OPTION" AS VARCHAR(16777216)) AS "OPTION",
        CAST("ISUSERLOCALIZEDLABEL" AS VARCHAR(16777216)) AS "ISUSERLOCALIZEDLABEL",
        CAST("LOCALIZEDLABELLANGUAGECODE" AS VARCHAR(16777216)) AS "LOCALIZEDLABELLANGUAGECODE",
        CAST("LOCALIZEDLABEL" AS VARCHAR(16777216)) AS "LOCALIZEDLABEL",
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE
FROM transform_data
    )
    SELECT * FROM type_data