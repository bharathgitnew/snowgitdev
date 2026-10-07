{{ config(
      materialized='tel_incremental',
    incremental_strategy='insert_overwrite'  ,
    alias='GS_BUSINESS_UNIT_SAP'  
) }}



with source_data as 
(
  SELECT DISTINCT
    -- BUSINESSUNITCODE AS BU_Code,
    -- KA,
    -- CONCAT_WS('-', BU_Code, KA) BU_KA_CODE,
    BUSINESSUNITNAME AS BU,
    CASE WHEN SUBBUSINESSUNITNAME IN ('SD', 'PVD') THEN 'SD'
        WHEN SUBBUSINESSUNITNAME IN ('ES', 'Certas') THEN 'ES'
        ELSE CASE WHEN BUSINESSUNITCODE = '65' AND KA IN ('33', '34') THEN 'FS_CT'
                WHEN BUSINESSUNITCODE = '65' AND KA IN ('35', '36') THEN 'FS_ES'
                WHEN BUSINESSUNITCODE = '65' AND KA IN ('38', '79') THEN 'FS_SPS'
                WHEN BUSINESSUNITCODE = '65' AND KA IN ('31', '32') THEN 'FS_TPS' ELSE SUBBUSINESSUNITNAME END END   AS BU_Group,
    CASE WHEN SPLIT_PART(BUSINESSUNITCODE, '-', 3) IS NOT NULL AND LENGTH(BUSINESSUNITCODE) <> 2 THEN SPLIT_PART(BUSINESSUNITCODE, '-', 3)
        ELSE CASE WHEN BUSINESSUNITCODE = '65' AND KA IN ('33', '34') THEN 'FS_CT'
                WHEN BUSINESSUNITCODE = '65' AND KA IN ('35', '36') THEN 'FS_ES'
                WHEN BUSINESSUNITCODE = '65' AND KA IN ('38', '79') THEN 'FS_SPS'
                WHEN BUSINESSUNITCODE = '65' AND KA IN ('31', '32') THEN 'FS_TPS' ELSE SUBBUSINESSUNITNAME END END  AS Sub_BU
    -- SUBBUSINESSUNITNAME,
  FROM {{ ref('SILVER__TEH_EQUIPMENT_SALES__FILE_TEL_GS_REVENUE_BUDGET_FORECAST') }} 
  WHERE _FILEDATE >= '8/1/2021'
)


,transform_data as
(
  SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        BU,
        BU_GROUP,
        SUB_BU
FROM source_data
)

,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        cast(SUB_BU as VARCHAR(16777216)) as SUB_BU
from transform_data
    )
select * from type_data