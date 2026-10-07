{{ config(
    alias='SHAREPOINT_SHIPPING_ADVICE_LIST',
    materialized='table',
    transient=false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD['Delivery No']::STRING AS DELIVERY_NO,
        JSONFIELD['Q''ty''']::STRING AS Q_TY,
        JSONFIELD['Material']::STRING AS MATERIAL,
        JSONFIELD['HAWB#']::STRING AS HAWB,
        JSONFIELD['Tracking No.']::STRING AS TRACKING_NO,
        JSONFIELD['Remarks']::STRING AS REMARKS,
        JSONFIELD['Serial No.']::STRING AS SERIAL_NO,
        JSONFIELD['Scheduled Customs Clearance Date']::STRING AS SCHEDULED_CUSTOMS_CLEARANCE_DATE,
        JSONFIELD['Carton No.']::STRING AS CARTON_NO,
        JSONFIELD['Creation Date']::STRING AS CREATION_DATE,
        JSONFIELD['Shipping Information Create Date']::STRING AS SHIPPING_INFORMATION_CREATE_DATE,
        JSONFIELD['Update Date']::STRING AS UPDATE_DATE,
        JSONFIELD['Confirmed Customs Clearance Date']::STRING AS CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        JSONFIELD['Net Weight Of The Item']::STRING AS NET_WEIGHT_OF_THE_ITEM,
        JSONFIELD['Weight']::STRING AS WEIGHT,
        JSONFIELD['Length']::STRING AS LENGTH,
        JSONFIELD['Width']::STRING AS WIDTH,
        JSONFIELD['Height']::STRING AS HEIGHT,
        JSONFIELD['Carton Name']::STRING AS CARTON_NAME,
        JSONFIELD['Hazmat']::STRING AS HAZMAT,
        JSONFIELD['UN Code']::STRING AS UN_CODE,
        JSONFIELD['EL Type']::STRING AS EL_TYPE,
        JSONFIELD['EL Number']::STRING AS EL_NUMBER,
        JSONFIELD['HS Code Export Country']::STRING AS HS_CODE_EXPORT_COUNTRY
    from {{ source('SHAREPOINT', 'SHIPPING_ADVICE_LIST') }}

),

transform_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' as _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        DELIVERY_NO,
        Q_TY,
        MATERIAL,
        HAWB,
        TRACKING_NO,
        REMARKS,
        SERIAL_NO,
        SCHEDULED_CUSTOMS_CLEARANCE_DATE,
        CARTON_NO,
        CREATION_DATE,
        SHIPPING_INFORMATION_CREATE_DATE,
        UPDATE_DATE,
        CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        NET_WEIGHT_OF_THE_ITEM,
        WEIGHT,
        LENGTH,
        WIDTH,
        HEIGHT,
        CARTON_NAME,
        HAZMAT,
        UN_CODE,
        EL_TYPE,
        EL_NUMBER,
        HS_CODE_EXPORT_COUNTRY
    from source_data
),

type_data as (
    select
        cast(_FILENAME as varchar(16777216)) as _FILENAME,
        cast(_FILEDATE as timestamp_ntz(9)) as _FILEDATE,
        cast(_UPLOADDATE as timestamp_ntz(9)) as _UPLOADDATE,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(DELIVERY_NO as varchar(16777216)) as DELIVERY_NO,
        cast(Q_TY as varchar(16777216)) as Q_TY,
        cast(MATERIAL as varchar(16777216)) as MATERIAL,
        cast(HAWB as varchar(16777216)) as HAWB,
        cast(TRACKING_NO as varchar(16777216)) as TRACKING_NO,
        cast(REMARKS as varchar(16777216)) as REMARKS,
        cast(SERIAL_NO as varchar(16777216)) as SERIAL_NO,
        cast(SCHEDULED_CUSTOMS_CLEARANCE_DATE as varchar(16777216)) as SCHEDULED_CUSTOMS_CLEARANCE_DATE,
        cast(CARTON_NO as varchar(16777216)) as CARTON_NO,
        cast(CREATION_DATE as varchar(16777216)) as CREATION_DATE,
        cast(SHIPPING_INFORMATION_CREATE_DATE as varchar(16777216)) as SHIPPING_INFORMATION_CREATE_DATE,
        cast(UPDATE_DATE as varchar(16777216)) as UPDATE_DATE,
        cast(CONFIRMED_CUSTOMS_CLEARANCE_DATE as varchar(16777216)) as CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        cast(NET_WEIGHT_OF_THE_ITEM as varchar(16777216)) as NET_WEIGHT_OF_THE_ITEM,
        cast(WEIGHT as varchar(16777216)) as WEIGHT,
        cast(LENGTH as varchar(16777216)) as LENGTH,
        cast(WIDTH as varchar(16777216)) as WIDTH,
        cast(HEIGHT as varchar(16777216)) as HEIGHT,
        cast(CARTON_NAME as varchar(16777216)) as CARTON_NAME,
        cast(HAZMAT as varchar(16777216)) as HAZMAT,
        cast(UN_CODE as varchar(16777216)) as UN_CODE,
        cast(EL_TYPE as varchar(16777216)) as EL_TYPE,
        cast(EL_NUMBER as varchar(16777216)) as EL_NUMBER,
        cast(HS_CODE_EXPORT_COUNTRY as varchar(16777216)) as HS_CODE_EXPORT_COUNTRY
    from transform_data
)

select * from type_data