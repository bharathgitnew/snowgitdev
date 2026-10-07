{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='PURCHASE_ORDER_CHANGE_HISTORY',
      transient=false
) }}

with source_data as (
    SELECT
        CDHDR.OBJECT_VALUE as PO_NUMBER,
        substr(cdpos.CHANGED_TABLE_RECORD_KEY,14,5) as line_number,
        ekpo.MATERIAL_NUMBER as MATERIAL_NUMBER,
        makt.MATERIAL_DESCRIPTION,
        lfa1.name_1 as Supplier_name,
        CDPOS.OLD_CONTENTS_OF_CHANGED_FIELD as  OLD_VALUE,
        CDPOS.NEW_CONTENTS_OF_CHANGED_FIELD as  NEW_VALUE,
        T024.description_of_purchasing_group as Buyer_Name,
        CDHDR.CREATION_DATE_OF_THE_CHANGE_DOCUMENT as  CHANGED_DATE,
        eket.statistics_relevant_delivery_date as statical_delivery_date,
        marc.PURCHASING_GROUP AS PURCHASING_GROUP
    from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__CHANGE_DOCUMENT_HEADER') }} cdhdr
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__CHANGE_DOCUMENT_ITEMS') }} cdpos
    on cdhdr.client = cdpos.client
    and cdhdr.OBJECT_CLASS = cdpos.OBJECT_CLASS
    and cdhdr.OBJECT_VALUE = cdpos.OBJECT_VALUE
    and cdhdr.CHANGE_NUMBER_OF_DOCUMENT = cdpos.CHANGE_NUMBER_OF_DOCUMENT
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_DOCUMENT_ITEM') }} ekpo
    on cdhdr.client = ekpo.client
    and cdhdr.object_value = ekpo.PURCHASING_DOCUMENT_NUMBER
    and line_number = ekpo.ITEM_NUMBER_OF_PURCHASING_DOCUMENT
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }} makt
    on cdhdr.client = makt.client
    and ekpo.MATERIAL_NUMBER = makt.material_number
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_DOCUMENT_HEADER') }} ekko
    on cdhdr.client = ekko.client
    and cdhdr.object_value = ekko.PURCHASING_DOCUMENT_NUMBER
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__VENDOR_MASTER') }} lfa1
    on ekko.client = lfa1.client
    and ekko.VENDORS_ACCOUNT_NUMBER = lfa1.ACCOUNT_NUMBER_OF_VENDOR_OR_CREDITOR
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__SCHEDULING_AGREEMENT_SCHEDULE_LINES') }} eket
    on cdhdr.client = eket.client
    and cdhdr.object_value = eket.PURCHASING_DOCUMENT_NUMBER
    and line_number = eket.ITEM_NUMBER_OF_PURCHASING_DOCUMENT
    and substr(cdpos.CHANGED_TABLE_RECORD_KEY,19,4) = eket.DELIVERY_SCHEDULE_LINE_COUNTER
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} as marc
    on cdhdr.client = marc.client
    and ekpo.plant  = marc.plant
    and ekpo.MATERIAL_NUMBER = marc.material_number
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_GROUPS') }} T024
    on cdhdr.client = T024.CLIENT
    and marc.PURCHASING_GROUP = T024.purchasing_group
    where cdhdr.client = '300'
    and CDHDR.OBJECT_CLASS = 'EINKBELEG'
    and cdpos.table_name = 'EKET'
    and cdpos.field_name in ('EINDT', 'SLFDT')
    and makt.language_key = 'E'
    and cdhdr.CREATION_DATE_OF_THE_CHANGE_DOCUMENT > date_from_parts(extract (year from current_date()) - 2, extract (month from current_date()), extract (day from current_date()))
),

transform_data as
(
    select '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, 
        * from source_data
)

,type_data as (
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(PO_NUMBER AS VARCHAR(270)) AS PO_NUMBER,
        CAST(LINE_NUMBER AS VARCHAR(70)) AS LINE_NUMBER,
        CAST(MATERIAL_NUMBER AS VARCHAR(54)) AS MATERIAL_NUMBER,
        CAST(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION,
        CAST(SUPPLIER_NAME AS VARCHAR(105)) AS SUPPLIER_NAME,
        CAST(OLD_VALUE AS VARCHAR(254)) AS OLD_VALUE,
        CAST(NEW_VALUE AS VARCHAR(254)) AS NEW_VALUE,
        CAST(BUYER_NAME AS VARCHAR(54)) AS BUYER_NAME,
        CAST(CHANGED_DATE AS VARCHAR(24)) AS CHANGED_DATE,
        CAST(STATICAL_DELIVERY_DATE AS VARCHAR(16777216)) AS STATICAL_DELIVERY_DATE,
        CAST(PURCHASING_GROUP AS VARCHAR(16777216)) AS PURCHASING_GROUP
    FROM transform_data
)

SELECT * from type_data