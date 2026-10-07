{{ config(
        materialized='view',
         alias='USER_MASTER_TEXTS_FOR_PROFILES_USR10',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		AUTH_PROFILE_IN_USER_MASTER_MAINTENANCE,
		ACTIVE_OR_MAINTENANCE_VERSION,
		TEXTS_IN_USER_MASTERAUTHORIZATIONS,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__USER_MASTER_TEXTS_FOR_PROFILES_USR10') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data