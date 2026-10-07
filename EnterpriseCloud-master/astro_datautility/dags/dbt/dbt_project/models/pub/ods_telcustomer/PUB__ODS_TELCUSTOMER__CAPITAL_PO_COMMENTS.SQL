/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.02"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_COMMENTS',
      transient=false
) }}

with source_data as (
    SELECT
        PO_NUMBER,
        REV,
        COMMENT_ID,
        COMMENT_DT,
        USERID,
        DESCR
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_COMMENTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data