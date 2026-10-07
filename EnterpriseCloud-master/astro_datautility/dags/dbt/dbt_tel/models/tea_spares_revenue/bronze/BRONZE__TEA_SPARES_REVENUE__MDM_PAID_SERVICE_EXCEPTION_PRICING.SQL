/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Paid_Service_Pricing__MDM_Paid_Service_Pricing.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Paid_Service_Exception_Pricing.SQL 
-materialized incremental
-alias Paid_Service_Exception_Pricing 
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
    alias='MDM_PAID_SERVICE_EXCEPTION_PRICING',
    unique_key = ['Service_Order']
) }}


with source_data as 
(
    SELECT  
        jsonfield:"Service Order"::VARCHAR AS Service_Order, 
        jsonfield:"Description"::VARCHAR AS Description, 
        jsonfield:"Hourly Rate"::NUMBER AS Hourly_Rate, 
        jsonfield:"Type"::VARCHAR AS Type, 
        jsonfield:"Program Year"::VARCHAR AS Program_Year, 
        jsonfield:"BU"::VARCHAR AS BU, 
        jsonfield:"PFP PO"::VARCHAR AS PFP_PO, 
        jsonfield:"Mapped SO"::VARCHAR AS Mapped_SO, 
        jsonfield:"Fab"::VARCHAR AS Fab 
        FROM {{ source("MDM", "PAID_SERVICE_EXCEPTION_PRICING") }} 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data.SERVICE_ORDER AS Service_Order, 
        source_data.DESCRIPTION AS Description, 
        source_data.HOURLY_RATE AS Hourly_Rate, 
        source_data.TYPE AS Type, 
        source_data.PROGRAM_YEAR AS Program_Year, 
        source_data.BU AS BU, 
        source_data.PFP_PO AS PFP_PO, 
        source_data.MAPPED_SO AS Mapped_SO, 
        source_data.FAB AS Fab
        FROM source_data
        )
,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        SERVICE_ORDER,
        DESCRIPTION,
        cast(HOURLY_RATE as NUMBER(38,10)) as HOURLY_RATE,
        TYPE,
        PROGRAM_YEAR,
        BU,
        PFP_PO,
        MAPPED_SO,
        FAB
    from transform_data
    )
select * from type_data