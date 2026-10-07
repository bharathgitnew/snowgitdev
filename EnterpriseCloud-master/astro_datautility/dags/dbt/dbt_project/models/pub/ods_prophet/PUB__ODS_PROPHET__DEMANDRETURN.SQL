{{ config(
      materialized='view',
      alias='DemandReturn',
      transient=false
) }}

with source_data as (
    select * from {{ ref('ODS__PROPHET__DEMANDRETURN') }}
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
  ,_FileName
from transform_data