{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_ASSIGNMENT_TASK_LISTS_MATERIALS',
    unique_key = ['MANDT',
    'MATNR',
    'WERKS',
    'PLNTY',
    'PLNNR',
    'PLNAL',
    'ZKRIZ',
    'ZAEHL']
) }}

with source_data as
(
    SELECT
        _CAPTUREDATETIME,
        MANDT,
        MATNR,
        WERKS,
        PLNTY,
        PLNNR,
        PLNAL,
        ZKRIZ,
        ZAEHL,
        DATUV,
        TECHV,
        AENNR,
        LOEKZ,
        PARKZ,
        ANDAT,
        ANNAM,
        AEDAT,
        AENAM,
        LIFNR,
        KUNR,
        SUCHFELD,
        VBELN,
        POSNR,
        PSPNR,
        MS_OBJECT,
        MS_OBJTYPE
        FROM {{ source("SAP_ORACLE_LIVE", "MAPL") }}
)
,transform_data as
(
    SELECT
         _CAPTUREDATETIME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        MANDT,
        MATNR,
        WERKS,
        PLNTY,
        PLNNR,
        PLNAL,
        ZKRIZ,
        ZAEHL,
        DATUV,
        TECHV,
        AENNR,
        LOEKZ,
        PARKZ,
        ANDAT,
        ANNAM,
        AEDAT,
        AENAM,
        LIFNR,
        KUNR,
        SUCHFELD,
        VBELN,
        POSNR,
        PSPNR,
        MS_OBJECT,
        MS_OBJTYPE	
        FROM source_data
)
,type_data as
(
   select
        CAST(_CAPTUREDATETIME as TIMESTAMP_LTZ(9) ) as _CAPTUREDATETIME,
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        MANDT,
        MATNR,
        WERKS,
        PLNTY,
        PLNNR,
        PLNAL,
        ZKRIZ,
        ZAEHL,
        DATUV,
        TECHV,
        AENNR,
        LOEKZ,
        PARKZ,
        ANDAT,
        ANNAM,
        AEDAT,
        AENAM,
        LIFNR,
        KUNR,
        SUCHFELD,
        VBELN,
        POSNR,
        PSPNR,
        MS_OBJECT,
        MS_OBJTYPE
    from transform_data
)
select * from type_data