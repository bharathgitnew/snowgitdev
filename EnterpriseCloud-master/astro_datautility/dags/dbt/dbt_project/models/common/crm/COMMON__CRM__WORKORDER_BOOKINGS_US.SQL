{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='WORKORDER_BOOKINGS_US',
    unique_key = ['BOOKING_ID']
) }}

WITH source_data AS
(
    SELECT
        B.BOOKABLERESOURCEBOOKINGID AS BOOKING_ID,
        B.MSDYN_WORKORDER AS WO_ID, --returns the unique WO ID 
        B.MSDYN_WORKORDERNAME AS WO_NO, --returns the WO No.
        B.TEL_WO_ACCEPTANCESTATUS AS ACCEPTANCE_STATUS_CODE, --returns the code for acceptance status, must be joined onto GLOBALOPTIONSETMETADATA to get the text value
        META.LOCALIZEDLABEL AS ACCEPTANCE_STATUS_VALUE, --returns the label for the acceptance status logical value
        B.RESOURCE AS RESOURCE_ID, --returns the unique resource ID 
        B.RESOURCENAME AS RESOURCE_NAME, --returns the resource name
        B.WO_REGIONNAME AS REGION_NAME, -- returns WO region name
        TRY_TO_DATE(TO_VARCHAR(TO_DATE(B.CREATEDON))) AS CREATEDON, -- returns booking created on date
        TRY_TO_DATE(TO_VARCHAR(TO_DATE(B.MODIFIEDON))) AS MODIFIEDON, -- returns booking modified on date
        BR.STATECODE AS RESOURCE_STATUS_CODE, -- returns resource state code
        BRMETA.LOCALIZEDLABEL AS RESOURCE_STATUS, -- returns resource state code description
        BR.WO_EMPLOYEEID AS BR_WO_EMPLOYEEID,
        CASE
            WHEN LEN(SPLIT_PART(B.RESOURCENAME, '_', -1)) = 6
            THEN SPLIT_PART(B.RESOURCENAME, '_', 1) 
            ELSE NULL END AS EMPLOYEE_NAME,
        CASE
            WHEN LEN(SPLIT_PART(B.RESOURCENAME, '_', -1)) = 6
            THEN SPLIT_PART(B.RESOURCENAME, '_', -1) 
            ELSE NULL END AS B_EMPLOYEE_ID,
        CASE
            WHEN NULLIF(BR_WO_EMPLOYEEID,'') IS NULL AND NULLIF(B_EMPLOYEE_ID, '') IS NOT NULL
            THEN B_EMPLOYEE_ID ELSE BR_WO_EMPLOYEEID END AS EMPLOYEE_ID, 
        B.STATECODE AS STATUS_CODE,
        STMETA.LOCALIZEDLABEL AS STATUS,
        B.STATUSCODE AS STATUS_REASON_CODE, --status code of booking record
        SRMETA.LOCALIZEDLABEL AS STATUS_REASON_VALUE, --returns the status reason of the booking record
        B.CREATEDBYNAME AS CREATED_BY, --created by employee name
        SU.EMPLOYEEID AS CREATED_BY_ID, --created by employee id
        B.DURATION,
        B.BOOKINGSTATUSNAME AS BOOKING_STATUS

    -- FROM PUB.ODS_CRM.BOOKABLERESOURCEBOOKING B
    FROM {{ ref('ODS__CRM_FILE__BOOKABLERESOURCEBOOKING') }} B
    --join for mapping a code to the metadata
    -- LEFT JOIN PUB.ODS_CRM.GLOBALOPTIONSETMETADATA META --join onto global metadata
    LEFT JOIN {{ ref('ODS__CRM_FILE__GLOBALOPTIONSETMETADATA') }} META --join onto global metadata
    ON META.OPTION = TEL_WO_ACCEPTANCESTATUS --join on the acceptance status code
    AND META.LOCALIZEDLABELLANGUAGECODE = '1033' --filters to english only (otherwise will produce duplicate rows)
    AND META.ENTITYNAME = 'bookableresourcebooking' --filters on the booking table (otherwise will produce duplicate rows)
    AND META.OPTIONSETNAME = 'tel_wo_acceptancestatus' --filters on the acceptance status field

    --join for mapping of resource id to the resource metadata
    -- LEFT JOIN PUB.ODS_CRM.BOOKABLERESOURCE AS BR
    LEFT JOIN {{ ref('ODS__CRM_FILE__BOOKABLERESOURCE') }} BR --join onto global metadata
    ON B.RESOURCE = BR.BOOKABLERESOURCEID

    --join for mapping of status code to the metadata
    -- LEFT JOIN PUB.ODS_CRM.STATUSMETADATA SRMETA --join only status metadata
    LEFT JOIN {{ ref('ODS__CRM_FILE__STATUSMETADATA') }} SRMETA --join only status metadata
    ON SRMETA.STATUS = B.STATUSCODE
    AND SRMETA.LOCALIZEDLABELLANGUAGECODE = '1033' --filters to english only (otherwise will produce duplicate rows)
    AND SRMETA.ENTITYNAME = 'bookableresourcebooking' --filters on the booking table (otherwise will produce duplicate rows)

    --join for mapping of status code to the metadata
    -- LEFT JOIN PUB.ODS_CRM.STATEMETADATA STMETA --join only status metadata
    LEFT JOIN {{ ref('ODS__CRM_FILE__STATEMETADATA') }} STMETA --join only status metadata
    ON STMETA.STATE = B.STATECODE
    AND STMETA.LOCALIZEDLABELLANGUAGECODE = '1033' --filters to english only (otherwise will produce duplicate rows)
    AND STMETA.ENTITYNAME = 'bookableresourcebooking' --filters on the booking table (otherwise will produce duplicate rows)

    --join for mapping of resource  status code to the metadata
    -- LEFT JOIN PUB.ODS_CRM.STATEMETADATA BRMETA --join only status metadata
    LEFT JOIN {{ ref('ODS__CRM_FILE__STATUSMETADATA') }} BRMETA --join only status metadata
    ON BRMETA.STATE = BR.STATECODE
    AND BRMETA.LOCALIZEDLABELLANGUAGECODE = '1033' --filters to english only (otherwise will produce duplicate rows)
    AND BRMETA.ENTITYNAME = 'bookableresource' --filters on the booking table (otherwise will produce duplicate rows)

    -- LEFT JOIN PUB.ODS_CRM.SYSTEMUSER AS SU
    LEFT JOIN {{ ref('ODS__CRM_FILE__SYSTEMUSER') }} SU
    ON SU.SYSTEMUSERID = B.CREATEDBY

    WHERE 1=1
    AND B.WO_REGIONNAME IN ('US')
)

