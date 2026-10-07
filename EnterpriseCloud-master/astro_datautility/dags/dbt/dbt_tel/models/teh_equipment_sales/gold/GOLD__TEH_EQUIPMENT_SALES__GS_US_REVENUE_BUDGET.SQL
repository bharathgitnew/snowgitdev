{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='GS_US_REVENUE_BUDGET',
    transient=false
) }}

with
DistinctAccount
as
(
select distinct
	Account_Code,
	_5_Digit_Old_Customer_Code,
	SALES_REGION,
    _SALES_ACCOUNT          as SALES_ACCOUNT,
    _SALES_ACCOUNT_REGION   as SALES_ACCOUNT_REGION,
    row_number() over (partition by Account_Code order by Account_Code desc) as row_number
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }}
where startswith(Account_Code, 'A')
    or startswith(Account_Code, 'B')
    or startswith(Account_Code, 'C')
    or startswith(Account_Code, 'D')
    and Account_Code is not null
    and SALES_REGION is not null
),
FirstDistinctAccount
as
(
select
    *
from DistinctAccount
    where row_number = 1    
),
SOURCE_DATA AS (
select
    case when LABAccount.SALES_ACCOUNT IS NOT NULL THEN LABAccount.SALES_ACCOUNT
        when contains(ACCOUNTNAME, 'SAMSUNG') and contains(ENDUSERNAME, 'INTEL') then 'Intel' 
        when contains(ACCOUNTNAME, 'SAMSUNG') and not contains(ENDUSERNAME, 'INTEL') then 'Samsung'
        when contains(ACCOUNTNAME, 'MICRON') then 'Micron'
        when contains(ACCOUNTNAME, 'GF') then 'GF/IBM'
        when contains(ACCOUNTNAME, 'TSMC') then 'tsmc'
        when contains(ACCOUNTNAME, 'INTEL') then 'Intel'
        when ACCOUNTNAME = 'Regional Customers' then 'N/A'
        when ENDUSERNAME = 'OTHERS US' then 'N/A'
        when startswith(ENDUSERNAME, 'TTCA') then 'TEL Group'
        when startswith(ENDUSERNAME, 'RF SUNY') then 'GF/IBM'
        when startswith(ENDUSERNAME, 'ALBANY NANO') then 'GF/IBM'
        when startswith(ENDUSERNAME, 'TI') then 'TI'
        when startswith(ENDUSERNAME, 'NXP') then 'Regional'
        when startswith(ENDUSERNAME, 'TEA') then 'TEL Group'
        when ACCOUNTNAME = 'OTHERS' and (ENDUSERCODE = 'CA4320003' or ENDUSERCODE = 'CB4719301') then 'Regional'
        when ACCOUNTNAME = 'OTHERS' and ENDUSERCODE is null then 'N/A'
        when ENDUSERCODE in ('CA4638401') then 'Regional'
        when ENDUSERCODE in ('CA3435611') then 'Micron'
        when left(ENDUSERCODE, 5) in ('43200', '47440', '46384', '42785', '42648', '49985', '32699', '46317', '44242') then 'Regional'
        when left(ENDUSERCODE, 5) in ('00129', '00136', '10160', '10100', '10137', '10105') then 'TEL Group'
        else 'Regional' end                                         as Sales_Account,
    case when LABAccount.SALES_REGION is not null then LABAccount.SALES_REGION
        when contains(ENDUSERCODE, '2030102') then 'West'
        when contains(ENDUSERCODE, '2030105') then 'West'
        when contains(ENDUSERCODE, '2030100') then 'West'
        when left(ENDUSERCODE, 5) in ('31927', '45550', '12300') then 'East'
        when left(ENDUSERCODE, 5) in ('45401', '02174', '39212', '10160', '10100', '10137', '10105') then 'West'
        when ENDUSERCODE in ('BA3806600', 'BA4667900', 'BA3442803', 'BA4264800', 'BA4653601') then 'West'
        when ENDUSERCODE in ('BA3839809', 'BA3924300', 'BA4320003', 'BA4320001','BA3839807', 'BA3621407', 'BA3849010') then 'East'
        else null end                                               as SALES_REGION,       
    case when SALES_ACCOUNT = 'Regional' then concat(SALES_ACCOUNT, ' ', SALES_REGION)
        else SALES_ACCOUNT end                                      as SALES_ACCOUNT_REGION,
    bu.BU,
    bu.BU_GROUP,
    bu.BU_TYPE,
    case when BUSINESSUNITCODE in ('01', '1') then 'TPS'
        when BUSINESSUNITCODE in ('02', '2') then 'SD'
        when BUSINESSUNITCODE in ('04', '4') and KA in ('00', '50', '62', '70', '71', '85') then 'ES'
        when BUSINESSUNITCODE in ('04', '4') and KA in ('84') then 'Certas'
        when BUSINESSUNITCODE in ('05', '5') then 'CT'
        when BUSINESSUNITCODE in ('06', '6') then 'SD'
        when BUSINESSUNITCODE in ('08', '8') then 'TS'
        when BUSINESSUNITCODE = '10' then 'SPS'
        when BUSINESSUNITCODE = '17' then 'PVD'
        when BUSINESSUNITCODE = '25' then '3DI'
        when BUSINESSUNITCODE = '65' and KA in ('33', '34') then 'FS_CT'
            when BUSINESSUNITCODE = '65' and KA in ('35', '36') then 'FS_ES'
            when BUSINESSUNITCODE = '65' and KA in ('38', '79') then 'FS_SPS'
            when BUSINESSUNITCODE = '65' and KA in ('31', '32') then 'FS_TPS'
            when BUSINESSUNITCODE = '65' and KA = '37' then 'FS_SD'
            when BUSINESSUNITCODE = '65' and KA = '70' then 'FS_Certas'
            when BUSINESSUNITCODE = '65' and KA = '71' then 'FS_SiC'
        when BUSINESSUNITCODE ilike any ('SPE-FS-FS-Others', 'SPE-FS') then 'FS_Other'
        when BUSINESSUNITCODE ilike any ('SPE-FS-TPS', 'SPE-FS-CT') then concat('FS_', split_part(BUSINESSUNITCODE, '-', 3))
        else split_part(BUSINESSUNITCODE, '-', 3) end               as SUB_BU,
    CUSTOMERNAME                                                    as Sold_to_Party,
    ENDUSERNAME                                                     as End_User,
    OPPORTUNITY                                                     as FAB,
    case when length(SALESORDERNUMBER) = 10 then RIGHT(SALESORDERNUMBER,9) else SALESORDERNUMBER end        as Sales_Order_No,
    LABOrder.Order_Type_Group                                       as Sales_Category_Group,
    LABOrder.ORDER_TYPE                                             AS Sales_Category,
    -- SALESCATEGORYNAME                                               as Sales_Category,
    case when BACKUP = '1' then 'Yes' 
        when BACKUP = '0' then 'No' else null end                   as Is_Placeholder,
    PRODUCTNAME                                                     as Product_Name,
    MACHINESERIALNUMBER                                             as Serial_No,
    case when Serial_No <> SPLIT_PART(Serial_No, ', ', 1) then SPLIT_PART(Serial_No, ',', 1)
        when Serial_No <> SPLIT_PART(Serial_No, ',', 1) then SPLIT_PART(Serial_No, ',', 1)
        when Serial_No <>  SPLIT_PART(Serial_No, '(', 1) then  SPLIT_PART(Serial_No, '(', 1)
        when Serial_No <>  SPLIT_PART(Serial_No, '/', 1) then SPLIT_PART(Serial_No, '/', 1)
        when Serial_No <>  SPLIT_PART(Serial_No, ' ', 1) then SPLIT_PART(Serial_No, ' ', 1)
        else Serial_No end                                          as First_Serial_No,
    SALESMONTH                                                      as Sales_Month,
    SALESAMOUNT                                                     as Sales_Amount,
    QUANTITY,
    to_date(CUSTOMCLEARANCEDATE)                                    as Customs_Clearance_Date,
    to_date(ONDOCKDATE)                                             as On_Dock_Date,
    to_date(SALESDATE)                                              as Sales_Date,
    case when LOANFLAG in ('X', 'x', '1') then 'Yes' else 'No' end  as Is_Loaner,
    case when to_date(_FILEDATE) <= '8/1/2021' and CSTFLAG = '1' then 'CST'
        when to_date(_FILEDATE) >= '8/1/2021' and CSTFLAG = '1' then 'Shipment'
        when to_date(_FILEDATE) <= '8/1/2021' and CSTFLAG = '2' then 'Shipment'
        when to_date(_FILEDATE) >= '8/1/2021' and CSTFLAG = '2' then 'Technical Acceptance'
        when CSTFLAG = '3' then 'Completion of Service'
        when CSTFLAG = '4' then 'Delivery' 
        when CSTFLAG = '0' then null else CSTFLAG end               as Revenue_Recognition_Criteria,
    case when to_date(_FILEDATE) <= '8/1/2021' and CSTFLAG = '1' then 'CST'
        when to_date(_FILEDATE) >= '8/1/2021' and CSTFLAG = '1' then 'Ship'
        when to_date(_FILEDATE) <= '8/1/2021' and CSTFLAG = '2' then 'Ship'
        when to_date(_FILEDATE) >= '8/1/2021' and CSTFLAG = '2' then 'Acceptance'
        when CSTFLAG = '3' then 'TSR'
        when CSTFLAG = '4' then 'Delivery' 
        when CSTFLAG = '0' then null else CSTFLAG end               as Revenue_Recognition_Criteria_Short,
    _FILEDATE                                                        as Data_Snapshot,
    SOURCETYPE                                                      as Data_Type,
    case when MONTH(DATA_SNAPSHOT) in (1, 2, 3, 4, 5, 6) then 'Original' 
        when MONTH(DATA_SNAPSHOT) in (7, 8, 9, 10, 11, 12) then 'Revised' end  as Budget_Type,
    BUSINESSUNITCODE_TEXT                                           as BU_Code,
    KA                                                              as Sub_BU_Code,
    SALESCATEGORYCODE                                               as Order_Type_Code,
    CUSTOMERCODE                                                    as Sold_to_Party_Code,
    ENDUSERCODE                                                     as End_User_Code_Mixed,
    case when length(ENDUSERCODE) = 7 then left(ENDUSERCODE, 5)
        when left(ENDUSERCODE,1) in ('C', 'D') then SUBSTR(ENDUSERCODE, 3, 5)
        else null end                                               as _5_DIGIT_END_USER_CODE,
    case when length(ENDUSERCODE) <> 7 then ENDUSERCODE 
        else null end                                               as End_User_Code,
    CommonDate1.FISCAL_YEAR_BEGINNING_DATE                          as Beginning_of_Current_FY,
    CommonDate1.FISCAL_YEAR_ENDING_DATE                             as End_of_Current_FY,
	CommonDate1.FISCAL_HALF_YEAR_BEGINNING_DATE                     as Beginning_of_Current_FY_Half,
	CommonDate1.FISCAL_HALF_YEAR_ENDING_DATE                        as End_of_Current_FY_Half,
	CommonDate1.FISCAL_QUARTER_BEGINNING_DATE                       as Beginning_of_Current_FY_Q,
	CommonDate1.FISCAL_QUARTER_ENDING_DATE                          as End_of_Current_FY_Q,
    dateadd(year, 1, Beginning_of_Current_FY)                       as Beginning_of_Next_FY,
	dateadd(year, 1, End_of_Current_FY)                             as End_of_Next_FY,
	dateadd(month, 6, Beginning_of_Current_FY_Half)                 as Beginning_of_Next_FY_Half,
	dateadd(month, 6, End_of_Current_FY_Half)                       as End_of_Next_FY_Half,
	dateadd(month, 3, Beginning_of_Current_FY_Q)                    as Beginning_of_Next_FY_Q,
	dateadd(month, 3, End_of_Current_FY_Q)                          as End_of_Next_FY_Q,
    dateadd(year, -1, Beginning_of_Current_FY)                      as Beginning_of_Previous_FY,
	dateadd(year, -1, End_of_Current_FY)                            as End_of_Previous_FY,
	dateadd(month, -6, Beginning_of_Current_FY_Half)                as Beginning_of_Previous_FY_Half,
	dateadd(month, -6, End_of_Current_FY_Half)                      as End_of_Previous_FY_Half,
	dateadd(month, -3, Beginning_of_Current_FY_Half)                as Beginning_of_Previous_FY_Q,
	dateadd(month, -3, End_of_Current_FY_Half)                      as End_of_Previous_FY_Q,
	dateadd(year, -2, Beginning_of_Current_FY)                      as Beginning_of_2_FY_Ago,
	dateadd(year, 2, End_of_Current_FY)                             as End_of_2_FY_Ahead,
    Sales_Month                                                     as GS_Budget_FK_Date,
    CommonDate.fiscal_year_short_text                               as GS_Budget_FY,
    CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT                 as GS_Budget_FY_Half,
    CommonDate.fiscal_year_quarter_short_text                       as GS_Budget_FY_Q,
    to_date(CommonDate.fiscal_year_beginning_date)                  as Beginning_of_GS_Budget_FY,
	to_date(CommonDate.fiscal_year_ending_date)                     as End_of_GS_Budget_FY,
	to_date(CommonDate.fiscal_half_year_beginning_date)             as Beginning_of_GS_Budget_FY_Half,
	to_date(CommonDate.fiscal_half_year_ending_date)                as End_of_GS_Budget_FY_Half,
    to_date(CommonDate.fiscal_quarter_beginning_date)               as Beginning_of_GS_Budget_FY_Q,
    to_date(CommonDate.fiscal_quarter_ending_date)                  as End_of_GS_Budget_FY_Q,
    _FILENAME
from {{ ref('SILVER__TEH_EQUIPMENT_SALES__FILE_TEL_GS_REVENUE_BUDGET_FORECAST') }} gs
    left outer join FirstDistinctAccount as LABAccount on LABAccount.Account_code = case when length(gs.ENDUSERCODE) <> 7 then gs.ENDUSERCODE else null end 
        and case when length(gs.ENDUSERCODE) <> 7 then gs.ENDUSERCODE else null end is not null
    left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_BUSINESS_UNIT') }} bu on bu.SUB_BU = case when BUSINESSUNITCODE in ('01', '1') then 'TPS'
                                                                            when BUSINESSUNITCODE in ('02', '2') then 'SD'
                                                                            when BUSINESSUNITCODE in ('04', '4') and KA in ('00', '50', '62', '70', '71', '85') then 'ES'
                                                                            when BUSINESSUNITCODE in ('04', '4') and KA in ('84') then 'Certas'
                                                                            when BUSINESSUNITCODE in ('05', '5') then 'CT'
                                                                            when BUSINESSUNITCODE in ('06', '6') then 'SD'
                                                                            when BUSINESSUNITCODE in ('08', '8') then 'TS'
                                                                            when BUSINESSUNITCODE = '10' then 'SPS'
                                                                            when BUSINESSUNITCODE = '17' then 'PVD'
                                                                            when BUSINESSUNITCODE = '25' then '3DI'
                                                                            when BUSINESSUNITCODE = '65' and KA in ('33', '34') then 'FS_CT'
                                                                                when BUSINESSUNITCODE = '65' and KA in ('35', '36') then 'FS_ES'
                                                                                when BUSINESSUNITCODE = '65' and KA in ('38', '79') then 'FS_SPS'
                                                                                when BUSINESSUNITCODE = '65' and KA in ('31', '32') then 'FS_TPS'
                                                                                when BUSINESSUNITCODE = '65' and KA = '37' then 'FS_SD'
                                                                                when BUSINESSUNITCODE = '65' and KA = '70' then 'FS_Certas'
                                                                                when BUSINESSUNITCODE = '65' and KA = '71' then 'FS_SiC'
                                                                            when BUSINESSUNITCODE ilike any ('SPE-FS-FS-Others', 'SPE-FS') then 'FS_Other'
                                                                            when BUSINESSUNITCODE ilike any ('SPE-FS-TPS', 'SPE-FS-CT') then concat('FS_', split_part(BUSINESSUNITCODE, '-', 3))
                                                                            else split_part(BUSINESSUNITCODE, '-', 3) end
    left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_US_ORDER_TYPE') }} LABOrder on LABOrder.ORDER_TYPE_Code = gs.salescategorycode
    left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} as CommonDate on to_date(CommonDate.CALENDAR_DATE) = gs.SalesMonth
    left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} as CommonDate1 on to_date(CommonDate1.CALENDAR_DATE) = CURRENT_DATE()
