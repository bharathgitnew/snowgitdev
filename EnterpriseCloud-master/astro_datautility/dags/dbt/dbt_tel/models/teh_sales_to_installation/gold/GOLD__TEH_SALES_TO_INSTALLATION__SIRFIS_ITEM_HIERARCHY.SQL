{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='SIRFIS_ITEM_HIERARCHY',
      transient=false
) }}

with source_data AS (
    SELECT DISTINCT
        ID AS ID,
        BUSINESS_UNIT AS BUSINESS_UNIT,
        BUSINESS_UNIT_SHORT_TEXT AS BUSINESS_UNIT_SHORT_TEXT,
        SITE AS SITE,
        CATEGORY AS CATEGORY,
        UEID AS UEID,
        MODEL AS MODEL,
        COPY_EXACT_ID AS CEID,
        ENTITY AS ENTITY,
        PROCESS AS PROCESS,
        REUSE_SITE AS REUSE_SITE,
        REUSE_CEID AS REUSE_CEID,
        REUSE_PROCESS AS REUSE_PROCESS,
        CASE WHEN IS_PART_ORDER = 'Yes' THEN 1 ELSE 0 END AS IS_PART_ORDER,
        DESCRIPTION AS DESCRIPTION
    FROM {{ ref('GOLD__TEH_SALES_TO_INSTALLATION__FORECAST_HISTORY') }}
    WHERE REVISION_DESC_ORDER = 1
),

transform_data AS
(   
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ID AS ID,
        BUSINESS_UNIT AS BUSINESS_UNIT,
        BUSINESS_UNIT_SHORT_TEXT AS BUSINESS_UNIT_SHORT_TEXT,
        CASE WHEN ENTITY = 'PXT403' THEN 'PVD'
        WHEN LEFT(ENTITY, 3) in ('BEC', 'CAR', 'CAT', 'CFS', 'OXS', 'OXT', 'SRT', 'ACT', 'CCT', 'CLE', 
        'DEV', 'GCT', 'PEB', 'RCT', 'RPD', 'SLM', 'SOX', 'SXD', 'TAK', 'TAN', 'TBH', 'TBJ', 'TBR', 
        'TCX', 'TNI', 'TTA', 'TTB', 'TTC', 'TTG', 'TTK', 'ZSK', 'ZTE') THEN 'FS'
        ELSE BUSINESS_UNIT_SHORT_TEXT END AS UNIVERSAL_BU,
        SITE AS SITE,
        CATEGORY AS CATEGORY,
        MODEL AS MODEL,
        CEID AS CEID,
        ENTITY AS ENTITY,
        PROCESS AS PROCESS,
        REUSE_SITE AS REUSE_SITE,
        REUSE_CEID AS REUSE_CEID,
        REUSE_PROCESS AS REUSE_PROCESS,
        IS_PART_ORDER AS IS_PART_ORDER,
        DESCRIPTION AS DESCRIPTION
    FROM source_data
)

,type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        ID,
        BUSINESS_UNIT,
        BUSINESS_UNIT_SHORT_TEXT,
        UNIVERSAL_BU,
        SITE,
        CATEGORY,
        MODEL,
        CEID,
        ENTITY,
        PROCESS,
        REUSE_SITE,
        REUSE_CEID,
        REUSE_PROCESS,
        CAST(IS_PART_ORDER AS NUMBER(1,0)) AS IS_PART_ORDER,
        DESCRIPTION
    FROM transform_data
)

SELECT * from type_data