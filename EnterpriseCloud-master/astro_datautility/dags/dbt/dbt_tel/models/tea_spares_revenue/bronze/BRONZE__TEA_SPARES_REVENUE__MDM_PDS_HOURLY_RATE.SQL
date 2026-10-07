/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\PDS_Hourly_Rate__MDM_PDS_Hourly_Rate.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\PDS_Hourly_Rate.SQL 
-materialized incremental
-alias PDS_Hourly_Rate 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_PDS_HOURLY_RATE',
    unique_key = ['Invoice_to_BPID']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"Invoice to BP"::VARCHAR AS Invoice_to_BP, 
        jsonfield:"Invoice to BPID"::VARCHAR AS Invoice_to_BPID,	 
        jsonfield:"Paid Service Hourly Rate"::NUMBER AS Paid_Service_Hourly_Rate 
        FROM {{ source("MDM", "PDS_HOURLY_RATE") }} 
        WHERE _FileDate = (SELECT COALESCE(MAX(_FileDate),'1900-01-01') FROM {{ source("MDM", "PDS_HOURLY_RATE") }}) 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data.INVOICE_TO_BP AS Invoice_to_BP, 
        source_data.INVOICE_TO_BPID AS Invoice_to_BPID, 
        source_data.PAID_SERVICE_HOURLY_RATE AS Paid_Service_Hourly_Rate
        FROM source_data
        )
,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        INVOICE_TO_BP,
        INVOICE_TO_BPID,
        cast(PAID_SERVICE_HOURLY_RATE as NUMBER(38,0)) as PAID_SERVICE_HOURLY_RATE
    from transform_data
    )
select * from type_data