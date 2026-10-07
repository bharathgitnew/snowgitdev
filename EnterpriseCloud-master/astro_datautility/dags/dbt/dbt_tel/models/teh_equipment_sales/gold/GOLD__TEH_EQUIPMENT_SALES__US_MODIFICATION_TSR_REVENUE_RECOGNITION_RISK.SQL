{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='US_MODIFICATION_TSR_REVENUE_RECOGNITION_RISK',
    	transient=false
) }}

WITH ref_cte_ACCOUNTING_MODIFICATION_TSR_REVENUE_RECOGNITION_CURRENT_FLAT as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__ACCOUNTING_MODIFICATION_TSR_REVENUE_RECOGNITION_CURRENT_FLAT') }}
),

ref_cte_CALENDARDATE as (
    select * from {{ source('STATIC_OBJECTS', 'CALENDARDATE') }}
),

ref_cte_GS_MODIFICATION_TSR_REVENUE_RECOGNITION_CURRENT_FLAT as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_MODIFICATION_TSR_REVENUE_RECOGNITION_CURRENT_FLAT') }}
),

ref_cte_SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION') }}
),

-- ServiceCRM?

-- AS

-- (

-- 

-- ),

FlatACC1

AS

(

SELECT

	Sales_Order_No,

    Order_Item,

    SALES_CATEGORY_GROUP,

    SALES_CATEGORY

    BU_PLACEHOLDER,

    SERIAL_NO,

    PM_SERIAL_NO,

	SHIP_MONTH,

    SCHEDULED_CUSTOMS_CLEARAN_DATE,

    CONFIRMED_CUSTOMS_CLEARAN_DATE,

    CASE WHEN CONFIRMED_CUSTOMS_CLEARAN_DATE IS NOT NULL THEN CONFIRMED_CUSTOMS_CLEARAN_DATE

        WHEN SCHEDULED_CUSTOMS_CLEARAN_DATE IS NOT NULL THEN SCHEDULED_CUSTOMS_CLEARAN_DATE

        ELSE SHIP_MONTH END                                                         AS SHIP_DATE,

    Is_Loaner,

    QUANTITY,

    Data_Snapshot,

	Revenue_Recognition_Criteria_Short,

    SALES_AMOUNT,

    row_number() over (partition by Sales_Order_No order by SALES_AMOUNT desc)      AS row_number

FROM ref_cte_ACCOUNTING_MODIFICATION_TSR_REVENUE_RECOGNITION_CURRENT_FLAT

WHERE SALES_AMOUNT <> 0

),

FlatACC

AS

(

SELECT *

FROM FlatACC1

WHERE row_number = 1

),

ModRollup

AS

(

SELECT

    LISTAGG(DISTINCT gs.Sales_Order_No, ', ')                   AS Sales_Order_No_All,

    CASE WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Equipment') THEN 'Equipment'

        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'New Equipment') THEN 'New Equipment'

        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Used Equip w/Core') THEN 'Used Equip w/Core'

        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Used Equip w/o Core') THEN 'Used Equip w/o Core'

        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Used Equip (as is)') THEN 'Used Equip (as is)'

        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Chamber') THEN 'Chamber'

        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Pre-kit') THEN 'Pre-kit'

        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Option') THEN 'Option'

        ELSE '' END                                             AS Primary_Sales_Category,

    LISTAGG(DISTINCT gs.Sales_Category, ', ')                   AS Sales_Category_All,

    LISTAGG(DISTINCT gs.Product_Name, ', ')                     AS Product_Name_All,

    LISTAGG(DISTINCT acc.Order_Item, ', ')                      AS ACC_Product_Name_All,

    CASE WHEN Product_Name_All IS NULL OR Product_Name_All = '' THEN ACC_Product_Name_All

        ELSE Product_Name_All END                               AS Product_Name,

    LISTAGG(DISTINCT gs.Serial_No, ', ')                        AS Serial_No_Distinct,

    LISTAGG(DISTINCT crm.Serial_No, ', ')                       AS CRM_Serial_No_Distinct,

    -- LISTAGG(DISTINCT crm.PM_SERIAL_NO, ', ')                    AS CRM_PM_Serial_No_Distinct, 

    LISTAGG(DISTINCT acc.Serial_No, ', ')                       AS ACC_Serial_No_Distinct,

    -- LISTAGG(DISTINCT acc.PM_SERIAL_NO, ', ')                    AS ACC_PM_Serial_No_Distinct,

    CASE WHEN CRM_Serial_No_Distinct IS NOT NULL AND CRM_Serial_No_Distinct <> '' THEN CRM_Serial_No_Distinct 

        ELSE ACC_Serial_No_Distinct END                         AS Adjusted_Serial_No,

    MAX(gs.Customs_Clearance_Date)                                  AS Customs_Clearance_Date_Max,

    MAX(crm.Ship_Date_Max)                                          AS CRM_Ship_Date_Max,

    MAX(acc.Ship_Date)                                              AS ACC_Ship_Date_Max,

    CASE WHEN CRM_Ship_Date_Max IS NOT NULL THEN CRM_Ship_Date_Max

        WHEN Customs_Clearance_Date_Max IS NOT NULL THEN Customs_Clearance_Date_Max

        ELSE ACC_Ship_Date_Max END                                  AS Adjusted_Ship_Date,

    DATEADD(day, 120, Adjusted_Ship_Date)                           AS Ship_Date_Plus_120,

    MAX(gs.Sales_Month)                                             AS Sales_Month_Max,

    -- MAX(acc.Scheduled_Acceptance_Sign_Off_Date)                     AS ACC_Sign_Off_Date_Max, 

    SUM(gs.QUANTITY)                                                AS Quantity_Summed,

    SUM(gs.SALES_AMOUNT)                                            AS Sales_Amount_Summed,

    MAX(gs.Data_Snapshot)                                           AS GS_Data_Snapshot_Max,

    MAX(acc.Data_Snapshot)                                          AS ACC_Data_Snapshot_Max

    -- SPLIT_PART(LISTAGG(DISTINCT gs.Sales_Order_No, ', ') IN GROUP (ORDER BY gs.SALES_ORDER_NO ASC), ', ', 1)    AS First_Sales_Order_No,

    -- SPLIT_PART(LISTAGG(acc.SALES_ORDER_NO, ',') IN GROUP (ORDER BY acc.SALES_ORDER_NO ASC), ',', 1)             AS ACC_Sales_Order_No_First

