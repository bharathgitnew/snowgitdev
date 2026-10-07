{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='ACCOUNTING_US_REVENUE_FORECAST',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select
    case when fcst.CUSTOMER_GROUP_1_NAME in ('インテル', 'INTEL GROUP') then 'Intel'
        when fcst.CUSTOMER_GROUP_1_NAME in ('サムスン', 'SAMSUNG GROUP') then 'Samsung'
        when fcst.CUSTOMER_GROUP_1_NAME = 'マイクロン' then 'Micron'
        else fcst.CUSTOMER_GROUP_1_NAME 
    end                                                                         as Account_Group1,
    case when fcst.CUSTOMER_GROUP_1_NAME in ('インテル', 'INTEL GROUP') then 'Intel'
        when fcst.CUSTOMER_GROUP_1_NAME in ('サムスン', 'SAMSUNG GROUP') then 'Samsung'
        when fcst.CUSTOMER_GROUP_2_NAME = 'マイクロン' then 'Micron'
        when fcst.CUSTOMER_GROUP_2_NAME = 'スカイワークス' then 'Skyworks'
        when fcst.CUSTOMER_GROUP_2_NAME = 'ウェスタンディジタル' then 'Western Digital'
        when fcst.CUSTOMER_GROUP_2_NAME = 'ルネサス' then 'Renesas'
        else fcst.CUSTOMER_GROUP_2_NAME 
    end                                                                         as Account_Group2,
    case --when SOLD_TO_PARTY_OFFICE_S_NAME_EN = 'MTTW' and ENDUSER_OFFICE_S_NAME_EN = 'MICRON' then 'Micron'
        when fcst.END_USER = 'B00001020' then 'GF/IBM'
        when fcst.END_USER = 'AA0012300' then 'TEL Group' --TTCA
        when fcst.END_USER = 'BA4316900' then 'Micron' -- MTTW
        when fcst.END_USER = 'B00003624' then 'Intel'
        when fcst.END_USER = 'BA0010149' and startswith(fcst.ENDUSER_OFFICE_S_NAME_EN, 'INTEL') then 'Intel'
        when fcst.END_USER = 'BA0010149' and startswith(fcst.ENDUSER_OFFICE_S_NAME_EN, 'Regional') then 'N/A'
        when fcst.END_USER is null and fcst.ENDUSER_OFFICE_S_NAME_EN = 'Samsung' then 'Samsung'
        when fcst.END_USER is null and fcst.ENDUSER_OFFICE_S_NAME_EN ilike any ('REGIONAL%', 'Others%') then 'N/A'
        when fcst.END_USER is null and fcst.ENDUSER_OFFICE_S_NAME_EN = 'Micron' then 'Micron'
        when fcst.END_USER is null and fcst.ENDUSER_OFFICE_S_NAME_EN = 'INTEL' then 'Intel'
        else acc.SALES_ACCOUNT_TI 
    end                                                                         as Sales_Account,
    acc.Sales_Region,
    case when fcst.END_USER = 'B00001020' then 'GF/IBM'
        when fcst.END_USER = 'AA0012300' then 'TEL Group' --TTCA
        when fcst.END_USER = 'BA4316900' then 'Micron' -- MTTW
        when fcst.END_USER = 'B00003624' then 'Intel'
        when fcst.END_USER = 'BA0010149' and startswith(fcst.ENDUSER_OFFICE_S_NAME_EN, 'INTEL') then 'Intel'
        when fcst.END_USER = 'BA0010149' and startswith(fcst.ENDUSER_OFFICE_S_NAME_EN, 'Regional') then 'N/A'
        when fcst.END_USER is null and fcst.ENDUSER_OFFICE_S_NAME_EN = 'Samsung' then 'Samsung'
        when fcst.END_USER is null and fcst.ENDUSER_OFFICE_S_NAME_EN ilike any ('REGIONAL%', 'Others%') then 'N/A'
        when fcst.END_USER is null and fcst.ENDUSER_OFFICE_S_NAME_EN = 'Micron' then 'Micron'
        when fcst.END_USER is null and fcst.ENDUSER_OFFICE_S_NAME_EN = 'INTEL' then 'Intel'
        when Sales_Account = 'Regional' then concat(Sales_Account, ' ', Sales_Region)
        else Sales_Account 
    end                                                                          as Sales_Account_Region,
    fcst.SOLD_TO_PARTY_OFFICE_S_NAME_EN                                          as Sold_to_Party,
    coalesce(fcst.ENDUSER_OFFICE_S_NAME_EN, fcst.SOLD_TO_PARTY_OFFICE_S_NAME_EN) as End_User,
    fcst.FAB_LINE_NAME                                                           as FAB,
    case when startswith(fcst.PROFIT_CENTER_GROUP2_NAME, 'SPE-') then split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 2) 
        when split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('CT', 'SPS') then 'CTSPS'
        when split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('ES', 'Certas') then 'ES'
        when split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('TPS', 'SD', 'PVD') then 'TFF'
        when split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('3DI', 'TS') then 'ATS'
        else split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 1) 
    end                                                                          as BU,
    case when startswith(fcst.PROFIT_CENTER_GROUP2_NAME, 'SPE-') and split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 4) ilike any ('other', 'Others') then 'FS_Other'
        when startswith(fcst.PROFIT_CENTER_GROUP2_NAME, 'SPE-') and split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 3) = 'FS_Sic' then 'FS_SiC'
        when startswith(fcst.PROFIT_CENTER_GROUP2_NAME, 'SPE-') then split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 3)
        when split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 1) = 'FS_other' then 'FS_Other'
        when split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 1) = 'FS_Others' then 'FS_Other'
        else split_part(fcst.PROFIT_CENTER_GROUP2_NAME, '-', 1) 
    end                                                                         as SUB_BU,
    case when Sub_BU in ('ES' , 'Certas') then 'ES' 
        when Sub_BU in ('SD' , 'PVD') then 'SD'  
        else Sub_BU 
    end                                                                         as BU_Group,
    case when Sub_BU in ('ES', 'Certas') then 'ES' 
        when Sub_BU in ('SD', 'PVD') then 'SD' 
        when Sub_BU like '3DI%' then '3DI' 
        when Sub_BU like any ('FS_ES', 'FS_Certas') then 'FS_ES'
        when Sub_BU like any ('FS_PVD', 'FS_SD') then 'FS_SD'
        when Sub_BU like any ('FS_3DI', 'FS_CCS', 'FS_GCIB', 'FS_SiC', 'FS_SD', 'FS_TS', 'FS_Other', 'FS', 'FS_FSI', 'FS_EPION') then 'FS_Others'
        else Sub_BU 
    end                                                                         as BU_TYPE,
    case when length(fcst.SALES_DOCUMENT) = 10 then right(fcst.SALES_DOCUMENT,9) 
        else fcst.SALES_DOCUMENT 
    end                                                                         as Sales_Order_No,
    LABOrder.Order_Type_Group                                                   as Sales_Category_Group,
    fcst.SALES_CATEGORY_NAME                                                    as SALES_CATEGORY,
    case when fcst.SALES_REPORTING_FLAG = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as SALES_REPORTING_FLAG,
    case when fcst.BU_PLACEHOLDER = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as BU_PLACEHOLDER,
    fcst.BULK_FLAG,
    case when fcst.INTERNAL_SALES = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as INTERNAL_SALES,
    fcst.BOOKING_CONFIDENCE_BU,
    fcst.MODEL_NAME                                                             as Model,
    fcst.ORDER_ITEM_NAME                                                        as Order_Item,
    fcst.CRM_OPPORTUNITY_ID                                                     as Opportunity_ID,
    fcst.CRM_SALES_DOCUMENT_ID                                                  as Sales_Document_Item_No,
    fcst.PROJECT_DEFINITION                                                     as Project_No,
    fcst.SERIAL_NO,
    fcst.PM_SERIAL_NO,
    case when Sales_Category = 'Chamber' then fcst.PM_Serial_No 
        else fcst.Serial_No 
    end                                                                         as Adjusted_Serial_No,
    case when Adjusted_Serial_No <> split_part(Adjusted_Serial_No, ', ', 1) then split_part(case when endswith(Adjusted_Serial_No,'R') or endswith(Adjusted_Serial_No,'P') then substr(Adjusted_Serial_No, 1, length(Adjusted_Serial_No)-1) 
                                                                                          else Adjusted_Serial_No end, ',', 1)
        when Adjusted_Serial_No <> split_part(Adjusted_Serial_No, ',', 1) then split_part(case when endswith(Adjusted_Serial_No,'R') or endswith(Adjusted_Serial_No,'P') then substr(Adjusted_Serial_No, 1, length(Adjusted_Serial_No)-1) 
                                                                                          else Adjusted_Serial_No end, ',', 1)
        when Adjusted_Serial_No <> split_part(Adjusted_Serial_No, '(', 1) then split_part(case when endswith(Adjusted_Serial_No,'R') or endswith(Adjusted_Serial_No,'P') then substr(Adjusted_Serial_No, 1, length(Adjusted_Serial_No)-1) 
                                                                                          else Adjusted_Serial_No end, '(', 1)
        when Adjusted_Serial_No <> split_part(Adjusted_Serial_No, '/', 1) then split_part(case when endswith(Adjusted_Serial_No,'R') or endswith(Adjusted_Serial_No,'P') then substr(Adjusted_Serial_No, 1, length(Adjusted_Serial_No)-1) 
                                                                                          else Adjusted_Serial_No end, '/', 1)
        when Adjusted_Serial_No <> split_part(Adjusted_Serial_No, ' ', 1) then split_part(case when endswith(Adjusted_Serial_No,'R') or endswith(Adjusted_Serial_No,'P') then substr(Adjusted_Serial_No, 1, length(Adjusted_Serial_No)-1) 
                                                                                          else Adjusted_Serial_No end, ' ', 1)
        else case when endswith(Adjusted_Serial_No,'R') or endswith(Adjusted_Serial_No,'P') then substr(Adjusted_Serial_No, 1, length(Adjusted_Serial_No)-1) 
                    else Adjusted_Serial_No end 
    end                                                                         as First_Serial_No,
    fcst.CUSTOMER_TOOL_ID,
    fcst.QUANTITY,
    fcst.MAIN_TOOL,
    fcst.BOOKING_month,
    fcst.BOOKING_DATE,
    fcst.ENDUSER_BOOKING_month,
    fcst.ENDUSER_BOOKING_DATE,
    case when fcst.ENDUSER_BOOKING_DATE_ACTUAL = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as ENDUSER_BOOKING_DATE_ACTUAL,
    fcst.ORDER_APPROVAL_STATUS,
    fcst.SHIP_month,
    fcst.SHIP_DATE,
    fcst.SCHEDULED_CUSTOMS_CLEARAN_DATE,
	fcst.CONFIRMED_CUSTOMS_CLEARAN_DATE,
	fcst.SCHEDULED_ONDOCK_DATE,
	case when fcst.SCHEDULED_ONDOCKDATE_CONFIRMED = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as SCHEDULED_ONDOCKDATE_CONFIRMED,
    fcst.TECH_ACCEPT_TSR_SIGN_DATE,
	case when fcst.TECH_ACCEP_TSRSIGN_DATE_ACTUAL = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as TECH_ACCEP_TSRSIGN_DATE_ACTUAL,
	fcst.TECH_ACCEP_TSRSIGN_UNAVAILABLE,
	fcst.EST,
    fcst.SALES_DATE_EST_ACTUAL_STATUS,
	
    fcst.ENDUSER_SALES_EST_ACT_STATUS,
	fcst.APPROVAL_STATUS_SALES,
    case when fcst.SALES_RECORDING_FLAG = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as SALES_RECORDING_FLAG,
    fcst.SALES_MONTH,
    fcst.SALES_DATE,
    fcst.ENDUSER_SALES_MONTH,
    fcst.END_USER_SALES_DATE,
    fcst.LEDGER_CURRENCY                                                        as Currency,
    fcst.SALES_AMOUNT_LEDGE                                                     as Sales_Amount,
    -- GASSAN_SALES_AMOUNT_LEDGE                                                as Sales_Amount_after_Adjustment,
    case when fcst.LOANER in ('X', '1') then 'Yes' 
        else 'No' 
    end                                                                         as Is_Loaner,
    null                                                                        as Loan_Expiration_Date,
    case when to_date(fcst._FILEDATE) <= '8/1/2021' and fcst.REVENUE_RECOGNITION_CRITERIA = '1' then 'CST'
        when to_date(fcst._FILEDATE) >= '8/1/2021' and fcst.REVENUE_RECOGNITION_CRITERIA = '1' then 'Shipment'
        when to_date(fcst._FILEDATE) <= '8/1/2021' and fcst.REVENUE_RECOGNITION_CRITERIA = '2' then 'Shipment'
        when to_date(fcst._FILEDATE) >= '8/1/2021' and fcst.REVENUE_RECOGNITION_CRITERIA = '2' then 'Technical Acceptance'
        when fcst.REVENUE_RECOGNITION_CRITERIA = '3' then 'Completion of Service'
        when fcst.REVENUE_RECOGNITION_CRITERIA = '4' then 'Delivery' 
        when fcst.REVENUE_RECOGNITION_CRITERIA = '0' then NULL 
        else fcst.REVENUE_RECOGNITION_CRITERIA 
    end                                                                         as Revenue_Recognition_Criteria,
    case when to_date(fcst._FILEDATE) <= '8/1/2021' and fcst.REVENUE_RECOGNITION_CRITERIA = '1' then 'CST'
        when to_date(fcst._FILEDATE) >= '8/1/2021' and fcst.REVENUE_RECOGNITION_CRITERIA = '1' then 'Ship'
        when to_date(fcst._FILEDATE) <= '8/1/2021' and fcst.REVENUE_RECOGNITION_CRITERIA = '2' then 'Ship'
        when to_date(fcst._FILEDATE) >= '8/1/2021' and fcst.REVENUE_RECOGNITION_CRITERIA = '2' then 'Acceptance'
        when fcst.REVENUE_RECOGNITION_CRITERIA = '3' then 'TSR'
        when fcst.REVENUE_RECOGNITION_CRITERIA = '4' then 'Delivery' 
        when fcst.REVENUE_RECOGNITION_CRITERIA = '0' then NULL 
        else fcst.REVENUE_RECOGNITION_CRITERIA 
    end                                                                         as Revenue_Recognition_Criteria_Short,
    fcst.SALES_DOCUMENT_TYPES,
    case when fcst.REVENUE_RECOGNITION = 'Y' then 'Yes' 
        else 'No' 
    end                                                                         as REVENUE_RECOGNITION,
    fcst.SALES_COMMENTS,
    fcst.INTERNAL_COMMENTS,
    fcst._FILEDATE                                                               as Data_Snapshot,
    fcst.SOURCETYPE                                                             as Source_Type,
    case when month(DATA_SNAPSHOT) in (1, 2, 3, 4, 5, 6) then 'Original' 
        when month(DATA_SNAPSHOT) in (7, 8, 9, 10, 11, 12) then 'Revised' 
    end                                                                         as Budget_Type,
    fcst.COST_CENTER                                                            as Cost_Center_Code,
    fcst.PROFIT_CENTER_GROUP2,
    fcst.PROFIT_CENT_GROUP_REPSEG,
    fcst.PROFIT_CENTER                                                          as Profit_Center_Code,
    fcst.PROFIT_CENTER_GROUP1                                                   as Profit_Center_Group_Code,
    fcst.SALES_CATEGORY                                                         as SALES_CATEGORY_CODE,
    fcst.MATERIAL_GROUP                                                         as Material_Group_Code,
    fcst.MODEL_CODE,
    fcst.SOLD_TO_PARTY_CODE,
    fcst.SOLD_TO_PARTY_OFFICE_CODE,
    fcst.END_USER                                                               as End_User_Code,
    fcst.ENDUSER_OFFICE_CODE,
    fcst.FAB_LINE_CODE                                                          as FAB_Code,
    fcst.SALES_MONTH                                                            as Accounting_Forecast_FK_Date,
    CommonDate.fiscal_year_short_text                                           as Accounting_Forecast_FY,
    CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT                             as Accounting_Forecast_FY_Half,
    CommonDate.fiscal_year_quarter_short_text                                   as Accounting_Forecast_FY_Q,
    to_date(CommonDate.FISCAL_HALF_YEAR_BEGINNING_DATE)                         as Beginning_of_Accounting_Forecast_FY_HALF,
    to_date(CommonDate.FISCAL_HALF_YEAR_ENDING_DATE)                            as End_of_Accounting_Forecast_FY_HALF,
    to_date(CommonDate.quarter_beginning_date)                                  as Beginning_of_Accounting_Forecast_FY_Q,
    to_date(CommonDate.quarter_ending_date)                                     as End_of_Accounting_Forecast_FY_Q,
    CommonDate1.FISCAL_YEAR_BEGINNING_DATE                                      as Beginning_of_Current_FY,
    CommonDate1.FISCAL_YEAR_ENDING_DATE                                         as End_of_Current_FY,
	CommonDate1.FISCAL_HALF_YEAR_BEGINNING_DATE                                 as Beginning_of_Current_FY_Half,
	CommonDate1.FISCAL_HALF_YEAR_ENDING_DATE                                    as End_of_Current_FY_Half,
	CommonDate1.FISCAL_QUARTER_BEGINNING_DATE                                   as Beginning_of_Current_FY_Q,
	CommonDate1.FISCAL_QUARTER_ENDING_DATE                                      as End_of_Current_FY_Q,
    dateadd('year', 1, Beginning_of_Current_FY)                                 as Beginning_of_Next_FY,
	dateadd('year', 1, End_of_Current_FY)                                       as End_of_Next_FY,
	dateadd('month', 6, Beginning_of_Current_FY_Half)                           as Beginning_of_Next_FY_Half,
	dateadd('month', 6, End_of_Current_FY_Half)                                 as End_of_Next_FY_Half,
	dateadd('month', 3, Beginning_of_Current_FY_Q)                              as Beginning_of_Next_FY_Q,
	dateadd('month', 3, End_of_Current_FY_Q)                                    as End_of_Next_FY_Q,
	dateadd('year', -2, Beginning_of_Current_FY)                                as Beginning_of_2_FY_Ago,
	dateadd('year', 2, End_of_Current_FY)                                       as End_of_2_FY_Ahead,
    fcst._FILENAME
