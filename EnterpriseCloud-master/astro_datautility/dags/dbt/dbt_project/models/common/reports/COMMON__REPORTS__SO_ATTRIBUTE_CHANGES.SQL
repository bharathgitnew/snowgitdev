{{ config(
        alias = 'SO_ATTRIBUTE_CHANGES',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        TRACKING_KEY,
        SNAPSHOT_DATE,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_ORDER_LINE,
        PNL_CATEGORY,
        AMOUNT_IN_COMPANY_CODE_CURRENCY,
        lag(END_USER, 1) over(partition by TRACKING_KEY order by SNAPSHOT_DATE) as OLD_END_USER,
        END_USER as NEW_END_USER,
        lag(SOLD_TO_PARTY, 1) over(partition by TRACKING_KEY order by SNAPSHOT_DATE) as OLD_SOLD_TO_PARTY,
        SOLD_TO_PARTY as NEW_SOLD_TO_PARTY,
        lag(SALES_CATEGORY, 1) over(partition by TRACKING_KEY order by SNAPSHOT_DATE) as OLD_SALES_CATEGORY,
        SALES_CATEGORY as NEW_SALES_CATEGORY,
        lag(SALES_DOCUMENT_TYPE, 1) over(partition by TRACKING_KEY order by SNAPSHOT_DATE) as OLD_SALES_DOCUMENT_TYPE,
        SALES_DOCUMENT_TYPE as NEW_SALES_DOCUMENT_TYPE,
        lag(ORDER_REASON, 1) over(partition by TRACKING_KEY order by SNAPSHOT_DATE) as OLD_ORDER_REASON,
        ORDER_REASON as NEW_ORDER_REASON
    from {{ ref('COMMON__SAPH__DAILY_ACTUALS_SALES_LINE_SNAPSHOT') }}
    qualify 1 != 1
        or OLD_END_USER            != NEW_END_USER
        or OLD_SOLD_TO_PARTY       != NEW_SOLD_TO_PARTY
        or OLD_SALES_CATEGORY      != NEW_SALES_CATEGORY
        or OLD_SALES_DOCUMENT_TYPE != NEW_SALES_DOCUMENT_TYPE
        or OLD_ORDER_REASON        != NEW_ORDER_REASON
),

transposed_data as (
    select
        TRACKING_KEY,
        SNAPSHOT_DATE,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_ORDER_LINE,
        PNL_CATEGORY,
        AMOUNT_IN_COMPANY_CODE_CURRENCY,
        'END_USER' as CHANGED_COLUMN,
        OLD_END_USER as OLD_VALUE,
        NEW_END_USER as NEW_VALUE
    from source_data
    where OLD_VALUE != NEW_VALUE
    union
    select
        TRACKING_KEY,
        SNAPSHOT_DATE,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_ORDER_LINE,
        PNL_CATEGORY,
        AMOUNT_IN_COMPANY_CODE_CURRENCY,
        'SOLD_TO_PARTY' as CHANGED_COLUMN,
        OLD_SOLD_TO_PARTY as OLD_VALUE,
        NEW_SOLD_TO_PARTY as NEW_VALUE
    from source_data
    where OLD_VALUE != NEW_VALUE
    union
    select
        TRACKING_KEY,
        SNAPSHOT_DATE,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_ORDER_LINE,
        PNL_CATEGORY,
        AMOUNT_IN_COMPANY_CODE_CURRENCY,
        'SALES_CATEGORY' as CHANGED_COLUMN,
        OLD_SALES_CATEGORY as OLD_VALUE,
        NEW_SALES_CATEGORY as NEW_VALUE
    from source_data
    where OLD_VALUE != NEW_VALUE
    union
    select
        TRACKING_KEY,
        SNAPSHOT_DATE,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_ORDER_LINE,
        PNL_CATEGORY,
        AMOUNT_IN_COMPANY_CODE_CURRENCY,
        'SALES_DOCUMENT_TYPE' as CHANGED_COLUMN,
        OLD_SALES_DOCUMENT_TYPE as OLD_VALUE,
        NEW_SALES_DOCUMENT_TYPE as NEW_VALUE
    from source_data
    where OLD_VALUE != NEW_VALUE
    union
    select
        TRACKING_KEY,
        SNAPSHOT_DATE,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_ORDER_LINE,
        PNL_CATEGORY,
        AMOUNT_IN_COMPANY_CODE_CURRENCY,
        'ORDER_REASON' as CHANGED_COLUMN,
        OLD_ORDER_REASON as OLD_VALUE,
        NEW_ORDER_REASON as NEW_VALUE
    from source_data
    where OLD_VALUE != NEW_VALUE
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        TRACKING_KEY,
        SNAPSHOT_DATE,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_ORDER_LINE,
        PNL_CATEGORY,
        AMOUNT_IN_COMPANY_CODE_CURRENCY,
        CHANGED_COLUMN,
        OLD_VALUE,
        NEW_VALUE
    from transposed_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        TRACKING_KEY,
        SNAPSHOT_DATE,
        ACCOUNTING_DOCUMENT_LINE,
        SALES_ORDER_LINE,
        PNL_CATEGORY,
        AMOUNT_IN_COMPANY_CODE_CURRENCY,
        CHANGED_COLUMN,
        OLD_VALUE,
        NEW_VALUE
    from transform_data
)

select * from type_data