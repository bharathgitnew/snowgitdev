/************
Model file generated from dbtGeneratePubViews: 10.27.2022.11.56.32"
*************/

{{ config(
      materialized='view',
      alias='REPORTING_PHISHING_SECURITY_TESTS_RECIPIENTS',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('ODS__KNOWBE4__REPORTING_PHISHING_SECURITY_TESTS_RECIPIENTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data