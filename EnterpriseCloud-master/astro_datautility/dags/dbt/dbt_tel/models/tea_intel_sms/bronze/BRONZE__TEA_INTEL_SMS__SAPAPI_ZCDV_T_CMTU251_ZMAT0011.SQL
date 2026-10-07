/************
    Model file generated from SAPAPIUtility
    *************/


    {{ config(
          materialized='tel_incremental',
          incremental_strategy='merge',
          alias='SAPAPI_ZCDV_T_CMTU251_ZMAT0011',
		  unique_key = ['PARTNER'],
          transient=false
) }}

    with source_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		get_ignore_case(to_object(JSONFIELD), 'CREATE_PRG') :: STRING AS "C_PGM",
		get_ignore_case(to_object(JSONFIELD), 'CREATE_DATE') :: STRING AS "C_DATE",
		get_ignore_case(to_object(JSONFIELD), 'UPDATE_PRG') :: STRING AS "U_PGM",
		get_ignore_case(to_object(JSONFIELD), 'UPD_TIME') :: STRING AS "U_TIME",
		get_ignore_case(to_object(JSONFIELD), 'UPD_USER') :: STRING AS "U_USER",
		get_ignore_case(to_object(JSONFIELD), 'CREATE_USER') :: STRING AS "C_USER",
		get_ignore_case(to_object(JSONFIELD), 'UPD_DATE') :: STRING AS "U_DATE",
		get_ignore_case(to_object(JSONFIELD), 'DEL_FLG') :: STRING AS "DEL_FLG",
		get_ignore_case(to_object(JSONFIELD), 'CREATE_TIME') :: STRING AS "C_TIME",
		get_ignore_case(to_object(JSONFIELD), 'CREATED_NAME') :: STRING AS "CREATED_NAME",
        get_ignore_case(to_object(JSONFIELD), 'partner_number') :: STRING AS "PARTNER",
		JSONFIELD:SEQNO::STRING as SEQNO,
		JSONFIELD:PRC_STS::STRING as PRC_STS,
		JSONFIELD:NAME2FIRST::STRING as NAME2FIRST,
		JSONFIELD:NAME2LAST::STRING as NAME2LAST,
		JSONFIELD:NAME3FIRST::STRING as NAME3FIRST,
		JSONFIELD:NAME3LAST::STRING as NAME3LAST,
		JSONFIELD:NAME1MIDDLE::STRING as NAME1MIDDLE,
		JSONFIELD:TEL_NUMBER::STRING as TEL_NUMBER,
		JSONFIELD:FAX_NUMBER::STRING as FAX_NUMBER,
		JSONFIELD:TEL_EXTENS::STRING as TEL_EXTENS,
		JSONFIELD:ZCOE::STRING as ZCOE,
		JSONFIELD:ZEGR::STRING as ZEGR,
		JSONFIELD:SMTP_ADDR::STRING as SMTP_ADDR,
		JSONFIELD:ZTCO::STRING as ZTCO,
		JSONFIELD:ZCCL::STRING as ZCCL,
		JSONFIELD:ZHRS::STRING as ZHRS
	FROM
        {{ source('SAPAPI', 'ZCDV_CM0610_24_ZMAT0011') }}
    where
        _FILEDATE = (
            select
                ifnull(
                    try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'),
                    '1970-01-01'
                )
            from
                {{ source('SAPAPI', 'CONTROLTABLE') }}
            where
                TABLE_NAME = 'ZCDV_CM0610_24'
        ) QUALIFY (
            ROW_NUMBER() OVER (
                PARTITION BY PARTNER
                ORDER BY
                    _FILEDATE DESC,
                    _UPLOADDATE DESC
            )
        ) = 1
),
    transform_data as (
        SELECT

        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        "PARTNER",
 	 	"SEQNO",
 	 	"PRC_STS",
 	 	"NAME2FIRST",
 	 	"NAME2LAST",
 	 	"NAME3FIRST",
 	 	"NAME3LAST",
 	 	REGEXP_REPLACE(SPLIT(CREATED_NAME,' ')[0],'"','') AS "NAME1FIRST",
 	 	"NAME1MIDDLE",
 	 	REGEXP_REPLACE(SPLIT(CREATED_NAME,' ')[1],'"','')  AS "NAME1LAST",
 	 	"TEL_NUMBER",
 	 	"FAX_NUMBER",
 	 	"TEL_EXTENS",
 	 	"ZCOE",
 	 	"ZEGR",
 	 	"SMTP_ADDR",
 	 	"ZTCO",
 	 	"ZCCL",
 	 	"ZHRS",
 	 	"DEL_FLG",
 	 	"C_DATE",
 	 	"C_TIME",
 	 	"C_USER",
 	 	"C_PGM",
 	 	"U_DATE",
 	 	"U_TIME",
 	 	"U_USER",
 	 	"U_PGM"
        FROM source_data
    ),
    type_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		 _AUDIT_LOG_ID,
         _ROW_HASH,
        "PARTNER",
 	 	"SEQNO",
 	 	"PRC_STS",
 	 	"NAME2FIRST",
 	 	"NAME2LAST",
 	 	"NAME3FIRST",
 	 	"NAME3LAST",
 	 	"NAME1FIRST",
 	 	"NAME1MIDDLE",
 	 	"NAME1LAST",
 	 	"TEL_NUMBER",
 	 	"FAX_NUMBER",
 	 	"TEL_EXTENS",
 	 	"ZCOE",
 	 	"ZEGR",
 	 	"SMTP_ADDR",
 	 	"ZTCO",
 	 	"ZCCL",
 	 	"ZHRS",
 	 	"DEL_FLG",
 	 	"C_DATE",
 	 	"C_TIME",
 	 	"C_USER",
 	 	"C_PGM",
 	 	"U_DATE",
 	 	"U_TIME",
 	 	"U_USER",
 	 	"U_PGM"
        FROM transform_data
    )
    SELECT * FROM type_data