/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.24"
*************/

{{ config(
      materialized='view',
      alias='USERREQUESTS',
      transient=false
) }}

with source_data as (
    SELECT
        REQUESTUNIQUEID,
        REQUESTID,
        REQUESTACTION,
        GROUPID,
        EMPLOYEEEMAIL,
        REQUESTSTATUS,
        APPROVERDATE1,
        APPROVERDATE2,
        APPROVERDATE3,
        CREATEDDATETIME,
        COMPLETEDDATETIME,
        LASTMODIFIEDDATETIME,
        DATASTEWARDEMAIL,
        EXECUTIVEEMAIL,
        MANAGEREMAIL
    from {{ ref('ODS__SHAREPOINT__USERREQUESTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data