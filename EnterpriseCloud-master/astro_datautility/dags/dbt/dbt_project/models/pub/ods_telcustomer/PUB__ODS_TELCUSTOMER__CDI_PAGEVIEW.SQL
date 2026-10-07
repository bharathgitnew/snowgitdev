{{ config(
      materialized='view',
      alias='CDI_PAGEVIEW',
      transient=false
) }}

with source_data as (
    SELECT
        ID,
        CDI_ANONYMOUSVISITORID_ID,
        CDI_ANONYMOUSVISITORID_NAME,
        CDI_BROWSER,
        CDI_CAMPAIGNCODE,
        CDI_CAMPAIGNID_ID,
        CDI_CAMPAIGNID_NAME,
        CDI_CONTACTID_ID,
        CDI_DOMAINID_ID,
        CDI_DOMAINID_NAME,
        CDI_DURATION,
        CDI_EMAIL,
        CDI_HOST,
        CDI_IP,
        CDI_IPORGANIZATIONID_ID,
        CDI_IPORGANIZATIONID_NAME,
        CDI_LEADID_ID,
        CDI_LEADID_NAME,
        CDI_OS,
        CDI_REFERRER,
        CDI_SCORE,
        CDI_SOURCE,
        CDI_TIME,
        CDI_TITLE,
        CDI_TYPE,
        CDI_TYPENAME,
        CDI_URI,
        CDI_VIEWEDON,
        CDI_VISITID_ID,
        CDI_VISITID_NAME,
        CDI_VISITORKEY,
        CREATEDON,
        STATECODE,
        STATUSCODE
    from {{ ref('ODS__TELCUSTOMER__CDI_PAGEVIEW') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data