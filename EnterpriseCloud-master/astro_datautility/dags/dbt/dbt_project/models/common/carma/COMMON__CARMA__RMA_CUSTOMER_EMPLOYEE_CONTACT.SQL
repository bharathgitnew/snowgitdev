/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-Carma\RMA_Intermediate.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\carma\RMA_Intermediate.SQL
-materialized incremental
-alias RMA_Intermediate
-incremental_strategy insert_overwrite
-envVariable <<ODS>>
-sourceSchema CARMA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 1/25/2022 3:06:11 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='RMA_CUSTOMER_EMPLOYEE_CONTACT',
    unique_key = []
) }}

with source_data as
(
   SELECT DISTINCT
    Qry_RMA_CustomerPrimary.CUSTOMER_PRIMARY_CONTACT,
    Qry_RMA_CustomerPrimaryEmail.CUSTOMER_PRIMARY_EMAIL,
    Qry_RMA_CustomerSecondary.CUSTOMER_SECONDARY_CONTACT,
    Qry_RMA_CustomerSecondaryEmail.CUSTOMER_SECONDARY_EMAIL,
    Qry_RMA_EmployeePrimary.EMPLOYEE_PRIMARY_CONTACT,
    Qry_RMA_EmployeeSecondary.EMPLOYEE_SECONDARY_CONTACT,
    RMA_CONTACT.REQUEST_SALES_ID
    FROM
    {{ ref('ODS__CARMA__RMA_CONTACT') }} RMA_CONTACT
    LEFT OUTER JOIN (
    SELECT DISTINCT CONCAT(first_name, ' ', last_name) AS customer_primary_contact, request_sales_id
    FROM {{ ref('ODS__CARMA__RMA_CONTACT') }}
    WHERE rma_contact_type_id = 1
    AND active = 1
    ) Qry_RMA_CustomerPrimary ON Qry_RMA_CustomerPrimary.REQUEST_SALES_ID = RMA_CONTACT.REQUEST_SALES_ID
    LEFT OUTER JOIN (
    SELECT DISTINCT email as Customer_Primary_Email, request_sales_id
    FROM {{ ref('ODS__CARMA__RMA_CONTACT') }}
    WHERE 1=1
    AND rma_contact_type_id = 1
    AND active = 1
    ) Qry_RMA_CustomerPrimaryEmail ON Qry_RMA_CustomerPrimaryEmail.REQUEST_SALES_ID = RMA_CONTACT.REQUEST_SALES_ID
    LEFT OUTER JOIN (
    SELECT DISTINCT CONCAT(first_name, ' ', last_name) AS customer_secondary_contact, request_sales_id
    FROM {{ ref('ODS__CARMA__RMA_CONTACT') }}
    WHERE 1=1
    AND rma_contact_type_id = 2
    AND active = 1
    ) Qry_RMA_CustomerSecondary ON Qry_RMA_CustomerSecondary.REQUEST_SALES_ID = RMA_CONTACT.REQUEST_SALES_ID
    LEFT OUTER JOIN (
    SELECT DISTINCT email as Customer_Secondary_Email, request_sales_id
    FROM {{ ref('ODS__CARMA__RMA_CONTACT') }}
    WHERE 1=1
    AND rma_contact_type_id = 2
    AND active = 1
    ) Qry_RMA_CustomerSecondaryEmail ON Qry_RMA_CustomerSecondaryEmail.REQUEST_SALES_ID = RMA_CONTACT.REQUEST_SALES_ID
    LEFT OUTER JOIN (
    SELECT DISTINCT employee_id as employee_primary_contact, request_sales_id
    FROM {{ ref('ODS__CARMA__RMA_CONTACT') }}
    WHERE 1=1
    AND rma_contact_type_id = 3
    AND active = 1
    ) Qry_RMA_EmployeePrimary ON Qry_RMA_EmployeePrimary.REQUEST_SALES_ID = RMA_CONTACT.REQUEST_SALES_ID
    LEFT OUTER JOIN (
    SELECT DISTINCT employee_id as employee_secondary_contact, request_sales_id
    FROM {{ ref('ODS__CARMA__RMA_CONTACT') }}
    WHERE 1=1
    AND rma_contact_type_id = 4
    AND active = 1
    ) Qry_RMA_EmployeeSecondary ON Qry_RMA_EmployeeSecondary.REQUEST_SALES_ID = RMA_CONTACT.REQUEST_SALES_ID
    WHERE  RMA_CONTACT.ACTIVE = 1
        )
,transform_data as
(
    SELECT DISTINCT
    CUSTOMER_PRIMARY_CONTACT,
    CUSTOMER_PRIMARY_EMAIL,
    CUSTOMER_SECONDARY_CONTACT,
    CUSTOMER_SECONDARY_EMAIL,
    EMPLOYEE_PRIMARY_CONTACT,
    EMPLOYEE_SECONDARY_CONTACT,
    REQUEST_SALES_ID,
    '{{ invocation_id }}' AS AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh. 
    FROM source_data
        )
,type_data as 
(
    select
        cast(REQUEST_SALES_ID as NUMBER(38,0)) as REQUEST_SALES_ID,
        cast(CUSTOMER_PRIMARY_CONTACT as VARCHAR(16777216)) as CUSTOMER_PRIMARY_CONTACT,
        cast(CUSTOMER_PRIMARY_EMAIL as VARCHAR(16777216)) as CUSTOMER_PRIMARY_EMAIL,
        cast(CUSTOMER_SECONDARY_CONTACT as VARCHAR(16777216)) as CUSTOMER_SECONDARY_CONTACT,
        cast(CUSTOMER_SECONDARY_EMAIL as VARCHAR(16777216)) as CUSTOMER_SECONDARY_EMAIL,
        cast(EMPLOYEE_PRIMARY_CONTACT as VARCHAR(16777216)) as EMPLOYEE_PRIMARY_CONTACT,
        cast(EMPLOYEE_SECONDARY_CONTACT as VARCHAR(16777216)) as EMPLOYEE_SECONDARY_CONTACT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data