/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TBL_AD_USERS__Lansweeper_tblADusers.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TBL_AD_USERS.SQL 
-materialized incremental
-alias TBL_AD_USERS 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema LANSWEEPER
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/12/2022 9:15:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TBL_AD_USERS',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"Username"::STRING AS Username 
        ,JSONFIELD:"Userdomain"::STRING AS User_domain 
        ,JSONFIELD:"Firstname"::STRING AS First_name 
        ,JSONFIELD:"Lastname"::STRING AS Last_name 
        ,JSONFIELD:"Name"::STRING AS Name 
        ,JSONFIELD:"Displayname"::STRING AS Display_name 
        ,JSONFIELD:"Description"::STRING AS Description 
        ,JSONFIELD:"Office"::STRING AS Office 
        ,JSONFIELD:"Telephone"::STRING AS Telephone 
        ,JSONFIELD:"Fax"::STRING AS Fax 
        ,JSONFIELD:"Mobile"::STRING AS Mobile 
        ,JSONFIELD:"Street"::STRING AS Street 
        ,JSONFIELD:"City"::STRING AS City 
        ,JSONFIELD:"C"::STRING AS C 
        ,JSONFIELD:"Zip"::STRING AS Zip 
        ,JSONFIELD:"Country"::STRING AS Country 
        ,JSONFIELD:"Countrycode"::STRING AS Country_code 
        ,JSONFIELD:"UPN"::STRING AS UPN 
        ,JSONFIELD:"Title"::STRING AS Title 
        ,JSONFIELD:"Department"::STRING AS Department 
        ,JSONFIELD:"Company"::STRING AS Company 
        ,JSONFIELD:"email"::STRING AS email 
        ,JSONFIELD:"OU"::STRING AS OU 
        ,REGEXP_REPLACE(JSONFIELD:"Lastchanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_changed 
        ,JSONFIELD:"Picture"::STRING AS Picture 
        ,JSONFIELD:"ADObjectID"::NUMBER AS AD_Object_ID 
        ,JSONFIELD:"ManagerADObjectId"::NUMBER AS Manager_AD_Object_Id 
        ,JSONFIELD:"HomePhone"::STRING AS Home_Phone 
        ,JSONFIELD:"Pager"::STRING AS Pager 
        ,JSONFIELD:"IpPhone"::STRING AS Ip_Phone 
        ,JSONFIELD:"State"::STRING AS State 
        ,JSONFIELD:"HomePage"::STRING AS Home_Page 
        ,JSONFIELD:"HomeDirectory"::STRING AS Home_Directory 
        ,JSONFIELD:"ProfilePath"::STRING AS Profile_Path 
        ,JSONFIELD:"LogonScript"::STRING AS Logon_Script 
        ,REGEXP_REPLACE(JSONFIELD:"whenCreated", '\/Date\\(|\\)\/', '')::TIMESTAMP AS when_Created 
        ,REGEXP_REPLACE(JSONFIELD:"whenChanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS when_Changed 
        ,JSONFIELD:"EmployeeID"::STRING AS Employee_ID 
        ,JSONFIELD:"EmployeeNumber"::STRING AS Employee_Number 
        ,JSONFIELD:"EmployeeType"::STRING AS Employee_Type 
        ,JSONFIELD:"Info"::STRING AS Info 
        ,JSONFIELD:"Division"::STRING AS Division 
        ,JSONFIELD:"ADUserID"::NUMBER AS ADUser_ID 
        ,JSONFIELD:"IsEnabled"::NUMBER AS Is_Enabled 
        ,REGEXP_REPLACE(JSONFIELD:"ExpirationDate", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Expiration_Date 
        ,REGEXP_REPLACE(JSONFIELD:"LockoutDate", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Lockout_Date 
        ,JSONFIELD:"PasswordNeverExpires"::NUMBER AS Password_Never_Expires 
        ,REGEXP_REPLACE(JSONFIELD:"PasswordLastSet", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Password_Last_Set 
        ,JSONFIELD:"UserCannotChangePassword"::NUMBER AS User_Cannot_Change_Password 
        ,JSONFIELD:"PasswordRequired"::NUMBER AS Password_Required 
        ,REGEXP_REPLACE(JSONFIELD:"PasswordExpirationDate", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Password_Expiration_Date 
        ,REGEXP_REPLACE(JSONFIELD:"PasswordChangeableDate", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Password_Changeable_Date 
        ,JSONFIELD:"Initials"::STRING AS Initials 
        ,JSONFIELD:"MiddleName"::STRING AS Middle_Name 
        ,JSONFIELD:"PostOfficeBox"::STRING AS Post_Office_Box 
        ,REGEXP_REPLACE(JSONFIELD:"LastLogon", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Logon 
        FROM {{ source("LANSWEEPER", "TBLADUSERS") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TBLADUSERS") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.ADUSER_ID, 
        source_data.AD_OBJECT_ID, 
        source_data.C, 
        source_data.CITY, 
        source_data.COMPANY, 
        source_data.COUNTRY, 
        source_data.COUNTRY_CODE, 
        source_data.DEPARTMENT, 
        source_data.DESCRIPTION, 
        source_data.DISPLAY_NAME, 
        source_data.DIVISION, 
        source_data.EMAIL, 
        source_data.EMPLOYEE_ID, 
        source_data.EMPLOYEE_NUMBER, 
        source_data.EMPLOYEE_TYPE, 
        source_data.EXPIRATION_DATE, 
        source_data.FAX, 
        source_data.FIRST_NAME, 
        source_data.HOME_DIRECTORY, 
        source_data.HOME_PAGE, 
        source_data.HOME_PHONE, 
        source_data.INFO, 
        source_data.INITIALS, 
        source_data.IP_PHONE, 
        source_data.IS_ENABLED, 
        source_data.LAST_CHANGED, 
        source_data.LAST_LOGON, 
        source_data.LAST_NAME, 
        source_data.LOCKOUT_DATE, 
        source_data.LOGON_SCRIPT, 
        source_data.MANAGER_AD_OBJECT_ID, 
        source_data.MIDDLE_NAME, 
        source_data.MOBILE, 
        source_data.NAME, 
        source_data.OFFICE, 
        source_data.OU, 
        source_data.PAGER, 
        source_data.PASSWORD_CHANGEABLE_DATE, 
        source_data.PASSWORD_EXPIRATION_DATE, 
        source_data.PASSWORD_LAST_SET, 
        source_data.PASSWORD_NEVER_EXPIRES, 
        source_data.PASSWORD_REQUIRED, 
        source_data.PICTURE, 
        source_data.POST_OFFICE_BOX, 
        source_data.PROFILE_PATH, 
        source_data.STATE, 
        source_data.STREET, 
        source_data.TELEPHONE, 
        source_data.TITLE, 
        source_data.UPN, 
        source_data.USERNAME, 
        source_data.USER_CANNOT_CHANGE_PASSWORD, 
        source_data.USER_DOMAIN, 
        source_data.WHEN_CHANGED, 
        source_data.WHEN_CREATED, 
        source_data.ZIP, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(USERNAME as VARCHAR(16777216)) as USERNAME,
        cast(USER_DOMAIN as VARCHAR(16777216)) as USER_DOMAIN,
        cast(FIRST_NAME as VARCHAR(16777216)) as FIRST_NAME,
        cast(LAST_NAME as VARCHAR(16777216)) as LAST_NAME,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(DISPLAY_NAME as VARCHAR(16777216)) as DISPLAY_NAME,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(OFFICE as VARCHAR(16777216)) as OFFICE,
        cast(TELEPHONE as VARCHAR(16777216)) as TELEPHONE,
        cast(FAX as VARCHAR(16777216)) as FAX,
        cast(MOBILE as VARCHAR(16777216)) as MOBILE,
        cast(STREET as VARCHAR(16777216)) as STREET,
        cast(CITY as VARCHAR(16777216)) as CITY,
        cast(C as VARCHAR(16777216)) as C,
        cast(ZIP as VARCHAR(16777216)) as ZIP,
        cast(COUNTRY as VARCHAR(16777216)) as COUNTRY,
        cast(COUNTRY_CODE as VARCHAR(16777216)) as COUNTRY_CODE,
        cast(UPN as VARCHAR(16777216)) as UPN,
        cast(TITLE as VARCHAR(16777216)) as TITLE,
        cast(DEPARTMENT as VARCHAR(16777216)) as DEPARTMENT,
        cast(COMPANY as VARCHAR(16777216)) as COMPANY,
        cast(EMAIL as VARCHAR(16777216)) as EMAIL,
        cast(OU as VARCHAR(16777216)) as OU,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(PICTURE as VARCHAR(16777216)) as PICTURE,
        cast(AD_OBJECT_ID as NUMBER(38,0)) as AD_OBJECT_ID,
        cast(MANAGER_AD_OBJECT_ID as NUMBER(38,0)) as MANAGER_AD_OBJECT_ID,
        cast(HOME_PHONE as VARCHAR(16777216)) as HOME_PHONE,
        cast(PAGER as VARCHAR(16777216)) as PAGER,
        cast(IP_PHONE as VARCHAR(16777216)) as IP_PHONE,
        cast(STATE as VARCHAR(16777216)) as STATE,
        cast(HOME_PAGE as VARCHAR(16777216)) as HOME_PAGE,
        cast(HOME_DIRECTORY as VARCHAR(16777216)) as HOME_DIRECTORY,
        cast(PROFILE_PATH as VARCHAR(16777216)) as PROFILE_PATH,
        cast(LOGON_SCRIPT as VARCHAR(16777216)) as LOGON_SCRIPT,
        cast(WHEN_CREATED as TIMESTAMP_NTZ(9)) as WHEN_CREATED,
        cast(WHEN_CHANGED as TIMESTAMP_NTZ(9)) as WHEN_CHANGED,
        cast(EMPLOYEE_ID as VARCHAR(16777216)) as EMPLOYEE_ID,
        cast(EMPLOYEE_NUMBER as VARCHAR(16777216)) as EMPLOYEE_NUMBER,
        cast(EMPLOYEE_TYPE as VARCHAR(16777216)) as EMPLOYEE_TYPE,
        cast(INFO as VARCHAR(16777216)) as INFO,
        cast(DIVISION as VARCHAR(16777216)) as DIVISION,
        cast(ADUSER_ID as NUMBER(38,0)) as ADUSER_ID,
        cast(IS_ENABLED as NUMBER(38,0)) as IS_ENABLED,
        cast(EXPIRATION_DATE as TIMESTAMP_NTZ(9)) as EXPIRATION_DATE,
        cast(LOCKOUT_DATE as TIMESTAMP_NTZ(9)) as LOCKOUT_DATE,
        cast(PASSWORD_NEVER_EXPIRES as NUMBER(38,0)) as PASSWORD_NEVER_EXPIRES,
        cast(PASSWORD_LAST_SET as TIMESTAMP_NTZ(9)) as PASSWORD_LAST_SET,
        cast(USER_CANNOT_CHANGE_PASSWORD as NUMBER(38,0)) as USER_CANNOT_CHANGE_PASSWORD,
        cast(PASSWORD_REQUIRED as NUMBER(38,0)) as PASSWORD_REQUIRED,
        cast(PASSWORD_EXPIRATION_DATE as TIMESTAMP_NTZ(9)) as PASSWORD_EXPIRATION_DATE,
        cast(PASSWORD_CHANGEABLE_DATE as TIMESTAMP_NTZ(9)) as PASSWORD_CHANGEABLE_DATE,
        cast(INITIALS as VARCHAR(16777216)) as INITIALS,
        cast(MIDDLE_NAME as VARCHAR(16777216)) as MIDDLE_NAME,
        cast(POST_OFFICE_BOX as VARCHAR(16777216)) as POST_OFFICE_BOX,
        cast(LAST_LOGON as TIMESTAMP_NTZ(9)) as LAST_LOGON,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data