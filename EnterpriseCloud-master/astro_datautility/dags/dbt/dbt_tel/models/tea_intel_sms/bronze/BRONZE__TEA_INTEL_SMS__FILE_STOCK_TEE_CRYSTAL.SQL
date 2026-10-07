{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_STOCK_TEE_CRYSTAL'
) }}

with source_data as
(
    SELECT
    "T$ITEM",
    "T$DSCA",
    "T$CWAR",
    "T$STOC",
    "T$ALLO",
    "T$ORDR",
    "T$SFST",
    "T$REOP",
    _FILEDATE
    FROM {{ source("FILE", "STOCK_TEE_CRYSTAL") }}
    WHERE _FILEDATE = (select max(_FILEDATE) from {{ source("FILE", "STOCK_TEE_CRYSTAL") }} )
)

,transform_data as
(
    SELECT
    _FILEDATE,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    "T$ITEM",
    "T$DSCA",
    "T$CWAR",
    REPLACE("T$STOC",',','') AS T$STOC,
    REPLACE("T$ALLO",',','') AS T$ALLO,
    REPLACE("T$ORDR",',','') AS T$ORDR,
    REPLACE("T$SFST",',','') AS T$SFST,
    REPLACE("T$REOP",',','') AS T$REOP
    FROM source_data
)

,type_data as
(
    select 
    CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
    CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    CAST("T$ITEM" AS VARCHAR(16777216)) AS "T$ITEM",
    CAST("T$DSCA" AS VARCHAR(16777216)) AS "T$DSCA",
    CAST("T$CWAR" AS VARCHAR(16777216)) AS "T$CWAR",
    CAST("T$STOC" AS VARCHAR(16777216)) AS "T$STOC",
    CAST("T$ALLO" AS VARCHAR(16777216)) AS "T$ALLO",
    CAST("T$ORDR" AS VARCHAR(16777216)) AS "T$ORDR",
    CAST("T$SFST" AS VARCHAR(16777216)) AS "T$SFST",
    CAST("T$REOP" AS VARCHAR(16777216)) AS "T$REOP"
    from transform_data
)
select * from type_data