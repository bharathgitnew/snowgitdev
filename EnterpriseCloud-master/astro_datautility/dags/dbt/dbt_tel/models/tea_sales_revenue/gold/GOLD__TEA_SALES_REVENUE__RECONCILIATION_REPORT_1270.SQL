{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite' ,
    alias='RECONCILIATION_REPORT_1270'
) }}

with src_ZSDT0167 as (
   select * from {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU250_ZSDT0167') }} 
)

,sales_order as (
        select * from {{ ref('SILVER__TEA_SALES_REVENUE__SALES_ORDER') }}
)
,business_partner as (
	select * from {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU020_KNA1') }}  
),
now_data as (
    select distinct REQUESTOR,REQUESTOR_EMP_NO,NCDR15
            from {{ ref('BRONZE__TEA_SALES_REVENUE__NOW_NOWDATA') }}
),
GLOBAL_EMP AS (
    SELECT DISTINCT SUPERVISOR_EMPLOYEE_ID,SUPERVISOR_NAME,EMPLOYEE_ID
            FROM {{ ref('SILVER__TEA_SALES_REVENUE__GLOBAL_EMPLOYEE') }}
)
,join_CTE as (

	select
        Z.ZOZZZ, 
        Z.ZDZZZ, 
        Z.ZDIZZ, 
        Z.ZSLZZ, 
        Z.ZLST, 
        Z.MATNR, 
        Z.ZRQZZ, 
        Z.ZBUZZ, 
        Z.ZGDOLS, 
        Z.ZTOEZ, 
        Z.ZCCIIM, 
        Z.ZSCWN, 
        Z.DEL_FLG, 
        Z.C_DATE, 
        Z.C_TIME, 
        Z.C_USER, 
        Z.C_PGM, 
        Z.U_DATE, 
        Z.U_TIME, 
        Z.U_USER, 
        Z.U_PGM,
        V.SALES_DOCUMENT_TYPE,
        V.NET_PRICE * Z.ZRQZZ AS NET_VALUE,
		B.NAME1 AS BUSINESS_PARTNER,
        NOW_DATA.REQUESTOR ,
        GLOBAL_EMP.SUPERVISOR_NAME,
	from src_ZSDT0167  Z
    left join sales_order V 
        on  Z.ZDZZZ = V.VBAK_SALES_DOCUMENT 
        and Z.ZDIZZ = V.SALES_DOCUMENT_ITEM_POSNR 
        and Z.ZOZZZ = V.VBAK_SALES_ORGANIZATION
	left join business_partner B
		on Z.ZCCIIM = B.KUNNR
    LEFT JOIN now_data 
        ON V.NCDR_NUMBER = NOW_DATA.NCDR15
        AND V.NCDR_REQUESTOR = NOW_DATA.REQUESTOR_EMP_NO    
    LEFT JOIN GLOBAL_EMP
        ON NOW_DATA.REQUESTOR_EMP_NO =GLOBAL_EMP.EMPLOYEE_ID    
	where Z.ZOZZZ = '3200' and  V.SALES_DOCUMENT_TYPE is not NULL

 
),
transform_data as (
    SELECT
        ZOZZZ::VARCHAR                AS	ORGANIZATION,
        SALES_DOCUMENT_TYPE::VARCHAR    AS  SALES_DOCUMENT_TYPE,
        ZDZZZ::VARCHAR	                AS	DOCUMENT_LENDING,
        ZDIZZ::VARCHAR	                AS	DOCUMENT_ITEM_LENDING,
        MATNR::VARCHAR	                AS	MATERIAL_NUMBER,
        ZCCIIM::VARCHAR	                AS	CUSTOMER_CODE_INVENTORY_IS_MANAGED_UNDER_IT,
        ZRQZZ::VARCHAR	                AS	REMAINING_QUANTITY,
        ZBUZZ::VARCHAR	                AS	BASE_UOM,
        TO_DATE(TRIM(ZGDOLS,'/Date()/'))::VARCHAR	                AS	GI_DATE_OF_LENDING_SO,        
        NET_VALUE::VARCHAR              AS  NET_VALUE,
		BUSINESS_PARTNER::VARCHAR 		AS 	BUSINESS_PARTNER,
        REQUESTOR::VARCHAR              AS  NCDR_REQUESTOR,
        SUPERVISOR_NAME::VARCHAR        AS  REQUESTOR_SUPERVISOR,
        '{{ invocation_id }}'   AS  _AUDIT_LOG_ID,
		SHA2('hash_me')        	AS  _ROW_HASH 
    from join_CTE
	),

type_data as(
	select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        ORGANIZATION,
        SALES_DOCUMENT_TYPE,
        DOCUMENT_LENDING,
        DOCUMENT_ITEM_LENDING,
        MATERIAL_NUMBER,
		CUSTOMER_CODE_INVENTORY_IS_MANAGED_UNDER_IT,
		REMAINING_QUANTITY,
        BASE_UOM,
        GI_DATE_OF_LENDING_SO,
        NET_VALUE,
        BUSINESS_PARTNER,
        NCDR_REQUESTOR,
        REQUESTOR_SUPERVISOR
		from transform_data
)

	select * from type_data