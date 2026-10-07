/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\DirectOrder_Header.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\DirectOrder_Header.SQL
-materialized incremental
-alias DirectOrder_Header
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema ARIBA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/4/2022 1:10:06 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='DemandReturn_Live',
    unique_key = []
) }}

with source_data as
(
    SELECT
       DemandReturn.ItemId
      ,DemandReturn.WarehouseRegionId
      ,DemandReturn.WarehouseId
      ,DemandReturn.TransactionType
      ,DemandReturn.OrderMonthDate
      ,DemandReturn.Quantity
      ,_FileName
      ,try_to_timestamp(replace(split_part(_filename,'_',2)||split_part(_filename,'_',3),'.feed.gz',''),'yyyymmddHH24MISS') AS FileDate
    FROM {{ ref('BRONZE__TEE_SPARES_SUPPORT__PROPHET_DEMANDRETURN') }} DemandReturn
)
,transform_data as
(
    SELECT
         '{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH 
        ,FileDate
        ,ItemId
        ,WarehouseRegionId
        ,WarehouseId
        ,TransactionType
        ,OrderMonthDate
        ,Quantity
        ,REPLACE(LEFT(_FILENAME,CHARINDEX('_',_FILENAME)-1),'DEMANDRETURN/SITETRANRTN','') AS OriginatingSubsidiary
        ,LEFT(WarehouseRegionId,CHARINDEX('-',WarehouseRegionId)-1) AS WarehouseSubsidiary
        ,SUBSTRING(WarehouseRegionId,CHARINDEX('-',WarehouseRegionId)+1) AS WarehouseType
    FROM source_data
)
,DemandReturn_Max as
(
    SELECT
        OriginatingSubsidiary,
        MAX(FileDate) AS FileDate
    FROM transform_data
    GROUP BY OriginatingSubsidiary
)
,transform_data_max as
(
    SELECT
         _AUDIT_LOG_ID
        ,_ROW_HASH 
        ,transform_data.FileDate as FILEDATE
        ,ItemId
        ,WarehouseRegionId
        ,WarehouseId
        ,TransactionType
        ,OrderMonthDate
        ,Quantity
        ,transform_data.OriginatingSubsidiary
        ,WarehouseSubsidiary
        ,WarehouseType
    FROM transform_data
    INNER JOIN DemandReturn_Max
    ON transform_data.OriginatingSubsidiary = DemandReturn_Max.OriginatingSubsidiary AND transform_data.FileDate = DemandReturn_Max.FileDate
)
,type_data as
(
    select
         CAST(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
         CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
         CAST(FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
         CAST(ItemId AS VARCHAR(16777216)) AS ItemId,
         CAST(WarehouseRegionId AS VARCHAR(16777216)) AS WarehouseRegionId,
         CAST(WarehouseId AS VARCHAR(16777216)) AS WarehouseId,
         CAST(TransactionType AS VARCHAR(16777216)) AS TransactionType,
         CAST(OrderMonthDate AS NUMBER(38,0)) AS OrderMonthDate,
         CAST(Quantity AS NUMBER(38,10)) AS Quantity,
         CAST(OriginatingSubsidiary AS VARCHAR(16777216)) AS OriginatingSubsidiary,
         CAST(WarehouseSubsidiary AS VARCHAR(16777216)) AS WarehouseSubsidiary,
         CAST(WarehouseType AS VARCHAR(16777216)) AS WarehouseType         
    from transform_data_max
    )
select * from type_data