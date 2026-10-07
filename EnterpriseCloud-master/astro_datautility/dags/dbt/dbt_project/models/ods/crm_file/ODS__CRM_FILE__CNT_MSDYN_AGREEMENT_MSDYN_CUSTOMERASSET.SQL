/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='incremental',
          incremental_strategy='merge',
          alias='CNT_MSDYN_AGREEMENT_MSDYN_CUSTOMERASSET',
          unique_key=['ID'],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'Id')::STRING AS "ID", 
 	 	get_ignore_case(to_object(JSONFIELD),'SinkCreatedOn')::STRING AS "SINKCREATEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'SinkModifiedOn')::STRING AS "SINKMODIFIEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'cnt_msdyn_agreement_msdyn_customerassetid')::STRING AS "CNT_MSDYN_AGREEMENT_MSDYN_CUSTOMERASSETID", 
 	 	get_ignore_case(to_object(JSONFIELD),'versionnumber')::STRING AS "VERSIONNUMBER", 
 	 	get_ignore_case(to_object(JSONFIELD),'msdyn_agreementid')::STRING AS "MSDYN_AGREEMENTID", 
 	 	get_ignore_case(to_object(JSONFIELD),'msdyn_customerassetid')::STRING AS "MSDYN_CUSTOMERASSETID", 
 	 	get_ignore_case(to_object(JSONFIELD),'IsDelete')::STRING AS "ISDELETE", 
 	 	get_ignore_case(to_object(JSONFIELD),'CreatedOn')::STRING AS "CREATEDON",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('CRM_FILE', 'CNT_MSDYN_AGREEMENT_MSDYN_CUSTOMERASSET') }} AS CNT_MSDYN_AGREEMENT_MSDYN_CUSTOMERASSET
        {% if is_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY get_ignore_case(to_object(JSONFIELD),'Id')::STRING  ORDER BY _FILEDATE DESC,_UPLOADDATE DESC)) = 1
    ),
    transform_data as (
        SELECT
        "ID", 
 	 	TRY_TO_TIMESTAMP("SINKCREATEDON", 'MM/DD/YYYY HH:MI:SS PM') AS "SINKCREATEDON", 
 	 	TRY_TO_TIMESTAMP("SINKMODIFIEDON", 'MM/DD/YYYY HH:MI:SS PM') AS "SINKMODIFIEDON", 
 	 	"CNT_MSDYN_AGREEMENT_MSDYN_CUSTOMERASSETID", 
 	 	"VERSIONNUMBER", 
 	 	"MSDYN_AGREEMENTID", 
 	 	"MSDYN_CUSTOMERASSETID", 
 	 	"ISDELETE", 
 	 	"CREATEDON",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST("ID" AS VARCHAR(16777216)) AS "ID", 
 	 	CAST("SINKCREATEDON" AS TIMESTAMP_LTZ(9)) AS "SINKCREATEDON", 
 	 	CAST("SINKMODIFIEDON" AS TIMESTAMP_LTZ(9)) AS "SINKMODIFIEDON", 
 	 	CAST("CNT_MSDYN_AGREEMENT_MSDYN_CUSTOMERASSETID" AS VARCHAR(16777216)) AS "CNT_MSDYN_AGREEMENT_MSDYN_CUSTOMERASSETID", 
 	 	CAST("VERSIONNUMBER" AS NUMBER(38,0)) AS "VERSIONNUMBER", 
 	 	CAST("MSDYN_AGREEMENTID" AS VARCHAR(16777216)) AS "MSDYN_AGREEMENTID", 
 	 	CAST("MSDYN_CUSTOMERASSETID" AS VARCHAR(16777216)) AS "MSDYN_CUSTOMERASSETID", 
 	 	CAST("ISDELETE" AS BOOLEAN) AS "ISDELETE", 
 	 	CAST("CREATEDON" AS TIMESTAMP_LTZ(9)) AS "CREATEDON",
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
        FROM transform_data
    )
    SELECT * FROM type_data