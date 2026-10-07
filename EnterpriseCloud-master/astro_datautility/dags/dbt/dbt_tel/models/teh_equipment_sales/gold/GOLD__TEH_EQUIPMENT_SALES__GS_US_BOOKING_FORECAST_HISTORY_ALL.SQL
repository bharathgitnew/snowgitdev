{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='GS_US_BOOKING_FORECAST_HISTORY_ALL',
    	transient=false
) }}

WITH ref_cte_CALENDARDATE as (
    select * from {{ source('STATIC_OBJECTS', 'CALENDARDATE') }}
),

ref_cte_GS_US_BOOKING_FORECAST as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_FORECAST') }}
),

ref_cte_GS_US_BOOKING_FORECAST_HISTORY_LEGACY as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_FORECAST_HISTORY_LEGACY') }}
),



source_data as (
SELECT

	Sales_Customer_Group                                            AS SALES_ACCOUNT,

	''                                                              AS SALES_REGION,

	BU,

    BU_GROUP,

    BU_TYPE,

    SUB_BU,

	CUSTOMER_NAME                                                   AS SOLD_TO_PARTY,

	END_USER_NAME                                                   AS END_USER,

	FAB,

	SO                                                              AS SALES_ORDER_NO,

    CASE WHEN CATEGORY LIKE 'Modification%' THEN 'Modification' 

        WHEN CATEGORY = 'Option' THEN 'Option' 

        ELSE 'Equipment' END                                        AS SALES_CATEGORY_GROUP,

	CATEGORY                                                        AS SALES_CATEGORY,

	BACK_UP                                                         AS IS_PLACEHOLDER,

    PRODUCT_NAME,

	SN                                                              AS SERIAL_NO,

    DATE_FROM_PARTS(SPLIT_PART(GS_BOOKING_MONTH,'-',1), SPLIT_PART(GS_BOOKING_MONTH,'-',2),1) AS BOOKING_MONTH,

	TO_NUMBER(BOOK_AMOUNT,38,0)                                     AS BOOKING_AMOUNT,

	QTY                                                             AS QUANTITY,

	SALES_DATE,

	LOAN_FLAG                                                       AS IS_LOANER,

	CASE WHEN CST_FLAG = 1 THEN 'CST'

        WHEN CST_FLAG = 2 THEN 'Shipment'

        WHEN CST_FLAG = 3 THEN 'Other'

        WHEN CST_FLAG = 0 THEN NULL

        ELSE NULL END                                               AS REVENUE_RECOGNITION_CRITERIA,

	CASE WHEN CST_FLAG = 1 THEN 'CST'

        WHEN CST_FLAG = 2 THEN 'Ship'

        WHEN CST_FLAG = 3 THEN 'Other'

        WHEN CST_FLAG = 0 THEN NULL

        ELSE NULL END                                               AS REVENUE_RECOGNITION_CRITERIA_SHORT,

	REPORT_LOAD_DATE                                                AS DATA_SNAPSHOT,

	'Forecast'                                                      AS DATA_TYPE,

	''                                                              AS BU_CODE,

	ORIGINAL_BU_CODES                                               AS SUB_BU_CODE,

	''                                                              AS ORDER_TYPE_CODE,

	CUSTOMER_CODE                                                   AS SOLD_TO_PARTY_CODE,

	''                                                              AS END_USER_CODE_MIXED,

	END_USER_CODE                                                   AS _5_DIGIT_END_USER_CODE,

	''                                                              AS END_USER_CODE,

    CommonDate1.FISCAL_YEAR_BEGINNING_DATE                          AS Beginning_of_Current_FY,

    CommonDate1.FISCAL_YEAR_ENDING_DATE                             AS End_of_Current_FY,

	CommonDate1.FISCAL_HALF_YEAR_BEGINNING_DATE                     AS Beginning_of_Current_FY_Half,

	CommonDate1.FISCAL_HALF_YEAR_ENDING_DATE                        AS End_of_Current_FY_Half,

	CommonDate1.FISCAL_QUARTER_BEGINNING_DATE                       AS Beginning_of_Current_FY_Q,

	CommonDate1.FISCAL_QUARTER_ENDING_DATE                          AS End_of_Current_FY_Q,

    DATEADD('year', 1, Beginning_of_Current_FY)                     AS Beginning_of_Next_FY,

	DATEADD('year', 1, End_of_Current_FY)                           AS End_of_Next_FY,

	DATEADD('month', 6, Beginning_of_Current_FY_Half)               AS Beginning_of_Next_FY_Half,

	DATEADD('month', 6, End_of_Current_FY_Half)                     AS End_of_Next_FY_Half,

	DATEADD('month', 3, Beginning_of_Current_FY_Q)                  AS Beginning_of_Next_FY_Q,

	DATEADD('month', 3, End_of_Current_FY_Q)                        AS End_of_Next_FY_Q,

	DATEADD('year', -2, Beginning_of_Current_FY)                    AS Beginning_of_2_FY_Ago,

	DATEADD('year', 2, End_of_Current_FY)                           AS End_of_2_FY_Ahead,

	BOOKING_MONTH                                                   AS GS_FORECAST_FK_DATE,

	CommonDate.fiscal_year_short_text                               AS GS_Forecast_FY,

    CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT                 AS GS_Forecast_FY_Half,

    CommonDate.fiscal_year_quarter_short_text                       AS GS_Forecast_FY_Q,

    TO_DATE(CommonDate.quarter_beginning_date)                      AS Beginning_of_GS_Forecast_FY_Q,

    TO_DATE(CommonDate.quarter_ending_date)                         AS End_of_GS_Forecast_FY_Q

FROM ref_cte_GS_US_BOOKING_FORECAST_HISTORY_LEGACY

    LEFT OUTER JOIN ref_cte_CALENDARDATE CommonDate ON TO_DATE(CommonDate.CALENDAR_DATE) = GS_Forecast_FK_Date

    LEFT OUTER JOIN ref_cte_CALENDARDATE CommonDate1 ON TO_DATE(CommonDate1.CALENDAR_DATE) = CURRENT_DATE() 



UNION ALL

SELECT

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

	BOOKING_MONTH,

	TO_NUMBER(BOOKING_AMOUNT,38,0)      AS BOOKING_AMOUNT,

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

	END_OF_GS_FORECAST_FY_Q

FROM ref_cte_GS_US_BOOKING_FORECAST

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
        END_OF_GS_FORECAST_FY_Q
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
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(BOOKING_AMOUNT as NUMBER(38,0)) as BOOKING_AMOUNT,
        CAST(QUANTITY as NUMBER(38,10)) as QUANTITY,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(REVENUE_RECOGNITION_CRITERIA as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA,
        CAST(REVENUE_RECOGNITION_CRITERIA_SHORT as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_SHORT,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_TYPE as VARCHAR(16777216)) as DATA_TYPE,
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
        CAST(GS_FORECAST_FK_DATE as DATE) as GS_FORECAST_FK_DATE,
        CAST(GS_FORECAST_FY as VARCHAR(16777216)) as GS_FORECAST_FY,
        CAST(GS_FORECAST_FY_HALF as VARCHAR(16777216)) as GS_FORECAST_FY_HALF,
        CAST(GS_FORECAST_FY_Q as VARCHAR(16777216)) as GS_FORECAST_FY_Q,
        CAST(BEGINNING_OF_GS_FORECAST_FY_Q as DATE) as BEGINNING_OF_GS_FORECAST_FY_Q,
        CAST(END_OF_GS_FORECAST_FY_Q as DATE) as END_OF_GS_FORECAST_FY_Q
from transform_data 
)
select * from type_data