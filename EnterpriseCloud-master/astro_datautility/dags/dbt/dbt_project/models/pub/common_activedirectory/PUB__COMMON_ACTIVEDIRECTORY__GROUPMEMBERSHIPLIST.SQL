{{ config(
      materialized='view',
      alias='GroupMembershipList',
      transient=false
) }}

with source_data as (
    select * from {{ ref('COMMON__ACTIVEDIRECTORY__GROUPMEMBERSHIPLIST') }}
),
transform_data AS
(
	select * from source_data
)
select
   GroupId
  ,MemberId
from transform_data