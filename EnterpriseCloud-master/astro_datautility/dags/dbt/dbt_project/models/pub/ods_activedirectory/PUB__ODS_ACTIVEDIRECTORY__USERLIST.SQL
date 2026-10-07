{{ config(
      materialized='view',
      alias='UserList',
      transient=false
) }}

with source_data as (
    select * from {{ ref('ODS__ACTIVEDIRECTORY__USERLIST') }}
),
transform_data AS
(
	select * from source_data
)
select
   UserId
  ,UserPrincipalName
  ,ObjectType
  ,UsageLocation
  ,GivenName
  ,Surname
  ,AccountEnabled
  ,MailNickname
  ,Mail
  ,DisplayName
  ,UserType
from transform_data