{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='GS_US_REVENUE_BUDGET_HISTORY_ALL',
    	transient=false
) }}

WITH ref_cte_CALENDARDATE as (
    select * from {{ source('STATIC_OBJECTS', 'CALENDARDATE') }}
),

ref_cte_GS_US_REVENUE_BUDGET as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }}
),

ref_cte_GS_US_REVENUE_BUDGET_HISTORY_LEGACY as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET_HISTORY_LEGACY') }}
),



source_data as (
select

	Sales_Customer_Group                               				as SALES_ACCOUNT,

	''                                                              as SALES_REGION,

	BU,

    BU_GROUP,

    BU_TYPE,

    SUB_BU,

	CUSTOMER_NAME                                                   as SOLD_TO_PARTY,

	END_USER_NAME                                                   as END_USER,

	FAB,

	SO                                                              as SALES_ORDER_NO,

    case when CATEGORY like 'Modification%' then 'Modification' 

        when CATEGORY = 'Option' then 'Option' 

        else 'Equipment' end                                        as SALES_CATEGORY_GROUP,

	CATEGORY                                                        as SALES_CATEGORY,

	''                                                              as IS_PLACEHOLDER,

    PRODUCT_NAME,

	SN                                                              as SERIAL_NO,

	DATE_FROM_PARTS(SPLIT_PART(GS_SALES_MONTH,'-',1), SPLIT_PART(GS_SALES_MONTH,'-',2),1) as SALES_MONTH,

    TO_NUMBER(SALES_AMOUNT,38,0)                                    as SALES_AMOUNT,

    QTY                                                             as QUANTITY,

    FCA_DATE                                                        as SHIP_DATE,

	ON_DOCK_DATE,

    CST_DATE,

	SALES_DATE,

	LOAN_FLAG                                                       as IS_LOANER,

	case when CST_FLAG = 1 then 'CST'

        when CST_FLAG = 2 then 'Shipment'

        when CST_FLAG = 3 then 'Other'

        when CST_FLAG = 0 then NULL

        else NULL end                                               as REVENUE_RECOGNITION_CRITERIA,

	case when CST_FLAG = 1 then 'CST'

        when CST_FLAG = 2 then 'Ship'

        when CST_FLAG = 3 then 'Other'

        when CST_FLAG = 0 then NULL

        else NULL end                                               as REVENUE_RECOGNITION_CRITERIA_SHORT,

	REPORT_LOAD_DATE                                                as DATA_SNAPSHOT,

	'Budget'                                                        as DATA_TYPE,

	case when MONTH(DATA_SNAPSHOT) in (1, 2, 3, 4, 5, 6) then 'Original' 

        when MONTH(DATA_SNAPSHOT) in (7, 8, 9, 10, 11, 12) then 'Revised' end as BUDGET_TYPE,

	''                                                              as BU_CODE,

	ORIGINAL_BU_CODES                                               as SUB_BU_CODE,

	''                                                              as ORDER_TYPE_CODE,

	CUSTOMER_CODE                                                   as SOLD_TO_PARTY_CODE,

	''                                                              as END_USER_CODE_MIXED,

	END_USER_CODE                                                   as _5_DIGIT_END_USER_CODE,

	''                                                              as END_USER_CODE,

    CommonDate1.FISCAL_YEAR_BEGINNING_DATE                          as Beginning_of_Current_FY,

    CommonDate1.FISCAL_YEAR_ENDING_DATE                             as End_of_Current_FY,

	CommonDate1.FISCAL_HALF_YEAR_BEGINNING_DATE                     as Beginning_of_Current_FY_Half,

	CommonDate1.FISCAL_HALF_YEAR_ENDING_DATE                        as End_of_Current_FY_Half,

	CommonDate1.FISCAL_QUARTER_BEGINNING_DATE                       as Beginning_of_Current_FY_Q,

	CommonDate1.FISCAL_QUARTER_ENDING_DATE                          as End_of_Current_FY_Q,

    DATEADD('year', 1, Beginning_of_Current_FY)                     as Beginning_of_Next_FY,

	DATEADD('year', 1, End_of_Current_FY)                           as End_of_Next_FY,

	DATEADD('month', 6, Beginning_of_Current_FY_Half)               as Beginning_of_Next_FY_Half,

	DATEADD('month', 6, End_of_Current_FY_Half)                     as End_of_Next_FY_Half,

	DATEADD('month', 3, Beginning_of_Current_FY_Q)                  as Beginning_of_Next_FY_Q,

	DATEADD('month', 3, End_of_Current_FY_Q)                        as End_of_Next_FY_Q,

	DATEADD('year', -2, Beginning_of_Current_FY)                    as Beginning_of_2_FY_Ago,

	DATEADD('year', 2, End_of_Current_FY)                           as End_of_2_FY_Ahead,

	SALES_MONTH                                                     as GS_BUDGET_FK_DATE,

	CommonDate.fiscal_year_short_text                               as GS_Budget_FY,

    CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT                 as GS_Budget_FY_Half,

    CommonDate.fiscal_year_quarter_short_text                       as GS_Budget_FY_Q,

	TO_DATE(CommonDate.fiscal_year_beginning_date)                  as Beginning_of_GS_Budget_FY,

	TO_DATE(CommonDate.fiscal_year_ending_date)                     as End_of_GS_Budget_FY,

	TO_DATE(CommonDate.fiscal_half_year_beginning_date)             as Beginning_of_GS_Budget_FY_Half,

	TO_DATE(CommonDate.fiscal_half_year_ending_date)                as End_of_GS_Budget_FY_Half,

    TO_DATE(CommonDate.fiscal_quarter_beginning_date)               as Beginning_of_GS_Budget_FY_Q,

    TO_DATE(CommonDate.fiscal_quarter_ending_date)                  as End_of_GS_Budget_FY_Q

from ref_cte_GS_US_REVENUE_BUDGET_HISTORY_LEGACY

    left outer join ref_cte_CALENDARDATE CommonDate on TO_DATE(CommonDate.CALENDAR_DATE) = GS_Budget_FK_Date

    left outer join ref_cte_CALENDARDATE CommonDate1 on TO_DATE(CommonDate1.CALENDAR_DATE) = CURRENT_DATE() 



union all

select

    SALES_ACCOUNT,

	SALES_REGION,

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

	SALES_MONTH,

	SALES_AMOUNT,

	QUANTITY,

    CUSTOMS_CLEARANCE_DATE          as Ship_Date,

	ON_DOCK_DATE,

    NULL                            as CST_Date,

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

	BEGINNING_OF_2_FY_AGO,

	END_OF_2_FY_AHEAD,

	GS_BUDGET_FK_DATE,

	GS_BUDGET_FY,

	GS_BUDGET_FY_HALF,

	GS_BUDGET_FY_Q,

	Beginning_of_GS_Budget_FY,

	End_of_GS_Budget_FY,

	Beginning_of_GS_Budget_FY_Half,

	End_of_GS_Budget_FY_Half,

    Beginning_of_GS_Budget_FY_Q,

    End_of_GS_Budget_FY_Q

from ref_cte_GS_US_REVENUE_BUDGET

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
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
        SALES_MONTH,
        SALES_AMOUNT,
        QUANTITY,
        SHIP_DATE,
        ON_DOCK_DATE,
        CST_DATE,
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
        END_OF_GS_BUDGET_FY_Q
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(BU_TYPE as VARCHAR(16777216)) as BU_TYPE,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(SOLD_TO_PARTY as VARCHAR(16777216)) as SOLD_TO_PARTY,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        CAST(SALES_CATEGORY_GROUP as VARCHAR(16777216)) as SALES_CATEGORY_GROUP,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(IS_PLACEHOLDER as VARCHAR(16777216)) as IS_PLACEHOLDER,
        CAST(PRODUCT_NAME as VARCHAR(16777216)) as PRODUCT_NAME,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(SALES_AMOUNT as NUMBER(38,0)) as SALES_AMOUNT,
        CAST(QUANTITY as NUMBER(38,10)) as QUANTITY,
        CAST(SHIP_DATE as DATE) as SHIP_DATE,
        CAST(ON_DOCK_DATE as DATE) as ON_DOCK_DATE,
        CAST(CST_DATE as DATE) as CST_DATE,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(REVENUE_RECOGNITION_CRITERIA as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA,
        CAST(REVENUE_RECOGNITION_CRITERIA_SHORT as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_SHORT,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_TYPE as VARCHAR(16777216)) as DATA_TYPE,
        CAST(BUDGET_TYPE as VARCHAR(16777216)) as BUDGET_TYPE,
        CAST(BU_CODE as VARCHAR(16777216)) as BU_CODE,
        CAST(SUB_BU_CODE as VARCHAR(16777216)) as SUB_BU_CODE,
        CAST(ORDER_TYPE_CODE as VARCHAR(16777216)) as ORDER_TYPE_CODE,
        CAST(SOLD_TO_PARTY_CODE as VARCHAR(16777216)) as SOLD_TO_PARTY_CODE,
        CAST(END_USER_CODE_MIXED as VARCHAR(16777216)) as END_USER_CODE_MIXED,
        CAST(_5_DIGIT_END_USER_CODE as VARCHAR(16777216)) as _5_DIGIT_END_USER_CODE,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
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
        CAST(GS_BUDGET_FK_DATE as DATE) as GS_BUDGET_FK_DATE,
        CAST(GS_BUDGET_FY as VARCHAR(16777216)) as GS_BUDGET_FY,
        CAST(GS_BUDGET_FY_HALF as VARCHAR(16777216)) as GS_BUDGET_FY_HALF,
        CAST(GS_BUDGET_FY_Q as VARCHAR(16777216)) as GS_BUDGET_FY_Q,
        CAST(BEGINNING_OF_GS_BUDGET_FY as DATE) as BEGINNING_OF_GS_BUDGET_FY,
        CAST(END_OF_GS_BUDGET_FY as DATE) as END_OF_GS_BUDGET_FY,
        CAST(BEGINNING_OF_GS_BUDGET_FY_HALF as DATE) as BEGINNING_OF_GS_BUDGET_FY_HALF,
        CAST(END_OF_GS_BUDGET_FY_HALF as DATE) as END_OF_GS_BUDGET_FY_HALF,
        CAST(BEGINNING_OF_GS_BUDGET_FY_Q as DATE) as BEGINNING_OF_GS_BUDGET_FY_Q,
        CAST(END_OF_GS_BUDGET_FY_Q as DATE) as END_OF_GS_BUDGET_FY_Q
from transform_data 
)
select * from type_data