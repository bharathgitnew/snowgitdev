{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_Shipping_Information',
    unique_key = ['Shipping_Information_Id']
) }}

with source_data as (
    SELECT 
        JSONFIELD:Shipping_Information_Id::Int as SHIPPING_INFORMATION_ID,
        JSONFIELD:Document_Number::String as DOCUMENT_NUMBER,
        JSONFIELD:Master_Airway_Bill_Number::String as MASTER_AIRWAY_BILL_NUMBER,
        JSONFIELD:House_Airway_Bill_Number::String as HOUSE_AIRWAY_BILL_NUMBER,
        JSONFIELD:Shipment_Carrier::String as SHIPMENT_CARRIER,
        JSONFIELD:Customs_Clearance_Date::String as CUSTOMS_CLEARANCE_DATE,
        JSONFIELD:BL_Issue_Date::String as BL_ISSUE_DATE,
        JSONFIELD:ETD::String as ETD,
        JSONFIELD:ETA::String as ETA,
        JSONFIELD:Flight_Number_1::String as FLIGHT_NUMBER_1,
        JSONFIELD:Flight_Number_2::String as FLIGHT_NUMBER_2,
        JSONFIELD:Flight_Number_3::String as FLIGHT_NUMBER_3,
        JSONFIELD:C_WT::String as C_WT,
        JSONFIELD:Tracking_Number::String as TRACKING_NUMBER,
        JSONFIELD:Point_Of_Lading::String as POINT_OF_LADING,
        JSONFIELD:Point_Of_Discharge::String as POINT_OF_DISCHARGE,
        JSONFIELD:Export_Shipping_Type::String as EXPORT_SHIPPING_TYPE,
        JSONFIELD:Processed::Smallint as PROCESSED,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Process_Dt" ,'/Date()/')) as PROCESS_DT,
        JSONFIELD:Error::Boolean as ERROR,
        JSONFIELD:Error_Message::String as ERROR_MESSAGE,
        JSONFIELD:Process_ID::Int as PROCESS_ID,
        _filedate as _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM {{ source('THREEPL','TPL_SHIPPING_INFORMATION') }}
    {% if is_incremental() %} WHERE _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY Shipping_Information_Id ORDER BY _FILEDATE DESC )) = 1
)

,transform_data as
(
    SELECT 
        source_data.SHIPPING_INFORMATION_ID,
        source_data.DOCUMENT_NUMBER,
        source_data.MASTER_AIRWAY_BILL_NUMBER,
        source_data.HOUSE_AIRWAY_BILL_NUMBER,
        source_data.SHIPMENT_CARRIER,
        source_data.CUSTOMS_CLEARANCE_DATE,
        source_data.BL_ISSUE_DATE,
        source_data.ETD,
        source_data.ETA,
        source_data.FLIGHT_NUMBER_1,
        source_data.FLIGHT_NUMBER_2,
        source_data.FLIGHT_NUMBER_3,
        source_data.C_WT,
        source_data.TRACKING_NUMBER,
        source_data.POINT_OF_LADING,
        source_data.POINT_OF_DISCHARGE,
        source_data.EXPORT_SHIPPING_TYPE,
        source_data.PROCESSED,
        source_data.PROCESS_DT,
        source_data.ERROR,
        source_data.ERROR_MESSAGE,
        source_data.PROCESS_ID,
        source_data._FILEDATE,
        source_data.AUDIT_LOG_ID,
        source_data._ROW_HASH
    FROM source_data    
),

type_data as(
    select
        CAST(SHIPPING_INFORMATION_ID as NUMBER(38,0)) as SHIPPING_INFORMATION_ID,
        CAST(DOCUMENT_NUMBER as VARCHAR(16777216)) as DOCUMENT_NUMBER,
        CAST(MASTER_AIRWAY_BILL_NUMBER as VARCHAR(16777216)) as MASTER_AIRWAY_BILL_NUMBER,
        CAST(HOUSE_AIRWAY_BILL_NUMBER as VARCHAR(16777216)) as HOUSE_AIRWAY_BILL_NUMBER,
        CAST(SHIPMENT_CARRIER as VARCHAR(16777216)) as SHIPMENT_CARRIER,
        CAST(CUSTOMS_CLEARANCE_DATE as VARCHAR(16777216)) as CUSTOMS_CLEARANCE_DATE,
        CAST(BL_ISSUE_DATE as VARCHAR(16777216)) as BL_ISSUE_DATE,
        CAST(ETD as VARCHAR(16777216)) as ETD,
        CAST(ETA as VARCHAR(16777216)) as ETA,
        CAST(FLIGHT_NUMBER_1 as VARCHAR(16777216)) as FLIGHT_NUMBER_1,
        CAST(FLIGHT_NUMBER_2 as VARCHAR(16777216)) as FLIGHT_NUMBER_2,
        CAST(FLIGHT_NUMBER_3 as VARCHAR(16777216)) as FLIGHT_NUMBER_3,
        CAST(C_WT as VARCHAR(16777216)) as C_WT,
        CAST(TRACKING_NUMBER as VARCHAR(16777216)) as TRACKING_NUMBER,
        CAST(POINT_OF_LADING as VARCHAR(16777216)) as POINT_OF_LADING,
        CAST(POINT_OF_DISCHARGE as VARCHAR(16777216)) as POINT_OF_DISCHARGE,
        CAST(EXPORT_SHIPPING_TYPE as VARCHAR(16777216)) as EXPORT_SHIPPING_TYPE,
        CAST(PROCESSED as NUMBER(38,0)) as PROCESSED,
        CAST(PROCESS_DT as TIMESTAMP_NTZ(9)) as PROCESS_DT,
        CAST(ERROR as VARCHAR(16777216)) as ERROR,
        CAST(ERROR_MESSAGE as VARCHAR(16777216)) as ERROR_MESSAGE,
        CAST(PROCESS_ID as NUMBER(38,0)) as PROCESS_ID,
        CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
    FROM transform_data
)

SELECT * FROM type_data