{{ config(
      materialized='view',
      alias='Employee',
      transient=false
) }}

with source_data as (
    select * from {{ ref('COMMON__ACTIVEDIRECTORY__EMPLOYEE') }}
),
transform_data AS
(
	select * from source_data
)
select
   UserId
  ,UserPrincipalName
  ,GivenName
  ,Surname
  ,MailNickname
  ,Mail
  ,DisplayName
  ,AccountEnabled
from transform_data