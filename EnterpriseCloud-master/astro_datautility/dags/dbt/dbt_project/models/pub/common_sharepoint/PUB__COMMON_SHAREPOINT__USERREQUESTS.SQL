/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.55.50"
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
    from {{ ref('COMMON__SHAREPOINT__USERREQUESTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data