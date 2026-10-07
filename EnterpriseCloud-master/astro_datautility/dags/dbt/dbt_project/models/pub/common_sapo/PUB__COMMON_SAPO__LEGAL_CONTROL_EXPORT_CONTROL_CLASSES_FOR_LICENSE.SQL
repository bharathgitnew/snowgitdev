{{ config(
        materialized='view',
         alias='LEGAL_CONTROL_EXPORT_CONTROL_CLASSES_FOR_LICENSE',
         transient=false
) }}

with source_data as (
    select
        _CAPTUREDATETIME,
        CLIENT,
        LEGAL_REGULATION_FOR_LEGAL_CONTROL,
        LICENSE_TYPE,
        EXPORT_CONTROL_CLASS_ACCORDING_THE_LEGAL_REG_FOR_LEGAL_CTRL,
        INTERNAL_LICENSE_NUMBER,
        LEGAL_CONTROL_SPECIAL_CHARACTERISTICS_CODE_FOR_GOODS,
        IS_DELETED
    from {{ ref('COMMON__SAPO__LEGAL_CONTROL_EXPORT_CONTROL_CLASSES_FOR_LICENSE') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data