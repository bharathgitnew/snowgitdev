{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='ON_TIME_DELIVERY_CALCULATIONS_MONTH_END',
    	transient=false
) }}

WITH 
ref_work_item_details as (
    select * from {{ ref('SILVER__TMEA_ENGINEERING__WORK_ITEM_DETAILS') }}  where kpiontimedelivery='Yes' 
),
calendar_date_logic as (
SELECT
CALENDAR_DATE AS MONTH_START,
LAST_DAY(CALENDAR_DATE) AS MONTH_END,
FROM {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }}
WHERE CALENDAR_DATE BETWEEN (SELECT MIN(COMMITTEDDATE) FROM ref_work_item_details) AND CURRENT_DATE()
AND IS_MONTH_FIRST_DAY = 'Yes'
),
late_months as (
select committeddate, deliverydate, id, 
CASE WHEN TEAMPROJECT = 'SWAP' THEN 'Orion' 
    WHEN TEAMPROJECT = 'GCIB300' THEN 'Acrevia' 
    ELSE TEAMPROJECT END AS PRODUCT_LINE,
    iff(coalesce(deliverydate, current_date)> coalesce(committeddate, current_date), TRUE,FALSE ) as IS_LATE,
    c.calendar_date as late_months_start,
    LAST_DAY(c.calendar_date) as late_months_end_day
    from  ref_work_item_details wi
    left join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }}
     c on c.calendar_date between date_trunc(month, coalesce(committeddate, current_date)) and date_trunc(month, coalesce(deliverydate, current_date)) 
    and is_month_first_day='Yes'
),
late_months_aggregation as(
    select product_line,
    late_months_start,
    late_months_end_day,
    COUNT(CASE when is_late=TRUE THEN 1 END) as num_late_delivered 
    from late_months
    GROUP BY ALL
),
work_item_monthly as(
    select 
        pl.product_line,
        c.month_start,
        c.month_end,
        Count(CASE WHEN w.committeddate >= w.deliverydate THEN 1 END ) as month_num_delivered,
        count(w.committeddate) as month_num_committed
    from 
    calendar_date_logic c
    cross join (
        select distinct  CASE WHEN TEAMPROJECT = 'SWAP' THEN 'Orion' 
        WHEN TEAMPROJECT = 'GCIB300' THEN 'Acrevia' 
        ELSE TEAMPROJECT END AS PRODUCT_LINE from ref_work_item_details ) pl
    left join 
    (select id,  CASE WHEN TEAMPROJECT = 'SWAP' THEN 'Orion' 
    WHEN TEAMPROJECT = 'GCIB300' THEN 'Acrevia' 
    ELSE TEAMPROJECT END AS PRODUCT_LINE, committeddate, deliverydate from ref_work_item_details ) w 
    on w.product_line = pl.product_line and w.committeddate between c.month_start and c.month_end 
   group by all
),
source_product_data as (
    select 
        w.product_line,
        w.month_start,
        w.month_end,
        coalesce(l.num_late_delivered,0) as month_num_late,
        w.month_num_delivered,
        w.month_num_committed
        from work_item_monthly w
        left join late_months_aggregation l on 
        l.product_line = w.product_line
        and l.late_months_start = w.month_start
        
),
source_data as (
    select * from source_product_data union all
    select 
        'All' as product_line,
        month_start,
        month_end,
        sum(month_num_late) as month_num_late,
        sum(month_num_delivered) as month_num_delivered,
        sum(month_num_committed) as month_num_committed
    from source_product_data where product_line IN ('UT Plus', 'ZETA', 'Acrevia', 'Antares', 'Antares G3', 'Yield Hunter', 'Ingenio')
    GROUP BY month_start,month_end
),
transform_data as (
select 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	PRODUCT_LINE,
	MONTH_START,
    MONTH_END,
    MONTH_NUM_LATE,
    MONTH_NUM_DELIVERED,
    MONTH_NUM_COMMITTED,
    CASE WHEN (month_num_delivered =0 and month_num_committed =0 ) then -1 
    else
    TO_DECIMAL((DIV0(month_num_delivered,month_num_committed)*100),10,2) end AS PERCENT_DELIVERED
from source_data
),

type_data as (
select
	
	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	cast(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    PRODUCT_LINE,
	MONTH_START,
    MONTH_END,
    MONTH_NUM_LATE,
    MONTH_NUM_DELIVERED,
    MONTH_NUM_COMMITTED,
    CAST(PERCENT_DELIVERED AS NUMBER(38,2)) AS PERCENT_DELIVERED
from transform_data
)
select * from type_data