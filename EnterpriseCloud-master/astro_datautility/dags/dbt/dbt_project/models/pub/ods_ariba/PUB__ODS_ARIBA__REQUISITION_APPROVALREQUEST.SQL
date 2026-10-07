/************
Model file generated from dbtGeneratePubViews: 03.09.2022.10.56.21"
*************/

{{ config(
      materialized='view',
      alias='REQUISITION_APPROVALREQUEST',
      transient=false
) }}

with source_data as (
    SELECT
        LASTUPDATED,
        REALMNAME,
        REQUISITIONIDKEY,
        REQUISITIONVERSIONKEY,
        REQUISITIONAPPROVALREQUESTKEY,
        ACTIVATIONDATE,
        ALLOWESCALATIONPERIODEXTENSION,
        APPROVALREQUIRED,
        APPROVEDBYCODE,
        APPROVERCODE,
        APPROVERCOMMENT,
        ASSIGNEDDATE,
        ASSIGNEDTOCODE,
        CREATORCODE,
        ESCALATIONDATE,
        ESCALATIONEXTENDEDBYUSERCODE,
        ESCALATIONEXTENSIONDATE,
        ESCALATIONWARNINGDATE,
        EXTENDESCALATIONREASONCODE,
        EXTENDESCALATIONUSERCOMMENTS,
        ISESCALATEDTOLIST,
        ISESCALATIONEXTENDED,
        MANUALLYADDED,
        REASON,
        REPORTINGEXTENDESCALATIONREASON,
        REPORTINGREASON,
        RULENAME,
        STATE,
        CUSTOMFIELD_BUSINESSJUSTIFICATION,
        ISHISTORICAL
    from {{ source('ODS__ARIBA', 'REQUISITION_APPROVALREQUEST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data