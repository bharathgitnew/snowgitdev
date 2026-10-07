/************
Model file generated from SAPAPIUtility
*************/


{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPAPI_ZCDV_T_CMTU047_VBPA',
    unique_key = ['VBELN',
    'POSNR',
    'PARVW'],
    tags=["finance"]
) }}

with source_data as (
SELECT
get_ignore_case(to_object(JSONFIELD),'Mandt')::STRING AS "MANDT",
get_ignore_case(to_object(JSONFIELD),'Vbeln')::STRING AS "VBELN",
get_ignore_case(to_object(JSONFIELD),'Posnr')::STRING AS "POSNR",
get_ignore_case(to_object(JSONFIELD),'Parvw')::STRING AS "PARVW",
get_ignore_case(to_object(JSONFIELD),'Kunnr')::STRING AS "KUNNR",
get_ignore_case(to_object(JSONFIELD),'Lifnr')::STRING AS "LIFNR",
get_ignore_case(to_object(JSONFIELD),'Pernr')::STRING AS "PERNR",
get_ignore_case(to_object(JSONFIELD),'Parnr')::STRING AS "PARNR",
get_ignore_case(to_object(JSONFIELD),'Adrnr')::STRING AS "ADRNR",
get_ignore_case(to_object(JSONFIELD),'Ablad')::STRING AS "ABLAD",
get_ignore_case(to_object(JSONFIELD),'Land1')::STRING AS "LAND1",
get_ignore_case(to_object(JSONFIELD),'Adrda')::STRING AS "ADRDA",
get_ignore_case(to_object(JSONFIELD),'Xcpdk')::STRING AS "XCPDK",
get_ignore_case(to_object(JSONFIELD),'Hityp')::STRING AS "HITYP",
get_ignore_case(to_object(JSONFIELD),'Prfre')::STRING AS "PRFRE",
get_ignore_case(to_object(JSONFIELD),'Bokre')::STRING AS "BOKRE",
get_ignore_case(to_object(JSONFIELD),'Histunr')::STRING AS "HISTUNR",
get_ignore_case(to_object(JSONFIELD),'Knref')::STRING AS "KNREF",
get_ignore_case(to_object(JSONFIELD),'Lzone')::STRING AS "LZONE",
get_ignore_case(to_object(JSONFIELD),'Hzuor')::STRING AS "HZUOR",
get_ignore_case(to_object(JSONFIELD),'Stceg')::STRING AS "STCEG",
get_ignore_case(to_object(JSONFIELD),'Parvw_Ff')::STRING AS "PARVW_FF",
get_ignore_case(to_object(JSONFIELD),'Adrnp')::STRING AS "ADRNP",
get_ignore_case(to_object(JSONFIELD),'Kale')::STRING AS "KALE",
get_ignore_case(to_object(JSONFIELD),'_Dataaging')::STRING AS "_DATAAGING",
get_ignore_case(to_object(JSONFIELD),'Dummy_Sddocpartner_Incl_Eew_Ps')::STRING AS "DUMMY_SDDOCPARTNER_INCL_EEW_PS",
get_ignore_case(to_object(JSONFIELD),'update_date')::STRING AS "UPDATE_DATE",
get_ignore_case(to_object(JSONFIELD),'UPDATE_TIME')::STRING AS "UPDATE_TIME",
_FILEDATE,
_FILENAME
from {{ source('SAPAPI','ZCDV_T_CMTU047_VBPA') }}
{% if is_tel_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
QUALIFY (ROW_NUMBER() OVER (PARTITION BY get_ignore_case(to_object(JSONFIELD),'Vbeln')::STRING,get_ignore_case(to_object(JSONFIELD),'Posnr')::STRING,get_ignore_case(to_object(JSONFIELD),'Parvw')::STRING ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1

),
transform_is_deleted as (
    select
        tgt.MANDT,
        tgt.VBELN,
        tgt.POSNR,
        tgt.PARVW,
        tgt.KUNNR,
        tgt.LIFNR,
        tgt.PERNR,
        tgt.PARNR,
        tgt.ADRNR,
        tgt.ABLAD,
        tgt.LAND1,
        tgt.ADRDA,
        tgt.XCPDK,
        tgt.HITYP,
        tgt.PRFRE,
        tgt.BOKRE,
        tgt.HISTUNR,
        tgt.KNREF,
        tgt.LZONE,
        tgt.HZUOR,
        tgt.STCEG,
        tgt.PARVW_FF,
        tgt.ADRNP,
        tgt.KALE,
        tgt._DATAAGING,
        tgt.DUMMY_SDDOCPARTNER_INCL_EEW_PS,
        tgt.UPDATE_DATE,
        tgt.UPDATE_TIME,
        tgt._FILEDATE,
        tgt._FILENAME,
        tgt._AUDIT_LOG_ID,
        tgt._ROW_HASH,
        CONCAT(tgt.VBELN, tgt.POSNR, tgt.PARVW) AS concatenated_fields,
        LTRIM(substr(c.tabkey,'4'),'0') as delete_key
    from {{this}} tgt
    left join {{ ref('BRONZE__TEA_LOGISTICS__SAPAPI_ZCDV_T_CMTU210_CDHDR') }} c 
    on concatenated_fields = delete_key 
    where c.tabname ='VBPA'
	and CONCAT(c.Udate,c.utime) > CONCAT(tgt.update_date,coalesce(tgt.UPDATE_TIME,'000000'))
    and delete_key not in (select CONCAT(VBELN,POSNR,PARVW) from source_data)
    
),
transform_data as (
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        "MANDT",
        "VBELN",
        "POSNR",
        "PARVW",
        "KUNNR",
        "LIFNR",
        "PERNR",
        "PARNR",
        "ADRNR",
        "ABLAD",
        "LAND1",
        "ADRDA",
        "XCPDK",
        "HITYP",
        "PRFRE",
        "BOKRE",
        "HISTUNR",
        "KNREF",
        "LZONE",
        "HZUOR",
        "STCEG",
        "PARVW_FF",
        "ADRNP",
        "KALE",
        "_DATAAGING",
        "DUMMY_SDDOCPARTNER_INCL_EEW_PS",
        "UPDATE_DATE",
        "UPDATE_TIME",
        'No' as IS_DELETED
from source_data
    UNION 
    select
    _Filename AS _Filename,
    _Filedate AS _Filedate,
    _AUDIT_LOG_ID,
    _ROW_HASH,
    "MANDT",
    "VBELN",
    "POSNR",
    "PARVW",
    "KUNNR",
    "LIFNR",
    "PERNR",
    "PARNR",
    "ADRNR",
    "ABLAD",
    "LAND1",
    "ADRDA",
    "XCPDK",
    "HITYP",
    "PRFRE",
    "BOKRE",
    "HISTUNR",
    "KNREF",
    "LZONE",
    "HZUOR",
    "STCEG",
    "PARVW_FF",
    "ADRNP",
    "KALE",
    "_DATAAGING",
    "DUMMY_SDDOCPARTNER_INCL_EEW_PS",
    "UPDATE_DATE",
    "UPDATE_TIME",
    'Yes' as IS_DELETED
from transform_is_deleted
),

type_data as (
SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST("MANDT" AS VARCHAR) AS "MANDT",
        CAST("VBELN" AS VARCHAR) AS "VBELN",
        CAST("POSNR" AS VARCHAR) AS "POSNR",
        CAST("PARVW" AS VARCHAR) AS "PARVW",
        CAST("KUNNR" AS VARCHAR) AS "KUNNR",
        CAST("LIFNR" AS VARCHAR) AS "LIFNR",
        CAST("PERNR" AS VARCHAR) AS "PERNR",
        CAST("PARNR" AS VARCHAR) AS "PARNR",
        CAST("ADRNR" AS VARCHAR) AS "ADRNR",
        CAST("ABLAD" AS VARCHAR) AS "ABLAD",
        CAST("LAND1" AS VARCHAR) AS "LAND1",
        CAST("ADRDA" AS VARCHAR) AS "ADRDA",
        CAST("XCPDK" AS VARCHAR) AS "XCPDK",
        CAST("HITYP" AS VARCHAR) AS "HITYP",
        CAST("PRFRE" AS VARCHAR) AS "PRFRE",
        CAST("BOKRE" AS VARCHAR) AS "BOKRE",
        CAST("HISTUNR" AS VARCHAR) AS "HISTUNR",
        CAST("KNREF" AS VARCHAR) AS "KNREF",
        CAST("LZONE" AS VARCHAR) AS "LZONE",
        CAST("HZUOR" AS VARCHAR) AS "HZUOR",
        CAST("STCEG" AS VARCHAR) AS "STCEG",
        CAST("PARVW_FF" AS VARCHAR) AS "PARVW_FF",
        CAST("ADRNP" AS VARCHAR) AS "ADRNP",
        CAST("KALE" AS VARCHAR) AS "KALE",
        CAST("_DATAAGING" AS VARCHAR) AS "_DATAAGING",
        CAST("DUMMY_SDDOCPARTNER_INCL_EEW_PS" AS VARCHAR) AS "DUMMY_SDDOCPARTNER_INCL_EEW_PS",
        CAST("UPDATE_DATE" AS VARCHAR) AS "UPDATE_DATE",
        CAST("UPDATE_TIME" AS VARCHAR(16777216)) AS "UPDATE_TIME",
        CAST(IS_DELETED AS VARCHAR) AS IS_DELETED
from transform_data
)

select * from type_data