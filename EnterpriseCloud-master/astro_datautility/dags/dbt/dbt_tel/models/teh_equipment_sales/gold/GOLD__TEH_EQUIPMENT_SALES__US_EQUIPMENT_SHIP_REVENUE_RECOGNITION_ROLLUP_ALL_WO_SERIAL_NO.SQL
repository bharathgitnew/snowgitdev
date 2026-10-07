{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='US_EQUIPMENT_SHIP_REVENUE_RECOGNITION_ROLLUP_ALL_WO_SERIAL_NO',
    transient=false
) }}

with
MachineData
as
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
MissingSNRollup
as
(
select
    listagg(distinct gs.Sales_Order_No, ', ')                                                           as Sales_Order_No_All,
    listagg(distinct gs.SALES_CATEGORY_GROUP, ', ') within group (order by SALES_CATEGORY_GROUP asc)    as Sales_Category_Group_Distinct,
    case when contains(listagg(distinct gs.SALES_CATEGORY, ', '), 'Equipment') then 'Equipment'
        when contains(listagg(distinct gs.SALES_CATEGORY, ', '), 'New Equipment') then 'New Equipment'
        when contains(listagg(distinct gs.SALES_CATEGORY, ', '), 'Used Equip w/Core') then 'Used Equip w/Core'
        when contains(listagg(distinct gs.SALES_CATEGORY, ', '), 'Used Equip w/o Core') then 'Used Equip w/o Core'
        when contains(listagg(distinct gs.SALES_CATEGORY, ', '), 'Used Equip (as is)') then 'Used Equip (as is)'
        when contains(listagg(distinct gs.SALES_CATEGORY, ', '), 'Chamber') then 'Chamber'
        when contains(listagg(distinct gs.SALES_CATEGORY, ', '), 'Pre-kit') then 'Pre-kit'
        when contains(listagg(distinct gs.SALES_CATEGORY, ', '), 'Option') then 'Option'
        else ''
    end                                                                                                 as Primary_Sales_Category,
    listagg(distinct gs.Sales_Category, ', ')                                                           as Sales_Category_All,
    listagg(distinct gs.Product_Name, ', ')                                                             as Product_Name_All,
    listagg(distinct gs.Serial_No, ', ')                                                                as Serial_No_Distinct,
    listagg(distinct crm.SERIAL_NO, ', ')                                                               as CRM_Serial_No_Distinct,
    listagg(distinct machine.SERIAL_NUMBER, ', ')                                                       as WISDOM_Serial_No,
    case when Serial_No_Distinct is not null and Serial_No_Distinct <> '' then Serial_No_Distinct
        when CRM_Serial_No_Distinct is not null and CRM_Serial_No_Distinct <> '' then CRM_Serial_No_Distinct
        else WISDOM_Serial_No
    end                                                                                                 as Adjusted_Serial_No,
    max(gs.Sales_Month)                                                                                 as Sales_Month_Max,
    max(gs.Customs_Clearance_Date)                                                                      as Customs_Clearance_Date_Max,
    max(crm.Ship_Date_Max)                                                                              as CRM_Ship_Date_Max,
    max(machine.Ship_Date)                                                                              as WISDOM_Ship_Date_Max,
    case when CRM_Ship_Date_Max is not null then CRM_Ship_Date_Max
        when Customs_Clearance_Date_Max is not null then Customs_Clearance_Date_Max
        else WISDOM_Ship_Date_Max
    end                                                                                                 as Adjusted_Ship_Date,
    sum(gs.QUANTITY)                                                                                    as Quantity_Summed,
    case when Quantity_Summed >= 2 then sum(gs.Sales_Amount)/Quantity_Summed
        else sum(gs.Sales_Amount)
    end                                                                                                 as Sales_Amount_Summed,
    max(gs.Data_Snapshot)                                                                               as GS_Data_Snapshot_Max,
    max(crm.Data_Snapshot)                                                                              as CRM_Data_Snapshot_Max,
    split_part(listagg(distinct gs.Sales_Order_No, ', ') within group (order by gs.SALES_ORDER_NO asc), ', ', 1)    as First_Sales_Order_No,
    listagg(distinct crm.PURCHASE_ORDER_NO, ', ')                                                                   as PURCHASE_ORDER_NO
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_EQUIPMENT_SHIP_REVENUE_RECOGNITION_CURRENT_FLAT') }} gs
    left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_EQUIPMENT_SHIP_BASE_REVENUE_RECOGNITION') }} crm on crm.SALES_ORDER_NO_DISTINCT = gs.Sales_Order_No
                                                                                            and crm.Primary_Sales_Category <> 'Option'
    left outer join MachineData machine on machine.Sales_Order_No = gs.Sales_Order_No
where (gs.SERIAL_NO is null
        or gs.SERIAL_NO = ''
        or gs.SERIAL_NO ilike 'TBD'
        or gs.SERIAL_NO ilike 'NONE'
	    or gs.SERIAL_NO = '0')
	and gs.Sales_Amount <> 0
    and gs.SALES_ORDER_NO is not null
    and not gs.SALES_ORDER_NO ilike any ('', '0', '取得中', 'バルク')
group by gs.SALES_ORDER_NO
having Quantity_Summed > 0
),
FirstRecordwoSN
as
(
select
	gs.Sales_Account,
	gs.Sales_Region,
	case when crm.SOLD_TO_PARTY is not null then crm.SOLD_TO_PARTY
	    else gs.Sold_to_Party
    end                                                         as Sold_to_Party,
    case when crm.END_USER is not null then crm.END_USER
	    else gs.End_User
    end                                                         as End_User,
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
	crm.Model                                                   as CRM_Model,
    machine.Model                                               as WISDOM_Model,
    case when CRM_Model is null then WISDOM_Model
        else CRM_Model
    end                                                         as Model,
    crm.CUSTOMER_TOOL_ID                                        as CRM_Customer_Tool_ID,
    machine.Customer_Tool_ID                                    as WISDOM_Customer_Tool_ID,
    case when CRM_Customer_Tool_ID is null then WISDOM_Customer_Tool_ID
        else CRM_Customer_Tool_ID
    end                                                         as CUSTOMER_TOOL_ID,
    crm.SALES_REPORTING_FLAG,
    gs.Is_Placeholder,
    crm.CONFIDENCE_BU_SHORT,
    crm.END_USER_BOOKING_DATE_BU_MAX,
    crm.IS_BOOKING_ACTUAL,
    crm.QUOTE_NO,
    crm.PURCHASE_ORDER_NO                                       as CRM_PO_No,
    machine.CUSTOMER_PURCHASE_ORDER                             as WISDOM_PO_No,
    case when CRM_PO_No is null then WISDOM_PO_No
        else CRM_PO_No
    end                                                         as PURCHASE_ORDER_NO,
    crm.END_USER_SALES_DATE_BU_MAX,
    crm.END_USER_SALES_DATE_ACCOUNT_MAX,
    crm.ACTUAL_SALES_DATE_MAX,
	crm.REVENUE_RECOGNITION_STATUS_DISTINCT,
    crm.BOOKING_SALES_STATUS,
    machine.SYSTEM_STATUS                                       as Machine_Status,
    gs.Is_Loaner,
    crm.LOAN_EXPIRATION_DATE,
    crm.VPA,
    gs.Revenue_Recognition_Criteria_Short,
    crm.ACCOUNT_SALES_PERSON,
    crm.BU_SALES_PERSON,
    crm.BU_COMMENTS			                                    as CRM_BU_COMMENTS,
    CRM_BU_COMMENTS                                             as BU_COMMENTS,
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
    row_number() over (partition by gs.SALES_ORDER_NO order by gs.SALES_AMOUNT desc) as row_number
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_EQUIPMENT_SHIP_REVENUE_RECOGNITION_CURRENT_FLAT') }} gs
    left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_EQUIPMENT_SHIP_BASE_REVENUE_RECOGNITION') }} crm on crm.SALES_ORDER_NO_DISTINCT = gs.SALES_ORDER_NO
                                                                                            and crm.PRIMARY_SALES_CATEGORY <> 'Option'
    left outer join MachineData machine on machine.Sales_Order_No = gs.Sales_Order_No
where gs.Sales_Amount <> 0
    and (gs.SERIAL_NO is null
         or gs.SERIAL_NO = ''
         or gs.SERIAL_NO ilike 'TBD'
         or gs.SERIAL_NO ilike 'NONE'
		 or gs.SERIAL_NO = '0')
    and gs.SALES_ORDER_NO is not null
    and not gs.SALES_ORDER_NO ilike any ('', '0', '取得中', 'バルク')
    and gs.Quantity = 1
),
SOURCE_DATA AS (
select
    CommonDate.fiscal_year_quarter_short_text       as GS_FY_Q,
    flat.ACCOUNT_REVENUE_FY_Q                       as Account_FY_Q,
    'Risk'                                          as Risk_Upside,
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
    flat.OPPORTUNITY_TITLE_FREE_TEXT                as Product_Details,
    flat.OPPORTUNITY_ID_DISTINCT,
    flat.Sales_Document_Item_No_All,
    flat.OPPORTUNITY_TITLE_FREE_TEXT,
    flat.PROJECT_NO_DISTINCT,
    rollup.Sales_Order_No_All,
    flat.Model,
    rollup.Adjusted_Serial_No,
    flat.CUSTOMER_TOOL_ID,
    flat.Machine_Status,
    rollup.Adjusted_Ship_Date,
	rollup.Sales_Month_Max,
	flat.END_USER_SALES_DATE_BU_MAX,
    flat.END_USER_SALES_DATE_ACCOUNT_MAX,
	flat.ACTUAL_SALES_DATE_MAX,
	flat.Is_Loaner,
    flat.LOAN_EXPIRATION_DATE,
    flat.VPA,
	flat.REVENUE_RECOGNITION_STATUS_DISTINCT,
    flat.BOOKING_SALES_STATUS,
    rollup.Sales_Amount_Summed,
    flat.Revenue_Recognition_Criteria_Short,
    flat.Sales_Reporting_Flag,
    flat.Is_Placeholder,
    flat.END_USER_BOOKING_DATE_BU_MAX,
    flat.IS_BOOKING_ACTUAL,
    flat.CONFIDENCE_BU_SHORT,
	flat.QUOTE_NO,
    rollup.PURCHASE_ORDER_NO,
    flat.ACCOUNT_SALES_PERSON,
    flat.BU_SALES_PERSON,
    flat.ACCOUNT_COMMENTS,
    flat.BU_COMMENTS,
    flat.SALES_COMMENTS_TO_SAP,
    flat.ASSISTANTS_COMMENTS_FROM_SAP,
    flat.Data_Type,
    flat.Budget_Type,
    flat.End_User_Code,
    rollup.GS_Data_Snapshot_Max                     as GS_Data_Snapshot,
    rollup.CRM_Data_Snapshot_Max                    as CRM_Data_Snapshot,
    null                                            as ACC_Data_Snapshot,
    rollup.Quantity_Summed,
    rollup.Sales_Month_Max                          as GS_FK_Date,
    CommonDate.fiscal_year_short_text               as GS_FY,
    CommonDate.fiscal_year_half_year_short_text_alt as GS_FY_Half,
    flat.ACCOUNT_REVENUE_FY                         as Account_FY,
    flat.ACCOUNT_REVENUE_FY_HALF                    as Account_FY_Half
from MissingSNRollup rollup
    left outer join FirstRecordwoSN flat on flat.Sales_Order_No = rollup.First_Sales_Order_No
                                            and flat.row_number = 1
    left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} CommonDate on CommonDate.CALENDAR_DATE = GS_FK_Date
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