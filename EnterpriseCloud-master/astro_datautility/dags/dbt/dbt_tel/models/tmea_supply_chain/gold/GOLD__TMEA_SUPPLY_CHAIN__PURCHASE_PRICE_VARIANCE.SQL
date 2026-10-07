{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='PURCHASE_PRICE_VARIANCE',
    	transient=false
) }}

WITH ref_cte_ACCOUNTING_DOCUMENT_HEADER as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__ACCOUNTING_DOCUMENT_HEADER') }}
),

ref_cte_ACCOUNTING_DOCUMENT_SEGMENT as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__ACCOUNTING_DOCUMENT_SEGMENT') }}
),

ref_cte_MATERIAL_DESCRIPTIONS as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }}
),

ref_cte_MATERIAL_VALUATION as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }}
),

ref_cte_PURCHASING_DOCUMENT_HEADER as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_DOCUMENT_HEADER') }}
),

ref_cte_PURCHASING_DOCUMENT_ITEM as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_DOCUMENT_ITEM') }}
),

ref_cte_PURCHASING_GROUPS as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_GROUPS') }}
),

main_ouput as(SELECT
    BKPF.accounting_document_number,
    BKPF.fiscal_year,
    BKPF.document_type,
    BSEG.POSTING_KEY,
    BSEG.price_control_indicator,
    BKPF.document_date_in_document,
    BKPF.posting_date_in_the_document,
    BSEG.cost_center,
    CAST (BSEG.amount_in_local_currency as NUMBER(38,2)) as amount_in_local_currency,
    BSEG.general_ledger_account,
    BSEG.material_number,
    MAKT.material_description,
    BSEG.quantity,
    BSEG.profit_center,
    BSEG.debit_credit_indicator,
    CAST (BSEG.amount_in_document_currency as NUMBER(38,2)) as amount_in_document_currency,
    EKKO.supplying_vendor,
    EKKO.purchasing_document_number,
    EKKO.purchasing_group,
    EKKO.purchasing_organization,
    EKKO.vendors_account_number,
    EKPO.denominator_conv_of_order_price_unit_to_order_unit,
    EKPO.numerator_conv_order_price_unit_to_order_unit,
    EKPO.order_price_unit,
    EKPO.purchase_order_quantity,
    EKPO.net_price_in_purchasing_document,
    EKPO.purchase_order_unit_of_measure,
    EKPO.numerator_for_conv_of_order_unit_to_base_unit,
    CAST (standard_price as NUMBER(38,2)) as standard_price,
    storage_location,
    description_of_purchasing_group,
    case when debit_credit_indicator = 'H' then CAST (amount_in_local_currency *-1 as NUMBER(38,2)) 
        else CAST(amount_in_local_currency as NUMBER(38,2)) end as PPV

from ref_cte_ACCOUNTING_DOCUMENT_HEADER as BKPF
    left join ref_cte_ACCOUNTING_DOCUMENT_SEGMENT as BSEG
        on BSEG.accounting_document_number = BKPF.accounting_document_number
        and BSEG.fiscal_year = BKPF.fiscal_year

    left join ref_cte_PURCHASING_DOCUMENT_HEADER as EKKO
        on BSEG.purchasing_document_number = EKKO.purchasing_document_number

    left join ref_cte_PURCHASING_DOCUMENT_ITEM as EKPO
        on BSEG.purchasing_document_number = EKPO.purchasing_document_number and
        BSEG.item_number_of_purchasing_document = EKPO.item_number_of_purchasing_document

    left join ref_cte_MATERIAL_DESCRIPTIONS as MAKT
        on MAKT.material_number =BSEG.material_number

    left join ref_cte_MATERIAL_VALUATION as MBEW
        on MBEW.material_number = BSEG.material_number

    left join ref_cte_PURCHASING_GROUPS as T024
        on T024.purchasing_group = EKKO.purchasing_group
        where T024.SPOOL_OUTPUT_DEVICE = 'EMAI'
        and MBEW.valuation_area = '0010'
),

source_data as (
SELECT distinct * from main_ouput 
    where posting_date_in_the_document >= '2020-01-01'
    and general_ledger_account= '0000530200'

    order by posting_date_in_the_document desc),

transform_data as (
select 
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	 SHA2('hash_me') as _ROW_HASH,
	ACCOUNTING_DOCUMENT_NUMBER,
	FISCAL_YEAR,
	DOCUMENT_TYPE,
	POSTING_KEY,
	PRICE_CONTROL_INDICATOR,
	DOCUMENT_DATE_IN_DOCUMENT,
	POSTING_DATE_IN_THE_DOCUMENT,
	COST_CENTER,
	AMOUNT_IN_LOCAL_CURRENCY,
	GENERAL_LEDGER_ACCOUNT,
	MATERIAL_NUMBER,
	MATERIAL_DESCRIPTION,
	QUANTITY,
	PROFIT_CENTER,
	DEBIT_CREDIT_INDICATOR,
	AMOUNT_IN_DOCUMENT_CURRENCY,
	SUPPLYING_VENDOR,
	PURCHASING_DOCUMENT_NUMBER,
	PURCHASING_GROUP,
	PURCHASING_ORGANIZATION,
	VENDORS_ACCOUNT_NUMBER,
	DENOMINATOR_CONV_OF_ORDER_PRICE_UNIT_TO_ORDER_UNIT,
	NUMERATOR_CONV_ORDER_PRICE_UNIT_TO_ORDER_UNIT,
	ORDER_PRICE_UNIT,
	PURCHASE_ORDER_QUANTITY,
	NET_PRICE_IN_PURCHASING_DOCUMENT,
	PURCHASE_ORDER_UNIT_OF_MEASURE,
	NUMERATOR_FOR_CONV_OF_ORDER_UNIT_TO_BASE_UNIT,
	STANDARD_PRICE,
	STORAGE_LOCATION,
	DESCRIPTION_OF_PURCHASING_GROUP,
	PPV
from source_data
),

