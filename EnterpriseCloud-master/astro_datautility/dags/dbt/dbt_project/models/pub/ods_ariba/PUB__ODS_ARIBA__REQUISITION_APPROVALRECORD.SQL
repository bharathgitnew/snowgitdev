/************
Model file generated from dbtGeneratePubViews: 03.09.2022.10.56.21"
*************/

{{ config(
      materialized='view',
      alias='REQUISITION_APPROVALRECORD',
      transient=false
) }}

with source_data as (
    SELECT
        LASTUPDATED,
        REALMNAME,
        REQUISITIONIDKEY,
        REQUISITIONVERSIONKEY,
        REQUISITIONAPPROVALRECORDKEY,
        ACTIVATIONDATE,
        COMMENTDATE,
        COMMENTEXTERNALCOMMENT,
        COMMENTTITLE,
        COMMENTUSERCODE,
        DATE,
        REALUSER,
        RECEIVEDFROMEMAIL,
        STATE,
        USERCODE,
        ISHISTORICAL
    from {{ source('ODS__ARIBA', 'REQUISITION_APPROVALRECORD') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data