FROM ref_cte_GS_MODIFICATION_TSR_REVENUE_RECOGNITION_CURRENT_FLAT gs

    LEFT OUTER JOIN ref_cte_SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION crm ON crm.SALES_ORDER_NO_DISTINCT = gs.SALES_ORDER_NO

    LEFT OUTER JOIN FlatACC acc ON acc.Sales_Order_No = gs.Sales_Order_No

WHERE gs.Sales_Amount <> 0

GROUP BY gs.Sales_Order_No

),

ModFirstRecord

AS

(

SELECT

	gs.Sales_Account,

	gs.Sales_Region,

	CASE WHEN crm.SOLD_TO_PARTY IS NOT NULL THEN crm.SOLD_TO_PARTY

	    ELSE gs.Sold_to_Party END               AS Sold_to_Party,

    CASE WHEN crm.END_USER IS NOT NULL THEN crm.END_USER

	    ELSE gs.End_User END                    AS End_User,

	gs.FAB,

    gs.BU,

	gs.Sub_BU,

	gs.BU_Group,

    gs.Sales_Order_No,

    gs.Sales_Category_Group,

    gs.Sales_Category,

    crm.ORDER_ITEM_OPPORTUNITY,

    crm.ORDER_ITEM_SALES_DOCUMENT_ALL,

    crm.Material_Type_Distinct,

    crm.OPPORTUNITY_TITLE_FREE_TEXT,

    crm.OPPORTUNITY_ID,

    crm.SALES_DOCUMENT_ITEM_NO_ALL,

    crm.PROJECT_NO,

	crm.Model,

    crm.SERIAL_NO,

    crm.CUSTOMER_TOOL_ID,

    crm.SALES_REPORTING_FLAG,

    gs.Is_Placeholder,

    -- crm.CONFIDENCE_BU_SHORT,

    -- crm.END_USER_BOOKING_DATE_BU_MAX,

    crm.IS_BOOKING_ACTUAL,

    crm.QUOTE_NO,

    crm.PURCHASE_ORDER_NO,

    crm.Scheduled_Sign_Off_Date_BU              AS BU_Sign_Off_Date_Max,

    crm.Scheduled_Sign_Off_Date_Account_Max     AS Account_Sign_Off_Date_Max,

    crm.Scheduled_Sign_Off_Date_WISDOM          AS WISDOM_Sign_Off_Date_Max,

    -- crm.END_USER_SALES_DATE_BU_MAX,

    -- crm.END_USER_SALES_DATE_ACCOUNT_MAX,

    crm.Actual_TSR_Sign_Off_Date,

    crm.IS_SIGN_OFF_WAVED,

	crm.REVENUE_RECOGNITION_STATUS_DISTINCT,

    crm.BOOKING_SALES_STATUS,

    gs.Is_Loaner,

    crm.LOAN_EXPIRATION_DATE,

    crm.VPA,

    crm.Revenue_Recognition_Criteria_Distinct,

    crm.ACCOUNT_SALES_PERSON,

    crm.BU_SALES_PERSON,

    crm.BU_COMMENTS,

    crm.ACCOUNT_COMMENTS,

    crm.SALES_COMMENTS_TO_SAP,

    crm.ASSISTANTS_COMMENTS_FROM_SAP,

    PO_INCLUDE_LABOR,

    MOD_LABOR_TYPE,

    WORK_ORDER_NO_SALES_CRM,

    WORK_ORDER_SALES_CRM_ISSUE_DATE,

	gs.Data_Type,

    gs.Budget_Type,

    crm.Data_Snapshot                           AS CRM_Data_Snapshot,

	gs.Quantity,

    gs.End_User_Code,

    ACCOUNT_REVENUE_FY,

    ACCOUNT_REVENUE_FY_HALF,

    ACCOUNT_REVENUE_FY_Q,

    row_number() over (partition by gs.Sales_Order_No order by gs.SALES_AMOUNT desc) as row_number

FROM ref_cte_GS_MODIFICATION_TSR_REVENUE_RECOGNITION_CURRENT_FLAT gs

    LEFT OUTER JOIN ref_cte_SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION crm ON crm.SALES_ORDER_NO_DISTINCT = gs.SALES_ORDER_NO

WHERE gs.Sales_Amount <> 0

),

