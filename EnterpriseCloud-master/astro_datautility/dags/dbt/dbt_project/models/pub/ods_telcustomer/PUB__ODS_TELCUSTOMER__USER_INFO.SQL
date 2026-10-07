{{ config(
      materialized='view',
      alias='USER_INFO',
      transient=false
) }}

with source_data as (
    SELECT
        USERID,
        USERNAME,
        TEL_REGION,
        BUSINESS_PARTNER_ID,
        EMPLOYER_ID,
        ACCEPT_NDA,
        LAST_ACTIVITY_DATE,
        ACTIVE,
        SALUTATION,
        TITLE,
        DEPT,
        PHONE,
        COUNTRY,
        FULL_KANJI_NAME,
        ACTIVATED,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        CREATED_BY,
        CREATE_DATE,
        UPDATED_BY,
        UPDATE_DATE,
        LAST_CONFIRM_DATE,
        JOB_CATEGORY,
        FAB,
        PRODUCT_LINE
    from {{ ref('ODS__TELCUSTOMER__USER_INFO') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data