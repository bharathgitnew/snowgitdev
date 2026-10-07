/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\PDS_Hourly_Rate__PDSHourlyRate.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\PDSHourlyRate.SQL
-materialized incremental
-alias PDSHourlyRate
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:05 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='PDSHourlyRate',
    unique_key = []
) }}

with source_data as
(
    SELECT
     PDS_Hourly_Rate.Invoice_to_BP AS Invoice_to_BP,
     PDS_Hourly_Rate.Invoice_to_BPID AS Invoice_to_BPID,
     PDS_Hourly_Rate.Paid_Service_Hourly_Rate AS Paid_Service_Hourly_Rate
     FROM {{ ref('ODS__MDM__PDS_HOURLY_RATE') }} PDS_Hourly_Rate
    )
,transform_data as
(
    SELECT
        Invoice_to_BP,
        Invoice_to_BPID,
        Paid_Service_Hourly_Rate
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        -- ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(INVOICE_TO_BP as VARCHAR(16777216)) as INVOICE_TO_BP,
        cast(INVOICE_TO_BPID as VARCHAR(16777216)) as INVOICE_TO_BPID,
        cast(PAID_SERVICE_HOURLY_RATE as NUMBER(38,0)) as PAID_SERVICE_HOURLY_RATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data