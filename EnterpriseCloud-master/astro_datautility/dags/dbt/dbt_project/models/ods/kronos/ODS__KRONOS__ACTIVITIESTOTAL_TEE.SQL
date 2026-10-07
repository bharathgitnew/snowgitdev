/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-kronos\ActivitiesTotalTEE__Kronos_ActivitiesTotalTEE.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\kronos\ActivitiesTotal.SQL
-materialized incremental
-alias ActivitiesTotal
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema kronos
-sourceDatabase LZ_DEV
-useDistinct $false
model file generated on: 1/11/2022 4:02:42 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ActivitiesTotal_TEE',
    unique_key = ['TRANSACTIONID',
    'PAYCODE',
    'APPLYDATE']
) }}


with source_data as
(
    SELECT
        lpad(ActivitiesTotal.EmployeeNumber, 6, '0') as EmployeeNumber
        ,ActivitiesTotal.ActivityLevel1NameMainCategory
        ,ActivitiesTotal.ActivityLevel1NameSubCategory
        ,ActivitiesTotal.ActivityLevel2NameCustomer
        ,ActivitiesTotal.ActivityLevel2NameBU
        ,ActivitiesTotal.ActivityLevel2NameSerialNo
        ,ActivitiesTotal.ActivityLevel3NameServiceOrder
        ,ActivitiesTotal.ActivityLevel3NameInstallationID
        ,ActivitiesTotal.ActivityLevel4NameTask
        ,ActivitiesTotal.ApplyDate
        ,ActivitiesTotal.UpdateDateTime
        ,ActivitiesTotal.AdjustedStartDateTime
        ,ActivitiesTotal.AdjustedEndDateTime
        ,ActivitiesTotal.AllocatedHoursTimeinSeconds
        ,ActivitiesTotal.WorkRule
        ,ActivitiesTotal.UserDefinedField1
        ,ActivitiesTotal.UserDefinedField2
        ,ActivitiesTotal.UserDefinedField3
        ,ActivitiesTotal.UserDefinedField4
        ,ActivitiesTotal.WorkRegion
        ,ActivitiesTotal.ResourceRegion
        ,ActivitiesTotal.TimePunchID
        ,ActivitiesTotal.ParentCompany
        ,ActivitiesTotal.HomeBS2Region
        ,ActivitiesTotal.HomeBS3Country
        ,ActivitiesTotal.HomeBS4Subsidiary
        ,ActivitiesTotal.HomeBS5TELOffice
        ,ActivitiesTotal.HomeJob
        ,ActivitiesTotal.HomeLaborCategory1CostStructure
        ,ActivitiesTotal.WorkedBS1ParentCompany
        ,ActivitiesTotal.WorkedBS2Region
        ,ActivitiesTotal.WorkedBS3Country
        ,ActivitiesTotal.WorkedBS4Subsidiary
        ,ActivitiesTotal.WorkedBS5TELOffice
        ,ActivitiesTotal.WorkedJob
        ,ActivitiesTotal.WorkedLaborCategory1CostStructure
        ,ActivitiesTotal.TransactionID
        ,ActivitiesTotal.ApprovedByManager
        ,ActivitiesTotal.PayCode
        ,ActivitiesTotal.Comments
    FROM {{ source("KRONOS", "ACTIVITIESTOTAL") }}
    WHERE _UPLOADDATE > CURRENT_DATE
    AND HOMEBS2REGION = 'Europe'
    QUALIFY (ROW_NUMBER() OVER ( PARTITION BY TransactionID,PayCode,ApplyDate ORDER BY _Filedate DESC )) = 1
)
,destination_Deletes AS
(
    SELECT DISTINCT
         SourceTable.TRANSACTIONID
        ,SourceTable.PayCode
        ,SourceTable.ApplyDate
    FROM {{ this }} SourceTable
    JOIN (SELECT MIN(TO_DATE(ApplyDate)) MinDate,MAX(TO_DATE(ApplyDate)) MaxDate FROM source_data ) QRY_DeleteRows
     ON SourceTable.APPLYDATE >= QRY_DeleteRows.MINDATE
        AND SourceTable.APPLYDATE <= QRY_DeleteRows.MAXDATE
    WHERE SourceTable.HOMEBS2REGION = 'Europe'
    EXCEPT
    SELECT
         TRANSACTIONID
        ,PayCode
        ,ApplyDate
    FROM source_data
)
,transform_data as
(
    SELECT
        source_data.EMPLOYEENUMBER AS EMPLOYEENUMBER,
        source_data.ACTIVITYLEVEL1NAMEMAINCATEGORY AS ACTIVITYLEVEL1NAMEMAINCATEGORY,
        source_data.ACTIVITYLEVEL1NAMESUBCATEGORY AS ACTIVITYLEVEL1NAMESUBCATEGORY,
        source_data.ACTIVITYLEVEL2NAMEBU AS ACTIVITYLEVEL2NAMEBU,
        source_data.ACTIVITYLEVEL2NAMESERIALNO AS ACTIVITYLEVEL2NAMESERIALNO,
        source_data.ACTIVITYLEVEL3NAMESERVICEORDER AS ACTIVITYLEVEL3NAMESERVICEORDER,
        source_data.ACTIVITYLEVEL3NAMEINSTALLATIONID AS ACTIVITYLEVEL3NAMEINSTALLATIONID,
        source_data.ACTIVITYLEVEL4NAMETASK AS ACTIVITYLEVEL4NAMETASK,
        source_data.APPLYDATE AS APPLYDATE,
        source_data.UPDATEDATETIME AS UPDATEDATETIME,
        source_data.ADJUSTEDSTARTDATETIME AS ADJUSTEDSTARTDATETIME,
        source_data.ADJUSTEDENDDATETIME AS ADJUSTEDENDDATETIME,
        source_data.WORKRULE AS WORKRULE,
        source_data.USERDEFINEDFIELD1 AS USERDEFINEDFIELD1,
        source_data.USERDEFINEDFIELD2 AS USERDEFINEDFIELD2,
        source_data.USERDEFINEDFIELD3 AS USERDEFINEDFIELD3,
        source_data.USERDEFINEDFIELD4 AS USERDEFINEDFIELD4,
        source_data.WORKREGION AS WORKREGION,
        source_data.RESOURCEREGION AS RESOURCEREGION,
        source_data.TIMEPUNCHID AS TIMEPUNCHID,
        source_data.PARENTCOMPANY AS PARENTCOMPANY,
        source_data.HOMEBS2REGION AS HOMEBS2REGION,
        source_data.HOMEBS3COUNTRY AS HOMEBS3COUNTRY,
        source_data.HOMEBS4SUBSIDIARY AS HOMEBS4SUBSIDIARY,
        source_data.HOMEBS5TELOFFICE AS HOMEBS5TELOFFICE,
        source_data.HOMEJOB AS HOMEJOB,
        source_data.HOMELABORCATEGORY1COSTSTRUCTURE AS HOMELABORCATEGORY1COSTSTRUCTURE,
        source_data.WORKEDBS1PARENTCOMPANY AS WORKEDBS1PARENTCOMPANY,
        source_data.WORKEDBS2REGION AS WORKEDBS2REGION,
        source_data.WORKEDBS3COUNTRY AS WORKEDBS3COUNTRY,
        source_data.WORKEDBS4SUBSIDIARY AS WORKEDBS4SUBSIDIARY,
        source_data.WORKEDBS5TELOFFICE AS WORKEDBS5TELOFFICE,
        source_data.WORKEDJOB AS WORKEDJOB,
        source_data.WORKEDLABORCATEGORY1COSTSTRUCTURE AS WORKEDLABORCATEGORY1COSTSTRUCTURE,
        source_data.TRANSACTIONID AS TRANSACTIONID,
        source_data.APPROVEDBYMANAGER AS APPROVEDBYMANAGER,
        source_data.PAYCODE AS PAYCODE,
        source_data.COMMENTS AS COMMENTS,
        source_data.ALLOCATEDHOURSTIMEINSECONDS AS ALLOCATEDHOURSTIMEINSECONDS,
        source_data.ACTIVITYLEVEL2NAMECUSTOMER AS ACTIVITYLEVEL2NAMECUSTOMER,
        'No' AS Is_SoftDeleted,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
    UNION
    SELECT
        current_data.EMPLOYEENUMBER AS EMPLOYEENUMBER,
        current_data.ACTIVITYLEVEL1NAMEMAINCATEGORY AS ACTIVITYLEVEL1NAMEMAINCATEGORY,
        current_data.ACTIVITYLEVEL1NAMESUBCATEGORY AS ACTIVITYLEVEL1NAMESUBCATEGORY,
        current_data.ACTIVITYLEVEL2NAMEBU AS ACTIVITYLEVEL2NAMEBU,
        current_data.ACTIVITYLEVEL2NAMESERIALNO AS ACTIVITYLEVEL2NAMESERIALNO,
        current_data.ACTIVITYLEVEL3NAMESERVICEORDER AS ACTIVITYLEVEL3NAMESERVICEORDER,
        current_data.ACTIVITYLEVEL3NAMEINSTALLATIONID AS ACTIVITYLEVEL3NAMEINSTALLATIONID,
        current_data.ACTIVITYLEVEL4NAMETASK AS ACTIVITYLEVEL4NAMETASK,
        current_data.APPLYDATE AS APPLYDATE,
        current_data.UPDATEDATETIME AS UPDATEDATETIME,
        current_data.ADJUSTEDSTARTDATETIME AS ADJUSTEDSTARTDATETIME,
        current_data.ADJUSTEDENDDATETIME AS ADJUSTEDENDDATETIME,
        current_data.WORKRULE AS WORKRULE,
        current_data.USERDEFINEDFIELD1 AS USERDEFINEDFIELD1,
        current_data.USERDEFINEDFIELD2 AS USERDEFINEDFIELD2,
        current_data.USERDEFINEDFIELD3 AS USERDEFINEDFIELD3,
        current_data.USERDEFINEDFIELD4 AS USERDEFINEDFIELD4,
        current_data.WORKREGION AS WORKREGION,
        current_data.RESOURCEREGION AS RESOURCEREGION,
        current_data.TIMEPUNCHID AS TIMEPUNCHID,
        current_data.PARENTCOMPANY AS PARENTCOMPANY,
        current_data.HOMEBS2REGION AS HOMEBS2REGION,
        current_data.HOMEBS3COUNTRY AS HOMEBS3COUNTRY,
        current_data.HOMEBS4SUBSIDIARY AS HOMEBS4SUBSIDIARY,
        current_data.HOMEBS5TELOFFICE AS HOMEBS5TELOFFICE,
        current_data.HOMEJOB AS HOMEJOB,
        current_data.HOMELABORCATEGORY1COSTSTRUCTURE AS HOMELABORCATEGORY1COSTSTRUCTURE,
        current_data.WORKEDBS1PARENTCOMPANY AS WORKEDBS1PARENTCOMPANY,
        current_data.WORKEDBS2REGION AS WORKEDBS2REGION,
        current_data.WORKEDBS3COUNTRY AS WORKEDBS3COUNTRY,
        current_data.WORKEDBS4SUBSIDIARY AS WORKEDBS4SUBSIDIARY,
        current_data.WORKEDBS5TELOFFICE AS WORKEDBS5TELOFFICE,
        current_data.WORKEDJOB AS WORKEDJOB,
        current_data.WORKEDLABORCATEGORY1COSTSTRUCTURE AS WORKEDLABORCATEGORY1COSTSTRUCTURE,
        current_data.TRANSACTIONID AS TRANSACTIONID,
        current_data.APPROVEDBYMANAGER AS APPROVEDBYMANAGER,
        current_data.PAYCODE AS PAYCODE,
        current_data.COMMENTS AS COMMENTS,
        current_data.ALLOCATEDHOURSTIMEINSECONDS AS ALLOCATEDHOURSTIMEINSECONDS,
        current_data.ACTIVITYLEVEL2NAMECUSTOMER AS ACTIVITYLEVEL2NAMECUSTOMER,
        'Yes' AS Is_SoftDeleted,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH -- Adds column to table
    FROM {{ this }} current_data
    JOIN destination_Deletes Deleteds
    ON current_data.ApplyDate = deleteds.ApplyDate
    AND current_data.TransactionId = deleteds.TransactionId
    AND current_data.PayCode = deleteds.PayCode
)
,type_data as
(
    select
        cast(EMPLOYEENUMBER as VARCHAR(16777216)) as EMPLOYEENUMBER,
        cast(ACTIVITYLEVEL1NAMEMAINCATEGORY as VARCHAR(16777216)) as ACTIVITYLEVEL1NAMEMAINCATEGORY,
        cast(ACTIVITYLEVEL1NAMESUBCATEGORY as VARCHAR(16777216)) as ACTIVITYLEVEL1NAMESUBCATEGORY,
        cast(ACTIVITYLEVEL2NAMEBU as VARCHAR(16777216)) as ACTIVITYLEVEL2NAMEBU,
        cast(ACTIVITYLEVEL2NAMESERIALNO as VARCHAR(16777216)) as ACTIVITYLEVEL2NAMESERIALNO,
        cast(ACTIVITYLEVEL3NAMESERVICEORDER as VARCHAR(16777216)) as ACTIVITYLEVEL3NAMESERVICEORDER,
        cast(ACTIVITYLEVEL3NAMEINSTALLATIONID as VARCHAR(16777216)) as ACTIVITYLEVEL3NAMEINSTALLATIONID,
        cast(ACTIVITYLEVEL4NAMETASK as VARCHAR(16777216)) as ACTIVITYLEVEL4NAMETASK,
        cast(APPLYDATE as DATE) as APPLYDATE,
        cast(UPDATEDATETIME as TIMESTAMP_NTZ(9)) as UPDATEDATETIME,
        cast(ADJUSTEDSTARTDATETIME as TIMESTAMP_NTZ(9)) as ADJUSTEDSTARTDATETIME,
        cast(ADJUSTEDENDDATETIME as TIMESTAMP_NTZ(9)) as ADJUSTEDENDDATETIME,
        cast(WORKRULE as VARCHAR(16777216)) as WORKRULE,
        cast(USERDEFINEDFIELD1 as VARCHAR(16777216)) as USERDEFINEDFIELD1,
        cast(USERDEFINEDFIELD2 as VARCHAR(16777216)) as USERDEFINEDFIELD2,
        cast(USERDEFINEDFIELD3 as VARCHAR(16777216)) as USERDEFINEDFIELD3,
        cast(USERDEFINEDFIELD4 as VARCHAR(16777216)) as USERDEFINEDFIELD4,
        cast(WORKREGION as VARCHAR(16777216)) as WORKREGION,
        cast(RESOURCEREGION as VARCHAR(16777216)) as RESOURCEREGION,
        cast(TIMEPUNCHID as VARCHAR(16777216)) as TIMEPUNCHID,
        cast(PARENTCOMPANY as VARCHAR(16777216)) as PARENTCOMPANY,
        cast(HOMEBS2REGION as VARCHAR(16777216)) as HOMEBS2REGION,
        cast(HOMEBS3COUNTRY as VARCHAR(16777216)) as HOMEBS3COUNTRY,
        cast(HOMEBS4SUBSIDIARY as VARCHAR(16777216)) as HOMEBS4SUBSIDIARY,
        cast(HOMEBS5TELOFFICE as VARCHAR(16777216)) as HOMEBS5TELOFFICE,
        cast(HOMEJOB as VARCHAR(16777216)) as HOMEJOB,
        cast(HOMELABORCATEGORY1COSTSTRUCTURE as VARCHAR(16777216)) as HOMELABORCATEGORY1COSTSTRUCTURE,
        cast(WORKEDBS1PARENTCOMPANY as VARCHAR(16777216)) as WORKEDBS1PARENTCOMPANY,
        cast(WORKEDBS2REGION as VARCHAR(16777216)) as WORKEDBS2REGION,
        cast(WORKEDBS3COUNTRY as VARCHAR(16777216)) as WORKEDBS3COUNTRY,
        cast(WORKEDBS4SUBSIDIARY as VARCHAR(16777216)) as WORKEDBS4SUBSIDIARY,
        cast(WORKEDBS5TELOFFICE as VARCHAR(16777216)) as WORKEDBS5TELOFFICE,
        cast(WORKEDJOB as VARCHAR(16777216)) as WORKEDJOB,
        cast(WORKEDLABORCATEGORY1COSTSTRUCTURE as VARCHAR(16777216)) as WORKEDLABORCATEGORY1COSTSTRUCTURE,
        cast(TRANSACTIONID as NUMBER(38,0)) as TRANSACTIONID,
        cast(APPROVEDBYMANAGER as BOOLEAN) as APPROVEDBYMANAGER,
        cast(PAYCODE as VARCHAR(16777216)) as PAYCODE,
        cast(COMMENTS as VARCHAR(16777216)) as COMMENTS,
        cast(ALLOCATEDHOURSTIMEINSECONDS as NUMBER(38,10)) as ALLOCATEDHOURSTIMEINSECONDS,
        cast(ACTIVITYLEVEL2NAMECUSTOMER as VARCHAR(16777216)) as ACTIVITYLEVEL2NAMECUSTOMER,
        cast(Is_SoftDeleted as VARCHAR(16777216)) as Is_SoftDeleted,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data