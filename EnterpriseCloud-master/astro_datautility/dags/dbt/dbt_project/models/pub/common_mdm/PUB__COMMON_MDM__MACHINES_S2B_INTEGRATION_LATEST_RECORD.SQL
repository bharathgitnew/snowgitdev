/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.11"
*************/

{{ config(
      materialized='view',
      alias='MACHINES_S2B_INTEGRATION_LATEST_RECORD',
      transient=false
) }}

with source_data as (
    SELECT
        ACCEPTANCE_COMMENT,
        CLUSTER_FLAG,
        FIRST_INTEGRATION,
        LATEST_TRANSACTION_DATE,
        REVENUE_METHOD_CODE,
        REVENUE_METHOD_DESCRIPTION,
        SN,
        SUPPLIER_CODE,
        TABLE_REFRESH_DATE,
        TRANSACTION_ID
    from {{ ref('COMMON__MDM__MACHINES_S2B_INTEGRATION_LATEST_RECORD') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data