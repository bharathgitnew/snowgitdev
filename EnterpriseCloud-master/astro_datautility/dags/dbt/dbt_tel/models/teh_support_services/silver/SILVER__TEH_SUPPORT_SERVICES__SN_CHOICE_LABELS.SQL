{{ config(
    alias = 'SN_CHOICE_LABELS',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
) }}

with source_data as (
    select 
        c.SYS_ID,
        c.NAME,
        c.ELEMENT,
        c.VALUE,
        d.DEPENDENT as DEPENDENT_COLUMN,
        c.DEPENDENT_VALUE,
        c.LABEL,
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_CHOICE') }} as c
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_DICTIONARY') }} as d
        on c.NAME = d.NAME
        and c.ELEMENT = d.ELEMENT
    where c.INACTIVE = FALSE
        and c.SYS_DOMAIN = 'global' 
        and c.LANGUAGE = 'en'
    qualify row_number() over(
        partition by c.NAME, c.ELEMENT, c.DEPENDENT_VALUE, c.VALUE
        order by c.SEQUENCE, c.SYS_UPDATED_ON desc, c.SYS_ID desc
    ) = 1
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        *,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _REFRESHDATE,
        SYS_ID,
        NAME,
        ELEMENT,
        VALUE,
        DEPENDENT_COLUMN,
        DEPENDENT_VALUE,
        LABEL,        
    from transform_data
)

select * from type_data
