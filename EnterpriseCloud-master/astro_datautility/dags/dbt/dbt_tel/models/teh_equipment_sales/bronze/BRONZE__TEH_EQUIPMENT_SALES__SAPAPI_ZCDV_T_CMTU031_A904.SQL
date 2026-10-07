/************
Model file generated from SAPAPIUtility
*************/


{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SAPAPI_ZCDV_T_CMTU031_A904'
) }}

with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:"Mandt"::STRING AS MANDT, -- No Mapping in GMX
		JSONFIELD:"KAPPL"::STRING AS KAPPL,
		JSONFIELD:"KSCHL"::STRING AS KSCHL,
		JSONFIELD:"KONDA"::STRING AS KONDA,
		JSONFIELD:"MATNR"::STRING AS MATNR,
		JSONFIELD:"DATBI"::STRING AS DATBI,
		JSONFIELD:"DATAB"::STRING AS DATAB,
		JSONFIELD:"KNUMH"::STRING AS KNUMH,
		JSONFIELD:"update_date"::STRING AS UPDATE_DATE -- No Mapping in GMX
    from {{ source('SAPH','SAP_SDM_EV_A904_GMX') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDM_EV_A904_GMX'
        ) 
QUALIFY ROW_NUMBER() OVER ( PARTITION BY DATBI, KAPPL, KONDA, KSCHL, MATNR ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
),
transform_data as (
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        MANDT as MANDT,
        KAPPL as KAPPL,
        KSCHL as KSCHL,
        coalesce(LPAD("KONDA",2,'0'),'') as "KONDA",
        MATNR as MATNR,
        COALESCE(REGEXP_REPLACE(TRY_TO_DATE("DATBI"),'-',''),'') as "DATBI",
        COALESCE(REGEXP_REPLACE(TRY_TO_DATE("DATAB"),'-',''),'') as "DATAB",
        LPAD(coalesce("KNUMH",''),10,'0') as "KNUMH",
        UPDATE_DATE as UPDATE_DATE
FROM source_data 
),
adj_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		KAPPL,
		KSCHL,
		KONDA,
		MATNR,
		lead(DATAB) over (partition by KAPPL, KSCHL, KONDA, MATNR order by DATAB) as NEXT_DATAB,
		to_varchar(dateadd('day', -1, try_to_date(NEXT_DATAB, 'YYYYMMDD')), 'YYYYMMDD') as ADJ_DATBI,
		coalesce(ADJ_DATBI, DATBI) as DATBI,
		DATAB,
		KNUMH,
		UPDATE_DATE as UPDATE_DATE
    FROM transform_data 
),

type_data as (
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        KAPPL,
        KSCHL,
        KONDA,
        MATNR,
        DATBI,
        DATAB,
        KNUMH,
        UPDATE_DATE
        FROM adj_data
        )
        select * from type_data