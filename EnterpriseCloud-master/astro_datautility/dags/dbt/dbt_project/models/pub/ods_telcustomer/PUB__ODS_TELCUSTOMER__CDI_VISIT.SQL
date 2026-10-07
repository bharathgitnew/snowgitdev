{{ config(
      materialized='view',
      alias='CDI_VISIT',
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
        CDI_CITY,
        CDI_COMPANY,
        CDI_CONTACTID_ID,
        CDI_CONTACTID_NAME,
        CDI_COUNTRY,
        CDI_DOMAINID_ID,
        CDI_DOMAINID_NAME,
        CDI_DURATION,
        CDI_EMAIL,
        CDI_ENDEDON,
        CDI_ENTRYPAGE,
        CDI_EXITPAGE,
        CDI_FIRSTVISIT,
        CDI_IP,
        CDI_IPORGANIZATIONID_ID,
        CDI_IPORGANIZATIONID_NAME,
        CDI_LATITUDE,
        CDI_LONGITUDE,
        CDI_OS,
        CDI_POSTALCODE,
        CDI_REFERRER,
        CDI_REFERRINGHOST,
        CDI_SCORE,
        CDI_SOURCE,
        CDI_STARTEDON,
        CDI_STATE,
        CDI_TIME,
        CDI_TOTALPAGES,
        CDI_VISITORKEY,
        CREATEDON,
        STATECODE,
        STATUSCODE,
        CDI_BOUNCE
    from {{ ref('ODS__TELCUSTOMER__CDI_VISIT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data