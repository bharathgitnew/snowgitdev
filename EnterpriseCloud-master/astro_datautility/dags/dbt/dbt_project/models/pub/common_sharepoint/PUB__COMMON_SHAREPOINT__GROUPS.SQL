/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.55.49"
*************/

{{ config(
      materialized='view',
      alias='GROUPS',
      transient=false
) }}

with source_data as (
    SELECT
        GROUPUNIQUEID,
        GROUPID,
        GROUPNAME,
        DESCRIPTION,
        APPROVEREMAIL1,
        APPROVEREMAIL2,
        AUTHOREMAIL,
        EDITOREMAIL,
        CREATEDDATETIME,
        LASTMODIFIEDDATETIME
    from {{ ref('COMMON__SHAREPOINT__GROUPS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data