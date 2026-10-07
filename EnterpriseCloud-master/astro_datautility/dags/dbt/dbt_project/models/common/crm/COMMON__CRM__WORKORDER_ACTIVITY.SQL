{{ config(
    alias='WORKORDER_ACTIVITY',
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    unique_key = []
) }}

with MSDYN_WORKORDER_REF as (
	select * from {{ ref('ODS__CRM_FILE__MSDYN_WORKORDER') }} where ISDELETE is null
),

WO_WORKORDERACTIVITY_REF as (
	select * from {{ ref('ODS__CRM_FILE__WO_WORKORDERACTIVITY') }} where ISDELETE is null
),

SYSTEMUSER_REF as (
	select * from {{ ref('ODS__CRM_FILE__SYSTEMUSER') }}
),

TEL_COM_ESCALATIONISSUE_REF as (
	select * from {{ ref('ODS__CRM_FILE__TEL_COM_ESCALATIONISSUE') }}
),

source_data as (
    select
        CreatedBy.FULLNAME as CREATED_BY ,
        CreatedBy.EMPLOYEEID as CREATED_BY_EMP_ID,
        PassDown.CREATEDON as CREATED_ON,
        PassDown.WO_CUSTOMERREQUESTMEMO as CUSTOMER_REQUEST,
        PassDown.WO_DELAY as DELAY,
        PassDown.WO_DETAILTOCUSTOMER as DETAIL_TO_CUSTOMER,
        Escalation.TEL_COM_NAME as ESCALATION,
        CreatedBy_R.EMPLOYEEID as FE_EMP_ID,
        CreatedBy_R.FULLNAME as FE_NAME,
        PassDown.WO_INTERNALDETAILS as INTERNAL_NOTES,
        ModifiedBy.FULLNAME as MODIFIED_BY,
        ModifiedBy.EMPLOYEEID as MODIFIED_BY_EMP_ID,
        PassDown.MODIFIEDON as MODIFIED_ON,
        PassDown.WO_NEXTACTIONR as NEXT_ACTION,
        PassDown.WO_NOTE as OUTCOME,
        PassDown.WO_DATE as PASSDOWN_DATE,
        PassDown.WO_WORKORDERACTIVITYID as PASS_DOWN_ID,
        PassDown.WO_DETAIL as REQUEST_TO_CUSTOMER,
        PassDown.WO_SAFETYRELATEDINFO as SAFETY_INFORMATION,
        PassDown.WO_NAME as TITLE,
        WorkOrderNo.MSDYN_NAME as WORK_ORDER_NO,
        PassDown.WO_PPACKYMATTACHMENT as PPACKYM_ATTACHMENT_FLAG,
        PassDown.STATECODE as STATECODE,
        statemetadata.LOCALIZEDLABEL as STATUS,
    from WO_WORKORDERACTIVITY_REF PassDown
    left join MSDYN_WORKORDER_REF WorkOrderNo on PassDown.WO_WORKORDERNO = WorkOrderNo.ID
    left join SYSTEMUSER_REF CreatedBy_R on PassDown.WO_FENAME = CreatedBy_R.ID
    left join SYSTEMUSER_REF CreatedBy on PassDown.CREATEDBY = CreatedBy.ID
    left join SYSTEMUSER_REF ModifiedBy on PassDown.MODIFIEDBY = ModifiedBy.ID
    left join TEL_COM_ESCALATIONISSUE_REF Escalation on PassDown.TEL_COM_ESCALATIONISSUE = Escalation.ID
    LEFT JOIN {{ ref('ODS__CRM_FILE__STATEMETADATA') }} as statemetadata
        on statemetadata.STATE = PassDown.STATECODE
        and statemetadata.ENTITYNAME = 'wo_workorderactivity'
        and statemetadata.LOCALIZEDLABELLANGUAGECODE = '1033'
),

transform_data as (
    select
        '{{ invocation_id }}' as _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        CREATED_BY,
        CREATED_BY_EMP_ID,
        CREATED_ON,
        CUSTOMER_REQUEST,
        DELAY,
        DETAIL_TO_CUSTOMER,
        ESCALATION,
        FE_EMP_ID,
        FE_NAME,
        INTERNAL_NOTES,
        MODIFIED_BY,
        MODIFIED_BY_EMP_ID,
        MODIFIED_ON,
        NEXT_ACTION,
        OUTCOME,
        PASSDOWN_DATE,
        PASS_DOWN_ID,
        REQUEST_TO_CUSTOMER,
        SAFETY_INFORMATION,
        TITLE,
        WORK_ORDER_NO,
        PPACKYM_ATTACHMENT_FLAG,
        STATECODE,
        STATUS,
    from source_data
),

type_data as (
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        PASS_DOWN_ID,
        TITLE,
        WORK_ORDER_NO,
        cast(PASSDOWN_DATE as TIMESTAMP_NTZ(9)) as PASSDOWN_DATE,
        DELAY,
        REQUEST_TO_CUSTOMER,
        DETAIL_TO_CUSTOMER,
        OUTCOME,
        INTERNAL_NOTES,
        NEXT_ACTION,
        SAFETY_INFORMATION,
        CUSTOMER_REQUEST,
        FE_NAME,
        FE_EMP_ID,
        CREATED_BY,
        CREATED_BY_EMP_ID,
        MODIFIED_BY,
        MODIFIED_BY_EMP_ID,
        ESCALATION,
        cast(CREATED_ON as TIMESTAMP_NTZ(9)) as CREATED_ON,
        cast(MODIFIED_ON as TIMESTAMP_NTZ(9)) as MODIFIED_ON,
        PPACKYM_ATTACHMENT_FLAG,
        STATECODE,
        STATUS,
    from transform_data
)

select * from type_data