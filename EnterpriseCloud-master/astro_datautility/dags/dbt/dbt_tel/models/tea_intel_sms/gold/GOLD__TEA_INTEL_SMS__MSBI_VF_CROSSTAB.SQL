{{ config(
    alias='MSBI_VF_CROSSTAB',
    materialized='tel_incremental'  ,
    incremental_strategy='insert_overwrite',
    tags=["insert_overwrite_tea_intel_sms"],
) }}

with source_data as (
    SELECT 
        SPN AS MATERIAL_NUMBER,
        sum(iff(WIINGS_LOCATION = 'ALOHA', SIMI_QTY_AVAILABLE, 0)) AS ALOHA_SIMI_QTY_AVAILABLE,
        sum(iff(WIINGS_LOCATION = 'ALOHA', TEL_DOI, 0)) AS ALOHA_DOI,
        sum(iff(WIINGS_LOCATION = 'ALOHA', MOU, 0)) AS ALOHA_MOU,
        sum(iff(WIINGS_LOCATION = 'AZ1', SIMI_QTY_AVAILABLE, 0)) AS AZ1_SIMI_QTY_AVAILABLE,
        sum(iff(WIINGS_LOCATION = 'AZ1', TEL_DOI, 0)) AS AZ1_DOI,
        sum(iff(WIINGS_LOCATION = 'AZ1', MOU, 0)) AS AZ1_MOU,
        sum(iff(WIINGS_LOCATION = 'IR1', SIMI_QTY_AVAILABLE, 0)) AS IR1_SIMI_QTY_AVAILABLE,
        sum(iff(WIINGS_LOCATION = 'IR1', TEL_DOI, 0)) AS IR1_DOI,
        sum(iff(WIINGS_LOCATION = 'IR1', MOU, 0)) AS IR1_MOU,
        sum(iff(WIINGS_LOCATION = 'IS1', SIMI_QTY_AVAILABLE, 0)) AS IS1_SIMI_QTY_AVAILABLE,
        sum(iff(WIINGS_LOCATION = 'IS1', TEL_DOI, 0)) AS IS1_DOI,
        sum(iff(WIINGS_LOCATION = 'IS1', MOU, 0)) AS IS1_MOU,
        sum(iff(WIINGS_LOCATION = 'NM1', SIMI_QTY_AVAILABLE, 0)) AS NM1_SIMI_QTY_AVAILABLE,
        sum(iff(WIINGS_LOCATION = 'NM1', TEL_DOI, 0)) AS NM1_DOI,
        sum(iff(WIINGS_LOCATION = 'NM1', MOU, 0)) AS NM1_MOU,
        sum(iff(WIINGS_LOCATION = 'RONLER', SIMI_QTY_AVAILABLE, 0)) AS RONLER_SIMI_QTY_AVAILABLE,
        sum(iff(WIINGS_LOCATION = 'RONLER', TEL_DOI, 0)) AS RONLER_DOI,
        sum(iff(WIINGS_LOCATION = 'RONLER', MOU, 0)) AS RONLER_MOU,
    FROM {{ ref('SILVER__TEA_INTEL_SMS__MSBI_VF_BY_SITE') }}
    GROUP BY SPN
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        *,
    from source_data
),

type_data as (
    SELECT 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _REFRESHDATE,
        MATERIAL_NUMBER,
        ALOHA_SIMI_QTY_AVAILABLE,
        ALOHA_DOI,
        ALOHA_MOU,
        AZ1_SIMI_QTY_AVAILABLE,
        AZ1_DOI,
        AZ1_MOU,
        IR1_SIMI_QTY_AVAILABLE,
        IR1_DOI,
        IR1_MOU,
        IS1_SIMI_QTY_AVAILABLE,
        IS1_DOI,
        IS1_MOU,
        NM1_SIMI_QTY_AVAILABLE,
        NM1_DOI,
        NM1_MOU,
        RONLER_SIMI_QTY_AVAILABLE,
        RONLER_DOI,
        RONLER_MOU,
    from transform_data
)

select * from type_data