{{ config(
      materialized='view',
      alias='SiteReturns_History',
      transient=false
) }}

with source_data as (
    select * from {{ ref('COMMON__PROPHET__DEMANDRETURN_HISTORY') }}
),
transform_data AS
(
	select * from source_data
)
select
         ItemId
        ,WarehouseRegionId
        ,WarehouseId
        ,TransactionType
        ,OrderMonthDate
        ,Quantity
        ,OriginatingSubsidiary
        ,WarehouseSubsidiary
        ,WarehouseType
        ,FILEDATE
from transform_data