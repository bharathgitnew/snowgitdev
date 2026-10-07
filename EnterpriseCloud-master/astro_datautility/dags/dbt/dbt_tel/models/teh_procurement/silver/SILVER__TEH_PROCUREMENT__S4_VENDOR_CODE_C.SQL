{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='S4_VENDOR_CODE_C',
        tags=["finance"],
        transient=false
) }}

WITH sales_org_data AS (
    SELECT DISTINCT
        KUNNR,
        VKORG
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU021_KNVV') }}
    WHERE VKORG = '3200'
),
partner_function_data as (
    select distinct vbpa1.kunnr as customer_kunnr, vbpa2.kunnr as partner_number, vbpa2.parvw as partner_function
    from {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU047_VBPA') }} vbpa1
    join {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU047_VBPA') }} vbpa2 on vbpa1.vbeln = vbpa2.vbeln
    join {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU009_VBAK') }} vbak on vbpa1.vbeln = vbak.vbeln
    where vbak.vkorg = '3200'
),
final as (
    SELECT 
    kna1.KUNNR AS CUSTOMER_NUMBER,
    k.VKORG AS SALES_ORG,
    pf.partner_function as partner_function,
    pf.partner_number as partner_number,
    kna1.LAND1 AS COUNTRY_KEY,
    kna1.NAME1 AS NAME_1,
    kna1.NAME2 AS NAME_2,
    kna1.ORT01 AS CITY,
    kna1.PSTLZ AS POSTAL_CODE,
    kna1.REGIO AS REGION,
    kna1.MCOD1 AS SEARCH_TERM,
    kna1.STRAS AS STREET,
    kna1.TELF1 AS FIRST_TELEPHONE_NUMBER,
    kna1.TELFX AS FAX_NUMBER,
    kna1.XCPDK AS ONE_TIME_ACCOUNT,
    kna1.ADRNR AS ADDRESS,
    kna1.ERDAT AS CREATED_ON,
    kna1.ERNAM AS CREATED_BY,
    kna1.NAME3 AS NAME_3,
    kna1.NAME4 AS NAME_4,
    kna1.EXABL AS INDICATOR_UNLOADING_POINTS_EXIST,
    kna1.VSO_R_DPOINT AS COLLECTIVE_UNLOADING_POINT_FOR_VSO,
    kna1.KTOKD AS ACCOUNT_GROUP,
    kna1.SPRAS AS LANGUAGE_KEY,
    kna1.STCD1 AS TAX_NUMBER_1,
    kna1.STCD2 AS TAX_NUMBER_2
FROM {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU020_KNA1') }} kna1
JOIN sales_org_data k 
    ON kna1.KUNNR = k.KUNNR
    AND kna1.KTOKD = 'ZC00'
LEFT JOIN partner_function_data  pf ON kna1.kunnr = pf.customer_kunnr
ORDER BY kna1.KUNNR, pf.partner_function
),
transform_data as (
    SELECT 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') AS _ROW_HASH,
    CUSTOMER_NUMBER,
    SALES_ORG,
    partner_function,
    partner_number,
    COUNTRY_KEY,
    NAME_1,
    NAME_2,
    CITY,
    POSTAL_CODE,
    REGION,
    SEARCH_TERM,
    STREET,
    FIRST_TELEPHONE_NUMBER,
    FAX_NUMBER,
    ONE_TIME_ACCOUNT,
    ADDRESS,
    CREATED_ON,
    CREATED_BY,
    NAME_3,
    NAME_4,
    INDICATOR_UNLOADING_POINTS_EXIST,
    COLLECTIVE_UNLOADING_POINT_FOR_VSO,
    ACCOUNT_GROUP,
    LANGUAGE_KEY,
    TAX_NUMBER_1,
    TAX_NUMBER_2
    from final
),
type_data as ( 
    select 
    _AUDIT_LOG_ID,
    _ROW_HASH,
    CUSTOMER_NUMBER, 
    SALES_ORG,
    partner_function,
    partner_number,
    COUNTRY_KEY,
    NAME_1,
    NAME_2,
    CITY,
    POSTAL_CODE,
    REGION,
    SEARCH_TERM,
    STREET,
    FIRST_TELEPHONE_NUMBER,
    FAX_NUMBER,
    ONE_TIME_ACCOUNT,
    ADDRESS,
    CREATED_ON,
    CREATED_BY,
    NAME_3,
    NAME_4,
    INDICATOR_UNLOADING_POINTS_EXIST,
    COLLECTIVE_UNLOADING_POINT_FOR_VSO,
    ACCOUNT_GROUP,
    LANGUAGE_KEY,
    TAX_NUMBER_1,
    TAX_NUMBER_2
    from transform_data
) select * from type_data