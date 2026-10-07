{{ config(
       materialized='tel_incremental'  ,
    incremental_strategy='insert_overwrite'  ,
    alias='MSBI_VF_BY_STOCKROOM'  ,
    tags=['MSBI']
) }}

with MSBI_RAW as (
select
    WIINGS_LOCATION,
    SPN,
    Stockroom,
    sum(MAX_QTY) as MAX_QTY,
    sum(ROP_Qty1) as ROP_Qty1,
    sum(Qty_Avail) as Qty_Avail,
    sum(Reject_Qty) as Reject_Qty,
    sum(On_Hand_Qty) as On_Hand_Qty,
    sum(QTY_ON_HOLD) as QTY_ON_HOLD,
    sum(TOTAL_IN_RECEIPT_QTY) as TOTAL_IN_RECEIPT_QTY,
    sum(Open_Customer_Order_Qty) as Open_Customer_Order_Qty,
    sum(Month_12_Consumption) as Month_12_Consumption,
    sum(Month_11_Consumption) as Month_11_Consumption,
    sum(Month_10_Consumption) as Month_10_Consumption,
    sum(Month_09_Consumption) as Month_09_Consumption,
    sum(Month_08_Consumption) as Month_08_Consumption,
    sum(Month_07_Consumption) as Month_07_Consumption,
    sum(Month_06_Consumption) as Month_06_Consumption,
    sum(Month_05_Consumption) as Month_05_Consumption,
    sum(Month_04_Consumption) as Month_04_Consumption,
    sum(Month_03_Consumption) as Month_03_Consumption,
    sum(Month_02_Consumption) as Month_02_Consumption,
    sum(Month_01_Consumption) as Month_01_Consumption,
    sum(CURRENT_MONTH_CONSUMPTION) as CURRENT_MONTH_CONSUMPTION,
    _FILENAME
    from {{ ref('BRONZE__TEA_INTEL_SMS__FILE_INTEL_MSBI_FULL_ITEM_BOM') }}
    group by _FILENAME, WIINGS_LOCATION, SPN, Stockroom
),

