{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='US_EQUIPMENT_SHIP_REVENUE_RECOGNITION_ROLLUP_CHAMBER_W_SERIAL_NO',
    transient=false
) }}

with
MachineData
AS
(
select distinct
	listagg(distinct SERIAL_NUMBER, ', ')              as SERIAL_NUMBER,
	listagg(distinct CUSTOMER_TOOL_ID, ', ')           as CUSTOMER_TOOL_ID,
	listagg(distinct WISDOM_BU, ', ')                  as TEL_BU,
    listagg(distinct TEL_MODEL, ', ')                  as MODEL,
	listagg(distinct MACHINE_HISTORY_REASON, ', ')     as SYSTEM_STATUS,
	max(TEL_SHIP_DATE)                                 as SHIP_DATE,
	listagg(distinct PO_NO, ', ')                      as CUSTOMER_PURCHASE_ORDER,
	listagg(distinct right(TEL_SALES_ORDER, 9), ', ')  as SALES_ORDER_NO
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__WISDOM_GLOBAL_MACHINES') }}
where TEL_REGION = 'North America'
    and ACTIVE_FLAG = 'Active'
    and WISDOM_BU not in ('FSI', 'Epion')
    and TEL_SHIP_DATE >= '4/1/2020'
    and TEL_SALES_ORDER is not null
group by right(TEL_SALES_ORDER, 9)
),
ChamberRollup
AS
(
SELECT
    LISTAGG(DISTINCT gs.Sales_Order_No, ', ')                                                           AS Sales_Order_No_All,
    listagg(distinct gs.SALES_CATEGORY_GROUP, ', ') within group (order by gs.SALES_CATEGORY_GROUP asc) as Sales_Category_Group_Distinct,
    CASE WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Equipment') THEN 'Equipment'
        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'New Equipment') THEN 'New Equipment'
        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Used Equip w/Core') THEN 'Used Equip w/Core'
        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Used Equip w/o Core') THEN 'Used Equip w/o Core'
        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Used Equip (as is)') THEN 'Used Equip (as is)'
        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Chamber') THEN 'Chamber'
        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Pre-kit') THEN 'Pre-kit'
        WHEN CONTAINS(LISTAGG(DISTINCT gs.SALES_CATEGORY, ', '), 'Option') THEN 'Option'
        ELSE ''
    END                                                                                                 AS Primary_Sales_Category,
    LISTAGG(DISTINCT gs.Sales_Category, ', ')                                                           AS Sales_Category_All,
    LISTAGG(DISTINCT gs.Product_Name, ', ')                                                             AS Product_Name_All,
    LISTAGG(DISTINCT gs.Serial_No, ', ')                                                                AS Serial_No_Distinct,
    LISTAGG(DISTINCT crm.PM_SERIAL_NO, ', ')                                                            AS CRM_PM_Serial_No_Distinct,
    LISTAGG(DISTINCT machine.SERIAL_NUMBER, ', ')                                                       AS WISDOM_Serial_No,
    CASE WHEN CRM_PM_Serial_No_Distinct IS NOT NULL AND CRM_PM_Serial_No_Distinct <> '' THEN CRM_PM_Serial_No_Distinct
        else WISDOM_Serial_No
    END                                                                                                 AS Adjusted_Serial_No,
    MAX(gs.Sales_Month)                                                                                 AS Sales_Month_Max,
    MAX(gs.Customs_Clearance_Date)                                                                      AS Customs_Clearance_Date_Max,
    MAX(crm.Ship_Date_Max)                                                                              AS CRM_Ship_Date_Max,
    MAX(machine.Ship_Date)                                                                              AS WISDOM_Ship_Date_Max,
    CASE WHEN CRM_Ship_Date_Max IS NOT NULL THEN CRM_Ship_Date_Max
        WHEN Customs_Clearance_Date_Max IS NOT NULL THEN Customs_Clearance_Date_Max
        ELSE WISDOM_Ship_Date_Max
    END                                                                                                 AS Adjusted_Ship_Date,
    SUM(gs.QUANTITY)                                                                                    AS Quantity_Summed,
    CASE WHEN Quantity_Summed >= 2 THEN SUM(gs.Sales_Amount)/Quantity_Summed
        ELSE SUM(gs.Sales_Amount)
    END                                                                                                 AS Sales_Amount_Summed,
    MAX(gs.Data_Snapshot)                                                                               AS GS_Data_Snapshot_Max,
    MAX(crm.Data_Snapshot)                                                                              AS CRM_Data_Snapshot_Max,
    SPLIT_PART(LISTAGG(DISTINCT gs.Sales_Order_No, ', ') WITHIN GROUP (ORDER BY gs.SALES_ORDER_NO ASC), ', ', 1)                    AS First_Sales_Order_No,
    listagg(distinct ifnull(crm.PURCHASE_ORDER_NO, 'N/A'), '||') within group (order by ifnull(crm.PURCHASE_ORDER_NO, 'N/A') asc)   as PURCHASE_ORDER_NO
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_EQUIPMENT_SHIP_REVENUE_RECOGNITION_CURRENT_FLAT') }} gs
    LEFT OUTER JOIN {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_EQUIPMENT_SHIP_BASE_REVENUE_RECOGNITION') }} crm ON crm.SALES_ORDER_NO_DISTINCT = gs.Sales_Order_No
    LEFT OUTER JOIN MachineData machine ON machine.Sales_Order_No = gs.Sales_Order_No
WHERE gs.SERIAL_NO IS NOT NULL
    AND gs.SERIAL_NO <> ''
    AND gs.SERIAL_NO NOT ILIKE 'TBD'
    AND gs.SERIAL_NO NOT ILIKE 'NONE'
	AND gs.SERIAL_NO <> '0'
    AND gs.SALES_CATEGORY_GROUP = 'Chamber'
    AND gs.Sales_Amount <> 0
    and gs.SALES_ORDER_NO is not null
    and not gs.SALES_ORDER_NO ilike any ('', '0', '取得中', 'バルク')
GROUP BY gs.SALES_ORDER_NO
-- HAVING Quantity_Summed > 0
),
FirstRecordwSNChamber
AS
(
SELECT
	gs.Sales_Account,
	gs.Sales_Region,
	CASE WHEN crm.SOLD_TO_PARTY IS NOT NULL THEN crm.SOLD_TO_PARTY
	    ELSE gs.Sold_to_Party
    END                                                         AS Sold_to_Party,
    CASE WHEN crm.END_USER IS NOT NULL THEN crm.END_USER
	    ELSE gs.End_User
    END                                                         AS End_User,
	gs.FAB,
    gs.BU,
	gs.Sub_BU,
	gs.BU_Group,
    gs.Sales_Order_No,
    gs.Sales_Category_Group,
    gs.Sales_Category,
    crm.ORDER_ITEM_OPPORTUNITY,
    crm.ORDER_ITEM_SALES_DOCUMENT_ALL,
    crm.OPPORTUNITY_TITLE_FREE_TEXT,
    crm.OPPORTUNITY_ID_DISTINCT,
    crm.SALES_DOCUMENT_ITEM_NO_ALL,
    crm.PROJECT_NO_DISTINCT,
	crm.Model                                                   AS CRM_Model,
    machine.Model                                               AS WISDOM_Model,
    CASE WHEN CRM_Model IS NULL THEN WISDOM_Model
        ELSE CRM_Model
    END                                                         AS Model,
	crm.CUSTOMER_TOOL_ID                                        AS CRM_Customer_Tool_ID,
    machine.Customer_Tool_ID                                    AS WISDOM_Customer_Tool_ID,
    CASE WHEN CRM_Customer_Tool_ID IS NULL THEN WISDOM_Customer_Tool_ID
        ELSE CRM_Customer_Tool_ID
    END                                                         AS CUSTOMER_TOOL_ID,
    crm.SALES_REPORTING_FLAG,
    gs.Is_Placeholder,
    crm.CONFIDENCE_BU_SHORT,
    crm.END_USER_BOOKING_DATE_BU_MAX,
    crm.IS_BOOKING_ACTUAL,
    crm.QUOTE_NO,
    crm.PURCHASE_ORDER_NO                                       AS CRM_PO_No,
    machine.CUSTOMER_PURCHASE_ORDER                             AS WISDOM_PO_No,
    CASE WHEN CRM_PO_No IS NULL THEN WISDOM_PO_No
        ELSE CRM_PO_No
    END                                                         AS PURCHASE_ORDER_NO,
    crm.END_USER_SALES_DATE_BU_MAX,
    crm.END_USER_SALES_DATE_ACCOUNT_MAX,
    crm.ACTUAL_SALES_DATE_MAX,
	REVENUE_RECOGNITION_STATUS_DISTINCT,
    crm.BOOKING_SALES_STATUS,
    machine.SYSTEM_STATUS                                       AS Machine_Status,
    gs.Is_Loaner,
    crm.LOAN_EXPIRATION_DATE,
    crm.VPA,
    gs.Revenue_Recognition_Criteria_Short,
    crm.ACCOUNT_SALES_PERSON,
    crm.BU_SALES_PERSON,
    crm.BU_COMMENTS			                                    AS CRM_BU_COMMENTS,
    CRM_BU_COMMENTS                                             AS BU_COMMENTS,
    crm.ACCOUNT_COMMENTS,
    crm.SALES_COMMENTS_TO_SAP,
    crm.ASSISTANTS_COMMENTS_FROM_SAP,
	gs.Data_Type,
    gs.Budget_Type,
	gs.Quantity,
    gs.End_User_Code,
    ACCOUNT_REVENUE_FY,
    ACCOUNT_REVENUE_FY_HALF,
    ACCOUNT_REVENUE_FY_Q,
    row_number() over (partition by gs.SALES_ORDER_NO order by gs.SALES_ORDER_NO desc) as row_number
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_EQUIPMENT_SHIP_REVENUE_RECOGNITION_CURRENT_FLAT') }} gs
LEFT OUTER JOIN {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_EQUIPMENT_SHIP_BASE_REVENUE_RECOGNITION') }} crm
    ON crm.SALES_ORDER_NO_DISTINCT = gs.SALES_ORDER_NO
LEFT OUTER JOIN MachineData machine ON machine.Sales_Order_No = gs.Sales_Order_No
WHERE gs.Sales_Amount <> 0
	AND gs.SERIAL_NO IS NOT NULL
    AND gs.SERIAL_NO <> ''
    AND gs.SERIAL_NO NOT ILIKE 'TBD'
    AND gs.SERIAL_NO NOT ILIKE 'NONE'
	AND gs.SERIAL_NO <> '0'
	AND gs.Sales_Category_Group = 'Chamber'
    and gs.SALES_ORDER_NO is not null
    and not gs.SALES_ORDER_NO ilike any ('', '0', '取得中', 'バルク')
),
SOURCE_DATA AS (
SELECT
    CommonDate.fiscal_year_quarter_short_text       AS GS_FY_Q,
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
    rollup.Sales_Category_All,
    rollup.Primary_Sales_Category,
    rollup.Product_Name_All,
    flat.OPPORTUNITY_TITLE_FREE_TEXT                AS Product_Details,
    flat.OPPORTUNITY_ID_DISTINCT,
    flat.Sales_Document_Item_No_All,
    flat.OPPORTUNITY_TITLE_FREE_TEXT,
    PROJECT_NO_DISTINCT,
    rollup.Sales_Order_No_All,
    flat.Model,
    rollup.Adjusted_Serial_No,
    flat.CUSTOMER_TOOL_ID,
	Machine_Status,
	rollup.Adjusted_Ship_Date,
	rollup.Sales_Month_Max,
	END_USER_SALES_DATE_BU_MAX,
    END_USER_SALES_DATE_ACCOUNT_MAX,
    ACTUAL_SALES_DATE_MAX,
	flat.Is_Loaner,
	flat.LOAN_EXPIRATION_DATE,
    VPA,
	REVENUE_RECOGNITION_STATUS_DISTINCT,
    BOOKING_SALES_STATUS,
    rollup.Sales_Amount_Summed,
	flat.Revenue_Recognition_Criteria_Short,
	flat.Sales_Reporting_Flag,
    flat.Is_Placeholder,
    END_USER_BOOKING_DATE_BU_MAX,
    IS_BOOKING_ACTUAL,
    CONFIDENCE_BU_SHORT,
    QUOTE_NO,
    rollup.PURCHASE_ORDER_NO,
    ACCOUNT_SALES_PERSON,
    BU_SALES_PERSON,
    ACCOUNT_COMMENTS,
    BU_COMMENTS,
    SALES_COMMENTS_TO_SAP,
    ASSISTANTS_COMMENTS_FROM_SAP,
    flat.Data_Type,
    Budget_Type,
    End_User_Code,
    rollup.GS_Data_Snapshot_Max                     AS GS_Data_Snapshot,
    rollup.CRM_Data_Snapshot_Max                    AS CRM_Data_Snapshot,
    null                                            AS ACC_Data_Snapshot,
    rollup.Quantity_Summed,
    rollup.Sales_Month_Max                          AS GS_FK_Date,
    CommonDate.fiscal_year_short_text               AS GS_FY,
    CommonDate.fiscal_year_half_year_short_text_alt AS GS_FY_Half,
    ACCOUNT_REVENUE_FY                              AS Account_FY,
    ACCOUNT_REVENUE_FY_HALF                         AS Account_FY_Half
FROM ChamberRollup rollup
LEFT OUTER JOIN FirstRecordwSNChamber flat ON flat.Sales_Order_No = rollup.First_Sales_Order_No
                                                AND flat.row_number = 1
LEFT OUTER JOIN {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate ON CommonDate.CALENDAR_DATE = GS_FK_Date
),
TRANSFORM_DATA AS (
SELECT
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
        SALES_CATEGORY_ALL,
        PRIMARY_SALES_CATEGORY,
        PRODUCT_NAME_ALL,
        PRODUCT_DETAILS,
        OPPORTUNITY_ID_DISTINCT,
        SALES_DOCUMENT_ITEM_NO_ALL,
        OPPORTUNITY_TITLE_FREE_TEXT,
        PROJECT_NO_DISTINCT,
        SALES_ORDER_NO_ALL,
        MODEL,
        ADJUSTED_SERIAL_NO,
        CUSTOMER_TOOL_ID,
        MACHINE_STATUS,
        ADJUSTED_SHIP_DATE,
        SALES_MONTH_MAX,
        END_USER_SALES_DATE_BU_MAX,
        END_USER_SALES_DATE_ACCOUNT_MAX,
        ACTUAL_SALES_DATE_MAX,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        REVENUE_RECOGNITION_STATUS_DISTINCT,
        BOOKING_SALES_STATUS,
        SALES_AMOUNT_SUMMED,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        END_USER_BOOKING_DATE_BU_MAX,
        IS_BOOKING_ACTUAL,
        CONFIDENCE_BU_SHORT,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        ACCOUNT_SALES_PERSON,
        BU_SALES_PERSON,
        ACCOUNT_COMMENTS,
        BU_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
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
FROM SOURCE_DATA
)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
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
        SALES_CATEGORY_ALL,
        PRIMARY_SALES_CATEGORY,
        PRODUCT_NAME_ALL,
        PRODUCT_DETAILS,
        OPPORTUNITY_ID_DISTINCT,
        SALES_DOCUMENT_ITEM_NO_ALL,
        OPPORTUNITY_TITLE_FREE_TEXT,
        PROJECT_NO_DISTINCT,
        SALES_ORDER_NO_ALL,
        MODEL,
        ADJUSTED_SERIAL_NO,
        CUSTOMER_TOOL_ID,
        MACHINE_STATUS,
        CAST(ADJUSTED_SHIP_DATE as DATE) as ADJUSTED_SHIP_DATE,
        CAST(SALES_MONTH_MAX as DATE) as SALES_MONTH_MAX,
        CAST(END_USER_SALES_DATE_BU_MAX as DATE) as END_USER_SALES_DATE_BU_MAX,
        CAST(END_USER_SALES_DATE_ACCOUNT_MAX as DATE) as END_USER_SALES_DATE_ACCOUNT_MAX,
        CAST(ACTUAL_SALES_DATE_MAX as DATE) as ACTUAL_SALES_DATE_MAX,
        IS_LOANER,
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        VPA,
        REVENUE_RECOGNITION_STATUS_DISTINCT,
        BOOKING_SALES_STATUS,
        CAST(SALES_AMOUNT_SUMMED as NUMBER(38,10)) as SALES_AMOUNT_SUMMED,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        CAST(END_USER_BOOKING_DATE_BU_MAX as DATE) as END_USER_BOOKING_DATE_BU_MAX,
        IS_BOOKING_ACTUAL,
        CONFIDENCE_BU_SHORT,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        ACCOUNT_SALES_PERSON,
        BU_SALES_PERSON,
        ACCOUNT_COMMENTS,
        BU_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
        DATA_TYPE,
        BUDGET_TYPE,
        END_USER_CODE,
        CAST(GS_DATA_SNAPSHOT as DATE) as GS_DATA_SNAPSHOT,
        CAST(CRM_DATA_SNAPSHOT as DATE) as CRM_DATA_SNAPSHOT,
        ACC_DATA_SNAPSHOT,
        CAST(QUANTITY_SUMMED as NUMBER(38,0)) as QUANTITY_SUMMED,
        CAST(GS_FK_DATE as DATE) as GS_FK_DATE,
        GS_FY,
        GS_FY_HALF,
        ACCOUNT_FY,
        ACCOUNT_FY_HALF
from transform_data
)
SELECT * FROM TYPE_DATA