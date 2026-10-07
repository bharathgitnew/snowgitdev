/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.56"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_EVENTSTRACKING',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADDITIONALINFORMATION,
        BUYFROMBUSINESSPARTNER,
        CUSTOMERPO,
        EVENTDATE,
        EVENTS,
        EVENTSEQUENCE,
        MORE,
        ORDER_NUMBER,
        ORDER_TYPEDESCRIPTION,
        ORDER_TYPEID,
        POSITION,
        SEQUENCE,
        USER
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_EVENTSTRACKING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data