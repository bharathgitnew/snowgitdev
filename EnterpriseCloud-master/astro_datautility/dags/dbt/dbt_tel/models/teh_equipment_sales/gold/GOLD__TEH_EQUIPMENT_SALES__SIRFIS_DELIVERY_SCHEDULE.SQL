{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SIRFIS_DELIVERY_SCHEDULE',
    transient=false
) }}

with
SIRFIS_ITEM_HIERARCHY
as
(
select *
from  {{ ref('GOLD__TEH_EQUIPMENT_SALES__SIRFIS_ITEM_HIERARCHY') }}
where IS_PART_ORDER = 0
),
SIRFIS_PRICING
as  
(
select distinct 
    ID, 
    max(PRICE_ESTIMATE) as PRICE_ESTIMATE
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SIRFIS_PRICING') }}
group by 1
),
SIRFIS_LIFECYCLE
as
(
select
  sirfis.ID,
  sirfis.EXPECTED_FORECAST_STATUS,
  sirfis.PO_STATUS,
  sirfis.PURCHASE_ORDER_NUMBER,
  sirfis.PURCHASE_ORDER_LINE_NUMBER,
  sirfis.PURCHASE_ORDER_KEY,
  sirfis.INITIAL_PO_DATE,
  sirfis.REQUESTED_TENDER_DATE,
  sirfis.SUPPLIER_TENDER_DATE,
  dateadd(
    day,
    - sirfis.BUILD_TIME,
    sirfis.REQUESTED_TENDER_DATE
  ) as BOOKING_DATE, --buildtime in SIRFIS is not necessary accurate, po.PURCHASE_ORDER_ACCEPTANCE_DATE --this is not the booking date
  sirfis.ENTERED_DATE,
  sirfis.LATEST_DATE,
  sirfis.INTEL_RELEASED_DATE,
  case
    when trim(sirfis.SUPPLIER_MAP, ' ') ilike 'NG REMOVED' then 'NG removed'
    when trim(sirfis.SUPPLIER_MAP, ' ') ilike 'NG' then 'NG'
    when trim(sirfis.SUPPLIER_MAP, ' ') ilike 'null' then null
    when sirfis.SUPPLIER_MAP ilike '' then null
    else trim(sirfis.SUPPLIER_MAP, ' ')
  end as SUPPLIER_MAP
from
  {{ ref('GOLD__TEH_EQUIPMENT_SALES__SIRFIS_LIFECYCLE') }} sirfis
  left join {{ ref('SILVER__TEH_EQUIPMENT_SALES__PURCHASE_ORDER_CHANGE_ORDER') }} po on sirfis.PURCHASE_ORDER_KEY = po.PURCHASE_ORDER_LINE_ID
where
  sirfis.READ_ONLY = 'No'
  and sirfis.ID in (
    select distinct
      ID
    from
      {{ ref('GOLD__TEH_EQUIPMENT_SALES__SIRFIS_ITEM_HIERARCHY') }}
    where
      IS_PART_ORDER = 0
  )
),
IDs
as
(
select
    FORECASTID,
    UEID,
    PID
from {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SIRFIS_SIRFIS_FORECAST_BASE') }}
where REVISION_DESC_ORDER = 1
    and SUPPLIERNUMBER <> 1000013881 --TMEA excluded
),
SOURCE_DATA AS (
    select
      sirfis.ID as FORECAST_ID,
      IDs.PID as TOOL_PROCUREMENT_ID,
      IDs.UEID as UNIQUE_EQUIPMENT_ID,
      bu.CEID as COPY_EXACT_ID,
      -- 'Intel'     as END_USER,
      area.AREA,
      bu.SITE,
      case
        when bu.SITE ilike 'D1%' then 'D1D'
        when bu.SITE ilike any('F34', 'SF24') then 'F24'
        when bu.SITE ilike 'F52' then 'F32'
        when bu.SITE ilike 'F28' then 'F38'
        when bu.SITE ilike 'SF11X' then 'F11X'
        when bu.SITE ilike 'KMP' then 'RA' --'KM2'
        when bu.SITE ilike 'RA-%'
        and bu.UNIVERSAL_BU ilike 'TS' then 'RA'
        when bu.SITE ilike 'AL-%' then 'F15'
        else bu.SITE
      end as ADJUSTED_SITE,
      case
        when bu.UNIVERSAL_BU = 'FS' then concat(bu.UNIVERSAL_BU, '_', bu.BUSINESS_UNIT_SHORT_TEXT)
        else bu.BUSINESS_UNIT_SHORT_TEXT
      end as SUB_BU,
      bu.CATEGORY,
      case
        when bu.CATEGORY ilike any('MT', 'PK') then 'Equipment'
        when bu.CATEGORY ilike 'PKD' then 'Pre-kit'
        when bu.CATEGORY ilike any('CK', 'UK') then 'Modification'
        else 'Others'
      end as SALES_CATEGORY_TYPE,
      bu.ENTITY,
      bu.MODEL as MODEL_QUOTE_NO,
      bu.DESCRIPTION,
      bu.PROCESS,
      sirfis.PURCHASE_ORDER_NUMBER as PO_NO,
      sirfis.PURCHASE_ORDER_LINE_NUMBER as PO_LINE_ITEM_NO,
      sirfis.PURCHASE_ORDER_KEY as PO_NO_LINE_ITEM_NO, --PURCHASE_ORDER_NUMBER, PURCHASE_ORDER_LINE_NUMBER
      case
        when SUB_BU ilike '3DI' then to_date(dateadd(day, -90, sirfis.REQUESTED_TENDER_DATE))
        when SUB_BU ilike 'CT' then to_date(dateadd(day, -100, sirfis.SUPPLIER_TENDER_DATE))
        when SUB_BU ilike any('ES', 'Certas') then to_date(dateadd(day, -100, sirfis.REQUESTED_TENDER_DATE))
        when SUB_BU ilike 'SPS' then to_date(dateadd(day, -100, sirfis.SUPPLIER_TENDER_DATE))
        when SUB_BU ilike any('TPS', 'SD', 'PVD') then to_date(dateadd(day, -90, sirfis.REQUESTED_TENDER_DATE))
        when SUB_BU ilike 'TS' then to_date(dateadd(day, -120, sirfis.REQUESTED_TENDER_DATE))
        when SUB_BU ilike 'FS%' then to_date(dateadd(day, -100, sirfis.REQUESTED_TENDER_DATE))
      end as RTD_BASE_BOOKING_DATE, --confirmed with BUs 5/2025
      to_date(sirfis.INITIAL_PO_DATE) as PO_FIRST_LISTED_DATE, --calculated date, sirfis min appended date w PO No, not necessary PO date in TCC
      case
        when sirfis.INITIAL_PO_DATE is not null then 'Yes'
        else 'No'
      end as IS_PO_RELEASED,
      to_date(sirfis.REQUESTED_TENDER_DATE) as REQUESTED_TENDER_DATE,
      to_date(sirfis.SUPPLIER_TENDER_DATE) as SUPPLIER_TENDER_DATE,
      'JPY' as BOOKING_CURRENCY,
      to_double(price.PRICE_ESTIMATE) as ESTIMATED_BOOKING_AMOUNT,
      to_date(sirfis.ENTERED_DATE) as RECORD_CREATED_DATE,
      to_date(sirfis.INTEL_RELEASED_DATE) as SIRFIS_RELEASED_DATE,
      to_date(sirfis.LATEST_DATE) as DATA_SNAPSHOT,
      concat(ADJUSTED_SITE, SALES_CATEGORY_TYPE, ENTITY) as FORECAST_KEY,
      sirfis.SUPPLIER_MAP
    from
      SIRFIS_LIFECYCLE sirfis
      left outer join IDs on IDs.FORECASTID = sirfis.ID
      left outer join SIRFIS_ITEM_HIERARCHY bu on bu.ID = sirfis.ID
      left outer join SIRFIS_PRICING price on price.ID = sirfis.ID
      left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__SIRFIS_AREA') }} area on area.SITE = bu.SITE
    where
      sirfis.EXPECTED_FORECAST_STATUS is not null
      and sirfis.EXPECTED_FORECAST_STATUS not ilike 'deleted'
      and price.PRICE_ESTIMATE is not null
      and sirfis.REQUESTED_TENDER_DATE >= '4/1/2021'
      and sirfis.REQUESTED_TENDER_DATE is not null
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        FORECAST_ID,
	    TOOL_PROCUREMENT_ID,
	    UNIQUE_EQUIPMENT_ID,
	    COPY_EXACT_ID,
	    AREA,
	    SITE,
	    ADJUSTED_SITE,
	    SUB_BU,
	    CATEGORY,
	    SALES_CATEGORY_TYPE,
	    ENTITY,
	    MODEL_QUOTE_NO,
	    DESCRIPTION,
	    PROCESS,
	    PO_NO,
	    PO_LINE_ITEM_NO,
	    PO_NO_LINE_ITEM_NO,
	    RTD_BASE_BOOKING_DATE,
	    PO_FIRST_LISTED_DATE,
	    IS_PO_RELEASED,
	    REQUESTED_TENDER_DATE,
	    SUPPLIER_TENDER_DATE,
	    BOOKING_CURRENCY,
	    ESTIMATED_BOOKING_AMOUNT,
	    RECORD_CREATED_DATE,
	    SIRFIS_RELEASED_DATE,
	    DATA_SNAPSHOT,
	    FORECAST_KEY,
	    SUPPLIER_MAP
FROM SOURCE_DATA
)
,
TYPE_DATA AS (
SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        FORECAST_ID,
	    TOOL_PROCUREMENT_ID,
	    UNIQUE_EQUIPMENT_ID,
	    COPY_EXACT_ID,
	    AREA,
	    SITE,
	    ADJUSTED_SITE,
	    SUB_BU,
	    CATEGORY,
	    SALES_CATEGORY_TYPE,
	    ENTITY,
	    MODEL_QUOTE_NO,
	    DESCRIPTION,
	    PROCESS,
	    PO_NO,
	    PO_LINE_ITEM_NO,
	    PO_NO_LINE_ITEM_NO,
	    RTD_BASE_BOOKING_DATE,
	    PO_FIRST_LISTED_DATE,
	    IS_PO_RELEASED,
	    REQUESTED_TENDER_DATE,
	    SUPPLIER_TENDER_DATE,
	    BOOKING_CURRENCY,
	    ESTIMATED_BOOKING_AMOUNT,
	    RECORD_CREATED_DATE,
	    SIRFIS_RELEASED_DATE,
	    DATA_SNAPSHOT,
	    FORECAST_KEY,
	    SUPPLIER_MAP
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA