/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.38"
*************/

{{ config(
      materialized='view',
      alias='TBL_AD_USERS',
      transient=false
) }}

with source_data as (
    SELECT
        USERNAME,
        USER_DOMAIN,
        FIRST_NAME,
        LAST_NAME,
        NAME,
        DISPLAY_NAME,
        DESCRIPTION,
        OFFICE,
        TELEPHONE,
        FAX,
        MOBILE,
        STREET,
        CITY,
        C,
        ZIP,
        COUNTRY,
        COUNTRY_CODE,
        UPN,
        TITLE,
        DEPARTMENT,
        COMPANY,
        EMAIL,
        OU,
        LAST_CHANGED,
        PICTURE,
        AD_OBJECT_ID,
        MANAGER_AD_OBJECT_ID,
        HOME_PHONE,
        PAGER,
        IP_PHONE,
        STATE,
        HOME_PAGE,
        HOME_DIRECTORY,
        PROFILE_PATH,
        LOGON_SCRIPT,
        WHEN_CREATED,
        WHEN_CHANGED,
        EMPLOYEE_ID,
        EMPLOYEE_NUMBER,
        EMPLOYEE_TYPE,
        INFO,
        DIVISION,
        ADUSER_ID,
        IS_ENABLED,
        EXPIRATION_DATE,
        LOCKOUT_DATE,
        PASSWORD_NEVER_EXPIRES,
        PASSWORD_LAST_SET,
        USER_CANNOT_CHANGE_PASSWORD,
        PASSWORD_REQUIRED,
        PASSWORD_EXPIRATION_DATE,
        PASSWORD_CHANGEABLE_DATE,
        INITIALS,
        MIDDLE_NAME,
        POST_OFFICE_BOX,
        LAST_LOGON,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TBL_AD_USERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data