MSBI as (
  select
    try_to_date(REGEXP_SUBSTR(_Filename, '\\d{4}-\\d{2}-\\d{2}'),'YYYY-MM-DD') as FILEDATE,
    ROW_NUMBER() OVER (
      ORDER BY
        WIINGS_LOCATION,
        SPN,
        Stockroom
    ) as serial_no,
    WIINGS_LOCATION,
    SPN,
    Stockroom,
    MAX_QTY as SIMI_MAX,
    ROP_Qty1 as SIMI_ROP,
    Qty_Avail as SIMI_QTY_AVAILABLE,
    Reject_Qty as SIMI_REJECT_QTY,
    On_Hand_Qty as SIMI_OH_QTY,
    QTY_ON_HOLD as SIMI_ON_HOLD_QTY,
    ZEROIFNULL(TOTAL_IN_RECEIPT_QTY) as SIMI_IN_RECEIPTS_QTY,
    Open_Customer_Order_Qty as SIMI_OPEN_ORDER_QTY,
    Month_12_Consumption,
    Month_11_Consumption,
    Month_10_Consumption,
    Month_09_Consumption,
    Month_08_Consumption,
    Month_07_Consumption,
    Month_06_Consumption,
    Month_05_Consumption,
    Month_04_Consumption,
    Month_03_Consumption,
    Month_02_Consumption,
    Month_01_Consumption,
    CURRENT_MONTH_CONSUMPTION,
    (
      case when Month_01_Consumption > 0 then 1 else 0 end
    ) + (
      case when CURRENT_MONTH_CONSUMPTION > 0 then 1 else 0 end
    ) + (
      case when Month_02_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_03_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_04_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_05_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_06_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_07_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_08_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_09_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_10_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_11_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_12_Consumption > 0 then 1 else 0 end
    ) as MOU,
    (
      case when Month_01_Consumption > 0 then 1 else 0 end
    ) +(
      case when Month_03_Consumption > 0 then 1 else 0 end
    ) + (
      case when Month_02_Consumption > 0 then 1 else 0 end
    ) as SIMI_3M_MOU,
    Month_12_Consumption + Month_11_Consumption + Month_10_Consumption + Month_09_Consumption + Month_08_Consumption + Month_07_Consumption + Month_06_Consumption + Month_05_Consumption + Month_04_Consumption + Month_03_Consumption + Month_02_Consumption + Month_01_Consumption as SIMI_12M_USE,
    SIMI_12M_USE / 12 as SIMI_12M_AVG,
    Month_01_Consumption + CURRENT_MONTH_CONSUMPTION + Month_02_Consumption as SIMI_M0_to_M2_USE,
    SIMI_M0_to_M2_USE / 3 as SIMI_M0_to_M2_avg,
    Month_01_Consumption + Month_03_Consumption + Month_02_Consumption as SIMI_3M_USE,
    SIMI_3M_USE / 3 as SIMI_3M_avg,
    SIMI_3M_USE / 91.5 as SIMI_3M_ADU,
    SIMI_3M_USE + CURRENT_MONTH_CONSUMPTION as SIMI_3M_C_Use,
    SIMI_3M_C_Use / 4 as SIMI_3M_C_avg,
    (
      Month_01_Consumption + Month_03_Consumption + Month_02_Consumption + CURRENT_MONTH_CONSUMPTION
    ) / 91.5 as SIMI_3M_C_ADU,
    Month_01_Consumption + Month_03_Consumption + Month_02_Consumption + Month_04_Consumption + Month_05_Consumption + Month_06_Consumption as SIMI_6M_USE,
    SIMI_6M_USE / 6 as SIMI_6M_AVG,
    case when (
      (
        SIMI_3M_avg + Month_01_Consumption
      )/ 2
    )/ 30.4 > SIMI_3M_ADU then (
      (
        SIMI_3M_avg + Month_01_Consumption
      )/ 2
    )/ 30.4 else SIMI_3M_ADU end as TEL_Sugg_DOI,
    case when MOU > 0 then TEL_Sugg_DOI else 0 end as TEL_Avg_Daily_Use,
    case when (
      (
        SIMI_3M_C_avg + CURRENT_MONTH_CONSUMPTION
      )/ 2
    )/ 30.4 > SIMI_3M_C_ADU then (
      (
        SIMI_3M_C_avg + CURRENT_MONTH_CONSUMPTION
      )/ 2
    )/ 30.4 else SIMI_3M_C_ADU end as TEL_Sugg_DOI_New,
    case when MOU > 0 then TEL_Sugg_DOI_New else 0 end as TEL_Avg_Daily_Use_New,
    round(
      (
        case when MOU > 0 then TEL_Avg_Daily_Use * 30 else 0 end
      ),
      0
    ) as TEL_30_DOI_QTY,
    round(TEL_30_DOI_QTY * 1.23) as TEL_37_DOI_QTY,
    round(TEL_30_DOI_QTY * 1.5) as TEL_45_DOI_QTY,
    round(TEL_30_DOI_QTY * 2) as TEL_60_DOI_QTY,
    round(TEL_30_DOI_QTY * 3) as TEL_90_DOI_QTY,
    round(TEL_30_DOI_QTY * 4) as TEL_120_DOI_QTY,
    case when TEL_45_DOI_QTY < 1
    and SIMI_QTY_AVAILABLE > 0 then 365 else (
      case when TEL_Avg_Daily_Use = 0
      and SIMI_QTY_AVAILABLE > 0 then 365 else (
        case when TEL_Avg_Daily_Use > 0 then SIMI_QTY_AVAILABLE / TEL_Avg_Daily_Use else 0 end
      ) end
    ) end as TEL_DOI,
    round(
      case when MOU > 0 then TEL_Avg_Daily_Use_New * 30 else 0 end
    ) as TEL_30_DOI_QTY_New,
    round(TEL_30_DOI_QTY_New * 1.23) as TEL_37_DOI_QTY_New,
    round(TEL_30_DOI_QTY_New * 1.5) as TEL_45_DOI_QTY_New,
    round(TEL_30_DOI_QTY_New * 2) as TEL_60_DOI_QTY_New,
    round(TEL_30_DOI_QTY_New * 3) as TEL_90_DOI_QTY_New,
    round(TEL_30_DOI_QTY_New * 4) as TEL_120_DOI_QTY_New,
    case when TEL_45_DOI_QTY_New < 1
    and SIMI_QTY_AVAILABLE > 0 then 365 else (
      case when TEL_Avg_Daily_Use_New = 0
      and SIMI_QTY_AVAILABLE > 0 then 365 else (
        case when TEL_Avg_Daily_Use_New > 0 then SIMI_QTY_AVAILABLE / TEL_Avg_Daily_Use_New else 0 end
      ) end
    ) end as TEL_DOI_NEW
  FROM
    MSBI_RAW
),
stand_dev_12 as (
  SELECT
    serial_no,
    Month_12_Consumption as Month_12
  FROM
    msbi
  UNION all
  SELECT
    serial_no,
    Month_11_Consumption as Month_12
  FROM
    msbi
  UNION all
  SELECT
    serial_no,
    Month_10_Consumption as Month_12
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_09_Consumption as Month_12
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_08_Consumption as Month_12
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_07_Consumption as Month_12
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_06_Consumption as Month_12
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_05_Consumption as Month_12
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_04_Consumption as Month_12
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_03_Consumption as Month_12
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_02_Consumption as Month_12
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_01_Consumption as Month_12
  FROM
    msbi
),
stand_dev_agg_12 as (
  select
    serial_no,
    STDDEV(Month_12) as Month_12
  from
    stand_dev_12
  group by
    serial_no
),
stand_dev_0_2 as(
  SELECT
    serial_no,
    CURRENT_MONTH_CONSUMPTION as Month_0_2
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_02_Consumption as Month_0_2
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_01_Consumption as Month_0_2
  FROM
    msbi
),
stand_dev_agg_0_2 as (
  select
    serial_no,
    STDDEV(Month_0_2) as Month_0_2
  from
    stand_dev_0_2
  group by
    serial_no
),
stand_dev_3 as(
  SELECT
    serial_no,
    Month_03_Consumption as Month_3
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_02_Consumption as Month_3
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_01_Consumption as Month_3
  FROM
    msbi
),
stand_dev_agg_3 as (
  select
    serial_no,
    STDDEV(Month_3) as Month_3
  from
    stand_dev_3
  group by
    serial_no
),
stand_dev_6 as(
  SELECT
    serial_no,
    Month_06_Consumption as Month_6
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_05_Consumption as Month_6
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_04_Consumption as Month_6
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_03_Consumption as Month_6
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_02_Consumption as Month_6
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_01_Consumption as Month_6
  FROM
    msbi
),
stand_dev_agg_6 as (
  select
    serial_no,
    STDDEV(Month_6) as Month_6
  from
    stand_dev_6
  group by
    serial_no
),
stand_dev_3_C as(
  SELECT
    serial_no,
    CURRENT_MONTH_CONSUMPTION as Month_3_C
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_02_Consumption as Month_3_C
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_01_Consumption as Month_3_C
  FROM
    msbi
  union all
  SELECT
    serial_no,
    Month_03_Consumption as Month_3_C
  FROM
    msbi
),
stand_dev_agg_3_C as (
  select
    serial_no,
    STDDEV(Month_3_C) as Month_3_C
  from
    stand_dev_3_C
  group by
    serial_no
),

