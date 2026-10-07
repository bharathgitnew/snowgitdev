/************
Model file generated from dbtGeneratePubViews: 02.03.2023.17.18.24"
*************/

{{ config(
      materialized='view',
      alias='TIMESHEET',
      transient=false
) }}

with source_data as (
    SELECT
        ADPCOMPANY,
        APPROVINGSUPERVISORID,
        BUCODE,
        BILLABLECATEGORY,
        COMMENT,
        DEPARTMENTID,
        EMPBUNAME,
        EMPLOYEEFULLNAME,
        EMPLOYEEID,
        EMPLOYEETYPE,
        ENDTIMESTAMP,
        ENTEREDONTIMESTAMP,
        EVENTDATE,
        EVENTTIMESTAMP,
        FAB,
        FABCODE,
        HOURSCHARGED,
        ISEMPLOYEEAPPROVED,
        MACHINEBU,
        MACHINESERIALNUMBER,
        NOTES,
        OTCOMMENT,
        OFFICEID,
        ORGMAPTYPE,
        ORGPATHTEXT,
        PAYCODENAME,
        PRODUCTSUBCATEGORY,
        PRODUCTTYPE,
        PROJECTCOMPANY,
        PROJECTGROUP,
        PROJECTSUBGROUP,
        PROJECTTASK,
        PROJECTTYPEOFWORK,
        SERVICEORDER,
        SHIFTNUMBER,
        SHIFTTYPE,
        SOURCESYSTEM,
        STARTTIMESTAMP,
        TASK,
        TASKSOURCE,
        TASKWRENCHTYPE,
        TIMEINSECONDS,
        TIMEPUNCHID,
        TIMESHEETITEMID,
        TYPEOFWORK,
        TYPEOFWORKGROUP,
        TYPEOFWORKSOURCE,
        WORKRULENAME,
        SAPOPERATION,
        CRMWORKORDER,
        TEL_WO_CATEGORYNAME,
        TEL_WO_BU2NAME,
        WO_REGIONNAME,
        WO_TASK2NAME,
        TEL_WO_TYPEOFPAYMENT,
        WO_TIMECATEGORY
    from {{ ref('COMMON__KRONOS__TIMESHEET') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data