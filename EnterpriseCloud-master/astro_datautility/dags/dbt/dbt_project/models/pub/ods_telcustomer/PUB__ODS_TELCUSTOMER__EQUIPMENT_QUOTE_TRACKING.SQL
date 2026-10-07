{{ config(
      materialized='view',
      alias='EQUIPMENT_QUOTE_TRACKING',
      transient=false
) }}

with source_data as (
SELECT
    EQUIPMENT_QUOTE_TRACKING_ID,
    QUOTE_ID,
    ACTION,
    USERID,
    ACTION_DATE,
    REQUEST_TYPE,
    QUOTE_SEQ
from {{ ref('ODS__TELCUSTOMER__EQUIPMENT_QUOTE_TRACKING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data