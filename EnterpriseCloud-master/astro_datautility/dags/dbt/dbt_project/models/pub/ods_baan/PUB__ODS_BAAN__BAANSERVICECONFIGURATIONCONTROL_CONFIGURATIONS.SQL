/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.17"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CALENDAR,
        CALL_OUTCHARGE,
        CONFIGURATION,
        CONFIGURATIONPRIORITY,
        CONFIGURATIONTEXT,
        CONTACTPERSON,
        CURRENCY,
        DESCRIPTION,
        DISTANCEZONE,
        ENDDATEPREVENTIVEMAINTENANCE,
        EXPIREDDESCRIPTION,
        EXPIREDID,
        EXPIRYDATE,
        EXTRAINFORMATION,
        HISTORYTEXT,
        LABORRATE,
        LOCATIONADDRESS,
        MODEM,
        OWNERDESCRIPTION,
        OWNERID,
        PAGEALLOWEDDESCRIPTION,
        PAGEALLOWEDID,
        PREFERREDENGINEER1,
        PREFERREDENGINEER2,
        RESPONSIBLEENGINEER,
        SEARCHARGUMENT,
        SEARCHARGUMENTWORKSITEADDRESS,
        SERVICEAREA,
        SERVICECENTER,
        SOLDTOADDRESS,
        SOLDTOBUSINESSPARTNER,
        STARTDATEPREVENTIVEMAINTENANCE,
        TRAVELDISTANCE,
        TRAVELINGTIME,
        USAGECLASS,
        WARRANTY,
        WORKCENTER
    from {{ ref('ODS__BAAN__BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data