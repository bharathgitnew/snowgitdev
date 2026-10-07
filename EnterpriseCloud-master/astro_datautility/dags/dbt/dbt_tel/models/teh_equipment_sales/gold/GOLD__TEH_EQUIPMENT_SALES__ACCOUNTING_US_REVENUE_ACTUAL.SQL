{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='ACCOUNTING_US_REVENUE_ACTUAL',
    transient=false
) }}

with
OldEndUserCode
as
(
select
    case when act.CUSTOMER_GROUP_1_NAME in ('インテル', 'INTEL GROUP') then 'Intel'
        when act.CUSTOMER_GROUP_1_NAME in ('サムスン', 'SAMSUNG GROUP') then 'Samsung'
        when act.CUSTOMER_GROUP_1_NAME = 'マイクロン' then 'Micron'
        else act.CUSTOMER_GROUP_1_NAME 
    end                                                                         as Account_Group1,
    case when act.CUSTOMER_GROUP_1_NAME in ('インテル', 'INTEL GROUP') then 'Intel'
        when act.CUSTOMER_GROUP_1_NAME in ('サムスン', 'SAMSUNG GROUP') then 'Samsung'
        when act.CUSTOMER_GROUP_2_NAME = 'マイクロン' then 'Micron'
        when act.CUSTOMER_GROUP_2_NAME = 'スカイワークス' then 'Skyworks'
        when act.CUSTOMER_GROUP_2_NAME = 'ウェスタンディジタル' then 'Western Digital'
        when act.CUSTOMER_GROUP_2_NAME = 'ルネサス' then 'Renesas'
        else act.CUSTOMER_GROUP_2_NAME 
    end                                                                         as Account_Group2,
    case when act.END_USER ilike any ('2020100', '4712300', '4712302', '4604901', '4369000', '4369003') then 'GF/IBM'
        when act.END_USER = '3883601' then 'tsmc'
        when act.END_USER ilike any ('2130100', '2130123', '4415000') then 'TI'
        when act.END_USER = '3435602' then 'Micron'
        when act.END_USER ilike any ('2030117', '3461200', '2030102', '2030105', '2030106') then 'Intel'
        when act.END_USER = '10100' and act.ENDUSER_OFFICE_CODE = '4369003' then 'GF/IBM' --RFSUNY
        when act.END_USER = '10100' and act.ENDUSER_OFFICE_CODE ilike any ('3192705', '4631700') then 'Regional' --Fairchild, GP Tech
        when act.END_USER = '10100' and act.ENDUSER_OFFICE_CODE = '2120300' then 'Samsung' --SAS
        when act.END_USER = '10100' and act.ENDUSER_OFFICE_CODE = '2030102' then 'Intel'
        when act.END_USER = '10100' and act.ENDUSER_OFFICE_CODE ilike any ('3435602', '3435603') then 'Micron'
        when act.END_USER = '10100' and act.ENDUSER_OFFICE_CODE = '4415000' then 'TI'
        when act.END_USER ilike any ('12300', '10100') then 'TEL Group'
        else acc.SALES_ACCOUNT_TI 
    end                                                                         as Sales_Account,
    acc.Sales_Region,
    case when act.END_USER ilike any ('2020100', '4712300', '4712302', '4604901', '4369000', '4369003') then 'GF/IBM'
        when act.END_USER = '3883601' then 'tsmc'
        when act.END_USER ilike any ('2130100', '2130123', '4415000') then 'TI'
        when act.END_USER = '3435602' then 'Micron'
        when act.END_USER ilike any ('2030117', '3461200', '2030102', '2030105', '2030106') then 'Intel'
        when act.END_USER = '10100' and act.ENDUSER_OFFICE_CODE ilike any ('3435602', '3435603') then 'Micron'
        when act.END_USER = '10100' and act.ENDUSER_OFFICE_CODE = '4415000' then 'TI'
        when act.END_USER ilike any ('12300', '10100') then 'TEL Group'
        when Sales_Account = 'Regional' then concat(Sales_Account, ' ', Sales_Region)
        else Sales_Account 
    end                                                                         as Sales_Account_Region,
    act.SOLD_TO_PARTY_OFFICE_S_NAME_EN                                          as Sold_to_Party,
    act.ENDUSER_OFFICE_S_NAME_EN                                                as End_User,
    act.FAB_LINE_NAME                                                           as FAB,
    case when startswith(act.PROFIT_CENTER_GROUP2_NAME, 'SPE-') then split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 2) 
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('CT', 'SPS') then 'CTSPS'
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('ES', 'Certas') then 'ES'
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('TPS', 'SD', 'PVD') then 'TFF'
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('3DI', 'TS') then 'ATS'
        else split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) 
    end                                                                         as BU,
    case when startswith(act.PROFIT_CENTER_GROUP2_NAME, 'SPE-') and split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 4) ilike any ('other', 'Others') then 'FS_Other'
        when startswith(act.PROFIT_CENTER_GROUP2_NAME, 'SPE-') and split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 3) = 'FS_Sic' then 'FS_SiC'
        when startswith(act.PROFIT_CENTER_GROUP2_NAME, 'SPE-') then split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 3)
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) = 'FS_other' then 'FS_Other'
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) = 'FS_Others' then 'FS_Other'
        else split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) 
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
    case when length(act.SALES_DOCUMENT) = 10 then right(act.SALES_DOCUMENT,9) 
        else act.SALES_DOCUMENT 
    end                                                                         as Sales_Order_No,
    LABOrder.Order_Type_Group                                                   as Sales_Category_Group,
    act.SALES_CATEGORY_NAME                                                     as SALES_CATEGORY,
    case when act.SALES_REPORTING_FLAG = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as SALES_REPORTING_FLAG,
    case when act.BU_PLACEHOLDER = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as BU_PLACEHOLDER,
    act.BULK_FLAG,
    case when act.INTERNAL_SALES = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as INTERNAL_SALES,
    act.BOOKING_CONFIDENCE_BU,
    act.MODEL_NAME                                                              as Model,
    act.ORDER_ITEM_NAME                                                         as Order_Item,
    act.CRM_OPPORTUNITY_ID                                                      as Opportunity_ID,
    act.CRM_SALES_DOCUMENT_ID                                                   as Sales_Document_Item_No,
    act.PROJECT_DEFINITION                                                      as Project_No,
    act.SERIAL_NO,
    act.PM_SERIAL_NO,
    case when Sales_Category = 'Chamber' then act.PM_Serial_No 
        else act.Serial_No 
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
    act.CUSTOMER_TOOL_ID,
    act.QUANTITY,
    act.MAIN_TOOL,
    act.BOOKING_MONTH,
    act.BOOKING_DATE,
    act.ENDUSER_BOOKING_month,
    act.ENDUSER_BOOKING_DATE,
    case when act.ENDUSER_BOOKING_DATE_ACTUAL = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as ENDUSER_BOOKING_DATE_ACTUAL,
    act.ORDER_APPROVAL_STATUS,
    act.SHIP_MONTH,
    act.SHIP_DATE,
    act.SCHEDULED_CUSTOMS_CLEARAN_DATE,
	act.CONFIRMED_CUSTOMS_CLEARAN_DATE,
	act.SCHEDULED_ONDOCK_DATE,
	case when act.SCHEDULED_ONDOCKDATE_CONFIRMED = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as SCHEDULED_ONDOCKDATE_CONFIRMED,
    act.TECH_ACCEPT_TSR_SIGN_DATE,
	case when act.TECH_ACCEP_TSRSIGN_DATE_ACTUAL = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as TECH_ACCEP_TSRSIGN_DATE_ACTUAL,
	act.TECH_ACCEP_TSRSIGN_UNAVAILABLE,
	act.EST,
    act.SALES_DATE_EST_ACTUAL_STATUS,
    act.ENDUSER_SALES_EST_ACT_STATUS,
	act.APPROVAL_STATUS_SALES,
    case when act.SALES_RECORDING_FLAG = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as SALES_RECORDING_FLAG,
    act.SALES_MONTH,
    act.SALES_DATE,
    act.ENDUSER_SALES_MONTH,
    act.END_USER_SALES_DATE,
    act.LEDGER_CURRENCY                                                         as Currency,
    act.SALES_AMOUNT_LEDGE                                                      as Sales_Amount,
    -- GASSAN_SALES_AMOUNT_LEDGE                                                as Sales_Amount_after_Adjustment,
    case when act.LOANER in ('X', '1') then 'Yes' 
        else 'No' 
    end                                                                         as Is_Loaner,
    null                                                                        as Loan_Expiration_Date,
    case when to_date(act._FILEDATE) <= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '1' then 'CST'
        when to_date(act._FILEDATE) >= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '1' then 'Shipment'
        when to_date(act._FILEDATE) <= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '2' then 'Shipment'
        when to_date(act._FILEDATE) >= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '2' then 'Technical Acceptance'
        when act.REVENUE_RECOGNITION_CRITERIA = '3' then 'Completion of Service'
        when act.REVENUE_RECOGNITION_CRITERIA = '4' then 'Delivery' 
        when act.REVENUE_RECOGNITION_CRITERIA = '0' then NULL 
        else act.REVENUE_RECOGNITION_CRITERIA 
    end                                                                         as Revenue_Recognition_Criteria,
    case when to_date(act._FILEDATE) <= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '1' then 'CST'
        when to_date(act._FILEDATE) >= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '1' then 'Ship'
        when to_date(act._FILEDATE) <= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '2' then 'Ship'
        when to_date(act._FILEDATE) >= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '2' then 'Acceptance'
        when act.REVENUE_RECOGNITION_CRITERIA = '3' then 'TSR'
        when act.REVENUE_RECOGNITION_CRITERIA = '4' then 'Delivery' 
        when act.REVENUE_RECOGNITION_CRITERIA = '0' then NULL 
        else act.REVENUE_RECOGNITION_CRITERIA 
    end                                                                         as Revenue_Recognition_Criteria_Short,
    act.SALES_DOCUMENT_TYPES,
    case when act.REVENUE_RECOGNITION = 'Y' then 'Yes' 
        else 'No' 
    end                                                                         as REVENUE_RECOGNITION,
    act.SALES_COMMENTS,
    act.INTERNAL_COMMENTS,
    act._FILEDATE                                                                as Data_Snapshot,
    act.SOURCETYPE                                                              as Source_Type,
    case when month(DATA_SNAPSHOT) in (1, 2, 3, 4, 5, 6) then 'Original' 
        when month(DATA_SNAPSHOT) in (7, 8, 9, 10, 11, 12) then 'Revised' 
    end                                                                         as Budget_Type,
    act.COST_CENTER                                                             as Cost_Center_Code,
    act.PROFIT_CENTER_GROUP2,
    act.PROFIT_CENT_GROUP_REPSEG,
    act.PROFIT_CENTER                                                           as Profit_Center_Code,
    act.PROFIT_CENTER_GROUP1                                                    as Profit_Center_Group_Code,
    act.SALES_CATEGORY                                                          as SALES_CATEGORY_CODE,
    act.MATERIAL_GROUP                                                          as Material_Group_Code,
    act.MODEL_CODE,
    act.SOLD_TO_PARTY_CODE,
    act.SOLD_TO_PARTY_OFFICE_CODE,
    act.END_USER                                                                as End_User_Code,
    act.ENDUSER_OFFICE_CODE,
    act.FAB_LINE_CODE                                                           as FAB_Code,
    act.SALES_MONTH                                                             as Accounting_ACTUAL_FK_Date,
    CommonDate.fiscal_year_short_text                                           as Accounting_ACTUAL_FY,
    CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT                             as Accounting_ACTUAL_FY_Half,
    CommonDate.fiscal_year_quarter_short_text                                   as Accounting_ACTUAL_FY_Q,
    to_date(CommonDate.FISCAL_HALF_YEAR_BEGINNING_DATE)                         as Beginning_of_Accounting_ACTUAL_FY_HALF,
    to_date(CommonDate.FISCAL_HALF_YEAR_ENDING_DATE)                            as End_of_Accounting_ACTUAL_FY_HALF,
    to_date(CommonDate.quarter_beginning_date)                                  as Beginning_of_Accounting_ACTUAL_FY_Q,
    to_date(CommonDate.quarter_ending_date)                                     as End_of_Accounting_ACTUAL_FY_Q,
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
    act._FILENAME
