{{ config(
      materialized='view',
      alias='TPL_Shipping_Information',
      transient=false
) }}

with source_data as (
    SELECT
    SHIPPING_INFORMATION_ID,
    DOCUMENT_NUMBER,
    MASTER_AIRWAY_BILL_NUMBER,
    HOUSE_AIRWAY_BILL_NUMBER,
    SHIPMENT_CARRIER,
    CUSTOMS_CLEARANCE_DATE,
    BL_ISSUE_DATE,
    ETD,
    ETA,
    FLIGHT_NUMBER_1,
    FLIGHT_NUMBER_2,
    FLIGHT_NUMBER_3,
    C_WT,
    TRACKING_NUMBER,
    POINT_OF_LADING,
    POINT_OF_DISCHARGE,
    EXPORT_SHIPPING_TYPE,
    PROCESSED,
    PROCESS_DT,
    ERROR,
    ERROR_MESSAGE,
    PROCESS_ID,
    _FILEDATE,
    AUDIT_LOG_ID,
    _ROW_HASH
    from {{ ref('ODS__THREEPL__TPL_SHIPPING_INFORMATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data