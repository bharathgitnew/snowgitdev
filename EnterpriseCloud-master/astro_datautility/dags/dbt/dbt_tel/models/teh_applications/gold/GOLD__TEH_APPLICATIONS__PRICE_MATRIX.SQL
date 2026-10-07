{{ config(
    alias='PRICE_MATRIX',
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    meta = {
        'owners': ['Bob Mayekawa'],
    },
) }}

with customer_group_mappings as (
    select 
        COLUMN1 as PRICE_GROUP,
        COLUMN2 as CUSTOMER
    from values
        ('01', 'INTEL CORPORATION'),
        ('02', 'MICRON TECHNOLOGY, INC.'),
        ('03', 'GLOBALFOUNDRIES U.S. INC.'),
        ('04', 'SAMSUNG SEMICONDUCTOR INC.'),
        ('05', 'SK HYNIX'),
        ('06', 'TSMC'),
        ('07', 'UMC'),
        ('08', 'POWERCHIP')
),

source_data as (
    SELECT
        pm.APPLICATION, 
        pm.CONDITION_RECORD_NUMBER, 
        pm.CONDITION, 
        pm.CONDITION_DESC, 
        pm.CONDITION_TYPE, 
        pm.SALES_ORGANIZATION, 
        pm.VALIDITY_START_DATE_OF_THE_CONDITION_RECORD, 
        pm.VALIDITY_END_DATE_OF_THE_CONDITION_RECORD, 
        pm.MATERIAL_NUMBER, 
        mara.MATERIAL_DESCRIPTION AS MATERIAL_DESCRIPTION, 
        mvke.KONDM AS MATERIAL_PRICE_GROUP, 
        pm.CUSTOMER_PRICE_GROUP, 
        pm.CUSTOMER_NUMBER, 
        CASE
            WHEN pm.CUSTOMER_NUMBER = 'BA3051316' THEN 'ANALOG DEVICES INC.'
            ELSE  coalesce(kna1.NAME1, cgm.CUSTOMER) 
        END AS CUSTOMER, 
        pm.DISTRIBUTION_CHANNEL, 
        pm.RELEASE_STATUS, 
        pm.PRICING_COUNTRY, 
        pm.PROCESSING_STATUS_FOR_CONDITIONS, 
        pm.ORDER_REASON, 
        pm.PRICE_LIST_TYPE, 
        pm.SD_DOCUMENT_CURRENCY, 
        pm.CONDITION_AMOUNT_OR_PERCENTAGE_WHERE_NO_SCALE_EXISTS as CONDITION_AMOUNT, 
        pm.CONDITION_UNIT_KONWA as CONDITION_UNIT
    FROM {{ ref('SILVER__TEH_APPLICATIONS__PRICE_MATRIX') }} pm
    LEFT JOIN {{ ref('BRONZE__TEH_APPLICATIONS__SAPAPI_ZCDV_T_CMTU020_KNA1') }} kna1 
    ON pm.CUSTOMER_NUMBER = kna1.KUNNR 
    LEFT JOIN {{ ref('BRONZE__TEH_APPLICATIONS__SAPAPI_ZCDV_T_CMTU019_MVKE') }} mvke 
    ON pm.MATERIAL_NUMBER = mvke.MATNR AND pm.SALES_ORGANIZATION = mvke.VKORG
    LEFT JOIN 
        (   select 
                distinct MARA_MATERIAL_NUMBER, MATERIAL_DESCRIPTION
            from {{ ref('SILVER__TEH_APPLICATIONS__MATERIAL_VALUATION_MASTER_CODED') }}
        ) mara 
    ON pm.MATERIAL_NUMBER = mara.MARA_MATERIAL_NUMBER
    LEFT JOIN customer_group_mappings cgm
    ON try_to_number(pm.CUSTOMER_PRICE_GROUP) = try_to_number(cgm.PRICE_GROUP)
    WHERE pm.CONDITION_RECORD_NUMBER IS NOT NULL
),

transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        APPLICATION, 
        CONDITION_RECORD_NUMBER, 
        CONDITION, 
        CONDITION_DESC, 
        CONDITION_TYPE, 
        SALES_ORGANIZATION, 
        VALIDITY_START_DATE_OF_THE_CONDITION_RECORD, 
        VALIDITY_END_DATE_OF_THE_CONDITION_RECORD, 
        MATERIAL_NUMBER, 
        MATERIAL_DESCRIPTION, 
        MATERIAL_PRICE_GROUP, 
        CUSTOMER_PRICE_GROUP, 
        CUSTOMER_NUMBER, 
        CUSTOMER, 
        DISTRIBUTION_CHANNEL, 
        RELEASE_STATUS, 
        PRICING_COUNTRY, 
        PROCESSING_STATUS_FOR_CONDITIONS, 
        ORDER_REASON, 
        PRICE_LIST_TYPE, 
        SD_DOCUMENT_CURRENCY, 
        CONDITION_AMOUNT, 
        CONDITION_UNIT-- Adds column to table on full refresh.
    FROM source_data
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID, 
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        APPLICATION, 
        CONDITION_RECORD_NUMBER, 
        CONDITION, 
        CONDITION_DESC, 
        CONDITION_TYPE, 
        SALES_ORGANIZATION, 
        VALIDITY_START_DATE_OF_THE_CONDITION_RECORD, 
        VALIDITY_END_DATE_OF_THE_CONDITION_RECORD, 
        MATERIAL_NUMBER, 
        MATERIAL_DESCRIPTION, 
        MATERIAL_PRICE_GROUP, 
        CUSTOMER_PRICE_GROUP, 
        CUSTOMER_NUMBER, 
        CUSTOMER, 
        DISTRIBUTION_CHANNEL, 
        RELEASE_STATUS, 
        PRICING_COUNTRY, 
        PROCESSING_STATUS_FOR_CONDITIONS, 
        ORDER_REASON, 
        PRICE_LIST_TYPE, 
        SD_DOCUMENT_CURRENCY, 
        CAST(CONDITION_AMOUNT AS NUMBER(38,10)) AS CONDITION_AMOUNT, 
        CONDITION_UNIT
    FROM transform_data
)

SELECT * from type_data