/************
Model file generated from dbtGeneratePubViews: 02.03.2023.17.18.25"
*************/

{{ config(
      materialized='view',
      alias='ACTIVITIES_TEE',
      transient=false
) }}

with source_data as (
    SELECT
        ACTIVITYLEVEL1NAMEMAINCATEGORY,
        ACTIVITYLEVEL1NAMESUBCATEGORY,
        ACTIVITYLEVEL2NAMEBU,
        ACTIVITYLEVEL2NAMESERIALNO,
        ACTIVITYLEVEL3NAMEINSTALLATIONID,
        ACTIVITYLEVEL3NAMESERVICEORDER,
        ACTIVITYLEVEL4NAMETASK,
        ALLOCATED_HOURS,
        APPLYDATE,
        APPROVEDBYMANAGER,
        EMPLOYEENUMBER,
        END_DATE,
        HOMELABORCATEGORY1COSTSTRUCTURE,
        HOME_REGION,
        PAYCODE,
        PAYCODE_TYPE,
        START_DATE,
        THIRD_PARTY_EMPLOYEE,
        TIMEPUNCHID,
        UPDATEDATETIME,
        WORKEDLABORCATEGORY1COSTSTRUCTURE,
        WORKRULE,
        WORK_REGION
    from {{ ref('COMMON__KRONOS__ACTIVITIES_TEE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data