from {{ ref('SILVER__TEH_EQUIPMENT_SALES__FILE_TEL_ACC_REVENUE_BUDGET_FORECAST') }} act
left outer join (select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }} qualify row_number() over (partition by _5_DIGIT_OLD_CUSTOMER_CODE order by ACCOUNT_CODE) = 1) acc 
            on acc._5_DIGIT_OLD_CUSTOMER_CODE = left(act.END_USER, 5)
left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_US_ORDER_TYPE') }} LABOrder on LABOrder.ORDER_TYPE_Code = act.SALES_CATEGORY
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate on to_date(CommonDate.CALENDAR_DATE) = act.Sales_Month
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate1 on to_date(CommonDate1.CALENDAR_DATE) = current_date()
where act._FILEDATE = '10/10/2018'
    and act.SALES_CATEGORY like any ('1%', '2%', '3%')
    and act.SOURCETYPE = 'ACTUAL'
),    
SAPEndUserCode
as
(
select
    case when act.CUSTOMER_GROUP_1_NAME in ('インテル', 'INTEL GROUP') then 'Intel'
        when act.CUSTOMER_GROUP_1_NAME in ('サムスン', 'SAMSUNG GROUP') then 'Samsung'
        when act.CUSTOMER_GROUP_1_NAME = 'マイクロン' then 'Micron'
        else act.CUSTOMER_GROUP_1_NAME 
    end                                                                         as Account_Group1,
    case when act.CUSTOMER_GROUP_1_NAME in ('インテル', 'INTEL GROUP') then 'Intel'
        when act.CUSTOMER_GROUP_1_NAME in ('サムスン', 'SAMSUNG GROUP') then 'Samsung'
        when act.CUSTOMER_GROUP_2_NAME = 'マイクロン' then 'Micron'
        when act.CUSTOMER_GROUP_2_NAME = 'スカイワークス' then 'Skyworks'
        when act.CUSTOMER_GROUP_2_NAME = 'ウェスタンディジタル' then 'Western Digital'
        when act.CUSTOMER_GROUP_2_NAME = 'ルネサス' then 'Renesas'
        else act.CUSTOMER_GROUP_2_NAME 
    end                                                                         as Account_Group2,
    case --when SOLD_TO_PARTY_OFFICE_S_NAME_EN = 'MTTW' and ENDUSER_OFFICE_S_NAME_EN = 'MICRON' then 'Micron'
        when act.END_USER = 'B00001020' then 'GF/IBM'
        when act.END_USER = 'AA0012300' then 'TEL Group' --TTCA
        when act.END_USER = 'BA4316900' then 'Micron' -- MTTW
        when act.END_USER = 'B00003624' then 'Intel'
        when act.END_USER = 'BA0010149' and startswith(act.ENDUSER_OFFICE_S_NAME_EN, 'INTEL') then 'Intel'
        when act.END_USER = 'BA0010149' and startswith(act.ENDUSER_OFFICE_S_NAME_EN, 'Regional') then 'N/A'
        else acc.SALES_ACCOUNT_TI 
    end                                                                         as Sales_Account,
    acc.Sales_Region,
    case when act.END_USER = 'B00001020' then 'GF/IBM'
        when act.END_USER = 'AA0012300' then 'TEL Group' --TTCA
        when act.END_USER = 'BA4316900' then 'Micron' -- MTTW
        when act.END_USER = 'B00003624' then 'Intel'
        when act.END_USER = 'BA0010149' and startswith(act.ENDUSER_OFFICE_S_NAME_EN, 'INTEL') then 'Intel'
        when act.END_USER = 'BA0010149' and startswith(act.ENDUSER_OFFICE_S_NAME_EN, 'Regional') then 'N/A'
        when Sales_Account = 'Regional' then concat(Sales_Account, ' ', Sales_Region)
        else Sales_Account 
    end                                                                         as Sales_Account_Region,
    act.SOLD_TO_PARTY_OFFICE_S_NAME_EN                                          as Sold_to_Party,
    coalesce(act.ENDUSER_OFFICE_S_NAME_EN, act.SOLD_TO_PARTY_OFFICE_S_NAME_EN)  as End_User,
    act.FAB_LINE_NAME                                                           as FAB,
    case when startswith(act.PROFIT_CENTER_GROUP2_NAME, 'SPE-') then split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 2) 
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('CT', 'SPS') then 'CTSPS'
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('ES', 'Certas') then 'ES'
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('TPS', 'SD', 'PVD') then 'TFF'
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) in ('3DI', 'TS') then 'ATS'
        else split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) 
    end                                                                         as BU,
    case when startswith(act.PROFIT_CENTER_GROUP2_NAME, 'SPE-') and split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 4) ilike any ('other', 'Others') then 'FS_Other'
        when startswith(act.PROFIT_CENTER_GROUP2_NAME, 'SPE-') and split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 3) = 'FS_Sic' then 'FS_SiC'
        when startswith(act.PROFIT_CENTER_GROUP2_NAME, 'SPE-') then split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 3)
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) = 'FS_other' then 'FS_Other'
        when split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) = 'FS_Others' then 'FS_Other'
        else split_part(act.PROFIT_CENTER_GROUP2_NAME, '-', 1) 
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
    case when length(act.SALES_DOCUMENT) = 10 then right(act.SALES_DOCUMENT,9) 
        else act.SALES_DOCUMENT 
    end                                                                         as Sales_Order_No,
    LABOrder.Order_Type_Group                                                   as Sales_Category_Group,
    act.SALES_CATEGORY_NAME                                                     as SALES_CATEGORY,
    case when act.SALES_REPORTING_FLAG = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as SALES_REPORTING_FLAG,
    case when act.BU_PLACEHOLDER = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as BU_PLACEHOLDER,
    act.BULK_FLAG,
    case when act.INTERNAL_SALES = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as INTERNAL_SALES,
    act.BOOKING_CONFIDENCE_BU,
    act.MODEL_NAME                                                              as Model,
    act.ORDER_ITEM_NAME                                                         as Order_Item,
    act.CRM_OPPORTUNITY_ID                                                      as Opportunity_ID,
    act.CRM_SALES_DOCUMENT_ID                                                   as Sales_Document_Item_No,
    act.PROJECT_DEFINITION                                                      as Project_No,
    act.SERIAL_NO,
    act.PM_SERIAL_NO,
    case when Sales_Category = 'Chamber' then act.PM_Serial_No 
        else act.Serial_No 
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
    act.CUSTOMER_TOOL_ID,
    act.QUANTITY,
    act.MAIN_TOOL,
    act.BOOKING_MONTH,
    act.BOOKING_DATE,
    act.ENDUSER_BOOKING_month,
    act.ENDUSER_BOOKING_DATE,
    case when act.ENDUSER_BOOKING_DATE_ACTUAL = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as ENDUSER_BOOKING_DATE_ACTUAL,
    act.ORDER_APPROVAL_STATUS,
    act.SHIP_MONTH,
    act.SHIP_DATE,
    act.SCHEDULED_CUSTOMS_CLEARAN_DATE,
	act.CONFIRMED_CUSTOMS_CLEARAN_DATE,
	act.SCHEDULED_ONDOCK_DATE,
	case when act.SCHEDULED_ONDOCKDATE_CONFIRMED = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as SCHEDULED_ONDOCKDATE_CONFIRMED,
    act.TECH_ACCEPT_TSR_SIGN_DATE,
	case when act.TECH_ACCEP_TSRSIGN_DATE_ACTUAL = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as TECH_ACCEP_TSRSIGN_DATE_ACTUAL,
	act.TECH_ACCEP_TSRSIGN_UNAVAILABLE,
	act.EST,
    act.SALES_DATE_EST_ACTUAL_STATUS,
	act.ENDUSER_SALES_EST_ACT_STATUS,
	act.APPROVAL_STATUS_SALES,
    case when act.SALES_RECORDING_FLAG = 'X' then 'Yes' 
        else 'No' 
    end                                                                         as SALES_RECORDING_FLAG,
    act.SALES_MONTH,
    act.SALES_DATE,
    act.ENDUSER_SALES_month,
    act.END_USER_SALES_DATE,
    act.LEDGER_CURRENCY                                                         as Currency,
    act.SALES_AMOUNT_LEDGE                                                      as Sales_Amount,
    -- GASSAN_SALES_AMOUNT_LEDGE                                                as Sales_Amount_after_Adjustment,
    case when act.LOANER in ('X', '1') then 'Yes' 
        else 'No' 
    end                                                                         as Is_Loaner,
    null                                                                        as Loan_Expiration_Date,
    case when to_date(act._FILEDATE) <= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '1' then 'CST'
        when to_date(act._FILEDATE) >= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '1' then 'Shipment'
        when to_date(act._FILEDATE) <= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '2' then 'Shipment'
        when to_date(act._FILEDATE) >= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '2' then 'Technical Acceptance'
        when act.REVENUE_RECOGNITION_CRITERIA = '3' then 'Completion of Service'
        when act.REVENUE_RECOGNITION_CRITERIA = '4' then 'Delivery' 
        when act.REVENUE_RECOGNITION_CRITERIA = '0' then NULL 
        else act.REVENUE_RECOGNITION_CRITERIA 
    end                                                                         as Revenue_Recognition_Criteria,
    case when to_date(act._FILEDATE) <= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '1' then 'CST'
        when to_date(act._FILEDATE) >= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '1' then 'Ship'
        when to_date(act._FILEDATE) <= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '2' then 'Ship'
        when to_date(act._FILEDATE) >= '8/1/2021' and act.REVENUE_RECOGNITION_CRITERIA = '2' then 'Acceptance'
        when act.REVENUE_RECOGNITION_CRITERIA = '3' then 'TSR'
        when act.REVENUE_RECOGNITION_CRITERIA = '4' then 'Delivery' 
        when act.REVENUE_RECOGNITION_CRITERIA = '0' then NULL 
        else act.REVENUE_RECOGNITION_CRITERIA 
    end                                                                         as Revenue_Recognition_Criteria_Short,
    act.SALES_DOCUMENT_TYPES,
    case when act.REVENUE_RECOGNITION = 'Y' then 'Yes' 
        else 'No' 
    end                                                                         as REVENUE_RECOGNITION,
    act.SALES_COMMENTS,
    act.INTERNAL_COMMENTS,
    act._FILEDATE                                                                as Data_Snapshot,
    act.SOURCETYPE                                                              as Source_Type,
    case when month(DATA_SNAPSHOT) in (1, 2, 3, 4, 5, 6) then 'Original' 
        when month(DATA_SNAPSHOT) in (7, 8, 9, 10, 11, 12) then 'Revised' 
    end                                                                         as Budget_Type,
    act.COST_CENTER                                                             as Cost_Center_Code,
    act.PROFIT_CENTER_GROUP2,
    act.PROFIT_CENT_GROUP_REPSEG,
    act.PROFIT_CENTER                                                           as Profit_Center_Code,
    act.PROFIT_CENTER_GROUP1                                                    as Profit_Center_Group_Code,
    act.SALES_CATEGORY                                                          as SALES_CATEGORY_CODE,
    act.MATERIAL_GROUP                                                          as Material_Group_Code,
    act.MODEL_CODE,
    act.SOLD_TO_PARTY_CODE,
    act.SOLD_TO_PARTY_OFFICE_CODE,
    act.END_USER                                                                as End_User_Code,
    act.ENDUSER_OFFICE_CODE,
    act.FAB_LINE_CODE                                                           as FAB_Code,
    act.Sales_MONTH                                                             as Accounting_ACTUAL_FK_Date,
    CommonDate.fiscal_year_short_text                                           as Accounting_ACTUAL_FY,
    CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT                             as Accounting_ACTUAL_FY_Half,
    CommonDate.fiscal_year_quarter_short_text                                   as Accounting_ACTUAL_FY_Q,
    to_date(CommonDate.FISCAL_HALF_YEAR_BEGINNING_DATE)                         as Beginning_of_Accounting_ACTUAL_FY_HALF,
    to_date(CommonDate.FISCAL_HALF_YEAR_ENDING_DATE)                            as End_of_Accounting_ACTUAL_FY_HALF,
    to_date(CommonDate.quarter_beginning_date)                                  as Beginning_of_Accounting_ACTUAL_FY_Q,
    to_date(CommonDate.quarter_ending_date)                                     as End_of_Accounting_ACTUAL_FY_Q,
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
    act._FILENAME
