/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.27"
*************/

{{ config(
      materialized='view',
      alias='PERSON',
      transient=false
) }}

with source_data as (
    SELECT
        PERSON_ID,
        ROLE_ID,
        TEL_SUBSIDIARY_ID,
        BU_ID,
        EMPLOYEE_NUMBER,
        FIRST_NAME,
        LAST_NAME,
        DEPARTMENT,
        SEGMENT,
        OFFICE,
        EMAIL_ADDRESS,
        PHONE,
        SUPERVISOR_FIRST_NAME,
        SUPERVISOR_LAST_NAME,
        SUPERVISOR_EMAIL_ADDRESS,
        USERNAME,
        PASSWORD,
        INACTIVE_DATE,
        CREATED_DATE,
        MODIFIED_DATE,
        IS_ACTIVE--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__PERSON') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data