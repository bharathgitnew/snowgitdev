/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.23"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICESERVICEORDERCONTROL_SERVICEEXECUTIONASSIGNMENTS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCEPTEDTIME,
        ACTIVITY,
        ASSIGNMENTDURATION,
        ASSIGNMENTLINE,
        CALENDARCHECKDESCRIPTION,
        CALENDARCHECKID,
        DOWNLOADEDTIME,
        EXECUTIONFINISHTIME,
        EXECUTIONSTARTTIME,
        JOBSHEETCOMPLETIONTIME,
        LASTCHANGEDTIME,
        PLANNEDFINISHTIME,
        PLANNEDSTARTTIME,
        REJECTIONTIME,
        SERVICEENGINEER,
        SERVICEORDER
    from {{ ref('ODS__BAAN__BAANSERVICESERVICEORDERCONTROL_SERVICEEXECUTIONASSIGNMENTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data