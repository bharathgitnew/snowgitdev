{{ config(
        materialized='view'    ,
     alias='BOOKING_BILLING_BACKLOG'    ,
     transient=false
) }}

with SOURCE_DATA AS (
    SELECT
        BU
        , SALES_CATEGORY
        , SOLD_TO_PARTY
        , CUSTOMER_NAME
        , END_USER
        , ORDER_REASON
        , SALES_DOCUMENT_TYPE
        , SALES_DOCUMENT_DATE
        , SALES_DOCUMENT
        , SALES_DOCUMENT_ITEM
        , MATERIAL_NUMBER
        , ORDER_AMOUNT
        , BILLING_AMOUNT
        , BACKLOG_AMOUNT
        , AS_OF_DATE
        , SCHEDULE_LINE_DATE
    FROM {{ ref('COMMON__REPORTS__BOOKING_BILLING_BACKLOG') }}
),

TRANSFORM_DATA AS (
	SELECT * from SOURCE_DATA
)

SELECT * FROM TRANSFORM_DATA