/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Paid_Service_Pricing__PaidServicePricing.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\PaidServiceExceptionPricing.SQL
-materialized incremental
-alias PaidServiceExceptionPricing
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='PaidServiceExceptionPricing',
    unique_key = ['Service_Order']
) }}

with source_data as
( 
    SELECT
    Paid_Service_Exception_Pricing.Service_Order AS Service_Order,
    Paid_Service_Exception_Pricing.Description AS Description,
    Paid_Service_Exception_Pricing.Hourly_Rate AS Hourly_Rate,
    Paid_Service_Exception_Pricing.Type AS Type,
    Paid_Service_Exception_Pricing.Program_Year AS Program_Year,
    Paid_Service_Exception_Pricing.BU AS BU,
    Paid_Service_Exception_Pricing.PFP_PO AS PFP_PO,
    Paid_Service_Exception_Pricing.Mapped_SO AS Mapped_SO,
    Paid_Service_Exception_Pricing.Fab AS Fab
    FROM {{ ref('ODS__MDM__PAID_SERVICE_EXCEPTION_PRICING') }} Paid_Service_Exception_Pricing
    )
,transform_data as
(
    SELECT
       Service_Order,
        Description,
        Hourly_Rate,
        Type,
        Program_Year,
        BU,
        PFP_PO,
        Mapped_SO,
        Fab
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(SERVICE_ORDER as VARCHAR(16777216)) as SERVICE_ORDER,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(HOURLY_RATE as NUMBER(38,10)) as HOURLY_RATE,
        cast(TYPE as VARCHAR(16777216)) as TYPE,
        cast(PROGRAM_YEAR as VARCHAR(16777216)) as PROGRAM_YEAR,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(PFP_PO as VARCHAR(16777216)) as PFP_PO,
        cast(MAPPED_SO as VARCHAR(16777216)) as MAPPED_SO,
        cast(FAB as VARCHAR(16777216)) as FAB,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data