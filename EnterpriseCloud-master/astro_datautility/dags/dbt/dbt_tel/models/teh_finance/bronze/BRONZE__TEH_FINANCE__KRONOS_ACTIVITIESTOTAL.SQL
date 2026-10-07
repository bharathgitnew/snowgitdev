{{ config(
    alias='KRONOS_ACTIVITIESTOTAL',
    materialized='tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['TRANSACTIONID', 'PAYCODE', 'APPLYDATE'],
    post_hook = "
        update {{ this }} set IS_SOFTDELETED = 'Yes' 
        where IS_SOFTDELETED = 'No' -- if its already deleted, we don't want to accidentally mark it as active
            and datediff( -- check if this is a recent record that should appear in a recent file. old records will stop receiving updates after two quarters
                'months',
                date_from_parts(year(APPLYDATE), ceil(month(APPLYDATE) / 3) * 3 - 2, 1), -- formats APPLYDATE to the first day of its fiscal quarter
                date_from_parts(year(current_date()), ceil(month(current_date()) / 3) * 3 - 2, 1) -- formats current date to the first day of its fiscal quarter
            ) <= 3 -- check if the rounded APPLYDATE falls within the current range
            and _FILEDATE::date != (select max(_FILEDATE)::date from {{ this }}) -- if so, it should appear in the latest file, otherwise it was deleted
    ",
) }}


with source_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        lpad(EMPLOYEENUMBER, 6, '0') as EMPLOYEENUMBER,
        ACTIVITYLEVEL1NAMEMAINCATEGORY,
        ACTIVITYLEVEL1NAMESUBCATEGORY,
        ACTIVITYLEVEL2NAMECUSTOMER,
        ACTIVITYLEVEL2NAMEBU,
        ACTIVITYLEVEL2NAMESERIALNO,
        ACTIVITYLEVEL3NAMESERVICEORDER,
        ACTIVITYLEVEL3NAMEINSTALLATIONID,
        ACTIVITYLEVEL4NAMETASK,
        APPLYDATE,
        UPDATEDATETIME,
        ADJUSTEDSTARTDATETIME,
        ADJUSTEDENDDATETIME,
        ALLOCATEDHOURSTIMEINSECONDS,
        WORKRULE,
        USERDEFINEDFIELD1,
        USERDEFINEDFIELD2,
        USERDEFINEDFIELD3,
        USERDEFINEDFIELD4,
        WORKREGION,
        RESOURCEREGION,
        TIMEPUNCHID,
        PARENTCOMPANY,
        HOMEBS2REGION,
        HOMEBS3COUNTRY,
        HOMEBS4SUBSIDIARY,
        HOMEBS5TELOFFICE,
        HOMEJOB,
        HOMELABORCATEGORY1COSTSTRUCTURE,
        WORKEDBS1PARENTCOMPANY,
        WORKEDBS2REGION,
        WORKEDBS3COUNTRY,
        WORKEDBS4SUBSIDIARY,
        WORKEDBS5TELOFFICE,
        WORKEDJOB,
        WORKEDLABORCATEGORY1COSTSTRUCTURE,
        TRANSACTIONID,
        APPROVEDBYMANAGER,
        PAYCODE,
        COMMENTS,
    FROM {{ source("KRONOS", "ACTIVITIESTOTAL") }}
    WHERE HomeBS2Region = 'Americas'
        and _FILEDATE >= (select ifnull(max(_FILEDATE), '1900-01-01') from {{ this }})
    QUALIFY (ROW_NUMBER() OVER ( PARTITION BY TransactionID,PayCode,ApplyDate ORDER BY _UPLOADDATE DESC )) = 1 
),

transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.*,
        'No' AS IS_SOFTDELETED,
    FROM source_data
),

type_data as (
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        EMPLOYEENUMBER,
        ACTIVITYLEVEL1NAMEMAINCATEGORY,
        ACTIVITYLEVEL1NAMESUBCATEGORY,
        ACTIVITYLEVEL2NAMEBU,
        ACTIVITYLEVEL2NAMESERIALNO,
        ACTIVITYLEVEL3NAMESERVICEORDER,
        ACTIVITYLEVEL3NAMEINSTALLATIONID,
        ACTIVITYLEVEL4NAMETASK,
        cast(APPLYDATE as DATE) as APPLYDATE,
        cast(UPDATEDATETIME as TIMESTAMP_NTZ(9)) as UPDATEDATETIME,
        cast(ADJUSTEDSTARTDATETIME as TIMESTAMP_NTZ(9)) as ADJUSTEDSTARTDATETIME,
        cast(ADJUSTEDENDDATETIME as TIMESTAMP_NTZ(9)) as ADJUSTEDENDDATETIME,
        WORKRULE,
        USERDEFINEDFIELD1,
        USERDEFINEDFIELD2,
        USERDEFINEDFIELD3,
        USERDEFINEDFIELD4,
        WORKREGION,
        RESOURCEREGION,
        TIMEPUNCHID,
        PARENTCOMPANY,
        HOMEBS2REGION,
        HOMEBS3COUNTRY,
        HOMEBS4SUBSIDIARY,
        HOMEBS5TELOFFICE,
        HOMEJOB,
        HOMELABORCATEGORY1COSTSTRUCTURE,
        WORKEDBS1PARENTCOMPANY,
        WORKEDBS2REGION,
        WORKEDBS3COUNTRY,
        WORKEDBS4SUBSIDIARY,
        WORKEDBS5TELOFFICE,
        WORKEDJOB,
        WORKEDLABORCATEGORY1COSTSTRUCTURE,
        cast(TRANSACTIONID as NUMBER(38,0)) as TRANSACTIONID,
        cast(APPROVEDBYMANAGER as BOOLEAN) as APPROVEDBYMANAGER,
        PAYCODE,
        COMMENTS,
        cast(ALLOCATEDHOURSTIMEINSECONDS as NUMBER(38,10)) as ALLOCATEDHOURSTIMEINSECONDS,
        ACTIVITYLEVEL2NAMECUSTOMER,
        IS_SOFTDELETED,
    from transform_data
)

select * from type_data

