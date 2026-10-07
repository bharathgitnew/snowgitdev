{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SIRFIS_REVENUE_FORECAST',
    transient=false
) }}

with
sirfisexpanded
as
(
select *,

    case when SUB_BU ilike 'TS'
            and not left(COPY_EXACT_ID, 3) ilike any ('PXA', 'PRE', 'PSP', 'HTP') --exclude Probers
            and CATEGORY ilike any ('MT', 'PK')
                -- or (CATEGORY ilike 'PKD' and MAX_SUPPLIER_TENDER_DATE < '11/1/2023')) --use when the scope expanded to before 11/1/2023
            then 'Split'
        when not SUB_BU ilike 'TS' 
            and CATEGORY ilike any ('MT', 'PK')
                -- or (CATEGORY ilike 'PKD' and MAX_SUPPLIER_TENDER_DATE < '11/1/2023')) --use when the scope expanded to before 11/1/2023
            then 'Split'
        else null 
    end                 as SPLIT_REVENUE
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SIRFIS_BOOKING_FORECAST') }} sirfis
),
Criteria_Ship_TSR
as
(
select *,
	case when (
                SALES_CATEGORY_TYPE ilike 'Modification' 
                    and to_double(ESTIMATED_BOOKING_AMOUNT) >= 10000000 
                    and MAX_SUPPLIER_TENDER_DATE <= '3/31/2025'
                )
            or (
                SALES_CATEGORY_TYPE ilike 'Modification' 
                    and to_double(ESTIMATED_BOOKING_AMOUNT) >= 20000000 
                    and MAX_SUPPLIER_TENDER_DATE >= '4/1/2025'
                )
            then 'TSR'
        else 'Ship' 
    end                 as Revenue_Recognition_Criteria
from sirfisexpanded
),
Criteria_Acceptance
as
(
select *,
    case when SPLIT_REVENUE = 'Split' then 'Acceptance'
        else null 
    end                 as Revenue_Recognition_Criteria
from sirfisexpanded
where Revenue_Recognition_Criteria is not null
),
SalesDocument
as
(
select *
from Criteria_Ship_TSR
union all
select *
from Criteria_Acceptance
),
SQF --2624
as
(
select
    tis.ID,
    base.UE_ID                      as UEID,
    config.ENTITY,
    config.SITE,
    config.EVENT_TYPE,
    config.BUSINESS_UNIT_SHORT_TEXT as SUB_BU,
    tis.MILESTONE_FINISH_DATE       as SUPPLIER_QUAL_FINISH_DATE,
    tis._FILEDATE                   as DATA_SNAPSHOT,
    case when base.SNAPSHOT_DATE < '2025-01-13' then base.SNAPSHOT_DATE
        else base._FILEDATE 
    end                             as DATA_TIMESTANP
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SIRFIS_TIS_MILESTONES_HISTORY') }} tis --3830
left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SIRFIS_TIS_ITEM_CONFIGURATION') }} config on config.ID = tis.ID
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__SIRFIS_TOOL_INSTALLATION_BASE') }} base on base.INSTALL_SCHEDULE_ID = tis.ID
where tis.MILESTONES_NAME ilike 'SUPPLIER%'
    and tis.MILESTONE_FINISH_DATE is not null
    and config.EVENT_TYPE ilike any ('%QUAL%', '%INSTALL%')
    and not config.EVENT_TYPE ilike '%FAC%'
    and upper(base.STATE) <> 'PAST'
    and base.MILESTONES_NAME ilike 'SUPPLIER%'
    and base.MILESTONES_FINISH is not null
    and base.EVENT_TYPE ilike any ('%QUAL%', '%INSTALL%')
    and not base.EVENT_TYPE ilike '%FAC%'
qualify row_number() over (partition by tis.ID order by DATA_TIMESTANP desc) = 1
),
MRCL --3069
as
(
select
    tis.ID,
    base.UE_ID                      as UEID,
    config.ENTITY,
    config.SITE,
    config.EVENT_TYPE,
    config.BUSINESS_UNIT_SHORT_TEXT as SUB_BU,
    tis.MILESTONE_FINISH_DATE       as MRCL_FINISH_DATE,
    tis._FILEDATE                   as DATA_SNAPSHOT,
    case when base.SNAPSHOT_DATE < '2025-01-13' then base.SNAPSHOT_DATE
        else base._FILEDATE 
    end                             as DATA_TIMESTANP
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SIRFIS_TIS_MILESTONES_HISTORY') }} tis --3830
left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SIRFIS_TIS_ITEM_CONFIGURATION') }} config on config.ID = tis.ID
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__SIRFIS_TOOL_INSTALLATION_BASE') }} base on base.INSTALL_SCHEDULE_ID = tis.ID
where tis.MILESTONES_NAME ilike 'MIRACLE'
    and tis.MILESTONE_FINISH_DATE is not null
    and config.EVENT_TYPE ilike any ('%QUAL%', '%INSTALL%')
    and not config.EVENT_TYPE ilike '%FAC%'
    and upper(base.STATE) <> 'PAST'
    and base.MILESTONES_NAME ilike 'MRCL'
    and base.MILESTONES_FINISH is not null
    and base.EVENT_TYPE ilike any ('%QUAL%', '%INSTALL%')
    and not base.EVENT_TYPE ilike '%FAC%'
qualify row_number() over (partition by tis.ID order by DATA_TIMESTANP desc) = 1
),
MRCL_ENTITY --2,718
as
(
select distinct
    SITE,
    ENTITY,
    SUB_BU,
    MRCL_FINISH_DATE,
    DATA_SNAPSHOT
from MRCL
qualify row_number() over (partition by SITE, ENTITY order by DATA_TIMESTANP desc) = 1
),
SQF_ENTITY --2,340
as
(
select distinct
    SITE,
    ENTITY,
    SUB_BU,
    SUPPLIER_QUAL_FINISH_DATE,
    DATA_SNAPSHOT
from SQF
qualify row_number() over (partition by SITE, ENTITY order by DATA_TIMESTANP desc) = 1
),
SITE_ENTITY --2,726
as
(
select
    SITE,
    ENTITY,
    SUB_BU
from MRCL_ENTITY

union
select
    SITE,
    ENTITY,
    SUB_BU
from SQF_ENTITY
),
TIS --2,726
as
(
select
    entity.ENTITY,
    entity.SITE,
    case when entity.SITE ilike 'D1%' then 'D1D'
        when entity.SITE ilike any('F34', 'SF24') then 'F24'
        when entity.SITE ilike 'F52' then 'F32'
        when entity.SITE ilike 'F28' then 'F38'
        when entity.SITE ilike 'SF11X' then 'F11X'
        when entity.SITE ilike 'KMP' then 'RA' --'KM2'
        when entity.SITE ilike 'RA-%' and entity.SUB_BU ilike 'TS' then 'RA'
        when entity.SITE ilike 'AL-%' then 'F15'
        else entity.SITE
    end                                             as ADJUSTED_SITE,
    sqf.SUPPLIER_QUAL_FINISH_DATE,
    mrcl.MRCL_FINISH_DATE,
    case when mrcl.DATA_SNAPSHOT >= sqf.DATA_SNAPSHOT 
            or sqf.DATA_SNAPSHOT is null then mrcl.DATA_SNAPSHOT
        else sqf.DATA_SNAPSHOT
    end                                             as DATA_SNAPSHOT,
    concat(ADJUSTED_SITE, 'Equipment', entity.ENTITY, 'Acceptance') as FORECAST_KEY
from SITE_ENTITY entity
left outer join SQF_ENTITY sqf on sqf.ENTITY = entity.ENTITY and sqf.SITE = entity.SITE
left outer join MRCL_ENTITY mrcl on mrcl.ENTITY = entity.ENTITY and mrcl.SITE = entity.SITE
),
SOURCE_DATA AS (
    select
    sd.SIRFIS_FORECAST_ID,
    sd.TOOL_PROCUREMENT_ID,
    sd.UNIQUE_EQUIPMENT_ID,
    sd.COPY_EXACT_ID,
    sd.END_USER,
    sd.AREA,
    sd.SITE,
    sd.ADJUSTED_SITE,
    sd.SUB_BU,
    sd.SALES_CATEGORY_TYPE,
    sd.CATEGORY,
    sd.REVENUE_RECOGNITION_CRITERIA,
    sd.ENTITY,
    sd.SUPPLIER_MAP,
    sd.MODEL_QUOTE_NO,
    sd.DESCRIPTION,
    sd.PROCESS,
    sd.PO_NO,
    sd.PO_LINE_ITEM_NO,
    -- sd.PO_NO_LINE_ITEM_NO, --PURCHASE_ORDER_NUMBER, PURCHASE_ORDER_LINE_NUMBER
    -- sd.MAX_REQUESTED_TENDER_DATE,
    -- sd.REQUESTED_TENDER_DATE_MT_PK,
    sd.MAX_SUPPLIER_TENDER_DATE,
    sd.SUPPLIER_TENDER_DATE_MT_PK,
    case when sd.REVENUE_RECOGNITION_CRITERIA ilike 'Acceptance' then tis.SUPPLIER_QUAL_FINISH_DATE
        else null
    end                                 as SUPPLIER_QUAL_FINISH_DATE,
    case when sd.REVENUE_RECOGNITION_CRITERIA ilike 'Acceptance' then tis.MRCL_FINISH_DATE
        else null
    end                                 as MRCL_FINISH_DATE,
    case when sd.Revenue_Recognition_Criteria ilike 'Ship' then sd.MAX_SUPPLIER_TENDER_DATE
        -- when sd.Revenue_Recognition_Criteria = 'Delivery' then dateadd(day, 7, sd.MAX_SUPPLIER_TENDER_DATE)
        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike '3DI' then dateadd(day, 180, sd.MAX_SUPPLIER_TENDER_DATE)
        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike 'CT' then dateadd(day, 220, sd.MAX_SUPPLIER_TENDER_DATE) --from ODD+230
        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike any ('ES', 'Certas') then dateadd(day, 365, sd.MAX_SUPPLIER_TENDER_DATE)
        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike 'SPS' then dateadd(day, 180, sd.MAX_SUPPLIER_TENDER_DATE)
        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike any ('TPS', 'SD', 'PVD') then dateadd(day, 120, sd.MAX_SUPPLIER_TENDER_DATE)
        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike 'TS' then dateadd(day, 150, sd.MAX_SUPPLIER_TENDER_DATE)
        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike 'FS%' then dateadd(day, 180, sd.MAX_SUPPLIER_TENDER_DATE)
        -- when sd.Revenue_Recognition_Criteria ilike 'TSR' then dateadd(day, 120, sd.MAX_SUPPLIER_TENDER_DATE)
        else null 
    end                                 as STD_BASE_SALES_DATE,
    BOOKING_CURRENCY                    as CURRENCY,
    round(
            case when sd.REVENUE_RECOGNITION_CRITERIA ilike 'Ship'              -- if not bringing anything other than MT and PKD or the time frame is limited, trim the logic
                and (
                        (
                        sd.SALES_CATEGORY_TYPE in ('Equipment', 'Pre-kit')
                            and sd.MAX_SUPPLIER_TENDER_DATE <= '10/31/2023'
                        )
                        or
                        (
                        sd.SALES_CATEGORY_TYPE ilike 'Equipment'
                            and sd.MAX_SUPPLIER_TENDER_DATE >= '11/1/2023' 
                            and sd.MAX_SUPPLIER_TENDER_DATE <= '3/31/2024'
                        )
                    )
            then 
            (
            case when sd.SUB_BU ilike 'CT' then sd.ESTIMATED_BOOKING_AMOUNT*.81 
                when sd.SUB_BU ilike 'SPS' then sd.ESTIMATED_BOOKING_AMOUNT*.86 
                when sd.SUB_BU ilike 'TPS' then sd.ESTIMATED_BOOKING_AMOUNT*.92 
                when sd.SUB_BU ilike 'SD' then sd.ESTIMATED_BOOKING_AMOUNT*.95 
                when sd.SUB_BU ilike 'PVD' then sd.ESTIMATED_BOOKING_AMOUNT*.90 
                when sd.SUB_BU ilike 'ES' then sd.ESTIMATED_BOOKING_AMOUNT*.95 
                when sd.SUB_BU ilike 'Certas' then sd.ESTIMATED_BOOKING_AMOUNT*.92 
                when sd.SUB_BU ilike 'TS' then sd.ESTIMATED_BOOKING_AMOUNT*.95 
                when sd.SUB_BU ilike '3DI' then sd.ESTIMATED_BOOKING_AMOUNT*.90 
                when sd.SUB_BU ilike 'FS%' then sd.ESTIMATED_BOOKING_AMOUNT*.90
                else null
            end
            )
            when sd.REVENUE_RECOGNITION_CRITERIA ilike 'Acceptance' 
                and (
                        (
                        sd.SALES_CATEGORY_TYPE in ('Equipment', 'Pre-kit') 
                            and sd.MAX_SUPPLIER_TENDER_DATE <= '10/31/2023'
                        )
                    or
                        (
                        sd.SALES_CATEGORY_TYPE ilike 'Equipment' 
                            and sd.MAX_SUPPLIER_TENDER_DATE >= '11/1/2023' 
                            and sd.MAX_SUPPLIER_TENDER_DATE <= '3/31/2024'
                        )
                    )      
            then 
            (
            case when sd.SUB_BU ilike 'CT' then sd.ESTIMATED_BOOKING_AMOUNT*.19 
                when sd.SUB_BU ilike 'SPS' then sd.ESTIMATED_BOOKING_AMOUNT*.14 
                when sd.SUB_BU ilike 'TPS' then sd.ESTIMATED_BOOKING_AMOUNT*.08 
                when sd.SUB_BU ilike 'SD' then sd.ESTIMATED_BOOKING_AMOUNT*.05 
                when sd.SUB_BU ilike 'PVD' then sd.ESTIMATED_BOOKING_AMOUNT*.10 
                when sd.SUB_BU ilike 'ES' then sd.ESTIMATED_BOOKING_AMOUNT*.05 
                when sd.SUB_BU ilike 'Certas' then sd.ESTIMATED_BOOKING_AMOUNT*.08 
                when sd.SUB_BU ilike 'TS' then sd.ESTIMATED_BOOKING_AMOUNT*.05 
                when sd.SUB_BU ilike '3DI' then sd.ESTIMATED_BOOKING_AMOUNT*.10 
                when sd.SUB_BU ilike 'FS%' then sd.ESTIMATED_BOOKING_AMOUNT*.10
                else null
            end
            )
            when sd.REVENUE_RECOGNITION_CRITERIA ilike 'Ship' 
                and sd.SALES_CATEGORY_TYPE ilike 'Equipment'
                and sd.MAX_SUPPLIER_TENDER_DATE >= '4/1/2024' 
             then 
             (
            case when sd.SUB_BU ilike 'CT' then sd.ESTIMATED_BOOKING_AMOUNT*.82 
                when sd.SUB_BU ilike 'SPS' then sd.ESTIMATED_BOOKING_AMOUNT*.83 
                when sd.SUB_BU ilike 'TPS' then sd.ESTIMATED_BOOKING_AMOUNT*.88 
                when sd.SUB_BU ilike 'SD' then sd.ESTIMATED_BOOKING_AMOUNT*.93 
                when sd.SUB_BU ilike 'PVD' then sd.ESTIMATED_BOOKING_AMOUNT*.89 
                when sd.SUB_BU ilike 'ES' then sd.ESTIMATED_BOOKING_AMOUNT*.94 
                when sd.SUB_BU ilike 'Certas' then sd.ESTIMATED_BOOKING_AMOUNT*.89 
                when sd.SUB_BU ilike 'TS' then sd.ESTIMATED_BOOKING_AMOUNT*.93 
                when sd.SUB_BU ilike '3DI' then sd.ESTIMATED_BOOKING_AMOUNT*.89 
                when sd.SUB_BU ilike 'FS%' then sd.ESTIMATED_BOOKING_AMOUNT*.91
                else null
            end
            )
            when sd.REVENUE_RECOGNITION_CRITERIA ilike 'Acceptance' 
                and sd.SALES_CATEGORY_TYPE ilike 'Equipment'
                and sd.MAX_SUPPLIER_TENDER_DATE >= '4/1/2024' 
             then 
             (
            case when sd.SUB_BU ilike 'CT' then sd.ESTIMATED_BOOKING_AMOUNT*.18 
                when sd.SUB_BU ilike 'SPS' then sd.ESTIMATED_BOOKING_AMOUNT*.17 
                when sd.SUB_BU ilike 'TPS' then sd.ESTIMATED_BOOKING_AMOUNT*.12 
                when sd.SUB_BU ilike 'SD' then sd.ESTIMATED_BOOKING_AMOUNT*.07 
                when sd.SUB_BU ilike 'PVD' then sd.ESTIMATED_BOOKING_AMOUNT*.11 
                when sd.SUB_BU ilike 'ES' then sd.ESTIMATED_BOOKING_AMOUNT*.06 
                when sd.SUB_BU ilike 'Certas' then sd.ESTIMATED_BOOKING_AMOUNT*.11 
                when sd.SUB_BU ilike 'TS' then sd.ESTIMATED_BOOKING_AMOUNT*.07 
                when sd.SUB_BU ilike '3DI' then sd.ESTIMATED_BOOKING_AMOUNT*.11 
                when sd.SUB_BU ilike 'FS%' then sd.ESTIMATED_BOOKING_AMOUNT*.09
                else null
            end
            )
            when sd.SALES_CATEGORY_TYPE ilike any ('Modification', 'Others')
                    or
                    (
                    sd.SALES_CATEGORY_TYPE ilike 'Pre-kit'
                        and sd.MAX_SUPPLIER_TENDER_DATE >= '11/1/2023'
                    ) 
                then sd.ESTIMATED_BOOKING_AMOUNT
            else null
        end, 
        0)                                              as ESTIMATED_SALES_AMOUNT_TEA,
    sd.RECORD_CREATED_DATE_MT_PK,
    sd.DATA_SNAPSHOT_MT_PK,
    sd.MAX_SIRFIS_RELEASED_DATE,
    sd.SIRFIS_RELEASED_DATE_MT_PK,
    concat(sd.FORECAST_KEY, sd.REVENUE_RECOGNITION_CRITERIA) as FORECAST_KEY,
    DateSirfis.fiscal_year_short_text                   as SIRFIS_REVENUE_FY, 
    DateSirfis.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT     as SIRFIS_REVENUE_FY_Half,
    DateSirfis.fiscal_year_quarter_short_text           as SIRFIS_REVENUE_FY_Q,
    to_date(DateSirfis.fiscal_year_beginning_date)      as SIRFIS_REVENUE_Beginning_of_FY,
    to_date(DateSirfis.fiscal_year_ending_date)         as SIRFIS_REVENUE_End_of_FY,
    to_date(DateSirfis.fiscal_half_year_beginning_date) as SIRFIS_REVENUE_Beginning_of_FY_Half,
    to_date(DateSirfis.fiscal_half_year_ending_date)    as SIRFIS_REVENUE_End_of_FY_Half,
    to_date(DateSirfis.fiscal_quarter_beginning_date)   as SIRFIS_REVENUE_Beginning_of_FY_Q,
    to_date(DateSirfis.fiscal_quarter_ending_date)      as SIRFIS_REVENUE_End_of_FY_Q,
	DateCurrent.FISCAL_YEAR_BEGINNING_DATE              as Beginning_of_Current_FY,
    DateCurrent.FISCAL_YEAR_ENDING_DATE                 as End_of_Current_FY,
	DateCurrent.FISCAL_HALF_YEAR_BEGINNING_DATE         as Beginning_of_Current_FY_Half,
	DateCurrent.FISCAL_HALF_YEAR_ENDING_DATE            as End_of_Current_FY_Half,
	DateCurrent.FISCAL_QUARTER_BEGINNING_DATE           as Beginning_of_Current_FY_Q,
	DateCurrent.FISCAL_QUARTER_ENDING_DATE              as End_of_Current_FY_Q,
	dateadd(year, 1, Beginning_of_Current_FY)           as Beginning_of_Next_FY,
	dateadd(year, 1, End_of_Current_FY)                 as End_of_Next_FY,
	dateadd(month, 6, Beginning_of_Current_FY_Half)                  as Beginning_of_Next_FY_Half,
	dateadd(day, -1, dateadd(year, 1, Beginning_of_Current_FY_Half)) as End_of_Next_FY_Half,
	dateadd(month, 3, Beginning_of_Current_FY_Q)                     as Beginning_of_Next_FY_Q,
	dateadd(day, -1, dateadd(month, 6, Beginning_of_Current_FY_Q))   as End_of_Next_FY_Q,
    dateadd(year, -1, Beginning_of_Current_FY)          as Beginning_of_Previous_FY,
	dateadd(year, -1, End_of_Current_FY)                as End_of_Previous_FY,
	dateadd(month, -6, Beginning_of_Current_FY_Half)    as Beginning_of_Previous_FY_Half,
	dateadd(day, -1, Beginning_of_Current_FY_Half)      as End_of_Previous_FY_Half,
	dateadd(month, -3, Beginning_of_Current_FY_Q)       as Beginning_of_Previous_FY_Q,
	dateadd(day, -1, Beginning_of_Current_FY_Q)         as End_of_Previous_FY_Q,
	dateadd(year, -2, Beginning_of_Current_FY)          as Beginning_of_2_FY_Ago,
	dateadd(year, 2, End_of_Current_FY)                 as End_of_2_FY_Ahead,
    STD_BASE_SALES_DATE                                 as SIRFIS_Revenue_Forecast_FK_Date
from SalesDocument sd 
left outer join tis on tis.FORECAST_KEY = concat(sd.FORECAST_KEY, sd.REVENUE_RECOGNITION_CRITERIA) --tis.ENTITY = sd.ENTITY
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} DateSirfis on DateSIRFIS.calendar_date = 
                                                                case when sd.Revenue_Recognition_Criteria ilike 'Ship' then sd.MAX_SUPPLIER_TENDER_DATE
                                                                    -- when sd.Revenue_Recognition_Criteria ilike 'Delivery' then dateadd(day, 7, sd.SHIP_DATE)
                                                                    when sd.Revenue_Recognition_Criteria ilike 'Acceptance' then case when sd.Revenue_Recognition_Criteria ilike 'Ship' then sd.MAX_SUPPLIER_TENDER_DATE
                                                                                                                                        -- when sd.Revenue_Recognition_Criteria = 'Delivery' then dateadd(day, 7, sd.MAX_SUPPLIER_TENDER_DATE)
                                                                                                                                        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike '3DI' then dateadd(day, 180, sd.MAX_SUPPLIER_TENDER_DATE)
                                                                                                                                        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike 'CT' then dateadd(day, 220, sd.MAX_SUPPLIER_TENDER_DATE) --from ODD+230
                                                                                                                                        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike any ('ES', 'Certas') then dateadd(day, 365, sd.MAX_SUPPLIER_TENDER_DATE)
                                                                                                                                        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike 'SPS' then dateadd(day, 180, sd.MAX_SUPPLIER_TENDER_DATE)
                                                                                                                                        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike any ('TPS', 'SD', 'PVD') then dateadd(day, 120, sd.MAX_SUPPLIER_TENDER_DATE)
                                                                                                                                        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike 'TS' then dateadd(day, 150, sd.MAX_SUPPLIER_TENDER_DATE)
                                                                                                                                        when sd.Revenue_Recognition_Criteria ilike 'Acceptance' and SUB_BU ilike 'FS%' then dateadd(day, 180, sd.MAX_SUPPLIER_TENDER_DATE)
                                                                                                                                        -- when sd.Revenue_Recognition_Criteria ilike 'TSR' then dateadd(day, 120, sd.MAX_SUPPLIER_TENDER_DATE)
                                                                                                                                        else null 
                                                                                                                                 end
                                                                    -- when sd.Revenue_Recognition_Criteria ilike 'TSR' then dateadd(day, 120, sd.MAX_SUPPLIER_TENDER_DATE)
                                                                    else null 
                                                                end
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} DateCurrent on DateCurrent.calendar_date = current_date()
order by sd.ENTITY asc, sd.REVENUE_RECOGNITION_CRITERIA asc
),
TRANSFORM_DATA AS (
  SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') AS _ROW_HASH,
    SIRFIS_FORECAST_ID,
	TOOL_PROCUREMENT_ID,
	UNIQUE_EQUIPMENT_ID,
	COPY_EXACT_ID,
	END_USER,
	AREA,
	SITE,
	ADJUSTED_SITE,
	SUB_BU,
	SALES_CATEGORY_TYPE,
	CATEGORY,
	REVENUE_RECOGNITION_CRITERIA,
	ENTITY,
	SUPPLIER_MAP,
	MODEL_QUOTE_NO,
	DESCRIPTION,
	PROCESS,
	PO_NO,
	PO_LINE_ITEM_NO,
	MAX_SUPPLIER_TENDER_DATE,
	SUPPLIER_TENDER_DATE_MT_PK,
	SUPPLIER_QUAL_FINISH_DATE,
	MRCL_FINISH_DATE,
	STD_BASE_SALES_DATE,
	CURRENCY,
	ESTIMATED_SALES_AMOUNT_TEA,
	RECORD_CREATED_DATE_MT_PK,
	DATA_SNAPSHOT_MT_PK,
	MAX_SIRFIS_RELEASED_DATE,
	SIRFIS_RELEASED_DATE_MT_PK,
	FORECAST_KEY,
	SIRFIS_REVENUE_FY,
	SIRFIS_REVENUE_FY_HALF,
	SIRFIS_REVENUE_FY_Q,
	SIRFIS_REVENUE_BEGINNING_OF_FY,
	SIRFIS_REVENUE_END_OF_FY,
	SIRFIS_REVENUE_BEGINNING_OF_FY_HALF,
	SIRFIS_REVENUE_END_OF_FY_HALF,
	SIRFIS_REVENUE_BEGINNING_OF_FY_Q,
	SIRFIS_REVENUE_END_OF_FY_Q,
	BEGINNING_OF_CURRENT_FY,
	END_OF_CURRENT_FY,
	BEGINNING_OF_CURRENT_FY_HALF,
	END_OF_CURRENT_FY_HALF,
	BEGINNING_OF_CURRENT_FY_Q,
	END_OF_CURRENT_FY_Q,
	BEGINNING_OF_NEXT_FY,
	END_OF_NEXT_FY,
	BEGINNING_OF_NEXT_FY_HALF,
	END_OF_NEXT_FY_HALF,
	BEGINNING_OF_NEXT_FY_Q,
	END_OF_NEXT_FY_Q,
	BEGINNING_OF_PREVIOUS_FY,
	END_OF_PREVIOUS_FY,
	BEGINNING_OF_PREVIOUS_FY_HALF,
	END_OF_PREVIOUS_FY_HALF,
	BEGINNING_OF_PREVIOUS_FY_Q,
	END_OF_PREVIOUS_FY_Q,
	BEGINNING_OF_2_FY_AGO,
	END_OF_2_FY_AHEAD,
	SIRFIS_REVENUE_FORECAST_FK_DATE
  FROM SOURCE_DATA
)
,
TYPE_DATA AS (
  SELECT
    cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
    cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
    SIRFIS_FORECAST_ID,
	TOOL_PROCUREMENT_ID,
	UNIQUE_EQUIPMENT_ID,
	COPY_EXACT_ID,
	END_USER,
	AREA,
	SITE,
	ADJUSTED_SITE,
	SUB_BU,
	SALES_CATEGORY_TYPE,
	CATEGORY,
	REVENUE_RECOGNITION_CRITERIA,
	ENTITY,
	SUPPLIER_MAP,
	MODEL_QUOTE_NO,
	DESCRIPTION,
	PROCESS,
	PO_NO,
	PO_LINE_ITEM_NO,
	MAX_SUPPLIER_TENDER_DATE,
	SUPPLIER_TENDER_DATE_MT_PK,
	SUPPLIER_QUAL_FINISH_DATE,
	MRCL_FINISH_DATE,
	STD_BASE_SALES_DATE,
	CURRENCY,
	ESTIMATED_SALES_AMOUNT_TEA,
	RECORD_CREATED_DATE_MT_PK,
	DATA_SNAPSHOT_MT_PK,
	MAX_SIRFIS_RELEASED_DATE,
	SIRFIS_RELEASED_DATE_MT_PK,
	FORECAST_KEY,
	SIRFIS_REVENUE_FY,
	SIRFIS_REVENUE_FY_HALF,
	SIRFIS_REVENUE_FY_Q,
	SIRFIS_REVENUE_BEGINNING_OF_FY,
	SIRFIS_REVENUE_END_OF_FY,
	SIRFIS_REVENUE_BEGINNING_OF_FY_HALF,
	SIRFIS_REVENUE_END_OF_FY_HALF,
	SIRFIS_REVENUE_BEGINNING_OF_FY_Q,
	SIRFIS_REVENUE_END_OF_FY_Q,
	BEGINNING_OF_CURRENT_FY,
	END_OF_CURRENT_FY,
	BEGINNING_OF_CURRENT_FY_HALF,
	END_OF_CURRENT_FY_HALF,
	BEGINNING_OF_CURRENT_FY_Q,
	END_OF_CURRENT_FY_Q,
	BEGINNING_OF_NEXT_FY,
	END_OF_NEXT_FY,
	BEGINNING_OF_NEXT_FY_HALF,
	END_OF_NEXT_FY_HALF,
	BEGINNING_OF_NEXT_FY_Q,
	END_OF_NEXT_FY_Q,
	BEGINNING_OF_PREVIOUS_FY,
	END_OF_PREVIOUS_FY,
	BEGINNING_OF_PREVIOUS_FY_HALF,
	END_OF_PREVIOUS_FY_HALF,
	BEGINNING_OF_PREVIOUS_FY_Q,
	END_OF_PREVIOUS_FY_Q,
	BEGINNING_OF_2_FY_AGO,
	END_OF_2_FY_AHEAD,
	SIRFIS_REVENUE_FORECAST_FK_DATE
  FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA