/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.03"
*************/

{{ config(
      materialized='view',
      alias='TELCUST_ARF_NEW_QUOTE',
      transient=false
) }}

with source_data as (
    SELECT
        REQTYPE,
        COMPANY,
        ARF_TYPE,
        REQUEST_NUMBER,
        REV,
        STATUS_DATE,
        PRODUCT_LINE,
        REQUESTOR_ID,
        REQUESTOR,
        REQUESTOR_PHONE,
        REQUESTOR_EMAIL,
        APPROVER_ID,
        APPROVER,
        APPROVER_PHONE,
        APPROVER_EMAIL,
        MODEL,
        FABS,
        NODES,
        PROCESSES,
        NODE_FROM_OTHER,
        NODE_TO_OTHER,
        PROCESS_FROM_OTHER,
        PROCESS_TO_OTHER,
        NODE_OTHER,
        PROCESS_OTHER,
        DESCRIPTION,
        PRIORITY_FLAG,
        DATA_LOAD_DATE,
        TEL_COMMENT,
        REQUEST_DATE,
        REQUEST_REVISION_DATE
    from {{ ref('ODS__TELCUSTOMER__TELCUST_ARF_NEW_QUOTE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data