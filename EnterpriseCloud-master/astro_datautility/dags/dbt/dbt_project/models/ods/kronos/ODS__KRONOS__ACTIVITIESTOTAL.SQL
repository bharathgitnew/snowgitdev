{{ config(
    alias = 'ACTIVITIESTOTAL',
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = ['TRANSACTIONID', 'PAYCODE', 'APPLYDATE'],
    post_hook = "
        -- APPLYDATE represents the date of the Kronos activity 
        -- but the files are batched by fiscal quarters (current and previous)
        -- so if there is a newer file for the same quarter, we want to mark the older one as deleted
        delete from {{ this }} as a
        using (
            select
                date_from_parts(year(APPLYDATE), ceil(month(APPLYDATE) / 3) * 3 - 2, 1) as FQ_START,
                max(_FILEDATE) as MAX_FILEDATE
            from {{ this }}
            group by all
        ) as b
        where date_from_parts(year(a.APPLYDATE), ceil(month(a.APPLYDATE) / 3) * 3 - 2, 1) = b.FQ_START
            and a._FILEDATE < b.MAX_FILEDATE
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
        and PAYCODE not in ('US-6th Day Tracking', 'US-Hours Worked 110 Hours') -- filter out paycodes that are used for tracking purposes but dont represent actual work
        and EMPLOYEENUMBER not in ('262626', '262628' , '262629') -- filter out invalid/test employee numbers
        and _FILEDATE >= (select ifnull(max(_FILEDATE), '1900-01-01') from {{ this }})
    QUALIFY (ROW_NUMBER() OVER ( PARTITION BY TransactionID,PayCode,ApplyDate ORDER BY _UPLOADDATE DESC )) = 1 
),

transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.*,
        'No' AS IS_SOFTDELETED, -- this is now a constant column since we are hard deleting records in the post-hook. this column can be removed in the future once there are no dependencies
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