type_data as (
select
	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
	CAST(ACCOUNTING_DOCUMENT_NUMBER as VARCHAR(16777216)) as ACCOUNTING_DOCUMENT_NUMBER,
	CAST(FISCAL_YEAR as VARCHAR(16777216)) as FISCAL_YEAR,
	CAST(DOCUMENT_TYPE as VARCHAR(16777216)) as DOCUMENT_TYPE,
	CAST(POSTING_KEY as VARCHAR(16777216)) as POSTING_KEY,
	CAST(PRICE_CONTROL_INDICATOR as VARCHAR(16777216)) as PRICE_CONTROL_INDICATOR,
	CAST(DOCUMENT_DATE_IN_DOCUMENT as DATE) as DOCUMENT_DATE_IN_DOCUMENT,
	CAST(POSTING_DATE_IN_THE_DOCUMENT as DATE) as POSTING_DATE_IN_THE_DOCUMENT,
	CAST(COST_CENTER as VARCHAR(16777216)) as COST_CENTER,
	CAST(AMOUNT_IN_LOCAL_CURRENCY as NUMBER(38,10)) as AMOUNT_IN_LOCAL_CURRENCY,
	CAST(GENERAL_LEDGER_ACCOUNT as VARCHAR(16777216)) as GENERAL_LEDGER_ACCOUNT,
	CAST(MATERIAL_NUMBER as VARCHAR(16777216)) as MATERIAL_NUMBER,
	CAST(MATERIAL_DESCRIPTION as VARCHAR(16777216)) as MATERIAL_DESCRIPTION,
	CAST(QUANTITY as NUMBER(38,10)) as QUANTITY,
	CAST(PROFIT_CENTER as VARCHAR(16777216)) as PROFIT_CENTER,
	CAST(DEBIT_CREDIT_INDICATOR as VARCHAR(16777216)) as DEBIT_CREDIT_INDICATOR,
	CAST(AMOUNT_IN_DOCUMENT_CURRENCY as NUMBER(38,10)) as AMOUNT_IN_DOCUMENT_CURRENCY,
	CAST(SUPPLYING_VENDOR as VARCHAR(16777216)) as SUPPLYING_VENDOR,
	CAST(PURCHASING_DOCUMENT_NUMBER as VARCHAR(16777216)) as PURCHASING_DOCUMENT_NUMBER,
	CAST(PURCHASING_GROUP as VARCHAR(16777216)) as PURCHASING_GROUP,
	CAST(PURCHASING_ORGANIZATION as VARCHAR(16777216)) as PURCHASING_ORGANIZATION,
	CAST(VENDORS_ACCOUNT_NUMBER as VARCHAR(16777216)) as VENDORS_ACCOUNT_NUMBER,
	CAST(DENOMINATOR_CONV_OF_ORDER_PRICE_UNIT_TO_ORDER_UNIT as NUMBER(38,10)) as DENOMINATOR_CONV_OF_ORDER_PRICE_UNIT_TO_ORDER_UNIT,
	CAST(NUMERATOR_CONV_ORDER_PRICE_UNIT_TO_ORDER_UNIT as NUMBER(38,10)) as NUMERATOR_CONV_ORDER_PRICE_UNIT_TO_ORDER_UNIT,
	CAST(ORDER_PRICE_UNIT as VARCHAR(16777216)) as ORDER_PRICE_UNIT,
	CAST(PURCHASE_ORDER_QUANTITY as NUMBER(38,10)) as PURCHASE_ORDER_QUANTITY,
	CAST(NET_PRICE_IN_PURCHASING_DOCUMENT as NUMBER(38,10)) as NET_PRICE_IN_PURCHASING_DOCUMENT,
	CAST(PURCHASE_ORDER_UNIT_OF_MEASURE as VARCHAR(16777216)) as PURCHASE_ORDER_UNIT_OF_MEASURE,
	CAST(NUMERATOR_FOR_CONV_OF_ORDER_UNIT_TO_BASE_UNIT as NUMBER(38,10)) as NUMERATOR_FOR_CONV_OF_ORDER_UNIT_TO_BASE_UNIT,
	CAST(STANDARD_PRICE as NUMBER(38,10)) as STANDARD_PRICE,
	CAST(STORAGE_LOCATION as VARCHAR(16777216)) as STORAGE_LOCATION,
	CAST(DESCRIPTION_OF_PURCHASING_GROUP as VARCHAR(16777216)) as DESCRIPTION_OF_PURCHASING_GROUP,
	CAST(PPV as NUMBER(38,10)) as PPV
from transform_data 
)
select * from type_data