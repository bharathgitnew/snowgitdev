{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='GS_US_BOOKING_FORECAST',
    transient=false
) }}

with
DistinctAccount
AS
(
SELECT DISTINCT
	Account_Code,
	_5_Digit_Old_Customer_Code,
	SALES_REGION,
    _SALES_ACCOUNT          as SALES_ACCOUNT,
    _SALES_ACCOUNT_REGION   as SALES_ACCOUNT_REGION,
    row_number() over (partition by Account_Code order by Account_Code desc) AS row_number
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }}
WHERE STARTSWITH(Account_Code, 'A')
    OR STARTSWITH(Account_Code, 'B')
    OR STARTSWITH(Account_Code, 'C')
    OR STARTSWITH(Account_Code, 'D')
    AND Account_Code IS NOT NULL
    AND SALES_REGION IS NOT NULL
),
FirstDistinctAccount
AS
(
SELECT
    *
FROM DistinctAccount
    WHERE row_number = 1    
),
SOURCE_DATA AS (
SELECT
    CASE WHEN LABAccount.SALES_ACCOUNT IS NOT NULL THEN LABAccount.SALES_ACCOUNT
        WHEN CONTAINS(ACCOUNTNAME, 'SAMSUNG') AND CONTAINS(ENDUSERNAME, 'INTEL') THEN 'Intel' 
        WHEN CONTAINS(ACCOUNTNAME, 'SAMSUNG') AND NOT CONTAINS(ENDUSERNAME, 'INTEL') THEN 'Samsung'
        WHEN CONTAINS(ACCOUNTNAME, 'MICRON') THEN 'Micron'
        WHEN CONTAINS(ACCOUNTNAME, 'GF') THEN 'GF/IBM'
        WHEN CONTAINS(ACCOUNTNAME, 'TSMC') THEN 'tsmc'
        WHEN CONTAINS(ACCOUNTNAME, 'INTEL') THEN 'Intel'
        WHEN ACCOUNTNAME = 'Regional Customers' THEN 'N/A'
        WHEN ENDUSERNAME = 'OTHERS US' THEN 'N/A'
        WHEN STARTSWITH(ENDUSERNAME, 'TTCA') THEN 'TEL Group'
        WHEN STARTSWITH(ENDUSERNAME, 'RF SUNY') THEN 'GF/IBM'
        WHEN STARTSWITH(ENDUSERNAME, 'ALBANY NANO') THEN 'GF/IBM'
        WHEN STARTSWITH(ENDUSERNAME, 'TI') THEN 'TI'
        WHEN STARTSWITH(ENDUSERNAME, 'NXP') THEN 'Regional'
        WHEN STARTSWITH(ENDUSERNAME, 'TEA') THEN 'TEL Group'
        WHEN ACCOUNTNAME = 'OTHERS' AND (ENDUSERCODE = 'CA4320003' OR ENDUSERCODE = 'CB4719301') THEN 'Regional'
        WHEN ACCOUNTNAME = 'OTHERS' AND ENDUSERCODE IS NULL THEN 'N/A'
        WHEN ENDUSERCODE IN ('CA4638401') THEN 'Regional'
        WHEN ENDUSERCODE IN ('CA3435611') THEN 'Micron'
        WHEN LEFT(ENDUSERCODE, 5) IN ('43200', '47440', '46384', '42785', '42648', '49985', '32699', '46317', '44242') THEN 'Regional'
        WHEN LEFT(ENDUSERCODE, 5) IN ('00129', '00136', '10160', '10100', '10137', '10105') THEN 'TEL Group'
        ELSE 'Regional' END                                         AS SALES_ACCOUNT,
    CASE WHEN LABAccount.SALES_REGION IS NOT NULL THEN LABAccount.SALES_REGION
        WHEN CONTAINS(ENDUSERCODE, '2030102') THEN 'West'
        WHEN CONTAINS(ENDUSERCODE, '2030105') THEN 'West'
        WHEN CONTAINS(ENDUSERCODE, '2030100') THEN 'West'
        WHEN LEFT(ENDUSERCODE, 5) IN ('31927', '45550', '12300') THEN 'East'
        WHEN LEFT(ENDUSERCODE, 5) IN ('45401', '02174', '39212', '10160', '10100', '10137', '10105') THEN 'West'
        WHEN ENDUSERCODE IN ('BA3806600', 'BA4667900', 'BA3442803', 'BA4264800', 'BA4653601') THEN 'West'
        WHEN ENDUSERCODE IN ('BA3839809', 'BA3924300', 'BA4320003', 'BA4320001','BA3839807', 'BA3621407', 'BA3849010') THEN 'East'
        ELSE NULL END                                               AS SALES_REGION,       
    CASE WHEN SALES_ACCOUNT = 'Regional' THEN CONCAT(SALES_ACCOUNT, ' ', SALES_REGION)
        ELSE SALES_ACCOUNT END                                      AS SALES_ACCOUNT_REGION,
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
        else split_part(BUSINESSUNITCODE, '-', 3) end               as Sub_BU,
    CUSTOMERNAME                                                    AS Sold_to_Party,
    ENDUSERNAME                                                     AS End_User,
    OPPORTUNITY                                                     AS FAB,
    CASE WHEN LENGTH(SALESORDERNUMBER) = 10 THEN RIGHT(SALESORDERNUMBER,9) ELSE SALESORDERNUMBER END        AS Sales_Order_No,
    LABOrder.Order_Type_Group                                       AS Sales_Category_Group,
    LABOrder.ORDER_TYPE                                             AS Sales_Category,
    -- SALESCATEGORYNAME                                               AS Sales_Category,
    CASE WHEN BACKUP = '1' THEN 'Yes' 
        WHEN BACKUP = '0' THEN 'No' ELSE NULL END                   AS Is_Placeholder,
    PRODUCTNAME                                                     AS Product_Name,
    MACHINESERIALNUMBER                                             AS Serial_No,
    TO_DATE(BOOKINGMONTH)                                           AS Booking_Month,
    BOOKINGAMOUNT                                                   AS Booking_Amount,
    QUANTITY,
    TO_DATE(SALESDATE)                                              AS Sales_Date,
    CASE WHEN LOANFLAG IN ('X', 'x', '1') THEN 'Yes' ELSE 'No' END  AS Is_Loaner,
    CASE WHEN TO_DATE(_FILEDATE) <= '8/1/2021' AND CSTFLAG = '1' THEN 'CST'
        WHEN TO_DATE(_FILEDATE) >= '8/1/2021' AND CSTFLAG = '1' THEN 'Shipment'
        WHEN TO_DATE(_FILEDATE) <= '8/1/2021' AND CSTFLAG = '2' THEN 'Shipment'
        WHEN TO_DATE(_FILEDATE) >= '8/1/2021' AND CSTFLAG = '2' THEN 'Technical Acceptance'
        WHEN CSTFLAG = '3' THEN 'Completion of Service'
        WHEN CSTFLAG = '4' THEN 'Delivery' 
        WHEN CSTFLAG = '0' THEN NULL ELSE CSTFLAG END               AS Revenue_Recognition_Criteria,
    CASE WHEN TO_DATE(_FILEDATE) <= '8/1/2021' AND CSTFLAG = '1' THEN 'CST'
        WHEN TO_DATE(_FILEDATE) >= '8/1/2021' AND CSTFLAG = '1' THEN 'Ship'
        WHEN TO_DATE(_FILEDATE) <= '8/1/2021' AND CSTFLAG = '2' THEN 'Ship'
        WHEN TO_DATE(_FILEDATE) >= '8/1/2021' AND CSTFLAG = '2' THEN 'Acceptance'
        WHEN CSTFLAG = '3' THEN 'TSR'
        WHEN CSTFLAG = '4' THEN 'Delivery' 
        WHEN CSTFLAG = '0' THEN NULL ELSE CSTFLAG END               AS Revenue_Recognition_Criteria_Short,
    TO_DATE(_FILEDATE)                                               AS Data_Snapshot,
    SOURCETYPE                                                      AS Data_Type,
    BUSINESSUNITCODE_TEXT                                           AS BU_Code,
    KA                                                              AS Sub_BU_Code,
    SALESCATEGORYCODE                                               AS Order_Type_Code,
    CUSTOMERCODE                                                    AS Sold_to_Party_Code,
    ENDUSERCODE                                                     AS End_User_Code_Mixed,
    CASE WHEN LENGTH(ENDUSERCODE) = 7 THEN LEFT(ENDUSERCODE, 5)
        WHEN LEFT(ENDUSERCODE,1) IN ('C', 'D') THEN SUBSTR(ENDUSERCODE, 3, 5)
        ELSE NULL END                                               AS _5_DIGIT_END_USER_CODE,
    CASE WHEN LENGTH(ENDUSERCODE) <> 7 THEN ENDUSERCODE 
        ELSE NULL END                                               AS End_User_Code,
    CommonDate1.FISCAL_YEAR_BEGINNING_DATE                          AS Beginning_of_Current_FY,
    CommonDate1.FISCAL_YEAR_ENDING_DATE                             AS End_of_Current_FY,
	CommonDate1.FISCAL_HALF_YEAR_BEGINNING_DATE                     AS Beginning_of_Current_FY_Half,
	CommonDate1.FISCAL_HALF_YEAR_ENDING_DATE                        AS End_of_Current_FY_Half,
	CommonDate1.FISCAL_QUARTER_BEGINNING_DATE                       AS Beginning_of_Current_FY_Q,
	CommonDate1.FISCAL_QUARTER_ENDING_DATE                          AS End_of_Current_FY_Q,
    DATEADD(Year, -1, Beginning_of_Current_FY)                      AS Beginning_of_Previous_FY,
	DATEADD(Year, -1, End_of_Current_FY)                            AS End_of_Previous_FY,
	DATEADD(Month, -6, Beginning_of_Current_FY_Half)                AS Beginning_of_Previous_FY_Half,
	DATEADD(Month, -6, End_of_Current_FY_Half)                      AS End_of_Previous_FY_Half,
	DATEADD(Month, -3, Beginning_of_Current_FY_Q)                   AS Beginning_of_Previous_FY_Q,
	DATEADD(Month, -3, End_of_Current_FY_Q)                         AS End_of_Previous_FY_Q,
    DATEADD(Year, 1, Beginning_of_Current_FY)                       AS Beginning_of_Next_FY,
	DATEADD(Year, 1, End_of_Current_FY)                             AS End_of_Next_FY,
	DATEADD(Month, 6, Beginning_of_Current_FY_Half)                 AS Beginning_of_Next_FY_Half,
	DATEADD(Month, 6, End_of_Current_FY_Half)                       AS End_of_Next_FY_Half,
	DATEADD(Month, 3, Beginning_of_Current_FY_Q)                    AS Beginning_of_Next_FY_Q,
	DATEADD(Month, 3, End_of_Current_FY_Q)                          AS End_of_Next_FY_Q,
	DATEADD(Year, -2, Beginning_of_Current_FY)                      AS Beginning_of_2_FY_Ago,
	DATEADD(Year, 2, End_of_Current_FY)                             AS End_of_2_FY_Ahead,
    Booking_Month                                                   AS GS_Forecast_FK_Date,
    CommonDate.fiscal_year_short_text                               AS GS_Forecast_FY,
    CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT                 AS GS_Forecast_FY_Half,
    CommonDate.fiscal_year_quarter_short_text                       AS GS_Forecast_FY_Q,
    TO_DATE(CommonDate.quarter_beginning_date)                      AS Beginning_of_GS_Forecast_FY_Q,
    TO_DATE(CommonDate.quarter_ending_date)                         AS End_of_GS_Forecast_FY_Q,
    _FILENAME
    -- ACCOUNTCODE,
    -- ACCOUNTNAME
    -- LEVEL,
    -- LEVEL2,
FROM {{ ref('SILVER__TEH_EQUIPMENT_SALES__FILE_TEL_GS_BOOKING_BUDGET_FORECAST') }} gs
    -- LEFT OUTER JOIN {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }} LABAccount1 ON LABAccount1._5_digit_old_customer_code = _5_DIGIT_END_USER_CODE AND CONTAINS(LABAccount1.ACCOUNT_NAME, End_User)
    LEFT OUTER JOIN FirstDistinctAccount LABAccount ON LABAccount.Account_code = CASE WHEN LENGTH(gs.ENDUSERCODE) <> 7 THEN gs.ENDUSERCODE ELSE NULL END
        and case when length(gs.ENDUSERCODE) <> 7 then gs.ENDUSERCODE else null end  is not null
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
    LEFT OUTER JOIN {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_US_ORDER_TYPE') }} LABOrder ON LABOrder.ORDER_TYPE_Code = gs.salescategorycode
    LEFT OUTER JOIN {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate ON TO_DATE(CommonDate.CALENDAR_DATE) = TO_DATE(BOOKINGMONTH) 
    LEFT OUTER JOIN {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate1 ON TO_DATE(CommonDate1.CALENDAR_DATE) = CURRENT_DATE()
WHERE Data_Type = 'FORECAST' 
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
        BOOKING_MONTH,
        BOOKING_AMOUNT,
        QUANTITY,
        SALES_DATE,
        IS_LOANER,
        REVENUE_RECOGNITION_CRITERIA,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        DATA_SNAPSHOT,
        DATA_TYPE,
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
        BEGINNING_OF_PREVIOUS_FY,
        END_OF_PREVIOUS_FY,
        BEGINNING_OF_PREVIOUS_FY_HALF,
        END_OF_PREVIOUS_FY_HALF,
        BEGINNING_OF_PREVIOUS_FY_Q,
        END_OF_PREVIOUS_FY_Q,
        BEGINNING_OF_NEXT_FY,
        END_OF_NEXT_FY,
        BEGINNING_OF_NEXT_FY_HALF,
        END_OF_NEXT_FY_HALF,
        BEGINNING_OF_NEXT_FY_Q,
        END_OF_NEXT_FY_Q,
        BEGINNING_OF_2_FY_AGO,
        END_OF_2_FY_AHEAD,
        GS_FORECAST_FK_DATE,
        GS_FORECAST_FY,
        GS_FORECAST_FY_HALF,
        GS_FORECAST_FY_Q,
        BEGINNING_OF_GS_FORECAST_FY_Q,
        END_OF_GS_FORECAST_FY_Q,
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
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(BOOKING_AMOUNT as NUMBER(38,0)) as BOOKING_AMOUNT,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        IS_LOANER,
        REVENUE_RECOGNITION_CRITERIA,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        DATA_TYPE,
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
        CAST(BEGINNING_OF_PREVIOUS_FY as DATE) as BEGINNING_OF_PREVIOUS_FY,
        CAST(END_OF_PREVIOUS_FY as DATE) as END_OF_PREVIOUS_FY,
        CAST(BEGINNING_OF_PREVIOUS_FY_HALF as DATE) as BEGINNING_OF_PREVIOUS_FY_HALF,
        CAST(END_OF_PREVIOUS_FY_HALF as DATE) as END_OF_PREVIOUS_FY_HALF,
        CAST(BEGINNING_OF_PREVIOUS_FY_Q as DATE) as BEGINNING_OF_PREVIOUS_FY_Q,
        CAST(END_OF_PREVIOUS_FY_Q as DATE) as END_OF_PREVIOUS_FY_Q,
        CAST(BEGINNING_OF_NEXT_FY as DATE) as BEGINNING_OF_NEXT_FY,
        CAST(END_OF_NEXT_FY as DATE) as END_OF_NEXT_FY,
        CAST(BEGINNING_OF_NEXT_FY_HALF as DATE) as BEGINNING_OF_NEXT_FY_HALF,
        CAST(END_OF_NEXT_FY_HALF as DATE) as END_OF_NEXT_FY_HALF,
        CAST(BEGINNING_OF_NEXT_FY_Q as DATE) as BEGINNING_OF_NEXT_FY_Q,
        CAST(END_OF_NEXT_FY_Q as DATE) as END_OF_NEXT_FY_Q,
        CAST(BEGINNING_OF_2_FY_AGO as DATE) as BEGINNING_OF_2_FY_AGO,
        CAST(END_OF_2_FY_AHEAD as DATE) as END_OF_2_FY_AHEAD,
        CAST(GS_FORECAST_FK_DATE as DATE) as GS_FORECAST_FK_DATE,
        GS_FORECAST_FY,
        GS_FORECAST_FY_HALF,
        GS_FORECAST_FY_Q,
        CAST(BEGINNING_OF_GS_FORECAST_FY_Q as DATE) as BEGINNING_OF_GS_FORECAST_FY_Q,
        CAST(END_OF_GS_FORECAST_FY_Q as DATE) as END_OF_GS_FORECAST_FY_Q,
        _FILENAME
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA