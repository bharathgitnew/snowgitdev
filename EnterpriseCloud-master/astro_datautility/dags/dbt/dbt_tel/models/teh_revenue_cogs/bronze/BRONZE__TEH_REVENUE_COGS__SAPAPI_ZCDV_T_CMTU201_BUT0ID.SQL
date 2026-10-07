/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU201_BUT0ID',
    	  unique_key = [''],
    	  tags=["finance"],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:Client::STRING AS CLIENT,
		JSONFIELD:Partner::STRING AS PARTNER,
		JSONFIELD:Type::STRING AS TYPE,
		JSONFIELD:Idnumber::STRING AS IDNUMBER,
		JSONFIELD:Institute::STRING AS INSTITUTE,
		JSONFIELD:EntryDate::STRING AS ENTRYDATE,
		JSONFIELD:ValidDateFrom::STRING AS VALIDDATEFROM,
		JSONFIELD:ValidDateTo::STRING AS VALIDDATETO,
		JSONFIELD:Country::STRING AS COUNTRY,
		JSONFIELD:Region::STRING AS REGION,
		JSONFIELD:IdnumberGuid::STRING AS IDNUMBERGUID,
		JSONFIELD:BpEewBut0id::STRING AS BPEEWBUT0ID
    FROM {{ source('SAPAPI','ZCDV_T_CMTU201_BUT0ID') }}
    where _FILEDATE = (select ifnull(try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'), '1970-01-01') from {{ source('SAPAPI', 'CONTROLTABLE') }} where TABLE_NAME = 'ZCDV_T_CMTU201')

	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		CLIENT as CLIENT,
		PARTNER as PARTNER,
		TYPE as TYPE,
		IDNUMBER as IDNUMBER,
		INSTITUTE as INSTITUTE,
		ENTRYDATE as ENTRYDATE,
		VALIDDATEFROM as VALIDDATEFROM,
		VALIDDATETO as VALIDDATETO,
		COUNTRY as COUNTRY,
		REGION as REGION,
		IDNUMBERGUID as IDNUMBERGUID,
		BPEEWBUT0ID as BPEEWBUT0ID
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		CLIENT,
		PARTNER,
		TYPE,
		IDNUMBER,
		INSTITUTE,
		ENTRYDATE,
		VALIDDATEFROM,
		VALIDDATETO,
		COUNTRY,
		REGION,
		IDNUMBERGUID,
		BPEEWBUT0ID
    FROM transform_data 
)

	select * from type_data