from {{ ref('SILVER__TEH_EQUIPMENT_SALES__FILE_TEL_ACC_REVENUE_BUDGET_FORECAST') }} act
left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }} acc on acc.ACCOUNT_CODE = case when act.END_USER = 'バルク' then act.ENDUSER_OFFICE_CODE else coalesce(act.END_USER, act.ENDUSER_OFFICE_CODE) end
left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_US_ORDER_TYPE') }} LABOrder on LABOrder.ORDER_TYPE_Code = act.SALES_CATEGORY
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate on to_date(CommonDate.CALENDAR_DATE) = act.Sales_Month
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate1 on to_date(CommonDate1.CALENDAR_DATE) = current_date()
where act.SALES_CATEGORY like any ('1%', '2%', '3%')
    and act._FILEDATE <> '10/10/2018'
    and act.SOURCETYPE = 'ACTUAL'
),
SOURCE_DATA AS (
select *
from OldEndUserCode

union all
select *
from SAPEndUserCode
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
        ACCOUNTING_ACTUAL_FK_DATE,
        ACCOUNTING_ACTUAL_FY,
        ACCOUNTING_ACTUAL_FY_HALF,
        ACCOUNTING_ACTUAL_FY_Q,
        BEGINNING_OF_ACCOUNTING_ACTUAL_FY_HALF,
        END_OF_ACCOUNTING_ACTUAL_FY_HALF,
        BEGINNING_OF_ACCOUNTING_ACTUAL_FY_Q,
        END_OF_ACCOUNTING_ACTUAL_FY_Q,
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
        CAST(ACCOUNTING_ACTUAL_FK_DATE as DATE) as ACCOUNTING_ACTUAL_FK_DATE,
        ACCOUNTING_ACTUAL_FY,
        ACCOUNTING_ACTUAL_FY_HALF,
        ACCOUNTING_ACTUAL_FY_Q,
        CAST(BEGINNING_OF_ACCOUNTING_ACTUAL_FY_HALF as DATE) as BEGINNING_OF_ACCOUNTING_ACTUAL_FY_HALF,
        CAST(END_OF_ACCOUNTING_ACTUAL_FY_HALF as DATE) as END_OF_ACCOUNTING_ACTUAL_FY_HALF,
        CAST(BEGINNING_OF_ACCOUNTING_ACTUAL_FY_Q as DATE) as BEGINNING_OF_ACCOUNTING_ACTUAL_FY_Q,
        CAST(END_OF_ACCOUNTING_ACTUAL_FY_Q as DATE) as END_OF_ACCOUNTING_ACTUAL_FY_Q,
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