{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SERVICEORDEROPENINVOICETOTALS',
    unique_key = [],
    enabled=true
) }}

with source_data as
(

    SELECT
        SERVICEORDER.SERVICE_ORDER_NO,
        SUM(CASE WHEN ServiceOrder.Order_Status_Desc = 'Released'
                AND LEFT(ServiceOrder.SERVICE_ORDER_NO, 3) IN ('PDS', 'PDT', 'PDM', 'PDF','PFP')
                AND ServiceOrder.Order_DT > '2014-04-01'
                AND ServiceOrder.Invoice_Date IS NOT NULL THEN COALESCE(ServiceOrder.Invoice_Amount,0)
            ELSE 0
            END) as TotalAmountInvoiced,
        SUM(CASE WHEN ServiceOrder.Order_Status_Desc = 'Released'
            AND LEFT(ServiceOrder.SERVICE_ORDER_NO, 3) IN ('PDS', 'PDT', 'PDM', 'PDF','PFP')
            AND ServiceOrder.Order_DT > '2014-04-01'
            AND ServiceOrder.Invoice_Date IS NOT NULL
            AND (ServiceOrder.Cost_Component LIKE '1%' OR ServiceOrder.Cost_Component LIKE '9%')
            AND (ServiceOrder.Source LIKE 'MATERIAL%' OR ServiceOrder.Source LIKE 'OTHER%')
            THEN ServiceOrder.Invoice_Amount
            ELSE 0
            END) as TotalInvoicePartsAndTravel
    FROM
    {{ ref('COMMON__BAAN__SERVICEORDER') }} SERVICEORDER
    GROUP BY SERVICEORDER.SERVICE_ORDER_NO

),

transform_data as
(
    select
        SERVICE_ORDER_NO as ServiceOrder,
        TotalAmountInvoiced,
        TotalInvoicePartsAndTravel,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
    FROM source_data
)

,type_data as
(
    select
        cast(SERVICEORDER as VARCHAR(16777216)) as SERVICEORDER,
        cast(TOTALAMOUNTINVOICED as NUMBER(38,10)) as TOTALAMOUNTINVOICED,
        cast(TOTALINVOICEPARTSANDTRAVEL as NUMBER(38,10)) as TOTALINVOICEPARTSANDTRAVEL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data