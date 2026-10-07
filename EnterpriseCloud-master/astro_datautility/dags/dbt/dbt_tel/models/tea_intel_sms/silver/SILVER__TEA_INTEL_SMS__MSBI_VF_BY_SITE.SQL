{{ config(
       materialized='tel_incremental'  ,
    incremental_strategy='insert_overwrite'  ,
    alias='MSBI_VF_BY_SITE'  ,
    tags=['MSBI']
) }}

with MSBI as (
SELECT
try_to_date(REGEXP_SUBSTR(_Filename, '\\d{4}-\\d{2}-\\d{2}'),'YYYY-MM-DD') as FILEDATE,
ROW_NUMBER() OVER (
      ORDER BY
        WIINGS_LOCATION,
        SPN
    ) as serial_no,
    WIINGS_LOCATION,
    SPN,
    SUM(MAX_QTY) as SIMI_MAX,
    SUM(ROP_Qty1) as SIMI_ROP,
    SUM(Qty_Avail) as SIMI_QTY_AVAILABLE,
    SUM(Reject_Qty) as SIMI_REJECT_QTY,
    SUM(On_Hand_Qty) as SIMI_OH_QTY,
    SUM(QTY_ON_HOLD) as SIMI_ON_HOLD_QTY,
    SUM(ZEROIFNULL(TOTAL_IN_RECEIPT_QTY)) as SIMI_IN_RECEIPTS_QTY,
    SUM(Open_Customer_Order_Qty) as SIMI_OPEN_ORDER_QTY,
    SUM(Month_12_Consumption) AS Month_12_Consumption,
    SUM(Month_11_Consumption) AS Month_11_Consumption,
    SUM(Month_10_Consumption) AS Month_10_Consumption,
    SUM(Month_09_Consumption) AS Month_09_Consumption,
    SUM(Month_08_Consumption) AS Month_08_Consumption,
    SUM(Month_07_Consumption) AS Month_07_Consumption,
    SUM(Month_06_Consumption) AS Month_06_Consumption,
    SUM(Month_05_Consumption) AS Month_05_Consumption,
    SUM(Month_04_Consumption) AS Month_04_Consumption,
    SUM(Month_03_Consumption) AS Month_03_Consumption,
    SUM(Month_02_Consumption) AS Month_02_Consumption,
    SUM(Month_01_Consumption) AS Month_01_Consumption,
    SUM(CURRENT_MONTH_CONSUMPTION) AS CURRENT_MONTH_CONSUMPTION
  FROM
    {{ ref('BRONZE__TEA_INTEL_SMS__FILE_INTEL_MSBI_FULL_ITEM_BOM') }}
 group by WIINGS_LOCATION,SPN,_FILENAME
),
 calculations as (
  select
    serial_no,
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
    msbi

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
    left join calculations as calculations on calculations.serial_no = msbi.serial_no
),

	transform_data as (
select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		WIINGS_LOCATION,
		SPN,
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
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(WIINGS_LOCATION AS VARCHAR(16777216)) AS WIINGS_LOCATION,
		CAST(SPN AS VARCHAR(16777216)) AS SPN,
		CAST(SIMI_MAX AS FLOAT) AS SIMI_MAX,
		CAST(SIMI_ROP AS FLOAT) AS SIMI_ROP,
		CAST(SIMI_QTY_AVAILABLE AS FLOAT) AS SIMI_QTY_AVAILABLE,
		CAST(SIMI_REJECT_QTY AS FLOAT) AS SIMI_REJECT_QTY,
		CAST(SIMI_OH_QTY AS FLOAT) AS SIMI_OH_QTY,
		CAST(SIMI_ON_HOLD_QTY AS FLOAT) AS SIMI_ON_HOLD_QTY,
		CAST(SIMI_IN_RECEIPTS_QTY AS FLOAT) AS SIMI_IN_RECEIPTS_QTY,
		CAST(SIMI_OPEN_ORDER_QTY AS FLOAT) AS SIMI_OPEN_ORDER_QTY,
		CAST(MONTH_12_CONSUMPTION AS FLOAT) AS MONTH_12_CONSUMPTION,
		CAST(MONTH_11_CONSUMPTION AS FLOAT) AS MONTH_11_CONSUMPTION,
		CAST(MONTH_10_CONSUMPTION AS FLOAT) AS MONTH_10_CONSUMPTION,
		CAST(MONTH_09_CONSUMPTION AS FLOAT) AS MONTH_09_CONSUMPTION,
		CAST(MONTH_08_CONSUMPTION AS FLOAT) AS MONTH_08_CONSUMPTION,
		CAST(MONTH_07_CONSUMPTION AS FLOAT) AS MONTH_07_CONSUMPTION,
		CAST(MONTH_06_CONSUMPTION AS FLOAT) AS MONTH_06_CONSUMPTION,
		CAST(MONTH_05_CONSUMPTION AS FLOAT) AS MONTH_05_CONSUMPTION,
		CAST(MONTH_04_CONSUMPTION AS FLOAT) AS MONTH_04_CONSUMPTION,
		CAST(MONTH_03_CONSUMPTION AS FLOAT) AS MONTH_03_CONSUMPTION,
		CAST(MONTH_02_CONSUMPTION AS FLOAT) AS MONTH_02_CONSUMPTION,
		CAST(MONTH_01_CONSUMPTION AS FLOAT) AS MONTH_01_CONSUMPTION,
		CAST(CURRENT_MONTH_CONSUMPTION AS FLOAT) AS CURRENT_MONTH_CONSUMPTION,
		CAST(MOU AS NUMBER(13,0)) AS MOU,
		CAST(SIMI_3M_MOU AS NUMBER(3,0)) AS SIMI_3M_MOU,
		CAST(SIMI_12M_USE AS FLOAT) AS SIMI_12M_USE,
		CAST(SIMI_12M_AVG AS FLOAT) AS SIMI_12M_AVG,
		CAST(MONTH_12_DEV AS FLOAT) AS MONTH_12_DEV,
		CAST(SIMI_M0_TO_M2_USE AS FLOAT) AS SIMI_M0_TO_M2_USE,
		CAST(SIMI_M0_TO_M2_AVG AS FLOAT) AS SIMI_M0_TO_M2_AVG,
		CAST(MONTH_0_2_DEV AS FLOAT) AS MONTH_0_2_DEV,
		CAST(SIMI_3M_USE AS FLOAT) AS SIMI_3M_USE,
		CAST(SIMI_3M_AVG AS FLOAT) AS SIMI_3M_AVG,
		CAST(MONTH_3_DEV AS FLOAT) AS MONTH_3_DEV,
		CAST(SIMI_3M_ADU AS FLOAT) AS SIMI_3M_ADU,
		CAST(SIMI_3M_C_USE AS FLOAT) AS SIMI_3M_C_USE,
		CAST(SIMI_3M_C_AVG AS FLOAT) AS SIMI_3M_C_AVG,
		CAST(MONTH_3_C_DEV AS FLOAT) AS MONTH_3_C_DEV,
		CAST(SIMI_3M_C_ADU AS FLOAT) AS SIMI_3M_C_ADU,
		CAST(SIMI_6M_USE AS FLOAT) AS SIMI_6M_USE,
		CAST(SIMI_6M_AVG AS FLOAT) AS SIMI_6M_AVG,
		CAST(MONTH_6_DEV AS FLOAT) AS MONTH_6_DEV,
		CAST(TEL_SUGG_DOI AS FLOAT) AS TEL_SUGG_DOI,
		CAST(TEL_AVG_DAILY_USE AS FLOAT) AS TEL_AVG_DAILY_USE,
		CAST(TEL_SUGG_DOI_NEW AS FLOAT) AS TEL_SUGG_DOI_NEW,
		CAST(TEL_AVG_DAILY_USE_NEW AS FLOAT) AS TEL_AVG_DAILY_USE_NEW,
		CAST(TEL_30_DOI_QTY AS FLOAT) AS TEL_30_DOI_QTY,
		CAST(TEL_37_DOI_QTY AS FLOAT) AS TEL_37_DOI_QTY,
		CAST(TEL_45_DOI_QTY AS FLOAT) AS TEL_45_DOI_QTY,
		CAST(TEL_60_DOI_QTY AS FLOAT) AS TEL_60_DOI_QTY,
		CAST(TEL_90_DOI_QTY AS FLOAT) AS TEL_90_DOI_QTY,
		CAST(TEL_120_DOI_QTY AS FLOAT) AS TEL_120_DOI_QTY,
		CAST(TEL_DOI AS FLOAT) AS TEL_DOI,
		CAST(TEL_30_DOI_QTY_NEW AS FLOAT) AS TEL_30_DOI_QTY_NEW,
		CAST(TEL_37_DOI_QTY_NEW AS FLOAT) AS TEL_37_DOI_QTY_NEW,
		CAST(TEL_45_DOI_QTY_NEW AS FLOAT) AS TEL_45_DOI_QTY_NEW,
		CAST(TEL_60_DOI_QTY_NEW AS FLOAT) AS TEL_60_DOI_QTY_NEW,
		CAST(TEL_90_DOI_QTY_NEW AS FLOAT) AS TEL_90_DOI_QTY_NEW,
		CAST(TEL_120_DOI_QTY_NEW AS FLOAT) AS TEL_120_DOI_QTY_NEW,
		CAST(TEL_DOI_NEW AS FLOAT) AS TEL_DOI_NEW,
		CAST(FILEDATE AS DATE) AS FILEDATE
    From transform_data
)
select
  *
from
  type_data