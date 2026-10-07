/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.23"
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
    from {{ ref('ODS__SHAREPOINT__GROUPS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data