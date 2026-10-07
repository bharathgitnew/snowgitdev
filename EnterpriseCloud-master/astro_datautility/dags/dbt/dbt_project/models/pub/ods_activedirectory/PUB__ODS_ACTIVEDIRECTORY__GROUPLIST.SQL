{{ config(
      materialized='view',
      alias='GroupList',
      transient=false
) }}

with source_data as (
    select * from {{ ref('ODS__ACTIVEDIRECTORY__GROUPLIST') }}
),
transform_data AS
(
	select * from source_data
)
select
   GroupId
  ,DisplayName
  ,SecurityEnabled
  ,MailNickname
  ,ObjectType
  ,Description
  ,Type
from transform_data