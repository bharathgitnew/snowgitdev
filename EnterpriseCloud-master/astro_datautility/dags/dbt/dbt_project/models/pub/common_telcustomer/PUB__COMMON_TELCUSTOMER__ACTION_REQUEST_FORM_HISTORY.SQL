/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.06"
*************/

{{ config(
      materialized='view',
      alias='ACTION_REQUEST_FORM_HISTORY',
      transient=false
) }}

with source_data as (
    SELECT *
    exclude (_AUDIT_LOG_ID, _ROW_HASH) 
    from {{ ref('COMMON__TELCUSTOMER__ACTION_REQUEST_FORM_HISTORY') }}
    
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data