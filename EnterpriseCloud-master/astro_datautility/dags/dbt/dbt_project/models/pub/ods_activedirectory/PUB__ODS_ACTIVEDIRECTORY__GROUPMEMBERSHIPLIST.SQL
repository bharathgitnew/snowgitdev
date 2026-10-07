{{ config(
      materialized='view',
      alias='GroupMembershipList',
      transient=false
) }}

with source_data as (
    select * from {{ ref('ODS__ACTIVEDIRECTORY__GROUPMEMBERSHIPLIST') }}
),
transform_data AS
(
	select * from source_data
)
select
   GroupId
  ,MemberId
  ,MemberName
from transform_data