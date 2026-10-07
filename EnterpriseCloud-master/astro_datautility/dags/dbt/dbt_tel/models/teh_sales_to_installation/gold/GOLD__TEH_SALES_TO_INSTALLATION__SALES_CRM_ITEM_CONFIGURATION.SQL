{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='merge',
    	alias='SALES_CRM_ITEM_CONFIGURATION',
    	unique_key=['OPPORTUNITY_ID'],
    	transient=false
) }} 

WITH SOURCE_DATA AS
(
     SELECT DISTINCT 
       TEL_SM_CRM_OPPORTUNITY_ID
     , SM_ACCOUNT_GROUP_NAMENAME
     , SM_CUSTOMER_TOOL_ID
     , TEL_SM_PROJECT_NO
     , SM_TEL_SO_NO
     , SM_SERIAL_NO
     , tel_sm_sales_district
     , tel_sm_cost_center_group_name
     , sm_account_name
     , sm_fab_line_name
     , tel_sm_model_name
     , tel_sm_order_type
     FROM {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__OPPORTUNITY') }}
), 

ACCOUNT as (
    select * from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__SALES_CRM_ACCOUNT') }}
),

DISTRICT as (
    select DISTINCT 
      sales_district_id
    , tel_com_sales_district AS sales_district
    from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__SALES_DISTRICT') }}
),

BUSINESS_UNIT as (
    select * from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__SALES_CRM_BUSINESS_UNIT') }}
),

FAB as (
    select * from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__SALES_CRM_FAB') }}
),

MODEL as (
    select * from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__SALES_CRM_MODEL') }}
),

ORDER_TYPE as (
    select * from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__SALES_CRM_ORDER_TYPE') }}
),

transform_data as (
    SELECT 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID
    , SHA2('hash_me') as _ROW_HASH
	, m.TEL_SM_CRM_OPPORTUNITY_ID AS OPPORTUNITY_ID
    , UPPER(m.SM_ACCOUNT_GROUP_NAMENAME) AS ACCOUNT
    , UPPER(accnt.SALES_ACCOUNT_TI) AS SALES_ACCOUNT  
    , UPPER(d.sales_district) AS SALES_DISTRICT     
    , UPPER(accnt.sales_region)          as SALES_REGION
    , accnt.account_name                 as END_USER
    , UPPER(fab.fab)                  AS FAB
    , bu.bu                                as BUSINESS_UNIT
    , bu.sub_bu                            as SUB_BU
    , UPPER(ot.ORDER_TYPE_GROUP)           as SALES_CATEGORY_GROUP 
    , UPPER(ot.ORDER_TYPE)                 as SALES_CATEGORY
    , m.SM_CUSTOMER_TOOL_ID                as CUSTOMER_TOOL_ID
    , model.model                          as MODEL
    , m.TEL_SM_PROJECT_NO                 AS PROJECT_NBR
    , m.SM_TEL_SO_NO                     AS SAP_SO_NBR
    , m.SM_SERIAL_NO                    AS SERIAL_NBR
    from SOURCE_DATA m 
    LEFT JOIN DISTRICT d
    ON m.tel_sm_sales_district = d.sales_district_id
    LEFT JOIN 
    BUSINESS_UNIT bu 
    ON m.tel_sm_cost_center_group_name = bu.BU_ID
    LEFT JOIN ACCOUNT accnt
    ON m.sm_account_name = accnt.account_id
    LEFT JOIN FAB 
    ON m.sm_fab_line_name = fab.fab_line_id
    LEFT JOIN MODEL
    ON m.tel_sm_model_name = model.model_id
    LEFT JOIN ORDER_TYPE ot
    ON m.tel_sm_order_type = ot.order_type_id
),
type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
        , CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
        , OPPORTUNITY_ID
        ,ACCOUNT,
        SALES_ACCOUNT,
        SALES_DISTRICT,
        SALES_REGION,
        END_USER,
        FAB,
        BUSINESS_UNIT,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        SUB_BU,
        MODEL,
        CUSTOMER_TOOL_ID,
        PROJECT_NBR
        , CAST(SAP_SO_NBR AS NUMBER(38,0)) AS SAP_SO_NBR
        ,SERIAL_NBR
        FROM transform_data
        --As per naoko Cole 2024.12.13
        WHERE SALES_DISTRICT || '-' || SALES_ACCOUNT IN 
        ('CHINA-INTEL', 'CHINA-TI', 	'EUROPE-GF/IBM', 'EUROPE-REGIONAL', 'EUROPE-TI', 'EUROPE-INTEL', 
    'EUROPE-MICRON', 'NORTH AMERICA-TI', 'NORTH AMERICA-INTEL', 'NORTH AMERICA-MICRON', 'NORTH AMERICA-REGIONAL', 	
    'NORTH AMERICA-GF/IBM', 'NORTH AMERICA-TSMC', 'NORTH AMERICA-SAMSUNG', 	
    'NORTH AMERICA-TEL GROUP', 	'SEA & OTHERS-TI', 	'SEA & OTHERS-INTEL', 	'SEA & OTHERS-MICRON'
)
)

SELECT * from type_data