from {{ ref('SILVER__TEH_EQUIPMENT_SALES__FILE_TEL_ACC_REVENUE_BUDGET_FORECAST') }} fcst
left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }} acc on acc.ACCOUNT_CODE = case when fcst.END_USER = 'バルク' then fcst.ENDUSER_OFFICE_CODE else coalesce(fcst.END_USER, fcst.ENDUSER_OFFICE_CODE) end
left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_US_ORDER_TYPE') }} LABOrder on LABOrder.ORDER_TYPE_Code = fcst.SALES_CATEGORY
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate on to_date(CommonDate.CALENDAR_DATE) = fcst.Sales_Month
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate1 on to_date(CommonDate1.CALENDAR_DATE) = current_date()
where fcst.SALES_CATEGORY like any ('1%', '2%', '3%')
    and fcst.SOURCETYPE = 'FORECAST'
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ACCOUNT_GROUP1,
        ACCOUNT_GROUP2,
        SALES_ACCOUNT,
        SALES_REGION,
        SALES_ACCOUNT_REGION,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        SUB_BU,
        BU_GROUP,
        BU_TYPE,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        SALES_REPORTING_FLAG,
        BU_PLACEHOLDER,
        BULK_FLAG,
        INTERNAL_SALES,
        BOOKING_CONFIDENCE_BU,
        MODEL,
        ORDER_ITEM,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO,
        PROJECT_NO,
        SERIAL_NO,
        PM_SERIAL_NO,
        ADJUSTED_SERIAL_NO,
        FIRST_SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUANTITY,
        MAIN_TOOL,
        BOOKING_MONTH,
        BOOKING_DATE,
        ENDUSER_BOOKING_MONTH,
        ENDUSER_BOOKING_DATE,
        ENDUSER_BOOKING_DATE_ACTUAL,
        ORDER_APPROVAL_STATUS,
        SHIP_MONTH,
        SHIP_DATE,
        SCHEDULED_CUSTOMS_CLEARAN_DATE,
        CONFIRMED_CUSTOMS_CLEARAN_DATE,
        SCHEDULED_ONDOCK_DATE,
        SCHEDULED_ONDOCKDATE_CONFIRMED,
        TECH_ACCEPT_TSR_SIGN_DATE,
        TECH_ACCEP_TSRSIGN_DATE_ACTUAL,
        TECH_ACCEP_TSRSIGN_UNAVAILABLE,
        EST,
        SALES_DATE_EST_ACTUAL_STATUS,
        ENDUSER_SALES_EST_ACT_STATUS,
        APPROVAL_STATUS_SALES,
        SALES_RECORDING_FLAG,
        SALES_MONTH,
        SALES_DATE,
        ENDUSER_SALES_MONTH,
        END_USER_SALES_DATE,
        CURRENCY,
        SALES_AMOUNT,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        REVENUE_RECOGNITION_CRITERIA,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        SALES_DOCUMENT_TYPES,
        REVENUE_RECOGNITION,
        SALES_COMMENTS,
        INTERNAL_COMMENTS,
        DATA_SNAPSHOT,
        SOURCE_TYPE,
        BUDGET_TYPE,
        COST_CENTER_CODE,
        PROFIT_CENTER_GROUP2,
        PROFIT_CENT_GROUP_REPSEG,
        PROFIT_CENTER_CODE,
        PROFIT_CENTER_GROUP_CODE,
        SALES_CATEGORY_CODE,
        MATERIAL_GROUP_CODE,
        MODEL_CODE,
        SOLD_TO_PARTY_CODE,
        SOLD_TO_PARTY_OFFICE_CODE,
        END_USER_CODE,
        ENDUSER_OFFICE_CODE,
        FAB_CODE,
        ACCOUNTING_FORECAST_FK_DATE,
        ACCOUNTING_FORECAST_FY,
        ACCOUNTING_FORECAST_FY_HALF,
        ACCOUNTING_FORECAST_FY_Q,
        BEGINNING_OF_ACCOUNTING_FORECAST_FY_HALF,
        END_OF_ACCOUNTING_FORECAST_FY_HALF,
        BEGINNING_OF_ACCOUNTING_FORECAST_FY_Q,
        END_OF_ACCOUNTING_FORECAST_FY_Q,
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
        BEGINNING_OF_2_FY_AGO,
        END_OF_2_FY_AHEAD,
        _FILENAME
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ACCOUNT_GROUP1,
        ACCOUNT_GROUP2,
        SALES_ACCOUNT,
        SALES_REGION,
        SALES_ACCOUNT_REGION,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        SUB_BU,
        BU_GROUP,
        BU_TYPE,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        SALES_REPORTING_FLAG,
        BU_PLACEHOLDER,
        BULK_FLAG,
        INTERNAL_SALES,
        BOOKING_CONFIDENCE_BU,
        MODEL,
        ORDER_ITEM,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO,
        PROJECT_NO,
        SERIAL_NO,
        PM_SERIAL_NO,
        ADJUSTED_SERIAL_NO,
        FIRST_SERIAL_NO,
        CUSTOMER_TOOL_ID,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(MAIN_TOOL as NUMBER(38,0)) as MAIN_TOOL,
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(BOOKING_DATE as DATE) as BOOKING_DATE,
        CAST(ENDUSER_BOOKING_MONTH as DATE) as ENDUSER_BOOKING_MONTH,
        CAST(ENDUSER_BOOKING_DATE as DATE) as ENDUSER_BOOKING_DATE,
        ENDUSER_BOOKING_DATE_ACTUAL,
        ORDER_APPROVAL_STATUS,
        CAST(SHIP_MONTH as DATE) as SHIP_MONTH,
        CAST(SHIP_DATE as DATE) as SHIP_DATE,
        CAST(SCHEDULED_CUSTOMS_CLEARAN_DATE as DATE) as SCHEDULED_CUSTOMS_CLEARAN_DATE,
        CAST(CONFIRMED_CUSTOMS_CLEARAN_DATE as DATE) as CONFIRMED_CUSTOMS_CLEARAN_DATE,
        CAST(SCHEDULED_ONDOCK_DATE as DATE) as SCHEDULED_ONDOCK_DATE,
        SCHEDULED_ONDOCKDATE_CONFIRMED,
        CAST(TECH_ACCEPT_TSR_SIGN_DATE as DATE) as TECH_ACCEPT_TSR_SIGN_DATE,
        TECH_ACCEP_TSRSIGN_DATE_ACTUAL,
        TECH_ACCEP_TSRSIGN_UNAVAILABLE,
        EST,
        SALES_DATE_EST_ACTUAL_STATUS,
        ENDUSER_SALES_EST_ACT_STATUS,
        APPROVAL_STATUS_SALES,
        SALES_RECORDING_FLAG,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        CAST(ENDUSER_SALES_MONTH as DATE) as ENDUSER_SALES_MONTH,
        CAST(END_USER_SALES_DATE as DATE) as END_USER_SALES_DATE,
        CURRENCY,
        CAST(SALES_AMOUNT as NUMBER(38,0)) as SALES_AMOUNT,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        REVENUE_RECOGNITION_CRITERIA,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        SALES_DOCUMENT_TYPES,
        REVENUE_RECOGNITION,
        SALES_COMMENTS,
        INTERNAL_COMMENTS,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        SOURCE_TYPE,
        BUDGET_TYPE,
        COST_CENTER_CODE,
        PROFIT_CENTER_GROUP2,
        PROFIT_CENT_GROUP_REPSEG,
        PROFIT_CENTER_CODE,
        PROFIT_CENTER_GROUP_CODE,
        SALES_CATEGORY_CODE,
        MATERIAL_GROUP_CODE,
        MODEL_CODE,
        SOLD_TO_PARTY_CODE,
        SOLD_TO_PARTY_OFFICE_CODE,
        END_USER_CODE,
        ENDUSER_OFFICE_CODE,
        FAB_CODE,
        CAST(ACCOUNTING_FORECAST_FK_DATE as DATE) as ACCOUNTING_FORECAST_FK_DATE,
        ACCOUNTING_FORECAST_FY,
        ACCOUNTING_FORECAST_FY_HALF,
        ACCOUNTING_FORECAST_FY_Q,
        CAST(BEGINNING_OF_ACCOUNTING_FORECAST_FY_HALF as DATE) as BEGINNING_OF_ACCOUNTING_FORECAST_FY_HALF,
        CAST(END_OF_ACCOUNTING_FORECAST_FY_HALF as DATE) as END_OF_ACCOUNTING_FORECAST_FY_HALF,
        CAST(BEGINNING_OF_ACCOUNTING_FORECAST_FY_Q as DATE) as BEGINNING_OF_ACCOUNTING_FORECAST_FY_Q,
        CAST(END_OF_ACCOUNTING_FORECAST_FY_Q as DATE) as END_OF_ACCOUNTING_FORECAST_FY_Q,
        CAST(BEGINNING_OF_CURRENT_FY as DATE) as BEGINNING_OF_CURRENT_FY,
        CAST(END_OF_CURRENT_FY as DATE) as END_OF_CURRENT_FY,
        CAST(BEGINNING_OF_CURRENT_FY_HALF as DATE) as BEGINNING_OF_CURRENT_FY_HALF,
        CAST(END_OF_CURRENT_FY_HALF as DATE) as END_OF_CURRENT_FY_HALF,
        CAST(BEGINNING_OF_CURRENT_FY_Q as DATE) as BEGINNING_OF_CURRENT_FY_Q,
        CAST(END_OF_CURRENT_FY_Q as DATE) as END_OF_CURRENT_FY_Q,
        CAST(BEGINNING_OF_NEXT_FY as DATE) as BEGINNING_OF_NEXT_FY,
        CAST(END_OF_NEXT_FY as DATE) as END_OF_NEXT_FY,
        CAST(BEGINNING_OF_NEXT_FY_HALF as DATE) as BEGINNING_OF_NEXT_FY_HALF,
        CAST(END_OF_NEXT_FY_HALF as DATE) as END_OF_NEXT_FY_HALF,
        CAST(BEGINNING_OF_NEXT_FY_Q as DATE) as BEGINNING_OF_NEXT_FY_Q,
        CAST(END_OF_NEXT_FY_Q as DATE) as END_OF_NEXT_FY_Q,
        CAST(BEGINNING_OF_2_FY_AGO as DATE) as BEGINNING_OF_2_FY_AGO,
        CAST(END_OF_2_FY_AHEAD as DATE) as END_OF_2_FY_AHEAD,
        _FILENAME
from transform_data
)
SELECT * FROM TYPE_DATA