where Data_Type = 'BUDGET'
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        SALES_ACCOUNT_REGION,
        BU,
        BU_GROUP,
        BU_TYPE,
        SUB_BU,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        IS_PLACEHOLDER,
        PRODUCT_NAME,
        SERIAL_NO,
        FIRST_SERIAL_NO,
        SALES_MONTH,
        SALES_AMOUNT,
        QUANTITY,
        CUSTOMS_CLEARANCE_DATE,
        ON_DOCK_DATE,
        SALES_DATE,
        IS_LOANER,
        REVENUE_RECOGNITION_CRITERIA,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        DATA_SNAPSHOT,
        DATA_TYPE,
        BUDGET_TYPE,
        BU_CODE,
        SUB_BU_CODE,
        ORDER_TYPE_CODE,
        SOLD_TO_PARTY_CODE,
        END_USER_CODE_MIXED,
        _5_DIGIT_END_USER_CODE,
        END_USER_CODE,
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
        GS_BUDGET_FK_DATE,
        GS_BUDGET_FY,
        GS_BUDGET_FY_HALF,
        GS_BUDGET_FY_Q,
        BEGINNING_OF_GS_BUDGET_FY,
        END_OF_GS_BUDGET_FY,
        BEGINNING_OF_GS_BUDGET_FY_HALF,
        END_OF_GS_BUDGET_FY_HALF,
        BEGINNING_OF_GS_BUDGET_FY_Q,
        END_OF_GS_BUDGET_FY_Q,
        _FILENAME
