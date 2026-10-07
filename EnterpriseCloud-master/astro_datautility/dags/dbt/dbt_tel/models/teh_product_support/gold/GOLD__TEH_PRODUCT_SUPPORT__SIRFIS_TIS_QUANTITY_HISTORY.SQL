{{ config(
      materialized='tel_incremental',
      incremental_strategy='merge',
      alias='SIRFIS_TIS_QUANTITY_HISTORY',
      unique_key=['ID','SNAPSHOT_DATE'],
      transient=false
) }}

with SIRFIS_TIS_LIFECYCLE as (
    select * from {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_FACT') }}
),
HISTORY AS
(
  SELECT * FROM {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_MILESTONES_HISTORY') }}
), 

 source_data as (
     SELECT DISTINCT ID,
        _FILEDATE as  SNAPSHOT_DATE,       
        MILESTONE_START_DATE AS SET_START_DATE, 
        FROM HISTORY 
        WHERE MILESTONES_NAME = 'SET'
        AND MILESTONE_START_DATE IS NOT NULL
        AND ID || '-' || _FILEDATE NOT IN (SELECT DISTINCT ID || '-' || LATEST_DATE FROM SIRFIS_TIS_LIFECYCLE
        WHERE EXPECTED_STATUS = 'DELETED')  
 )   ,
transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID
        , SHA2('hash_me') AS _ROW_HASH  
        , ID
        , SNAPSHOT_DATE
        , SET_START_DATE
    from source_data
),
type_data as(
    SELECT 
        _AUDIT_LOG_ID
        , _ROW_HASH
        , ID
        , SNAPSHOT_DATE
        , SET_START_DATE
    From transform_data
)
SELECT * FROM type_data