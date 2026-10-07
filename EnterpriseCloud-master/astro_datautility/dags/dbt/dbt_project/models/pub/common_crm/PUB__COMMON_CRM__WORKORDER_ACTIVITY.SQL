{{ config(
        alias = 'WORKORDER_ACTIVITY',
        materialized = 'view',
        transient = 'false'
) }}

with source_data as (
    select
        PASS_DOWN_ID,
        TITLE,
        WORK_ORDER_NO,
        PASSDOWN_DATE,
        DELAY,
        REQUEST_TO_CUSTOMER,
        DETAIL_TO_CUSTOMER,
        OUTCOME,
        INTERNAL_NOTES,
        NEXT_ACTION,
        SAFETY_INFORMATION,
        CUSTOMER_REQUEST,
        FE_NAME,
        FE_EMP_ID,
        CREATED_BY,
        CREATED_BY_EMP_ID,
        MODIFIED_BY,
        MODIFIED_BY_EMP_ID,
        ESCALATION,
        CREATED_ON,
        MODIFIED_ON
    from {{ ref('COMMON__CRM__WORKORDER_ACTIVITY') }}
)

select * from source_data