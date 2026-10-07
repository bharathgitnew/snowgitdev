{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='BUSINESS_PARTNERS_3200_ADDRESS',
      transient=false
) }}


with source_data as (
    select
        * exclude(_ROW_HASH,_AUDIT_LOG_ID)
    FROM {{ ref('COMMON__REPORTS__BUSINESS_PARTNERS_3200_ADDRESS') }}


),

transform_data AS
(
    select 
        *
     from source_data
)

    select
        *
    from transform_data