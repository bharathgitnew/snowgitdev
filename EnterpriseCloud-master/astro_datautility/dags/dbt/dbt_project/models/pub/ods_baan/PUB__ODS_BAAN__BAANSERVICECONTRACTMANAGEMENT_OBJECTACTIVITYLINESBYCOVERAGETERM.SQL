/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.21"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONTRACTMANAGEMENT_OBJECTACTIVITYLINESBYCOVERAGETERM',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACTIVITYNUMBER,
        CONFIGURATION_CCFG,
        CONFIGURATION_CFGR,
        COSTTYPEDESCRIPTION,
        COSTTYPEID,
        COVERAGETERMNUMBER,
        MODELITEM,
        OBJECT,
        OBJECTNUMBER,
        REFERENCEACTIVITY,
        SEQUENCENUMBER,
        SERIALNUMBER,
        SERVICETYPE,
        TERMID
    from {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_OBJECTACTIVITYLINESBYCOVERAGETERM') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data