{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='INVENTORY_MATCH_SAP_DATA'
) }}


with char_data as
(

    select 
        mchb_material_number as MATERIAL
        ,mchb_plant as PLANT
        ,mchb_storage_location as STORAGE_LOCATION
        ,case when length(mchb_batch_number) <10 then lpad(mchb_batch_number,10,'0') else mchb_batch_number end as SAP_BATCH_NUMBER
        ,ausp_internal_characteristic as CHARACTERISTIC_ID
        ,ausp_characteristic_value as CHARACTERISTIC_VALUE
        ,case when ausp_internal_characteristic = '0000000012' then ausp_characteristic_value else '' end as WMS_BATCH_NO
        ,case when ausp_internal_characteristic = '0000000013' then ausp_characteristic_value else '' end as SERIAL_NO
    from {{ ref('SILVER__TEA_THREEPL_OPERATIONS__STORAGE_LOCATION_BATCH_CHARACTERISTICS') }}
    where ausp_internal_characteristic in ('0000000012','0000000013')
    
),

matdoc_data as
(
    select 
        matdoc.material_in_respect_of_which_stock_is_managed as MATERIAL
        , matdoc.plant_werks as PLANT
        , matdoc.storage_location_lgort_sid as STORAGE_LOCATION
        , matdoc.batch_number_charg_sid as SAP_BATCH_NUMBER
        , MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED||MATDOC.TIME_OF_ENTRY as UTC_ENTRY_TIMESTAMP
        , sum(matdoc.STOCK_QUANTITY) AS ON_HAND_QTY
    from {{ ref('SILVER__TEA_THREEPL_OPERATIONS__INVENTORY_PLANT_MATERIAL') }} matdoc
    where storage_location_lgort_sid in ('A120', 'A121', 'A122', 'A123', 'A124', 'A129', 'A220', 'A223', 'A224', 'A320', 'A323', 'A324', 'A420', 'A423', 'A424', 'A520', 'A523', 'A524', 'A530', 'A531', 'A532', 'A533', 'A534', 'A539', 'A620', 'A623', 'A624', 'A720', 'A723', 'A724', 'A820', 'A823', 'A824', 'A920', 'A923', 'A924', 'B120', 'B123', 'B124', 'B220', 'B230', 'B233', 'B234', 'B330', 'B333', 'B334', 'B430', 'B433', 'B434', 'B520', 'B523', 'B524','H420')
    and convert_timezone('Etc/UCT', 'US/Central', to_timestamp(MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED||MATDOC.TIME_OF_ENTRY,'YYYYMMDDHH24MISS')) <= dateadd(hour,6,date_trunc('day',current_timestamp())) 
    group by 
        material_in_respect_of_which_stock_is_managed
        , plant_werks
        , storage_location_lgort_sid
        , batch_number_charg_sid
        , MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED||MATDOC.TIME_OF_ENTRY
        , dateadd(hour,6,date_trunc('day',current_timestamp()))
),

source_data as
(
    select 
        matdoc.MATERIAL
        , matdoc.PLANT
        , matdoc.STORAGE_LOCATION
        , matdoc.SAP_BATCH_NUMBER
        , matdoc.UTC_ENTRY_TIMESTAMP
        , char_data.CHARACTERISTIC_VALUE
        , char_data.CHARACTERISTIC_ID
        , char_data.WMS_BATCH_NO
        , char_data.SERIAL_NO
        , matdoc.ON_HAND_QTY
    from matdoc_data matdoc
    left join char_data on char_data.MATERIAL = matdoc.MATERIAL 
            and char_data.PLANT = matdoc.PLANT
            and char_data.STORAGE_LOCATION = matdoc.STORAGE_LOCATION
            and char_data.SAP_BATCH_NUMBER = matdoc.SAP_BATCH_NUMBER   
),

transform_data as
(
    select 
          '{{ invocation_id }}' AS _AUDIT_LOG_ID
        , SHA2('hash_me') as _ROW_HASH
        , MATERIAL
        , PLANT
        , STORAGE_LOCATION
        , SAP_BATCH_NUMBER
        , CHARACTERISTIC_VALUE
        , WMS_BATCH_NO
        , SERIAL_NO
        , case when CHARACTERISTIC_ID = '0000000012' then 
                    count(distinct CHARACTERISTIC_VALUE) over (partition by MATERIAL,STORAGE_LOCATION)
                    else 0
                    end as BATCH_COUNT
        , case when CHARACTERISTIC_ID = '0000000013' then 
                    count(distinct CHARACTERISTIC_VALUE) over (partition by MATERIAL,STORAGE_LOCATION)
                    else 0
                    end as SERIAL_COUNT                 
        , sum(ON_HAND_QTY) as ON_HAND_QTY
    from source_data 

    group by 
        MATERIAL 
        , PLANT
        , STORAGE_LOCATION
        , SAP_BATCH_NUMBER
        , CHARACTERISTIC_ID
        , CHARACTERISTIC_VALUE
        , WMS_BATCH_NO
        , SERIAL_NO
    order by
        MATERIAL
        , STORAGE_LOCATION
),

type_data as
(
    select
          CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID
        , CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
        , MATERIAL
        , PLANT
        , STORAGE_LOCATION
        , SAP_BATCH_NUMBER
        , CHARACTERISTIC_VALUE
        , WMS_BATCH_NO
        , SERIAL_NO
        , BATCH_COUNT
        , SERIAL_COUNT                 
        , ON_HAND_QTY
    from transform_data 
)

select * from type_data