,transform_data AS
(
    SELECT
        BOOKING_ID AS BOOKING_ID
        ,WO_ID  AS WO_ID 
        ,WO_NO AS WO_NO
        ,REGION_NAME AS REGION_NAME
        ,RESOURCE_ID  AS RESOURCE_ID 
        ,RESOURCE_NAME AS RESOURCE_NAME
        ,EMPLOYEE_NAME AS EMPLOYEE_NAME
        ,EMPLOYEE_ID AS EMPLOYEE_ID
        ,RESOURCE_STATUS_CODE AS RESOURCE_STATUS_CODE
        ,RESOURCE_STATUS AS RESOURCE_STATUS
        ,CREATEDON AS CREATEDON
        ,CREATED_BY AS CREATED_BY
        ,CREATED_BY_ID AS CREATED_BY_ID
        ,MODIFIEDON AS MODIFIEDON
        ,ACCEPTANCE_STATUS_CODE AS ACCEPTANCE_STATUS_CODE
        ,ACCEPTANCE_STATUS_VALUE AS ACCEPTANCE_STATUS_VALUE
        ,STATUS_CODE AS STATUS_CODE
        ,STATUS AS STATUS
        ,STATUS_REASON_CODE AS STATUS_REASON_CODE
        ,STATUS_REASON_VALUE AS STATUS_REASON_VALUE
        ,DURATION AS DURATION
        ,BOOKING_STATUS AS BOOKING_STATUS
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH
    FROM source_data
)

,type_data AS
(
    SELECT
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID
        ,CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
        ,CAST(BOOKING_ID AS VARCHAR(16777216)) AS BOOKING_ID
        ,CAST(WO_ID  AS VARCHAR(16777216)) AS WO_ID 
        ,CAST(WO_NO AS VARCHAR(16777216)) AS WO_NO
        ,CAST(REGION_NAME AS VARCHAR(16777216)) AS REGION_NAME
        ,CAST(RESOURCE_ID  AS VARCHAR(16777216)) AS RESOURCE_ID 
        ,CAST(RESOURCE_NAME AS VARCHAR(16777216)) AS RESOURCE_NAME
        ,CAST(EMPLOYEE_NAME AS VARCHAR(16777216)) AS EMPLOYEE_NAME
        ,CAST(EMPLOYEE_ID AS VARCHAR(16777216)) AS EMPLOYEE_ID
        ,CAST(RESOURCE_STATUS_CODE AS NUMBER(38,0)) AS RESOURCE_STATUS_CODE
        ,CAST(RESOURCE_STATUS AS VARCHAR(16777216)) AS RESOURCE_STATUS
        ,CAST(CREATEDON AS DATE) AS CREATEDON
        ,CAST(CREATED_BY AS VARCHAR(16777216)) AS CREATED_BY
        ,CAST(CREATED_BY_ID AS VARCHAR(16777216)) AS CREATED_BY_ID
        ,CAST(MODIFIEDON AS DATE) AS MODIFIEDON
        ,CAST(ACCEPTANCE_STATUS_CODE AS NUMBER(38,0)) AS ACCEPTANCE_STATUS_CODE
        ,CAST(ACCEPTANCE_STATUS_VALUE AS VARCHAR(16777216)) AS ACCEPTANCE_STATUS_VALUE
        ,CAST(STATUS_CODE AS NUMBER(38,0)) AS STATUS_CODE
        ,CAST(STATUS AS VARCHAR(16777216)) AS STATUS
        ,CAST(STATUS_REASON_CODE AS NUMBER(38,0)) AS STATUS_REASON_CODE
        ,CAST(STATUS_REASON_VALUE AS VARCHAR(16777216)) AS STATUS_REASON_VALUE
        ,CAST(DURATION AS NUMBER(38,0)) AS DURATION
        ,CAST(BOOKING_STATUS AS VARCHAR(16777216)) AS BOOKING_STATUS
    FROM transform_data    
)

SELECT * FROM type_data