FROM SOURCE_DATA
)

,
TYPE_DATA AS (
SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        SALES_ACCOUNT_REGION,
        BU,
        BU_GROUP,
        BU_TYPE,
        SUB_BU,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        IS_PLACEHOLDER,
        PRODUCT_NAME,
        SERIAL_NO,
        FIRST_SERIAL_NO,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(SALES_AMOUNT as NUMBER(38,0)) as SALES_AMOUNT,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(CUSTOMS_CLEARANCE_DATE as DATE) as CUSTOMS_CLEARANCE_DATE,
        CAST(ON_DOCK_DATE as DATE) as ON_DOCK_DATE,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        IS_LOANER,
        REVENUE_RECOGNITION_CRITERIA,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        DATA_TYPE,
        BUDGET_TYPE,
        BU_CODE,
        SUB_BU_CODE,
        ORDER_TYPE_CODE,
        SOLD_TO_PARTY_CODE,
        END_USER_CODE_MIXED,
        _5_DIGIT_END_USER_CODE,
        END_USER_CODE,
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
        CAST(BEGINNING_OF_PREVIOUS_FY as DATE) as BEGINNING_OF_PREVIOUS_FY,
        CAST(END_OF_PREVIOUS_FY as DATE) as END_OF_PREVIOUS_FY,
        CAST(BEGINNING_OF_PREVIOUS_FY_HALF as DATE) as BEGINNING_OF_PREVIOUS_FY_HALF,
        CAST(END_OF_PREVIOUS_FY_HALF as DATE) as END_OF_PREVIOUS_FY_HALF,
        CAST(BEGINNING_OF_PREVIOUS_FY_Q as DATE) as BEGINNING_OF_PREVIOUS_FY_Q,
        CAST(END_OF_PREVIOUS_FY_Q as DATE) as END_OF_PREVIOUS_FY_Q,
        CAST(BEGINNING_OF_2_FY_AGO as DATE) as BEGINNING_OF_2_FY_AGO,
        CAST(END_OF_2_FY_AHEAD as DATE) as END_OF_2_FY_AHEAD,
        CAST(GS_BUDGET_FK_DATE as DATE) as GS_BUDGET_FK_DATE,
        GS_BUDGET_FY,
        GS_BUDGET_FY_HALF,
        GS_BUDGET_FY_Q,
        CAST(BEGINNING_OF_GS_BUDGET_FY as DATE) as BEGINNING_OF_GS_BUDGET_FY,
        CAST(END_OF_GS_BUDGET_FY as DATE) as END_OF_GS_BUDGET_FY,
        CAST(BEGINNING_OF_GS_BUDGET_FY_HALF as DATE) as BEGINNING_OF_GS_BUDGET_FY_HALF,
        CAST(END_OF_GS_BUDGET_FY_HALF as DATE) as END_OF_GS_BUDGET_FY_HALF,
        CAST(BEGINNING_OF_GS_BUDGET_FY_Q as DATE) as BEGINNING_OF_GS_BUDGET_FY_Q,
        CAST(END_OF_GS_BUDGET_FY_Q as DATE) as END_OF_GS_BUDGET_FY_Q,
        _FILENAME
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA