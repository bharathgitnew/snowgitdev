{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_MRP_CONTROLLERS',
    unique_key = ['MANDT',
    'WERKS',
    'DISPO']
) }}

with source_data as
(
    SELECT
        _CAPTUREDATETIME,
        MANDT,
        WERKS,
        DISPO,
        DSNAM,
        DSTEL,
        EKGRP,
        MEMPF,
        GSBER,
        PRCTR,
        USRTYP,
        USRKEY
        FROM {{ source("SAP_ORACLE_LIVE", "T024D") }}
)
,transform_data as
(
    SELECT  
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
       _CAPTUREDATETIME,
        MANDT,
        WERKS,
        DISPO,
        DSNAM,
        DSTEL,
        EKGRP,
        MEMPF,
        GSBER,
        PRCTR,
        USRTYP,
        USRKEY
        FROM source_data
)
,type_data as
(
    select
        CAST(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
        MANDT,
        WERKS,
        DISPO,
        DSNAM,
        DSTEL,
        EKGRP,
        MEMPF,
        GSBER,
        PRCTR,
        USRTYP,
        USRKEY
    from transform_data
)
select * from type_data