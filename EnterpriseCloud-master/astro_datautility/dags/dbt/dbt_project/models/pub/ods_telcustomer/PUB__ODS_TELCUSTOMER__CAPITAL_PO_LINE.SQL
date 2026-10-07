/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.02"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_LINE',
      transient=false
) }}

with source_data as (
    SELECT
        MESSAGE_ID,
        PO_NUMBER,
        LINE_NUMBER,
        SUB_LINE_NUMBER,
        ACTION_CODE,
        ITEM_NUMBER,
        CUSTOMER_ITEM_NUMBER,
        ITEM_DESCRIPTION,
        COMMENTS,
        SPECIAL_HANDLING_INSTRUCTION,
        TAX_EXEMPT,
        TAX_EXEMPT_CODE,
        CURRENCY,
        AMOUNT,
        DROP_SHIP,
        CARRIER_CODE,
        FOB_CODE,
        SHIPPING_SERVICE_LEVEL_CODE,
        REQUESTED_DATE,
        REQUESTED_EVENT,
        SHIP_TO_LOCATION_ID,
        SHIP_TO_NAME,
        SHIP_TO_ADDRESS_1,
        SHIP_TO_ADDRESS_2,
        SHIP_TO_ADDRESS_3,
        SHIP_TO_CITY,
        SHIP_TO_REGION,
        SHIP_TO_COUNTRY,
        SHIP_TO_POSTAL_CODE,
        QTY,
        UOM,
        REQUESTED_UNIT_PRICE,
        QUOTE_NUMBER,
        ENTITY_CODE,
        TECHNOLOGY_CODE,
        DESIGNATED_DELIVERY_DATE,
        CAPITAL_CATEGORY_CODE,
        MODEL_ID,
        PURCHASING_TEAM_CODE,
        DRAFT_DIRECTION_CODE,
        HANDEDNESS_ORIENTATION_CODE,
        COPY_EXACT_ID,
        CONTRACT_ID,
        REV,
        TEL_LINE_STATUS,
        REASON,
        INCO_TERM,
        SHIPPING_CONDITION,
        SHIPPING_INSTRUCTION,
        DISCLAIMER,
        TENDER_DATE,
        REQUESTED_TENDER_DATE,
        INTERNAL_MODEL_IDENTIFIER,
        HIGH_ALTITUDE_INDICATOR,
        FACTORY_LAYOUT_CODE,
        PRE_FAC_KIT_MATERIAL_MASTER_ID,
        SUPPLIER_PRE_CONTAMINATION_IND,
        GEOGRAPHY_PWR_REQUIREMENT_CODE,
        ESA,
        STATUS_DT,
        QRF_QUOTE_ID,
        QRF_QUOTE_SEQ,
        LAST_MODIFIED_BY_DT,
        PROV_STATUS
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_LINE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data