{{ config(
        alias='INVENTORY_MATCH_UPS',
        transient=false
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
    from {{ ref('COMMON__SAPH__STORAGE_LOCATION_BATCH_CHARACTERISTICS') }}
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
    from {{ ref('COMMON__SAPH__INVENTORY_PLANT_MATERIAL') }} matdoc
    where storage_location_lgort_sid in ('A120', 'A121', 'A122', 'A123', 'A124', 'A129', 'A220', 'A223', 'A224', 'A320', 'A323', 'A324', 'A420', 'A423', 'A424', 'A520', 'A523', 'A524', 'A530', 'A531', 'A532', 'A533', 'A534', 'A539', 'A620', 'A623', 'A624', 'A720', 'A723', 'A724', 'A820', 'A823', 'A824', 'A920', 'A923', 'A924', 'B120', 'B123', 'B124', 'B220', 'B230', 'B233', 'B234', 'B330', 'B333', 'B334', 'B430', 'B433', 'B434', 'B520', 'B523', 'B524','H420')
    and convert_timezone('Etc/UCT', 'US/Central', to_timestamp(MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED||MATDOC.TIME_OF_ENTRY,'YYYYMMDDHH24MISS')) <= dateadd(hour,6,date_trunc('day',current_timestamp())) 
    group by 
        material_in_respect_of_which_stock_is_managed
        , plant_werks
        , storage_location_lgort_sid
        , batch_number_charg_sid
        , MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED||MATDOC.TIME_OF_ENTRY
        , dateadd(hour,6,date_trunc('day',current_timestamp()))
)
,

src_data as
(
    select distinct
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
qty_data as
(
SELECT
            MATERIAL,
            PLANT,
            STORAGE_LOCATION,
            SUM(ON_HAND_QTY) as ON_HAND_QTY
    from
    (
    select
        
            MATERIAL,
            PLANT,
            STORAGE_LOCATION,
            ON_HAND_QTY as ON_HAND_QTY
    from matdoc_data
    )
    group by all
),

tfn_data as
(
    select 
        MATERIAL
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
    from src_data 
    order by
        MATERIAL
        , STORAGE_LOCATION
),
final_data as
(
    SELECT distinct
        tfn_data.MATERIAL
        , tfn_data.PLANT
        , tfn_data.STORAGE_LOCATION
        , tfn_data.SAP_BATCH_NUMBER
        , SERIAL_NO
        , BATCH_COUNT
        , SERIAL_COUNT
        , ON_HAND_QTY
    from tfn_data
            inner join qty_data
            on tfn_data.MATERIAL=qty_data.MATERIAL
            and tfn_data.PLANT=qty_data.PLANT
            and tfn_data.STORAGE_LOCATION=qty_data.STORAGE_LOCATION
),
INVENTORY_MATCH_SAP_DATA as
(
    select * from final_data 
), 
ups_base as
(    select
        PART_NUMBER
        ,STORAGE_LOCATION
        ,WMS_BATCH_NUMBER
        ,SERIAL_NUMBER
        ,QUANTITY
        ,to_date(left(date_of_extract,8),'YYYYMMDD') as EXTRACT_DATE
    FROM {{ ref('ODS__THREEPL__TPL_UPS_INVENTORY_FILE_US') }}
),
ups_data AS
(
        select
        PART_NUMBER
        ,STORAGE_LOCATION
        ,WMS_BATCH_NUMBER
        ,SERIAL_NUMBER
        ,EXTRACT_DATE
        ,sum(QUANTITY) as ON_HAND_QTY
        ,count(distinct WMS_BATCH_NUMBER) over (partition by PART_NUMBER,STORAGE_LOCATION) as BATCH_COUNT
        ,count(distinct SERIAL_NUMBER) over (partition by PART_NUMBER,STORAGE_LOCATION) as SERIAL_COUNT        
    from ups_base
    group by 
        PART_NUMBER
        ,STORAGE_LOCATION
        ,WMS_BATCH_NUMBER
        ,SERIAL_NUMBER
        ,EXTRACT_DATE
    order by
        PART_NUMBER
        ,STORAGE_LOCATION
),
sap_data as 
(
    select distinct
    INVENTORY_MATCH_SAP_DATA.material
    ,INVENTORY_MATCH_SAP_DATA.storage_location
    ,max(batch_count) as batch_count
    ,max(serial_count) as serial_count
    ,on_hand_qty as on_hand_qty
    from INVENTORY_MATCH_SAP_DATA
    group by all
),
non_ups_data as
(
    SELECT distinct
        material
    ,storage_location
    from sap_data 
    where on_hand_qty='0'
    minus
    select distinct PART_NUMBER,STORAGE_LOCATION from ups_base       
),
tpl_data as
(
    select
    part_number
    ,storage_location
    ,max(batch_count) as batch_count
    ,max(serial_count) as serial_count
    ,sum(on_hand_qty) as on_hand_qty
    from ups_data
    group by 
    part_number
    ,storage_location
    union all
        select
    material as part_number
    ,storage_location
    ,0 as batch_count
    ,0 as serial_count
    ,0 as on_hand_qty
    from non_ups_data
),

batch_mismatches as (

    select 
        case when tpl.part_number is null then sap.material else tpl.part_number end as MATERIAL
        ,case when tpl.part_number is null then sap.storage_location else tpl.storage_location end as storage_location
        ,'batch mistmatch' as reason
    from ups_data tpl
    full join {{ ref('COMMON__DE_THREEPL__INVENTORY_MATCH_SAP_DATA') }} sap on 
        SAP.MATERIAL = tpl.part_number 
        and sap.storage_location = tpl.storage_location 
        and sap.wms_batch_no = tpl.wms_batch_number
     where material is null or part_number is null
),

ups_serials_only as
(
    select 
    part_number
    ,storage_location
    ,serial_number
    from ups_Data tpl 
    where serial_number is not null
),

sap_serials_only as
(
    select 
    material
    ,storage_location
    ,serial_no
    from {{ ref('COMMON__DE_THREEPL__INVENTORY_MATCH_SAP_DATA') }}
    where serial_no != ''
),

serial_mismatches as 
(
    select 
    case when tpl.part_number is null then sap.material else tpl.part_number end as MATERIAL
    ,case when tpl.part_number is null then sap.storage_location else tpl.storage_location end as storage_location
    ,'serial mistmatch' as reason
    from ups_serials_only tpl
    full join  sap_serials_only sap on SAP.MATERIAL = tpl.part_number and sap.storage_location = tpl.storage_location and sap.serial_no = tpl.serial_number
),

combined_mismatches as
(
    select * from serial_mismatches
    union
    select * from batch_mismatches
),

source_data as
(
    select
        sap.material
        , tpl.part_number
        , sap.storage_location as SAP_STORAGE_LOCATION
        , tpl.storage_location as TPL_STORAGE_LOCATION
        , sap.on_hand_qty as SAP_ON_HAND
        , TPL.on_hand_qty as UPS_ON_HAND
        , listagg(mismatches.reason,',') as reason 
    from tpl_data tpl
    full join sap_data sap on sap.material = tpl.part_number and sap.storage_location = tpl.storage_location
    left join combined_mismatches mismatches on sap.material = mismatches.material and sap.storage_location = mismatches.storage_location
    group by all
),

transform_data as
(
    select
       case when material is null then part_number else material end as MATERIAL
        , case when SAP_STORAGE_LOCATION is null then TPL_STORAGE_LOCATION else SAP_STORAGE_LOCATION end as STORAGE_LOCATION
        , nvl(SAP_ON_HAND,0) as SAP_ON_HAND
        , nvl(UPS_ON_HAND,0) as UPS_ON_HAND
        , nvl(UPS_ON_HAND,0) -nvl(SAP_ON_HAND,0)  as ON_HAND_DIFFERENCE
        , case when reason is not null and trim(reason)!='' then reason 
               when on_hand_difference != 0 then 'Qty mismatch' else 'OK'  end as REASON
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as 
(
    select
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        MATERIAL,
        STORAGE_LOCATION,
        cast(SAP_ON_HAND as NUMBER(38,0)) as SAP_ON_HAND,
        cast(UPS_ON_HAND as NUMBER(38,0)) as UPS_ON_HAND,
        cast(ON_HAND_DIFFERENCE as NUMBER(38,0)) as ON_HAND_DIFFERENCE,
        REASON
        from transform_data
        
)

select * from type_data