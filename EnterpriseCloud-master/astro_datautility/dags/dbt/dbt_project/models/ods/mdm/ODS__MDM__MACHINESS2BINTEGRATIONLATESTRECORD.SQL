/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\MachinesIntegrationLatest__MDM_MachineIntegration.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\MachinesS2BIntegrationLatest.SQL 
-materialized incremental
-alias MachinesS2BIntegrationLatest 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='MachinesS2BIntegrationLatestRecord',
    unique_key = ['TransactionID']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"Latest Trans Dt"::VARCHAR AS LatestTransDate, 
        jsonfield:"Trans ID"::NUMBER AS TransactionID, 
        jsonfield:"BU"::VARCHAR AS BU, 
        jsonfield:"SN"::VARCHAR AS SN, 
        jsonfield:"SWLH Model"::VARCHAR AS SWLHModel, 
        jsonfield:"MPI Model Name"::VARCHAR AS MPIModelName, 
        jsonfield:"TEL Model Code"::VARCHAR AS TELModelCode, 
        jsonfield:"TEL Model Name"::VARCHAR AS TELModelName, 
        jsonfield:"Supplier Code"::VARCHAR AS SupplierCode, 
        jsonfield:"Revenue Method Code"::VARCHAR AS RevenueMethodCode, 
        jsonfield:"Revenue Method Desc"::VARCHAR AS RevenueMethodDescription, 
        jsonfield:"Cluster Flag"::VARCHAR AS ClusterFlag, 
        jsonfield:"Machine Module Type"::VARCHAR AS MachineModuleType, 
        jsonfield:"Parent SN"::VARCHAR AS ParentSerialNumber, 
        jsonfield:"Chamber Install Position"::VARCHAR AS ChamberInstallPosition, 
        jsonfield:"Customer Tool ID"::VARCHAR AS CustomerToolID, 
        jsonfield:"Wafer Size"::VARCHAR AS WaferSize, 
        jsonfield:"Table Refresh Date"::VARCHAR AS TableRefreshDate, 
        jsonfield:"Acceptance Comment"::VARCHAR AS AcceptanceComment, 
        jsonfield:"TEL Sales Order"::VARCHAR AS TELSalesOrder, 
        jsonfield:"Wisdom System Name"::VARCHAR AS WisdomSystemName, 
        jsonfield:"First Integration"::VARCHAR AS FirstIntegration 
        FROM {{ source("MDM", "MACHINESS2BINTEGRATIONLATESTRECORD") }} 
        )
,transform_data as
(
    SELECT 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.LATESTTRANSDATE , '/Date(' , '' ) , ')/' , '' ) ) AS LatestTransactionDate, 
        source_data.TRANSACTIONID AS TransactionID, 
        source_data.BU AS BU, 
        source_data.SN AS SN, 
        source_data.SWLHMODEL AS SWLHModel, 
        source_data.MPIMODELNAME AS MPIModelName, 
        source_data.TELMODELCODE AS TELModelCode, 
        source_data.TELMODELNAME AS TELModelName, 
        source_data.SUPPLIERCODE AS SupplierCode, 
        source_data.REVENUEMETHODCODE AS RevenueMethodCode, 
        source_data.REVENUEMETHODDESCRIPTION AS RevenueMethodDescription, 
        source_data.CLUSTERFLAG AS ClusterFlag, 
        source_data.MACHINEMODULETYPE AS MachineModuleType, 
        source_data.PARENTSERIALNUMBER AS ParentSerialNumber, 
        source_data.CHAMBERINSTALLPOSITION AS ChamberInstallPosition, 
        source_data.CUSTOMERTOOLID AS CustomerToolID, 
        source_data.WAFERSIZE AS WaferSize, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.TABLEREFRESHDATE , '/Date(' , '' ) , ')/' , '' ) ) AS TableRefreshDate, 
        source_data.ACCEPTANCECOMMENT AS AcceptanceComment, 
        source_data.TELSALESORDER AS TELSalesOrder, 
        source_data.WISDOMSYSTEMNAME AS WisdomSystemName, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.FIRSTINTEGRATION , '/Date(' , '' ) , ')/' , '' ) ) AS FirstIntegration, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(LATESTTRANSACTIONDATE as TIMESTAMP_NTZ(9)) as LATESTTRANSACTIONDATE,
        cast(TRANSACTIONID as NUMBER(38,0)) as TRANSACTIONID,
        cast(BU as VARCHAR(1677216)) as BU,
        cast(SN as VARCHAR(16777216)) as SN,
        cast(SWLHMODEL as VARCHAR(16777216)) as SWLHMODEL,
        cast(MPIMODELNAME as VARCHAR(16777216)) as MPIMODELNAME,
        cast(TELMODELCODE as VARCHAR(16777216)) as TELMODELCODE,
        cast(TELMODELNAME as VARCHAR(16777216)) as TELMODELNAME,
        cast(SUPPLIERCODE as VARCHAR(16777216)) as SUPPLIERCODE,
        cast(REVENUEMETHODCODE as VARCHAR(16777216)) as REVENUEMETHODCODE,
        cast(REVENUEMETHODDESCRIPTION as VARCHAR(16777216)) as REVENUEMETHODDESCRIPTION,
        cast(CLUSTERFLAG as VARCHAR(16777216)) as CLUSTERFLAG,
        cast(MACHINEMODULETYPE as VARCHAR(16777216)) as MACHINEMODULETYPE,
        cast(PARENTSERIALNUMBER as VARCHAR(16777216)) as PARENTSERIALNUMBER,
        cast(CHAMBERINSTALLPOSITION as VARCHAR(16777216)) as CHAMBERINSTALLPOSITION,
        cast(CUSTOMERTOOLID as VARCHAR(16777216)) as CUSTOMERTOOLID,
        cast(WAFERSIZE as VARCHAR(16777216)) as WAFERSIZE,
        cast(TABLEREFRESHDATE as TIMESTAMP_NTZ(9)) as TABLEREFRESHDATE,
        cast(ACCEPTANCECOMMENT as VARCHAR(16777216)) as ACCEPTANCECOMMENT,
        cast(TELSALESORDER as VARCHAR(16777216)) as TELSALESORDER,
        cast(WISDOMSYSTEMNAME as VARCHAR(16777216)) as WISDOMSYSTEMNAME,
        cast(FIRSTINTEGRATION as TIMESTAMP_NTZ(9)) as FIRSTINTEGRATION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data