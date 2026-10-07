{{ config(
      materialized='view',
      alias='GroupList',
      transient=false
) }}

with source_data as (
    select * from {{ ref('COMMON__ACTIVEDIRECTORY__GROUPLIST') }}
),
transform_data AS
(
	select * from source_data
)
select
   GroupId
  ,DisplayName
  ,IsSecurityEnabled
  ,EmailAddress
  ,Description
  ,Type
from transform_data