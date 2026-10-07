{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_TEL_ACC_REVENUE_BUDGET_FORECAST'
) }}


with source_data as
(
SELECT
	    BOOKING_CONFIDENCE_BU,
        BOOKING_DATE,
        BOOKING_MONTH,
        BU_PLACEHOLDER,
        COMPANY,
        COMPANY_NAME,
        COST_CENTER,
        CRM_OPPORTUNITY_ID,
        CRM_SALES_DOCUMENT_ID,
        CUSTOMER_PROCESS,
        CUSTOMER_TOOL_ID,
        DELIVERY_SELECTION_FLAG,
        ENDUSER_BOOKING_DATE,
        ENDUSER_BOOKING_MONTH,
        ENDUSER_CORPORATE_CODE,
        ENDUSER_CORPORATE_S_NAME_EN,
        ENDUSER_COUNTRY,
        ENDUSER_OFFICE_CODE,
        ENDUSER_OFFICE_S_NAME_EN,
        ENDUSER_SALES_MONTH,
        END_USER,
        END_USER_SALES_DATE,
        FAB_LINE_CODE,
        FAB_LINE_NAME,
        LEDGER_CURRENCY,
        MAIN_TOOL,
        MATERIAL_GROUP,
        MODEL_CODE,
        MODEL_NAME,
        ORDER_ITEM_NAME,
        ORDER_SELECTION_FLAG,
        PM_SERIAL_NO,
        PROFIT_CENTER,
        PROFIT_CENTER_GROUP1,
        PROFIT_CENTER_GROUP1_NAME,
        PROFIT_CENTER_GROUP2_NAME,
        PROFIT_CENT_GROUP_REPSEG_NAME,
        REFERENCE_SERIAL_NO,
        REVENUE_RECOGNITION_CRITERIA,
        SALES_AMOUNT_LEDGE,
        SALES_CATEGORY,
        SALES_CATEGORY_NAME,
        SALES_DATE,
        SALES_DISTRICT_NAME,
        SALES_DOCUMENT,
        SALES_DOCUMENT_ITEM,
        SALES_MONTH,
        SALES_REPORTING_FLAG,
        SALES_SELECTION_FLAG,
        SERIAL_NO,
        SHIP_DATE,
        SHIP_MONTH,
        SOLD_TO_PARTY_CODE,
        SOLD_TO_PARTY_OFFICE_CODE,
        SOLD_TO_PARTY_OFFICE_S_NAME_EN,
        TOTAL_BOOKING_AMOUNT_LEDGE,
        SALES_DOCUMENT_TYPES,
        INTERNAL_SALES,
        PROFIT_CENTER_GROUP2,
        BULK_FLAG,
        SALES_RECORDING_FLAG,
        SALES_COMMENTS,
        PROFIT_CENT_GROUP_REPSEG,
        PROJECT_DEFINITION,
        CUSTOMER_GROUP_1_NAME,
        CUSTOMER_GROUP_2_NAME,
        QUANTITY,
        ORDER_APPROVAL_STATUS,
        ENDUSER_BOOKING_DATE_ACTUAL,
        SCHEDULED_CUSTOMS_CLEARAN_DATE,
        CONFIRMED_CUSTOMS_CLEARAN_DATE,
        SCHEDULED_ONDOCK_DATE,
        SCHEDULED_ONDOCKDATE_CONFIRMED,
        SALES_DATE_EST_ACTUAL_STATUS,
        ENDUSER_SALES_EST_ACT_STATUS,
        APPROVAL_STATUS_SALES,
        REVENUE_RECOGNITION,
        TECH_ACCEPT_TSR_SIGN_DATE,
        TECH_ACCEP_TSRSIGN_DATE_ACTUAL,
        TECH_ACCEP_TSRSIGN_UNAVAILABLE,
        LOANER,
        EST,
        INTERNAL_COMMENTS,
        _FILENAME
    FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SALES_OPERATIONS_TEL_ACC_REVENUE_BUDGET_FORECAST') }} 
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        BOOKING_CONFIDENCE_BU,
        case
        when length(BOOKING_DATE)=5 and BOOKING_DATE not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,BOOKING_DATE,to_date('1900-01-01'))
        when length(BOOKING_DATE)=8 and BOOKING_DATE like '%/%'
        then try_to_date(to_varchar(try_to_date(BOOKING_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(BOOKING_DATE)=8
        then try_to_date(BOOKING_DATE,'yyyymmdd')
        when length(BOOKING_DATE)=9
        then try_to_date(to_varchar(try_to_date(BOOKING_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(BOOKING_DATE)=10 and regexp_count(BOOKING_DATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(BOOKING_DATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(BOOKING_DATE)=10 and regexp_count(BOOKING_DATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(BOOKING_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as BOOKING_DATE,
        case
        when BOOKING_MONTH='#NUM!' then NULL
        when length(BOOKING_MONTH)=5 and BOOKING_MONTH not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,BOOKING_MONTH,to_date('1900-01-01'))
        ELSE
        TRY_TO_DATE( LEFT(REPLACE(BOOKING_MONTH,'/',''),6), 'yyyymm') END AS BOOKING_MONTH,
        BU_PLACEHOLDER,
        COMPANY,
        COMPANY_NAME,
        COST_CENTER,
        CRM_OPPORTUNITY_ID,
        CRM_SALES_DOCUMENT_ID,
        CUSTOMER_PROCESS,
        CUSTOMER_TOOL_ID,
        DELIVERY_SELECTION_FLAG,
        case
        when length(ENDUSER_BOOKING_DATE)=5 and ENDUSER_BOOKING_DATE not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,ENDUSER_BOOKING_DATE,to_date('1900-01-01'))
        when length(ENDUSER_BOOKING_DATE)=8 and ENDUSER_BOOKING_DATE like '%/%'
        then try_to_date(to_varchar(try_to_date(ENDUSER_BOOKING_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(ENDUSER_BOOKING_DATE)=8
        then try_to_date(ENDUSER_BOOKING_DATE,'yyyymmdd')
        when length(ENDUSER_BOOKING_DATE)=9
        then try_to_date(to_varchar(try_to_date(ENDUSER_BOOKING_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(ENDUSER_BOOKING_DATE)=10 and regexp_count(ENDUSER_BOOKING_DATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(ENDUSER_BOOKING_DATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(ENDUSER_BOOKING_DATE)=10 and regexp_count(ENDUSER_BOOKING_DATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(ENDUSER_BOOKING_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as ENDUSER_BOOKING_DATE,
        case
        when ENDUSER_BOOKING_MONTH='#NUM!' then NULL
        when length(ENDUSER_BOOKING_MONTH)=5  and ENDUSER_BOOKING_MONTH not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,ENDUSER_BOOKING_MONTH,to_date('1900-01-01'))
        ELSE
        TRY_TO_DATE( LEFT(REPLACE(ENDUSER_BOOKING_MONTH,'/',''),6), 'yyyymm') END AS ENDUSER_BOOKING_MONTH,
        ENDUSER_CORPORATE_CODE,
        ENDUSER_CORPORATE_S_NAME_EN,
        ENDUSER_COUNTRY,
        ENDUSER_OFFICE_CODE,
        ENDUSER_OFFICE_S_NAME_EN,
        case when length(ENDUSER_SALES_MONTH)=5  and ENDUSER_SALES_MONTH not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,ENDUSER_SALES_MONTH,to_date('1900-01-01'))
        ELSE
        TRY_TO_DATE( LEFT(REPLACE(ENDUSER_SALES_MONTH,'/',''),6), 'yyyymm') END AS ENDUSER_SALES_MONTH,
        END_USER,
        case
        when length(END_USER_SALES_DATE)=5  and END_USER_SALES_DATE not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,END_USER_SALES_DATE,to_date('1900-01-01'))
        when length(END_USER_SALES_DATE)=8 and END_USER_SALES_DATE like '%/%'
        then try_to_date(to_varchar(try_to_date(END_USER_SALES_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(END_USER_SALES_DATE)=8
        then try_to_date(END_USER_SALES_DATE,'yyyymmdd')
        when length(END_USER_SALES_DATE)=9
        then try_to_date(to_varchar(try_to_date(END_USER_SALES_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(END_USER_SALES_DATE)=10 and regexp_count(END_USER_SALES_DATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(END_USER_SALES_DATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(END_USER_SALES_DATE)=10 and regexp_count(END_USER_SALES_DATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(END_USER_SALES_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as END_USER_SALES_DATE,
        FAB_LINE_CODE,
        FAB_LINE_NAME,
        LEDGER_CURRENCY,
        try_to_number(MAIN_TOOL) as MAIN_TOOL,
        MATERIAL_GROUP,
        MODEL_CODE,
        MODEL_NAME,
        ORDER_ITEM_NAME,
        ORDER_SELECTION_FLAG,
        PM_SERIAL_NO,
        PROFIT_CENTER,
        PROFIT_CENTER_GROUP1,
        PROFIT_CENTER_GROUP1_NAME,
        PROFIT_CENTER_GROUP2_NAME,
        PROFIT_CENT_GROUP_REPSEG_NAME,
        REFERENCE_SERIAL_NO,
        REVENUE_RECOGNITION_CRITERIA,
        try_to_number(regexp_replace(SALES_AMOUNT_LEDGE,',')) as SALES_AMOUNT_LEDGE,
        SALES_CATEGORY,
        SALES_CATEGORY_NAME,
        case
        when length(SALES_DATE)=5  and SALES_DATE not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,SALES_DATE,to_date('1900-01-01'))
        when length(SALES_DATE)=8 and SALES_DATE like '%/%'
        then try_to_date(to_varchar(try_to_date(SALES_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SALES_DATE)=8
        then try_to_date(SALES_DATE,'yyyymmdd')
        when length(SALES_DATE)=9
        then try_to_date(to_varchar(try_to_date(SALES_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SALES_DATE)=10 and regexp_count(SALES_DATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(SALES_DATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(SALES_DATE)=10 and regexp_count(SALES_DATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(SALES_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as SALES_DATE,
        SALES_DISTRICT_NAME,
        SALES_DOCUMENT,
        SALES_DOCUMENT_ITEM,
        case when length(SALES_MONTH)=5  and SALES_MONTH not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,SALES_MONTH,to_date('1900-01-01'))
        ELSE
        TRY_TO_DATE( LEFT(REPLACE(SALES_MONTH,'/',''),6), 'yyyymm') END AS SALES_MONTH,
        SALES_REPORTING_FLAG,
        SALES_SELECTION_FLAG,
        SERIAL_NO,
        case
        when length(SHIP_DATE)=5  and SHIP_DATE not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,SHIP_DATE,to_date('1900-01-01'))
        when length(SHIP_DATE)=8 and SHIP_DATE like '%/%'
        then try_to_date(to_varchar(try_to_date(SHIP_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SHIP_DATE)=8
        then try_to_date(SHIP_DATE,'yyyymmdd')
        when length(SHIP_DATE)=9
        then try_to_date(to_varchar(try_to_date(SHIP_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SHIP_DATE)=10 and regexp_count(SHIP_DATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(SHIP_DATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(SHIP_DATE)=10 and regexp_count(SHIP_DATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(SHIP_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as SHIP_DATE,
        case when length(SHIP_MONTH)=5  and SHIP_MONTH not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,SHIP_MONTH,to_date('1900-01-01'))
        ELSE
        TRY_TO_DATE( LEFT(REPLACE(SHIP_MONTH,'/',''),6), 'yyyymm') END AS SHIP_MONTH,
        SOLD_TO_PARTY_CODE,
        SOLD_TO_PARTY_OFFICE_CODE,
        SOLD_TO_PARTY_OFFICE_S_NAME_EN,
        try_to_number(regexp_replace(TOTAL_BOOKING_AMOUNT_LEDGE,',')) as TOTAL_BOOKING_AMOUNT_LEDGE,
        SALES_DOCUMENT_TYPES,
        INTERNAL_SALES,
        PROFIT_CENTER_GROUP2,
        BULK_FLAG,
        SALES_RECORDING_FLAG,
        SALES_COMMENTS,
        PROFIT_CENT_GROUP_REPSEG,
        PROJECT_DEFINITION,
        CUSTOMER_GROUP_1_NAME,
        CUSTOMER_GROUP_2_NAME,
        try_to_number(QUANTITY) AS QUANTITY,
        ORDER_APPROVAL_STATUS,
        ENDUSER_BOOKING_DATE_ACTUAL,
        case
        when length(SCHEDULED_CUSTOMS_CLEARAN_DATE)=5  and SCHEDULED_CUSTOMS_CLEARAN_DATE not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,SCHEDULED_CUSTOMS_CLEARAN_DATE,to_date('1900-01-01'))
        when length(SCHEDULED_CUSTOMS_CLEARAN_DATE)=8 and SCHEDULED_CUSTOMS_CLEARAN_DATE like '%/%'
        then try_to_date(to_varchar(try_to_date(SCHEDULED_CUSTOMS_CLEARAN_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SCHEDULED_CUSTOMS_CLEARAN_DATE)=8
        then try_to_date(SCHEDULED_CUSTOMS_CLEARAN_DATE,'yyyymmdd')
        when length(SCHEDULED_CUSTOMS_CLEARAN_DATE)=9
        then try_to_date(to_varchar(try_to_date(SCHEDULED_CUSTOMS_CLEARAN_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SCHEDULED_CUSTOMS_CLEARAN_DATE)=10 and regexp_count(SCHEDULED_CUSTOMS_CLEARAN_DATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(SCHEDULED_CUSTOMS_CLEARAN_DATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(SCHEDULED_CUSTOMS_CLEARAN_DATE)=10 and regexp_count(SCHEDULED_CUSTOMS_CLEARAN_DATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(SCHEDULED_CUSTOMS_CLEARAN_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as SCHEDULED_CUSTOMS_CLEARAN_DATE,
        case
        when length(CONFIRMED_CUSTOMS_CLEARAN_DATE)=5  and CONFIRMED_CUSTOMS_CLEARAN_DATE not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,CONFIRMED_CUSTOMS_CLEARAN_DATE,to_date('1900-01-01'))
        when length(CONFIRMED_CUSTOMS_CLEARAN_DATE)=8 and CONFIRMED_CUSTOMS_CLEARAN_DATE like '%/%'
        then try_to_date(to_varchar(try_to_date(CONFIRMED_CUSTOMS_CLEARAN_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(CONFIRMED_CUSTOMS_CLEARAN_DATE)=8
        then try_to_date(CONFIRMED_CUSTOMS_CLEARAN_DATE,'yyyymmdd')
        when length(CONFIRMED_CUSTOMS_CLEARAN_DATE)=9
        then try_to_date(to_varchar(try_to_date(CONFIRMED_CUSTOMS_CLEARAN_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(CONFIRMED_CUSTOMS_CLEARAN_DATE)=10 and regexp_count(CONFIRMED_CUSTOMS_CLEARAN_DATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(CONFIRMED_CUSTOMS_CLEARAN_DATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(CONFIRMED_CUSTOMS_CLEARAN_DATE)=10 and regexp_count(CONFIRMED_CUSTOMS_CLEARAN_DATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(CONFIRMED_CUSTOMS_CLEARAN_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as CONFIRMED_CUSTOMS_CLEARAN_DATE,
        case
        when length(SCHEDULED_ONDOCK_DATE)=5  and SCHEDULED_ONDOCK_DATE not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,SCHEDULED_ONDOCK_DATE,to_date('1900-01-01'))
        when length(SCHEDULED_ONDOCK_DATE)=8 and SCHEDULED_ONDOCK_DATE like '%/%'
        then try_to_date(to_varchar(try_to_date(SCHEDULED_ONDOCK_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SCHEDULED_ONDOCK_DATE)=8
        then try_to_date(SCHEDULED_ONDOCK_DATE,'yyyymmdd')
        when length(SCHEDULED_ONDOCK_DATE)=9
        then try_to_date(to_varchar(try_to_date(SCHEDULED_ONDOCK_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SCHEDULED_ONDOCK_DATE)=10 and regexp_count(SCHEDULED_ONDOCK_DATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(SCHEDULED_ONDOCK_DATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(SCHEDULED_ONDOCK_DATE)=10 and regexp_count(SCHEDULED_ONDOCK_DATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(SCHEDULED_ONDOCK_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as SCHEDULED_ONDOCK_DATE,
        SCHEDULED_ONDOCKDATE_CONFIRMED,
        SALES_DATE_EST_ACTUAL_STATUS,
        ENDUSER_SALES_EST_ACT_STATUS,
        APPROVAL_STATUS_SALES,
        REVENUE_RECOGNITION,
        case
        when length(TECH_ACCEPT_TSR_SIGN_DATE)=5  and TECH_ACCEPT_TSR_SIGN_DATE not in ('バルク','確定通関日','技術検収日')
        then dateadd(day,TECH_ACCEPT_TSR_SIGN_DATE,to_date('1900-01-01'))
        when length(TECH_ACCEPT_TSR_SIGN_DATE)=8 and TECH_ACCEPT_TSR_SIGN_DATE like '%/%'
        then try_to_date(to_varchar(try_to_date(TECH_ACCEPT_TSR_SIGN_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(TECH_ACCEPT_TSR_SIGN_DATE)=8
        then try_to_date(TECH_ACCEPT_TSR_SIGN_DATE,'yyyymmdd')
        when length(TECH_ACCEPT_TSR_SIGN_DATE)=9
        then try_to_date(to_varchar(try_to_date(TECH_ACCEPT_TSR_SIGN_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(TECH_ACCEPT_TSR_SIGN_DATE)=10 and regexp_count(TECH_ACCEPT_TSR_SIGN_DATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(TECH_ACCEPT_TSR_SIGN_DATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(TECH_ACCEPT_TSR_SIGN_DATE)=10 and regexp_count(TECH_ACCEPT_TSR_SIGN_DATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(TECH_ACCEPT_TSR_SIGN_DATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as TECH_ACCEPT_TSR_SIGN_DATE,
        TECH_ACCEP_TSRSIGN_DATE_ACTUAL,
        TECH_ACCEP_TSRSIGN_UNAVAILABLE,
        LOANER,
        EST,
        INTERNAL_COMMENTS,
        _FILENAME AS _FILENAME,
        regexp_substr(_FILENAME,'\\d+++++++') as _FILEDATE,
        CASE WHEN _FILENAME ILIKE '%_Budget %' THEN 'BUDGET'
        WHEN _FILENAME ILIKE '%_Actual %' THEN 'ACTUAL'
        ELSE 'FORECAST'
        end	AS SOURCETYPE
FROM source_data
        where EST <> 'EST' OR EST IS NULL
)
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(BOOKING_CONFIDENCE_BU as VARCHAR(16777216)) as BOOKING_CONFIDENCE_BU,
        cast(BOOKING_DATE as DATE) as BOOKING_DATE,
        cast(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        cast(BU_PLACEHOLDER as VARCHAR(16777216)) as BU_PLACEHOLDER,
        cast(COMPANY as VARCHAR(16777216)) as COMPANY,
        cast(COMPANY_NAME as VARCHAR(16777216)) as COMPANY_NAME,
        cast(COST_CENTER as VARCHAR(16777216)) as COST_CENTER,
        cast(CRM_OPPORTUNITY_ID as VARCHAR(16777216)) as CRM_OPPORTUNITY_ID,
        cast(CRM_SALES_DOCUMENT_ID as VARCHAR(16777216)) as CRM_SALES_DOCUMENT_ID,
        cast(CUSTOMER_PROCESS as VARCHAR(16777216)) as CUSTOMER_PROCESS,
        cast(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        cast(DELIVERY_SELECTION_FLAG as VARCHAR(16777216)) as DELIVERY_SELECTION_FLAG,
        cast(ENDUSER_BOOKING_DATE as DATE) as ENDUSER_BOOKING_DATE,
        cast(ENDUSER_BOOKING_MONTH as DATE) as ENDUSER_BOOKING_MONTH,
        cast(ENDUSER_CORPORATE_CODE as VARCHAR(16777216)) as ENDUSER_CORPORATE_CODE,
        cast(ENDUSER_CORPORATE_S_NAME_EN as VARCHAR(16777216)) as ENDUSER_CORPORATE_S_NAME_EN,
        cast(ENDUSER_COUNTRY as VARCHAR(16777216)) as ENDUSER_COUNTRY,
        cast(ENDUSER_OFFICE_CODE as VARCHAR(16777216)) as ENDUSER_OFFICE_CODE,
        cast(ENDUSER_OFFICE_S_NAME_EN as VARCHAR(16777216)) as ENDUSER_OFFICE_S_NAME_EN,
        cast(ENDUSER_SALES_MONTH as DATE) as ENDUSER_SALES_MONTH,
        cast(END_USER as VARCHAR(16777216)) as END_USER,
        cast(END_USER_SALES_DATE as DATE) as END_USER_SALES_DATE,
        cast(FAB_LINE_CODE as VARCHAR(16777216)) as FAB_LINE_CODE,
        cast(FAB_LINE_NAME as VARCHAR(16777216)) as FAB_LINE_NAME,
        cast(LEDGER_CURRENCY as VARCHAR(16777216)) as LEDGER_CURRENCY,
        CAST(MAIN_TOOL as NUMBER(38,0)) as MAIN_TOOL,
        cast(MATERIAL_GROUP as VARCHAR(16777216)) as MATERIAL_GROUP,
        cast(MODEL_CODE as VARCHAR(16777216)) as MODEL_CODE,
        cast(MODEL_NAME as VARCHAR(16777216)) as MODEL_NAME,
        cast(ORDER_ITEM_NAME as VARCHAR(16777216)) as ORDER_ITEM_NAME,
        cast(ORDER_SELECTION_FLAG as VARCHAR(16777216)) as ORDER_SELECTION_FLAG,
        cast(PM_SERIAL_NO as VARCHAR(16777216)) as PM_SERIAL_NO,
        cast(PROFIT_CENTER as VARCHAR(16777216)) as PROFIT_CENTER,
        cast(PROFIT_CENTER_GROUP1 as VARCHAR(16777216)) as PROFIT_CENTER_GROUP1,
        cast(PROFIT_CENTER_GROUP1_NAME as VARCHAR(16777216)) as PROFIT_CENTER_GROUP1_NAME,
        cast(PROFIT_CENTER_GROUP2_NAME as VARCHAR(16777216)) as PROFIT_CENTER_GROUP2_NAME,
        cast(PROFIT_CENT_GROUP_REPSEG_NAME as VARCHAR(16777216)) as PROFIT_CENT_GROUP_REPSEG_NAME,
        cast(REFERENCE_SERIAL_NO as VARCHAR(16777216)) as REFERENCE_SERIAL_NO,
        cast(REVENUE_RECOGNITION_CRITERIA as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA,
        CAST(SALES_AMOUNT_LEDGE as NUMBER(38,0)) as SALES_AMOUNT_LEDGE,
        cast(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        cast(SALES_CATEGORY_NAME as VARCHAR(16777216)) as SALES_CATEGORY_NAME,
        cast(SALES_DATE as DATE) as SALES_DATE,
        cast(SALES_DISTRICT_NAME as VARCHAR(16777216)) as SALES_DISTRICT_NAME,
        cast(SALES_DOCUMENT as VARCHAR(16777216)) as SALES_DOCUMENT,
        cast(SALES_DOCUMENT_ITEM as VARCHAR(16777216)) as SALES_DOCUMENT_ITEM,
        cast(SALES_MONTH as DATE) as SALES_MONTH,
        cast(SALES_REPORTING_FLAG as VARCHAR(16777216)) as SALES_REPORTING_FLAG,
        cast(SALES_SELECTION_FLAG as VARCHAR(16777216)) as SALES_SELECTION_FLAG,
        cast(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        cast(SHIP_DATE as DATE) as SHIP_DATE,
        cast(SHIP_MONTH as DATE) as SHIP_MONTH,
        cast(SOLD_TO_PARTY_CODE as VARCHAR(16777216)) as SOLD_TO_PARTY_CODE,
        cast(SOLD_TO_PARTY_OFFICE_CODE as VARCHAR(16777216)) as SOLD_TO_PARTY_OFFICE_CODE,
        cast(SOLD_TO_PARTY_OFFICE_S_NAME_EN as VARCHAR(16777216)) as SOLD_TO_PARTY_OFFICE_S_NAME_EN,
        CAST(TOTAL_BOOKING_AMOUNT_LEDGE as NUMBER(38,0)) as TOTAL_BOOKING_AMOUNT_LEDGE,
        CAST(SALES_DOCUMENT_TYPES AS VARCHAR(16777216)) AS SALES_DOCUMENT_TYPES,
        CAST(INTERNAL_SALES AS VARCHAR(16777216)) AS INTERNAL_SALES,
        CAST(PROFIT_CENTER_GROUP2 AS VARCHAR(16777216)) AS PROFIT_CENTER_GROUP2,
        CAST(BULK_FLAG AS VARCHAR(16777216)) AS BULK_FLAG,
        CAST(SALES_RECORDING_FLAG AS VARCHAR(16777216)) AS SALES_RECORDING_FLAG,
        CAST(SALES_COMMENTS AS VARCHAR(16777216)) AS SALES_COMMENTS,
        CAST(PROFIT_CENT_GROUP_REPSEG AS VARCHAR(16777216)) AS PROFIT_CENT_GROUP_REPSEG,
        CAST(PROJECT_DEFINITION AS VARCHAR(16777216)) AS PROJECT_DEFINITION,
        CAST(CUSTOMER_GROUP_1_NAME AS VARCHAR(16777216)) AS CUSTOMER_GROUP_1_NAME,
        CAST(CUSTOMER_GROUP_2_NAME AS VARCHAR(16777216)) AS CUSTOMER_GROUP_2_NAME,
        CAST(QUANTITY AS NUMBER(38,0)) AS QUANTITY,
        CAST(ORDER_APPROVAL_STATUS AS VARCHAR(16777216)) AS ORDER_APPROVAL_STATUS,
        CAST(ENDUSER_BOOKING_DATE_ACTUAL AS VARCHAR(16777216)) AS ENDUSER_BOOKING_DATE_ACTUAL,
        CAST(SCHEDULED_CUSTOMS_CLEARAN_DATE AS DATE) AS SCHEDULED_CUSTOMS_CLEARAN_DATE,
        CAST(CONFIRMED_CUSTOMS_CLEARAN_DATE AS DATE) AS CONFIRMED_CUSTOMS_CLEARAN_DATE,
        CAST(SCHEDULED_ONDOCK_DATE AS DATE) AS SCHEDULED_ONDOCK_DATE,
        CAST(SCHEDULED_ONDOCKDATE_CONFIRMED AS VARCHAR(16777216)) AS SCHEDULED_ONDOCKDATE_CONFIRMED,
        CAST(SALES_DATE_EST_ACTUAL_STATUS AS VARCHAR(16777216)) AS SALES_DATE_EST_ACTUAL_STATUS,
        CAST(ENDUSER_SALES_EST_ACT_STATUS AS VARCHAR(16777216)) AS ENDUSER_SALES_EST_ACT_STATUS,
        CAST(APPROVAL_STATUS_SALES AS VARCHAR(16777216)) AS APPROVAL_STATUS_SALES,
        CAST(REVENUE_RECOGNITION AS VARCHAR(16777216)) AS REVENUE_RECOGNITION,
        CAST(TECH_ACCEPT_TSR_SIGN_DATE AS DATE) AS TECH_ACCEPT_TSR_SIGN_DATE,
        CAST(TECH_ACCEP_TSRSIGN_DATE_ACTUAL AS VARCHAR(16777216)) AS TECH_ACCEP_TSRSIGN_DATE_ACTUAL,
        CAST(TECH_ACCEP_TSRSIGN_UNAVAILABLE AS VARCHAR(16777216)) AS TECH_ACCEP_TSRSIGN_UNAVAILABLE,
        CAST(LOANER AS VARCHAR(16777216)) AS LOANER,
        CAST(EST AS VARCHAR(16777216)) AS EST,
        CAST(INTERNAL_COMMENTS AS VARCHAR(16777216)) AS INTERNAL_COMMENTS,
        cast(_FILENAME as VARCHAR(16777216)) as _FILENAME,
        TO_DATE(_FILEDATE,'YYYYMMDD') as _FILEDATE,
        cast(SOURCETYPE as VARCHAR(8)) as SOURCETYPE
from transform_data
    )
select 
_AUDIT_LOG_ID,
_ROW_HASH,
BOOKING_DATE,
BOOKING_MONTH,
ENDUSER_BOOKING_DATE,
SOLD_TO_PARTY_CODE,
END_USER,
SALES_DOCUMENT,
SALES_DOCUMENT_ITEM,
SALES_CATEGORY,
BOOKING_CONFIDENCE_BU,
FAB_LINE_CODE,
PROFIT_CENTER_GROUP1,
SHIP_DATE,
SALES_DATE,
END_USER_SALES_DATE,
SALES_REPORTING_FLAG,
ORDER_SELECTION_FLAG,
DELIVERY_SELECTION_FLAG,
SALES_SELECTION_FLAG,
BU_PLACEHOLDER,
COMPANY,
COMPANY_NAME,
COST_CENTER,
PROFIT_CENTER,
PROFIT_CENT_GROUP_REPSEG_NAME,
PROFIT_CENTER_GROUP1_NAME,
PROFIT_CENTER_GROUP2_NAME,
CRM_OPPORTUNITY_ID,
CRM_SALES_DOCUMENT_ID,
CUSTOMER_TOOL_ID,
SOLD_TO_PARTY_OFFICE_CODE,
SOLD_TO_PARTY_OFFICE_S_NAME_EN,
ENDUSER_CORPORATE_CODE,
ENDUSER_CORPORATE_S_NAME_EN,
ENDUSER_OFFICE_CODE,
ENDUSER_OFFICE_S_NAME_EN,
ENDUSER_COUNTRY,
SALES_DISTRICT_NAME,
FAB_LINE_NAME,
CUSTOMER_PROCESS,
MODEL_CODE,
MODEL_NAME,
ORDER_ITEM_NAME,
MATERIAL_GROUP,
SERIAL_NO,
PM_SERIAL_NO,
REFERENCE_SERIAL_NO,
TOTAL_BOOKING_AMOUNT_LEDGE,
SALES_AMOUNT_LEDGE,
LEDGER_CURRENCY,
MAIN_TOOL,
SALES_CATEGORY_NAME,
ENDUSER_BOOKING_MONTH,
SHIP_MONTH,
SALES_MONTH,
ENDUSER_SALES_MONTH,
REVENUE_RECOGNITION_CRITERIA,
SALES_DOCUMENT_TYPES,
INTERNAL_SALES,
PROFIT_CENTER_GROUP2,
BULK_FLAG,
SALES_RECORDING_FLAG,
SALES_COMMENTS,
PROFIT_CENT_GROUP_REPSEG,
PROJECT_DEFINITION,
CUSTOMER_GROUP_1_NAME,
CUSTOMER_GROUP_2_NAME,
QUANTITY,
ORDER_APPROVAL_STATUS,
ENDUSER_BOOKING_DATE_ACTUAL,
SCHEDULED_CUSTOMS_CLEARAN_DATE,
CONFIRMED_CUSTOMS_CLEARAN_DATE,
SCHEDULED_ONDOCK_DATE,
SCHEDULED_ONDOCKDATE_CONFIRMED,
SALES_DATE_EST_ACTUAL_STATUS,
ENDUSER_SALES_EST_ACT_STATUS,
APPROVAL_STATUS_SALES,
REVENUE_RECOGNITION,
TECH_ACCEPT_TSR_SIGN_DATE,
TECH_ACCEP_TSRSIGN_DATE_ACTUAL,
TECH_ACCEP_TSRSIGN_UNAVAILABLE,
LOANER,
EST,
INTERNAL_COMMENTS,
_FILENAME,
_FILEDATE,
SOURCETYPE
 from type_data