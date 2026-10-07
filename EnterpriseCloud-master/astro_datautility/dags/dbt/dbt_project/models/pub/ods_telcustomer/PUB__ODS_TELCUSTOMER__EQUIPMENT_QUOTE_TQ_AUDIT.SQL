{{ config(
      materialized='view',
      alias='EQUIPMENT_QUOTE_TQ_AUDIT',
      transient=false
) }}

with source_data as (
SELECT
    TEL_QUOTE_ID,
    EQUIPMENT_QUOTE_TEL_QUOTE_ID,
    EQUIPMENT_QUOTE_ID,
    QUOTE_AMT,
    QUOTE_CURRENCY,
    LEAD_TIME,
    LEAD_TIME_UNIT,
    REFERENCE_1,
    QUOTE_SEQ,
    CATEGORY,
    NTE,
    QUOTE_TYPE,
    ENTITY,
    ESA,
    TIERED,
    ENTITY_REQUIRED,
    LAST_UPDATE_BY,
    LAST_UPDATE_DT,
    ESA_LITE_CANDIDATE,
    ESA_LITE_YEAR,
    ESA_LITE_QUARTER,
    ESA_LITE_COMMENTS,
    ACTIVE
from {{ ref('ODS__TELCUSTOMER__EQUIPMENT_QUOTE_TQ_AUDIT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data