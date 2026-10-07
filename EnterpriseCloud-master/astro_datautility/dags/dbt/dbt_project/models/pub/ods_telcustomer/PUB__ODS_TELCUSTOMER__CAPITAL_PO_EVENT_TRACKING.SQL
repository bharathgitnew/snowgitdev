/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.02"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_EVENT_TRACKING',
      transient=false
) }}

with source_data as (
    SELECT
        PO_NUMBER,
        REV,
        USERID,
        ACTION_DATE,
        EVENT_TYPE,
        OLD_STATUS,
        NEW_STATUS
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_EVENT_TRACKING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data