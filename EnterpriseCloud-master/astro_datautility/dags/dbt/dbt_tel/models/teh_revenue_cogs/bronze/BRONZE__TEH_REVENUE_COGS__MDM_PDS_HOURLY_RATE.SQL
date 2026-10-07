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
        _FILEDATE,
		_FILENAME,
        jsonfield:"Invoice to BP"::VARCHAR AS Invoice_to_BP, 
        jsonfield:"Invoice to BPID"::VARCHAR AS Invoice_to_BPID,	 
        jsonfield:"Paid Service Hourly Rate"::NUMBER AS Paid_Service_Hourly_Rate 
        FROM {{ source("MDM", "PDS_HOURLY_RATE") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "PDS_HOURLY_RATE") }}) 
        )
,transform_data as
(
    SELECT 
        _FILEDATE,
		_FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.INVOICE_TO_BP AS Invoice_to_BP, 
        source_data.INVOICE_TO_BPID AS Invoice_to_BPID, 
        source_data.PAID_SERVICE_HOURLY_RATE AS Paid_Service_Hourly_Rate        
        FROM source_data
        )
,type_data as 
(
    select
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(INVOICE_TO_BP as VARCHAR(16777216)) as INVOICE_TO_BP,
        cast(INVOICE_TO_BPID as VARCHAR(16777216)) as INVOICE_TO_BPID,
        cast(PAID_SERVICE_HOURLY_RATE as NUMBER(38,0)) as PAID_SERVICE_HOURLY_RATE        
    from transform_data
    )
select * from type_data