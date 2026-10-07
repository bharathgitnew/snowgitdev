/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='tel_incremental',
          incremental_strategy='merge',
          alias='CRM_FILE_CNT_CNT_CONTRACTSUMMARY_ACCOUNT_FAB',
          unique_key=['ID'],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'Id')::STRING AS "ID", 
 	 	get_ignore_case(to_object(JSONFIELD),'SinkCreatedOn')::STRING AS "SINKCREATEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'SinkModifiedOn')::STRING AS "SINKMODIFIEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'accountid')::STRING AS "ACCOUNTID", 
 	 	get_ignore_case(to_object(JSONFIELD),'versionnumber')::STRING AS "VERSIONNUMBER", 
 	 	get_ignore_case(to_object(JSONFIELD),'cnt_cnt_contractsummary_account_fabid')::STRING AS "CNT_CNT_CONTRACTSUMMARY_ACCOUNT_FABID", 
 	 	get_ignore_case(to_object(JSONFIELD),'cnt_contractsummaryid')::STRING AS "CNT_CONTRACTSUMMARYID", 
 	 	get_ignore_case(to_object(JSONFIELD),'IsDelete')::STRING AS "ISDELETE", 
 	 	get_ignore_case(to_object(JSONFIELD),'CreatedOn')::STRING AS "CREATEDON",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('CRM_FILE', 'CNT_CNT_CONTRACTSUMMARY_ACCOUNT_FAB') }} AS CNT_CNT_CONTRACTSUMMARY_ACCOUNT_FAB
        {% if is_tel_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY get_ignore_case(to_object(JSONFIELD),'Id')::STRING  ORDER BY _FILEDATE DESC,_UPLOADDATE DESC)) = 1
    ),
    transform_data as (
        SELECT
        "ID", 
 	 	TRY_TO_TIMESTAMP("SINKCREATEDON", 'MM/DD/YYYY HH:MI:SS PM') AS "SINKCREATEDON", 
 	 	TRY_TO_TIMESTAMP("SINKMODIFIEDON", 'MM/DD/YYYY HH:MI:SS PM') AS "SINKMODIFIEDON", 
 	 	"ACCOUNTID", 
 	 	"VERSIONNUMBER", 
 	 	"CNT_CNT_CONTRACTSUMMARY_ACCOUNT_FABID", 
 	 	"CNT_CONTRACTSUMMARYID", 
 	 	"ISDELETE", 
 	 	"CREATEDON",
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
        "ID" AS "ID", 
 	 	CAST("SINKCREATEDON" AS TIMESTAMP_LTZ(9)) AS "SINKCREATEDON", 
 	 	CAST("SINKMODIFIEDON" AS TIMESTAMP_LTZ(9)) AS "SINKMODIFIEDON", 
 	 	"ACCOUNTID" AS "ACCOUNTID", 
 	 	CAST("VERSIONNUMBER" AS NUMBER(38,0)) AS "VERSIONNUMBER", 
 	 	"CNT_CNT_CONTRACTSUMMARY_ACCOUNT_FABID" AS "CNT_CNT_CONTRACTSUMMARY_ACCOUNT_FABID", 
 	 	"CNT_CONTRACTSUMMARYID" AS "CNT_CONTRACTSUMMARYID", 
 	 	CAST("ISDELETE" AS BOOLEAN) AS "ISDELETE", 
 	 	CAST("CREATEDON" AS TIMESTAMP_LTZ(9)) AS "CREATEDON",
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE
        FROM transform_data
    )
    SELECT * FROM type_data