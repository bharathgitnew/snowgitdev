{{ config(
        materialized='view'    ,
     alias='WIP_SERVICE_NCDR_REPAIR'    ,
     transient=false
) }}

with SOURCE_DATA AS (
    SELECT
        PROFIT_CENTER
        , SOLD_TO_PARTY
        , CUSTOMER_NAME
        , SALES_CATEGORY
        , SALES_CATEGORY_NAME
        , SALES_DOCUMENT
        , SALES_DOCUMENT_LINE
        , CUSTOMER_PO
        , ITEM_DESCRIPTION
        , WBS_ELEMENT
        , AMOUNT
    FROM {{ ref('COMMON__REPORTS__WIP_SERVICE_NCDR_REPAIR') }}
),

TRANSFORM_DATA AS (
    SELECT * FROM SOURCE_DATA
)

SELECT * FROM TRANSFORM_DATA