source_data as (
SELECT CommonDate.fiscal_year_quarter_short_text       AS GS_FY_Q,

    ACCOUNT_REVENUE_FY_Q                            AS Account_FY_Q,

    'Risk'                                          AS Risk_Upside,

    flat.Sales_Account,

    flat.Sales_Region,

    flat.Sold_to_Party,

    flat.End_User,

    flat.FAB,

    flat.BU,

    flat.BU_Group,

    flat.Sub_BU,

    flat.Sales_Category_Group,

    flat.Sales_Category,

    flat.Material_Type_Distinct 		            AS Material_Type,

    rollup.Product_Name,

    flat.Sales_Document_Item_No_All                 AS Product_Details,

    flat.OPPORTUNITY_TITLE_FREE_TEXT                AS Product_Details2,

    flat.OPPORTUNITY_ID,

    flat.Sales_Document_Item_No_All                 AS SALES_DOCUMENT_ITEM_NO,

    PROJECT_NO,

    rollup.Sales_Order_No_All 						AS Sales_Order_No,

    flat.Model,

    rollup.Adjusted_Serial_No 						AS SERIAL_NO,

    flat.CUSTOMER_TOOL_ID,

    rollup.Adjusted_Ship_Date 						AS Ship_Date,

    rollup.Ship_Date_Plus_120,

    rollup.Sales_Month_Max 							AS Sales_Month,

    BU_Sign_Off_Date_Max 							AS BU_Sign_Off_Date,

    Account_Sign_Off_Date_Max 						AS Account_Sign_Off_Date,

    WISDOM_Sign_Off_Date_Max 						AS WISDOM_Sign_Off_Date,

    -- END_USER_SALES_DATE_BU_MAX,

    -- END_USER_SALES_DATE_ACCOUNT_MAX,

    Actual_TSR_Sign_Off_Date,

    flat.IS_SIGN_OFF_WAVED,

    flat.Is_Loaner,

    flat.LOAN_EXPIRATION_DATE,

    VPA,

    REVENUE_RECOGNITION_STATUS_DISTINCT 			AS REVENUE_RECOGNITION_STATUS,

    BOOKING_SALES_STATUS,

    rollup.Sales_Amount_Summed 						AS Sales_Amount,

    flat.Revenue_Recognition_Criteria_Distinct      AS Revenue_Recognition_Criteria,

    flat.Sales_Reporting_Flag,

    flat.Is_Placeholder,

    -- END_USER_BOOKING_DATE_BU_MAX,

    IS_BOOKING_ACTUAL,

    QUOTE_NO,

    PURCHASE_ORDER_NO,

    ACCOUNT_SALES_PERSON,

    BU_SALES_PERSON,

    ACCOUNT_COMMENTS,

    BU_COMMENTS,

    SALES_COMMENTS_TO_SAP,

    ASSISTANTS_COMMENTS_FROM_SAP,

	PO_INCLUDE_LABOR,

    MOD_LABOR_TYPE,

    WORK_ORDER_NO_SALES_CRM,

    WORK_ORDER_SALES_CRM_ISSUE_DATE,

	flat.Data_Type,

    Budget_Type,

    End_User_Code,

    rollup.GS_Data_Snapshot_Max                     AS GS_Data_Snapshot,

    flat.CRM_Data_Snapshot,

    rollup.ACC_Data_Snapshot_Max                    AS ACC_Data_Snapshot,

    rollup.Quantity_Summed,

    rollup.Sales_Month_Max                          AS GS_FK_Date,

    CommonDate.fiscal_year_short_text               AS GS_FY,

    CommonDate.fiscal_year_half_year_short_text_alt AS GS_FY_Half,

    ACCOUNT_REVENUE_FY                              AS Account_FY,

    ACCOUNT_REVENUE_FY_HALF                         AS Account_FY_Half

    -- TO_DATE(CommonDate.quarter_beginning_date)      AS Beginning_of_GS_FY_Q,

    -- TO_DATE(CommonDate.quarter_ending_date)         AS End_of_GS_FY_Q,

	-- Beginning_of_Current_FY,

	-- End_of_Current_FY,

	-- Beginning_of_Current_FY_Half,

	-- End_of_Current_FY_Half,

	-- Beginning_of_Current_FY_Q,

	-- End_of_Current_FY_Q

FROM ModRollup rollup

    LEFT OUTER JOIN ModFirstRecord flat ON flat.Sales_Order_No = rollup.Sales_Order_No_All AND flat.row_number = 1

    LEFT OUTER JOIN FlatACC acc ON acc.Sales_Order_No = rollup.Sales_Order_No_All

    LEFT OUTER JOIN ref_cte_CALENDARDATE CommonDate ON CommonDate.CALENDAR_DATE = rollup.Sales_Month_Max

WHERE SALES_ACCOUNT <> 'N/A'

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        GS_FY_Q,
        ACCOUNT_FY_Q,
        RISK_UPSIDE,
        SALES_ACCOUNT,
        SALES_REGION,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MATERIAL_TYPE,
        PRODUCT_NAME,
        PRODUCT_DETAILS,
        PRODUCT_DETAILS2,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO,
        PROJECT_NO,
        SALES_ORDER_NO,
        MODEL,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        SHIP_DATE,
        SHIP_DATE_PLUS_120,
        SALES_MONTH,
        BU_SIGN_OFF_DATE,
        ACCOUNT_SIGN_OFF_DATE,
        WISDOM_SIGN_OFF_DATE,
        ACTUAL_TSR_SIGN_OFF_DATE,
        IS_SIGN_OFF_WAVED,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        REVENUE_RECOGNITION_STATUS,
        BOOKING_SALES_STATUS,
        SALES_AMOUNT,
        REVENUE_RECOGNITION_CRITERIA,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        IS_BOOKING_ACTUAL,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        ACCOUNT_SALES_PERSON,
        BU_SALES_PERSON,
        ACCOUNT_COMMENTS,
        BU_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
        PO_INCLUDE_LABOR,
        MOD_LABOR_TYPE,
        WORK_ORDER_NO_SALES_CRM,
        WORK_ORDER_SALES_CRM_ISSUE_DATE,
        DATA_TYPE,
        BUDGET_TYPE,
        END_USER_CODE,
        GS_DATA_SNAPSHOT,
        CRM_DATA_SNAPSHOT,
        ACC_DATA_SNAPSHOT,
        QUANTITY_SUMMED,
        GS_FK_DATE,
        GS_FY,
        GS_FY_HALF,
        ACCOUNT_FY,
        ACCOUNT_FY_HALF
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(GS_FY_Q as VARCHAR(16777216)) as GS_FY_Q,
        CAST(ACCOUNT_FY_Q as VARCHAR(16777216)) as ACCOUNT_FY_Q,
        CAST(RISK_UPSIDE as VARCHAR(16777216)) as RISK_UPSIDE,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(SOLD_TO_PARTY as VARCHAR(16777216)) as SOLD_TO_PARTY,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(SALES_CATEGORY_GROUP as VARCHAR(16777216)) as SALES_CATEGORY_GROUP,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(MATERIAL_TYPE as VARCHAR(16777216)) as MATERIAL_TYPE,
        CAST(PRODUCT_NAME as VARCHAR(16777216)) as PRODUCT_NAME,
        CAST(PRODUCT_DETAILS as VARCHAR(16777216)) as PRODUCT_DETAILS,
        CAST(PRODUCT_DETAILS2 as VARCHAR(16777216)) as PRODUCT_DETAILS2,
        CAST(OPPORTUNITY_ID as VARCHAR(16777216)) as OPPORTUNITY_ID,
        CAST(SALES_DOCUMENT_ITEM_NO as VARCHAR(16777216)) as SALES_DOCUMENT_ITEM_NO,
        CAST(PROJECT_NO as VARCHAR(16777216)) as PROJECT_NO,
        CAST(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        CAST(MODEL as VARCHAR(16777216)) as MODEL,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        CAST(SHIP_DATE as DATE) as SHIP_DATE,
        CAST(SHIP_DATE_PLUS_120 as DATE) as SHIP_DATE_PLUS_120,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(BU_SIGN_OFF_DATE as DATE) as BU_SIGN_OFF_DATE,
        CAST(ACCOUNT_SIGN_OFF_DATE as DATE) as ACCOUNT_SIGN_OFF_DATE,
        CAST(WISDOM_SIGN_OFF_DATE as DATE) as WISDOM_SIGN_OFF_DATE,
        CAST(ACTUAL_TSR_SIGN_OFF_DATE as DATE) as ACTUAL_TSR_SIGN_OFF_DATE,
        CAST(IS_SIGN_OFF_WAVED as VARCHAR(16777216)) as IS_SIGN_OFF_WAVED,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        CAST(VPA as VARCHAR(16777216)) as VPA,
        CAST(REVENUE_RECOGNITION_STATUS as VARCHAR(16777216)) as REVENUE_RECOGNITION_STATUS,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(SALES_AMOUNT as NUMBER(38,0)) as SALES_AMOUNT,
        CAST(REVENUE_RECOGNITION_CRITERIA as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA,
        CAST(SALES_REPORTING_FLAG as VARCHAR(16777216)) as SALES_REPORTING_FLAG,
        CAST(IS_PLACEHOLDER as VARCHAR(16777216)) as IS_PLACEHOLDER,
        CAST(IS_BOOKING_ACTUAL as VARCHAR(16777216)) as IS_BOOKING_ACTUAL,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(PURCHASE_ORDER_NO as VARCHAR(16777216)) as PURCHASE_ORDER_NO,
        CAST(ACCOUNT_SALES_PERSON as VARCHAR(16777216)) as ACCOUNT_SALES_PERSON,
        CAST(BU_SALES_PERSON as VARCHAR(16777216)) as BU_SALES_PERSON,
        CAST(ACCOUNT_COMMENTS as VARCHAR(16777216)) as ACCOUNT_COMMENTS,
        CAST(BU_COMMENTS as VARCHAR(16777216)) as BU_COMMENTS,
        CAST(SALES_COMMENTS_TO_SAP as VARCHAR(16777216)) as SALES_COMMENTS_TO_SAP,
        CAST(ASSISTANTS_COMMENTS_FROM_SAP as VARCHAR(16777216)) as ASSISTANTS_COMMENTS_FROM_SAP,
        CAST(PO_INCLUDE_LABOR as VARCHAR(16777216)) as PO_INCLUDE_LABOR,
        CAST(MOD_LABOR_TYPE as VARCHAR(16777216)) as MOD_LABOR_TYPE,
        CAST(WORK_ORDER_NO_SALES_CRM as VARCHAR(16777216)) as WORK_ORDER_NO_SALES_CRM,
        CAST(WORK_ORDER_SALES_CRM_ISSUE_DATE as DATE) as WORK_ORDER_SALES_CRM_ISSUE_DATE,
        CAST(DATA_TYPE as VARCHAR(16777216)) as DATA_TYPE,
        CAST(BUDGET_TYPE as VARCHAR(16777216)) as BUDGET_TYPE,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
        CAST(GS_DATA_SNAPSHOT as DATE) as GS_DATA_SNAPSHOT,
        CAST(CRM_DATA_SNAPSHOT as DATE) as CRM_DATA_SNAPSHOT,
        CAST(ACC_DATA_SNAPSHOT as DATE) as ACC_DATA_SNAPSHOT,
        CAST(QUANTITY_SUMMED as NUMBER(38,0)) as QUANTITY_SUMMED,
        CAST(GS_FK_DATE as DATE) as GS_FK_DATE,
        CAST(GS_FY as VARCHAR(16777216)) as GS_FY,
        CAST(GS_FY_HALF as VARCHAR(16777216)) as GS_FY_HALF,
        CAST(ACCOUNT_FY as VARCHAR(16777216)) as ACCOUNT_FY,
        CAST(ACCOUNT_FY_HALF as VARCHAR(16777216)) as ACCOUNT_FY_HALF
from transform_data 
)
select * from type_data