/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Machines_S2B_Integration_Latest_Record.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\Machines_S2B_Integration_Latest_Record.SQL
-materialized incremental
-alias Machines_S2B_Integration_Latest_Record
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
    alias='Machines_S2B_Integration_Latest_Record',
    unique_key = ['TRANSACTION_ID']
) }}

with source_data as
( SELECT
    MachinesS2BIntegrationLatestRecord.AcceptanceComment AS ACCEPTANCE_COMMENT,
    MachinesS2BIntegrationLatestRecord.ClusterFlag AS CLUSTER_FLAG,
    MachinesS2BIntegrationLatestRecord.FirstIntegration AS FIRST_INTEGRATION,
    MachinesS2BIntegrationLatestRecord.LatestTransactionDate AS LATEST_TRANSACTION_DATE,
    MachinesS2BIntegrationLatestRecord.RevenueMethodCode AS REVENUE_METHOD_CODE,
    MachinesS2BIntegrationLatestRecord.RevenueMethodDescription AS REVENUE_METHOD_DESCRIPTION,
    MachinesS2BIntegrationLatestRecord.SN AS SN,
    MachinesS2BIntegrationLatestRecord.SupplierCode AS SUPPLIER_CODE,
    MachinesS2BIntegrationLatestRecord.TableRefreshDate AS TABLE_REFRESH_DATE,
    MachinesS2BIntegrationLatestRecord.TransactionID AS TRANSACTION_ID
FROM {{ ref('ODS__MDM__MACHINESS2BINTEGRATIONLATESTRECORD') }} MachinesS2BIntegrationLatestRecord
    )
,transform_data as
(
    SELECT
        ACCEPTANCE_COMMENT,
        CLUSTER_FLAG,
        FIRST_INTEGRATION,
        LATEST_TRANSACTION_DATE,
        REVENUE_METHOD_CODE,
        REVENUE_METHOD_DESCRIPTION,
        SN,
        SUPPLIER_CODE,
        TABLE_REFRESH_DATE,
        TRANSACTION_ID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(ACCEPTANCE_COMMENT as VARCHAR(16777216)) as ACCEPTANCE_COMMENT,
        cast(CLUSTER_FLAG as VARCHAR(16777216)) as CLUSTER_FLAG,
        cast(FIRST_INTEGRATION as TIMESTAMP_NTZ(9)) as FIRST_INTEGRATION,
        cast(LATEST_TRANSACTION_DATE as TIMESTAMP_NTZ(9)) as LATEST_TRANSACTION_DATE,
        cast(REVENUE_METHOD_CODE as VARCHAR(16777216)) as REVENUE_METHOD_CODE,
        cast(REVENUE_METHOD_DESCRIPTION as VARCHAR(16777216)) as REVENUE_METHOD_DESCRIPTION,
        cast(SN as VARCHAR(16777216)) as SN,
        cast(SUPPLIER_CODE as VARCHAR(16777216)) as SUPPLIER_CODE,
        cast(TABLE_REFRESH_DATE as TIMESTAMP_NTZ(9)) as TABLE_REFRESH_DATE,
        cast(TRANSACTION_ID as NUMBER(38,0)) as TRANSACTION_ID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data