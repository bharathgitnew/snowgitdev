{{ config(
       materialized='tel_incremental'  ,
    incremental_strategy='insert_overwrite'  ,
    alias='MSBI_VF_TEE'  ,
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
    where Stockroom in ( 'F24 Copper St (90)', 'F24 Stores (91)','F28 Copper (102)', 'F28 Stores (21)' )
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
--    WIINGS_LOCATION,
msbi.SPN as TEE_SPN,
--    Stockroom,
sum(msbi.SIMI_MAX) as TEE_SIMI_MAX,
sum(msbi.SIMI_ROP) as TEE_SIMI_ROP,
sum(msbi.SIMI_QTY_AVAILABLE) as TEE_SIMI_QTY_AVAILABLE,
sum(msbi.SIMI_REJECT_QTY) as TEE_SIMI_REJECT_QTY,
sum(msbi.SIMI_OH_QTY) as TEE_SIMI_OH_QTY,
sum(msbi.SIMI_ON_HOLD_QTY) as TEE_SIMI_ON_HOLD_QTY,
sum(msbi.SIMI_IN_RECEIPTS_QTY) as TEE_SIMI_IN_RECEIPTS_QTY,
sum(msbi.SIMI_OPEN_ORDER_QTY) as TEE_SIMI_OPEN_ORDER_QTY,
sum(Month_12_Consumption) as TEE_Month_12_Consumption,
sum(Month_11_Consumption) as TEE_Month_11_Consumption,
sum(Month_10_Consumption) as TEE_Month_10_Consumption,
sum(Month_09_Consumption) as TEE_Month_09_Consumption,
sum(Month_08_Consumption) as TEE_Month_08_Consumption,
sum(Month_07_Consumption) as TEE_Month_07_Consumption,
sum(Month_06_Consumption) as TEE_Month_06_Consumption,
sum(Month_05_Consumption) as TEE_Month_05_Consumption,
sum(Month_04_Consumption) as TEE_Month_04_Consumption,
sum(Month_03_Consumption) as TEE_Month_03_Consumption,
sum(Month_02_Consumption) as TEE_Month_02_Consumption,
sum(Month_01_Consumption) as TEE_Month_01_Consumption,
sum(CURRENT_MONTH_CONSUMPTION) as TEE_CURRENT_MONTH_CONSUMPTION,
sum(MOU) as TEE_MOU,
sum(SIMI_3M_MOU) as TEE_SIMI_3M_MOU,
sum(SIMI_12M_USE) as TEE_SIMI_12M_USE,
sum(SIMI_12M_AVG) as TEE_SIMI_12M_AVG,
sum(stand_dev_agg_12.Month_12) as TEE_Month_12_dev,
sum(SIMI_M0_to_M2_USE) as TEE_SIMI_M0_to_M2_USE,
sum(SIMI_M0_to_M2_avg) as TEE_SIMI_M0_to_M2_avg,
sum(stand_dev_agg_0_2.Month_0_2) as TEE_Month_0_2_dev,
sum(SIMI_3M_USE) as TEE_SIMI_3M_USE,
sum(SIMI_3M_avg) as TEE_SIMI_3M_avg,
sum(stand_dev_agg_3.Month_3) as TEE_Month_3_dev,
sum(SIMI_3M_ADU) as TEE_SIMI_3M_ADU,
sum(SIMI_3M_C_Use) as TEE_SIMI_3M_C_Use,
sum(SIMI_3M_C_avg) as TEE_SIMI_3M_C_avg,
sum(stand_dev_agg_3_c.Month_3_C) as TEE_Month_3_C_dev,
sum(SIMI_3M_C_ADU) as TEE_SIMI_3M_C_ADU,
sum(SIMI_6M_USE) as TEE_SIMI_6M_USE,
sum(SIMI_6M_AVG) as TEE_SIMI_6M_AVG,
sum(stand_dev_agg_6.Month_6) as TEE_Month_6_dev,
sum(TEL_Sugg_DOI) as TEE_Sugg_DOI,
sum(TEL_Avg_Daily_Use) as TEE_Avg_Daily_Use,
sum(TEL_Sugg_DOI_New) as TEE_Sugg_DOI_New,
sum(TEL_Avg_Daily_Use_New) as TEE_Avg_Daily_Use_New,
sum(tEL_30_DOI_QTY) as TEE_30_DOI_QTY,
sum(TEL_37_DOI_QTY) as TEE_37_DOI_QTY,
sum(TEL_45_DOI_QTY) as TEE_45_DOI_QTY,
sum(TEL_60_DOI_QTY) as TEE_60_DOI_QTY,
sum(TEL_90_DOI_QTY) as TEE_90_DOI_QTY,
sum(TEL_120_DOI_QTY) as TEE_120_DOI_QTY,
sum(TEL_DOI) as TEE_DOI,
sum(TEL_30_DOI_QTY_New) as TEE_30_DOI_QTY_New,
sum(TEL_37_DOI_QTY_New) as TEE_37_DOI_QTY_New,
sum(TEL_45_DOI_QTY_New) as TEE_45_DOI_QTY_New,
sum(TEL_60_DOI_QTY_New) as TEE_60_DOI_QTY_New,
sum(TEL_90_DOI_QTY_New) as TEE_90_DOI_QTY_New,
sum(TEL_120_DOI_QTY_New) as TEE_120_DOI_QTY_New,
sum(TEL_DOI_NEW) as TEE_DOI_NEW,
FILEDATE as TEE_FILEDATE
  from
    msbi as msbi
    left join stand_dev_agg_12 as stand_dev_agg_12 on stand_dev_agg_12.serial_no = msbi.serial_no
    left join stand_dev_agg_0_2 as stand_dev_agg_0_2 on stand_dev_agg_0_2.serial_no = msbi.serial_no
    left join stand_dev_agg_3 as stand_dev_agg_3 on stand_dev_agg_3.serial_no = msbi.serial_no
    left join stand_dev_agg_3_C as stand_dev_agg_3_C on stand_dev_agg_3_C.serial_no = msbi.serial_no
    left join stand_dev_agg_6 as stand_dev_agg_6 on stand_dev_agg_6.serial_no = msbi.serial_no
    group by msbi.SPN,FILEDATE
),
transform_data as(
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') as _ROW_HASH,
	TEE_SPN,
	TEE_SIMI_MAX,
	TEE_SIMI_ROP,
	TEE_SIMI_QTY_AVAILABLE,
	TEE_SIMI_REJECT_QTY,
	TEE_SIMI_OH_QTY,
	TEE_SIMI_ON_HOLD_QTY,
	TEE_SIMI_IN_RECEIPTS_QTY,
	TEE_SIMI_OPEN_ORDER_QTY,
	TEE_Month_12_Consumption,
	TEE_Month_11_Consumption,
	TEE_Month_10_Consumption,
	TEE_Month_09_Consumption,
	TEE_Month_08_Consumption,
	TEE_Month_07_Consumption,
	TEE_Month_06_Consumption,
	TEE_Month_05_Consumption,
	TEE_Month_04_Consumption,
	TEE_Month_03_Consumption,
	TEE_Month_02_Consumption,
	TEE_Month_01_Consumption,
	TEE_CURRENT_MONTH_CONSUMPTION,
	TEE_MOU,
	TEE_SIMI_3M_MOU,
	TEE_SIMI_12M_USE,
	TEE_SIMI_12M_AVG,
	TEE_Month_12_dev,
	TEE_SIMI_M0_to_M2_USE,
	TEE_SIMI_M0_to_M2_avg,
	TEE_Month_0_2_dev,
	TEE_SIMI_3M_USE,
	TEE_SIMI_3M_avg,
	TEE_Month_3_dev,
	TEE_SIMI_3M_ADU,
	TEE_SIMI_3M_C_Use,
	TEE_SIMI_3M_C_avg,
	TEE_Month_3_C_dev,
	TEE_SIMI_3M_C_ADU,
	TEE_SIMI_6M_USE,
	TEE_SIMI_6M_AVG,
	TEE_Month_6_dev,
	TEE_Sugg_DOI,
	TEE_Avg_Daily_Use,
	TEE_Sugg_DOI_New,
	TEE_Avg_Daily_Use_New,
	TEE_30_DOI_QTY,
	TEE_37_DOI_QTY,
	TEE_45_DOI_QTY,
	TEE_60_DOI_QTY,
	TEE_90_DOI_QTY,
	TEE_120_DOI_QTY,
	TEE_DOI,
	TEE_30_DOI_QTY_New,
	TEE_37_DOI_QTY_New,
	TEE_45_DOI_QTY_New,
	TEE_60_DOI_QTY_New,
	TEE_90_DOI_QTY_New,
	TEE_120_DOI_QTY_New,
	TEE_DOI_NEW,
	TEE_FILEDATE
from source_data
),
type_data as (
SELECT
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	TEE_SPN,
	TEE_SIMI_MAX,
	TEE_SIMI_ROP,
	TEE_SIMI_QTY_AVAILABLE,
	TEE_SIMI_REJECT_QTY,
	TEE_SIMI_OH_QTY,
	TEE_SIMI_ON_HOLD_QTY,
	TEE_SIMI_IN_RECEIPTS_QTY,
	TEE_SIMI_OPEN_ORDER_QTY,
	TEE_Month_12_Consumption,
	TEE_Month_11_Consumption,
	TEE_Month_10_Consumption,
	TEE_Month_09_Consumption,
	TEE_Month_08_Consumption,
	TEE_Month_07_Consumption,
	TEE_Month_06_Consumption,
	TEE_Month_05_Consumption,
	TEE_Month_04_Consumption,
	TEE_Month_03_Consumption,
	TEE_Month_02_Consumption,
	TEE_Month_01_Consumption,
	TEE_CURRENT_MONTH_CONSUMPTION,
	TEE_MOU,
	TEE_SIMI_3M_MOU,
	TEE_SIMI_12M_USE,
	TEE_SIMI_12M_AVG,
	TEE_Month_12_dev,
	TEE_SIMI_M0_to_M2_USE,
	TEE_SIMI_M0_to_M2_avg,
	TEE_Month_0_2_dev,
	TEE_SIMI_3M_USE,
	TEE_SIMI_3M_avg,
	TEE_Month_3_dev,
	TEE_SIMI_3M_ADU,
	TEE_SIMI_3M_C_Use,
	TEE_SIMI_3M_C_avg,
	TEE_Month_3_C_dev,
	TEE_SIMI_3M_C_ADU,
	TEE_SIMI_6M_USE,
	TEE_SIMI_6M_AVG,
	TEE_Month_6_dev,
	TEE_Sugg_DOI,
	TEE_Avg_Daily_Use,
	TEE_Sugg_DOI_New,
	TEE_Avg_Daily_Use_New,
	TEE_30_DOI_QTY,
	TEE_37_DOI_QTY,
	TEE_45_DOI_QTY,
	TEE_60_DOI_QTY,
	TEE_90_DOI_QTY,
	TEE_120_DOI_QTY,
	TEE_DOI,
	TEE_30_DOI_QTY_New,
	TEE_37_DOI_QTY_New,
	TEE_45_DOI_QTY_New,
	TEE_60_DOI_QTY_New,
	TEE_90_DOI_QTY_New,
	TEE_120_DOI_QTY_New,
	TEE_DOI_NEW,
	CAST(TEE_FILEDATE AS DATE) AS TEE_FILEDATE
FROM transform_data
)

select * from type_data