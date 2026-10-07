{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='NOW_USER'
) }}


with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        USER_ID,
        EMPLOYEE_NUMBER,
        FIRST_NAME,
        LAST_NAME,
        PHONE,
        PHONE_EXT,
        PAGER,
        PAGER_PIN,
        EMAIL,
        CUSTOMER_PHONE,
        CUSTOMER_PHONE_EXT,
        CUSTOMER_PAGER,
        CUSTOMER_PAGER_PIN,
        PASSWORD,
        ACCOUNT_STATUS_ID,
        ACCOUNT_TYPE_ID,
        CHANGE_PASSWORD,
        LANGUAGE_ID,
        TZ_ID,
        DATE_FORMAT_ID,
        MILITARY_TIME_ID,
        DUMMY_USER,
        LOCK_FLG,
        LOGIN_ERROR_DT,
        LOGIN_ERROR_CNT,
        LAST_UPDATE_USER,
        LAST_UPDATE_DATE
        FROM {{ ref('ODS__NOW__NOW_USER') }}
)

,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        USER_ID,
        EMPLOYEE_NUMBER,
        FIRST_NAME,
        LAST_NAME,
        PHONE,
        PHONE_EXT,
        PAGER,
        PAGER_PIN,
        EMAIL,
        CUSTOMER_PHONE,
        CUSTOMER_PHONE_EXT,
        CUSTOMER_PAGER,
        CUSTOMER_PAGER_PIN,
        PASSWORD,
        ACCOUNT_STATUS_ID,
        ACCOUNT_TYPE_ID,
        CHANGE_PASSWORD,
        LANGUAGE_ID,
        TZ_ID,
        DATE_FORMAT_ID,
        MILITARY_TIME_ID,
        DUMMY_USER,
        LOCK_FLG,
        LOGIN_ERROR_DT,
        LOGIN_ERROR_CNT,
        LAST_UPDATE_USER,
        LAST_UPDATE_DATE
    FROM source_data
),

type_data as (
select
    CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
    CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
    CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    USER_ID,
    EMPLOYEE_NUMBER,
    FIRST_NAME,
    LAST_NAME,
    PHONE,
    PHONE_EXT,
    PAGER,
    PAGER_PIN,
    EMAIL,
    CUSTOMER_PHONE,
    CUSTOMER_PHONE_EXT,
    CUSTOMER_PAGER,
    CUSTOMER_PAGER_PIN,
    PASSWORD,
    ACCOUNT_STATUS_ID,
    ACCOUNT_TYPE_ID,
    CHANGE_PASSWORD,
    LANGUAGE_ID,
    TZ_ID,
    DATE_FORMAT_ID,
    MILITARY_TIME_ID,
    DUMMY_USER,
    LOCK_FLG,
    LOGIN_ERROR_DT,
    LOGIN_ERROR_CNT,
    LAST_UPDATE_USER,
    LAST_UPDATE_DATE
from transform_data
)

select * from type_data