source_data as (
  select
    WIINGS_LOCATION,
    msbi.SPN,
    Stockroom,
    msbi.SIMI_MAX,
    msbi.SIMI_ROP,
    msbi.SIMI_QTY_AVAILABLE,
    msbi.SIMI_REJECT_QTY,
    msbi.SIMI_OH_QTY,
    msbi.SIMI_ON_HOLD_QTY,
    msbi.SIMI_IN_RECEIPTS_QTY,
    msbi.SIMI_OPEN_ORDER_QTY,
    Month_12_Consumption,
    Month_11_Consumption,
    Month_10_Consumption,
    Month_09_Consumption,
    Month_08_Consumption,
    Month_07_Consumption,
    Month_06_Consumption,
    Month_05_Consumption,
    Month_04_Consumption,
    Month_03_Consumption,
    Month_02_Consumption,
    Month_01_Consumption,
    CURRENT_MONTH_CONSUMPTION,
    MOU,
    SIMI_3M_MOU,
    SIMI_12M_USE,
    SIMI_12M_AVG,
    stand_dev_agg_12.Month_12 as Month_12_dev,
    SIMI_M0_to_M2_USE,
    SIMI_M0_to_M2_avg,
    stand_dev_agg_0_2.Month_0_2 as Month_0_2_dev,
    SIMI_3M_USE,
    SIMI_3M_avg,
    stand_dev_agg_3.Month_3 as Month_3_dev,
    SIMI_3M_ADU,
    SIMI_3M_C_Use,
    SIMI_3M_C_avg,
    stand_dev_agg_3_c.Month_3_C as Month_3_C_dev,
    SIMI_3M_C_ADU,
    SIMI_6M_USE,
    SIMI_6M_AVG,
    stand_dev_agg_6.Month_6 as Month_6_dev,
    TEL_Sugg_DOI,
    TEL_Avg_Daily_Use,
    TEL_Sugg_DOI_New,
    TEL_Avg_Daily_Use_New,
    tEL_30_DOI_QTY,
    TEL_37_DOI_QTY,
    TEL_45_DOI_QTY,
    TEL_60_DOI_QTY,
    TEL_90_DOI_QTY,
    TEL_120_DOI_QTY,
    TEL_DOI,
    TEL_30_DOI_QTY_New,
    TEL_37_DOI_QTY_New,
    TEL_45_DOI_QTY_New,
    TEL_60_DOI_QTY_New,
    TEL_90_DOI_QTY_New,
    TEL_120_DOI_QTY_New,
    TEL_DOI_NEW,
    FILEDATE
  from
    msbi as msbi
    left join stand_dev_agg_12 as stand_dev_agg_12 on stand_dev_agg_12.serial_no = msbi.serial_no
    left join stand_dev_agg_0_2 as stand_dev_agg_0_2 on stand_dev_agg_0_2.serial_no = msbi.serial_no
    left join stand_dev_agg_3 as stand_dev_agg_3 on stand_dev_agg_3.serial_no = msbi.serial_no
    left join stand_dev_agg_3_C as stand_dev_agg_3_C on stand_dev_agg_3_C.serial_no = msbi.serial_no
    left join stand_dev_agg_6 as stand_dev_agg_6 on stand_dev_agg_6.serial_no = msbi.serial_no
),
	transform_data as (
  select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		WIINGS_LOCATION,
		SPN,
		STOCKROOM,
		IFNULL(SIMI_MAX,0) as SIMI_MAX,
		IFNULL(SIMI_ROP,0) as SIMI_ROP,
		SIMI_QTY_AVAILABLE,
		SIMI_REJECT_QTY,
		SIMI_OH_QTY,
		SIMI_ON_HOLD_QTY,
		SIMI_IN_RECEIPTS_QTY,
		SIMI_OPEN_ORDER_QTY,
		MONTH_12_CONSUMPTION,
		MONTH_11_CONSUMPTION,
		MONTH_10_CONSUMPTION,
		MONTH_09_CONSUMPTION,
		MONTH_08_CONSUMPTION,
		MONTH_07_CONSUMPTION,
		MONTH_06_CONSUMPTION,
		MONTH_05_CONSUMPTION,
		MONTH_04_CONSUMPTION,
		MONTH_03_CONSUMPTION,
		MONTH_02_CONSUMPTION,
		MONTH_01_CONSUMPTION,
		CURRENT_MONTH_CONSUMPTION,
		MOU,
		SIMI_3M_MOU,
		SIMI_12M_USE,
		SIMI_12M_AVG,
		MONTH_12_DEV,
		SIMI_M0_TO_M2_USE,
		SIMI_M0_TO_M2_AVG,
		MONTH_0_2_DEV,
		SIMI_3M_USE,
		SIMI_3M_AVG,
		MONTH_3_DEV,
		SIMI_3M_ADU,
		SIMI_3M_C_USE,
		SIMI_3M_C_AVG,
		MONTH_3_C_DEV,
		SIMI_3M_C_ADU,
		SIMI_6M_USE,
		SIMI_6M_AVG,
		MONTH_6_DEV,
		TEL_SUGG_DOI,
		TEL_AVG_DAILY_USE,
		TEL_SUGG_DOI_NEW,
		TEL_AVG_DAILY_USE_NEW,
		TEL_30_DOI_QTY,
		TEL_37_DOI_QTY,
		TEL_45_DOI_QTY,
		TEL_60_DOI_QTY,
		TEL_90_DOI_QTY,
		TEL_120_DOI_QTY,
		TEL_DOI,
		TEL_30_DOI_QTY_NEW,
		TEL_37_DOI_QTY_NEW,
		TEL_45_DOI_QTY_NEW,
		TEL_60_DOI_QTY_NEW,
		TEL_90_DOI_QTY_NEW,
		TEL_120_DOI_QTY_NEW,
		TEL_DOI_NEW,
		FILEDATE
  from
    source_data
),
	type_data as (
    SELECT
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		CAST(WIINGS_LOCATION as VARCHAR(16777216)) as WIINGS_LOCATION,
		CAST(SPN as VARCHAR(16777216)) as SPN,
		CAST(STOCKROOM as VARCHAR(16777216)) as STOCKROOM,
		CAST(SIMI_MAX as VARCHAR(16777216)) as SIMI_MAX,
		CAST(SIMI_ROP as VARCHAR(16777216)) as SIMI_ROP,
		CAST(SIMI_QTY_AVAILABLE as VARCHAR(16777216)) as SIMI_QTY_AVAILABLE,
		CAST(SIMI_REJECT_QTY as VARCHAR(16777216)) as SIMI_REJECT_QTY,
		CAST(SIMI_OH_QTY as VARCHAR(16777216)) as SIMI_OH_QTY,
		CAST(SIMI_ON_HOLD_QTY as VARCHAR(16777216)) as SIMI_ON_HOLD_QTY,
		CAST(SIMI_IN_RECEIPTS_QTY as FLOAT) as SIMI_IN_RECEIPTS_QTY,
		CAST(SIMI_OPEN_ORDER_QTY as VARCHAR(16777216)) as SIMI_OPEN_ORDER_QTY,
		CAST(MONTH_12_CONSUMPTION as VARCHAR(16777216)) as MONTH_12_CONSUMPTION,
		CAST(MONTH_11_CONSUMPTION as VARCHAR(16777216)) as MONTH_11_CONSUMPTION,
		CAST(MONTH_10_CONSUMPTION as VARCHAR(16777216)) as MONTH_10_CONSUMPTION,
		CAST(MONTH_09_CONSUMPTION as VARCHAR(16777216)) as MONTH_09_CONSUMPTION,
		CAST(MONTH_08_CONSUMPTION as VARCHAR(16777216)) as MONTH_08_CONSUMPTION,
		CAST(MONTH_07_CONSUMPTION as VARCHAR(16777216)) as MONTH_07_CONSUMPTION,
		CAST(MONTH_06_CONSUMPTION as VARCHAR(16777216)) as MONTH_06_CONSUMPTION,
		CAST(MONTH_05_CONSUMPTION as VARCHAR(16777216)) as MONTH_05_CONSUMPTION,
		CAST(MONTH_04_CONSUMPTION as VARCHAR(16777216)) as MONTH_04_CONSUMPTION,
		CAST(MONTH_03_CONSUMPTION as VARCHAR(16777216)) as MONTH_03_CONSUMPTION,
		CAST(MONTH_02_CONSUMPTION as VARCHAR(16777216)) as MONTH_02_CONSUMPTION,
		CAST(MONTH_01_CONSUMPTION as VARCHAR(16777216)) as MONTH_01_CONSUMPTION,
		CAST(CURRENT_MONTH_CONSUMPTION as VARCHAR(16777216)) as CURRENT_MONTH_CONSUMPTION,
		CAST(MOU as NUMBER(13,0)) as MOU,
		CAST(SIMI_3M_MOU as NUMBER(3,0)) as SIMI_3M_MOU,
		CAST(SIMI_12M_USE as FLOAT) as SIMI_12M_USE,
		CAST(SIMI_12M_AVG as FLOAT) as SIMI_12M_AVG,
		CAST(MONTH_12_DEV as FLOAT) as MONTH_12_DEV,
		CAST(SIMI_M0_TO_M2_USE as FLOAT) as SIMI_M0_TO_M2_USE,
		CAST(SIMI_M0_TO_M2_AVG as FLOAT) as SIMI_M0_TO_M2_AVG,
		CAST(MONTH_0_2_DEV as FLOAT) as MONTH_0_2_DEV,
		CAST(SIMI_3M_USE as FLOAT) as SIMI_3M_USE,
		CAST(SIMI_3M_AVG as FLOAT) as SIMI_3M_AVG,
		CAST(MONTH_3_DEV as FLOAT) as MONTH_3_DEV,
		CAST(SIMI_3M_ADU as FLOAT) as SIMI_3M_ADU,
		CAST(SIMI_3M_C_USE as FLOAT) as SIMI_3M_C_USE,
		CAST(SIMI_3M_C_AVG as FLOAT) as SIMI_3M_C_AVG,
		CAST(MONTH_3_C_DEV as FLOAT) as MONTH_3_C_DEV,
		CAST(SIMI_3M_C_ADU as FLOAT) as SIMI_3M_C_ADU,
		CAST(SIMI_6M_USE as FLOAT) as SIMI_6M_USE,
		CAST(SIMI_6M_AVG as FLOAT) as SIMI_6M_AVG,
		CAST(MONTH_6_DEV as FLOAT) as MONTH_6_DEV,
		CAST(TEL_SUGG_DOI as FLOAT) as TEL_SUGG_DOI,
		CAST(TEL_AVG_DAILY_USE as FLOAT) as TEL_AVG_DAILY_USE,
		CAST(TEL_SUGG_DOI_NEW as FLOAT) as TEL_SUGG_DOI_NEW,
		CAST(TEL_AVG_DAILY_USE_NEW as FLOAT) as TEL_AVG_DAILY_USE_NEW,
		CAST(TEL_30_DOI_QTY as FLOAT) as TEL_30_DOI_QTY,
		CAST(TEL_37_DOI_QTY as FLOAT) as TEL_37_DOI_QTY,
		CAST(TEL_45_DOI_QTY as FLOAT) as TEL_45_DOI_QTY,
		CAST(TEL_60_DOI_QTY as FLOAT) as TEL_60_DOI_QTY,
		CAST(TEL_90_DOI_QTY as FLOAT) as TEL_90_DOI_QTY,
		CAST(TEL_120_DOI_QTY as FLOAT) as TEL_120_DOI_QTY,
		CAST(TEL_DOI as FLOAT) as TEL_DOI,
		CAST(TEL_30_DOI_QTY_NEW as FLOAT) as TEL_30_DOI_QTY_NEW,
		CAST(TEL_37_DOI_QTY_NEW as FLOAT) as TEL_37_DOI_QTY_NEW,
		CAST(TEL_45_DOI_QTY_NEW as FLOAT) as TEL_45_DOI_QTY_NEW,
		CAST(TEL_60_DOI_QTY_NEW as FLOAT) as TEL_60_DOI_QTY_NEW,
		CAST(TEL_90_DOI_QTY_NEW as FLOAT) as TEL_90_DOI_QTY_NEW,
		CAST(TEL_120_DOI_QTY_NEW as FLOAT) as TEL_120_DOI_QTY_NEW,
		CAST(TEL_DOI_NEW as FLOAT) as TEL_DOI_NEW,
		CAST(FILEDATE as DATE) as FILEDATE
    From transform_data
)
select
  *
from
  type_data