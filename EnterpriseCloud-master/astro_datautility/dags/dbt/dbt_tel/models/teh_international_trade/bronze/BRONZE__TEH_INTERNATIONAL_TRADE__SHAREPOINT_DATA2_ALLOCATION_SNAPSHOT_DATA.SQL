{{ config(
    alias = 'SHAREPOINT_DATA2_ALLOCATION_SNAPSHOT_DATA',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key=['SNAPSHOT_DATE']
) }}

with source_data as (
    select
       * exclude (_audit_log_id, _row_hash)
    from {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SHAREPOINT_DATA2_ALLOCATION_DATA') }} 
    {% if is_tel_incremental() %} WHERE  FILE_LAST_MODIFIED_TIMESTAMP > IFNULL((SELECT MAX(	FILE_LAST_MODIFIED_TIMESTAMP ) FROM {{ this }}),'1970-01-01') {% endif %}
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        CURRENT_DATE() AS SNAPSHOT_DATE,
        *
    from source_data
),

type_data as (
    select 
       *
    from transform_data
)

select * from type_data
