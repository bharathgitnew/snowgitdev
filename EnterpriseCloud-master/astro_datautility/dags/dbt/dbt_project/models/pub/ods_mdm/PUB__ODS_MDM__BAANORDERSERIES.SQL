/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.17"
*************/

{{ config(
      materialized='view',
      alias='BAANORDERSERIES',
      transient=false
) }}

with source_data as (
    SELECT
        ORDERSERIES,
        ORDERSERIESCODE,
        ORDERGROUPCODE,
        ORDERGROUPNAME,
        KRONOSTYPEOFWORK,
        BAANPRODUCTTYPECODE,
        ORDERCREATOR
    from {{ ref('ODS__MDM__BAANORDERSERIES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data