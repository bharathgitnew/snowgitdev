/************
Model file generated from dbtGeneratePubViews: 03.09.2022.10.56.15"
*************/

{{ config(
      materialized='view',
      alias='AUDITLOG',
      transient=false
) }}

with source_data as (
    SELECT
        FILENAME,
        REALM,
        DOCUMENTTYPE,
        VIEWTEMPLATENAME,
        PARAMETERSTARTDATETIME,
        PARAMETERENDDATETIME,
        REQUESTEDDATETIME,
        COMPLETEDDATETIME,
        PROCESSEDDATETIME,
        FILECOUNT,
        FILENAMELIST,
        RECORDCOUNT,
        JOBID,
        JOBSTATUS
    from {{ ref('ODS__ARIBA__AUDITLOG') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data