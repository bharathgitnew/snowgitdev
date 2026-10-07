{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='PURCHASE_ORDERS',
        tags=["finance"],
    	transient=false
) }} 

with return_rate_of_items as ( 
    SELECT
  purchaseorderidkey,
  SUM(
    numberconfirmedrejected + numberconfirmedsubstituted + numberconfirmedbackordered
  ) / SUM(quantity) AS return_rate
FROM
  {{ref('SILVER__TEH_PROCUREMENT__PURCHASEORDER_LINEITEM')}}
WHERE
  numberconfirmedrejected > 0
  OR numberconfirmedsubstituted > 0
  OR numberconfirmedbackordered > 0
  group by 1
),
transform_data as (
    select 
    distinct
      '{{ invocation_id }}' AS _AUDIT_LOG_ID,
      SHA2('HASH_ME') AS _ROW_HASH, -- ADDS COLUMN TO TABLE ON FULL REFRESH.
    ph.purchaseorderid,
    ph.purchaseorderidkey,
    ph.supplier,
    ph.suppliercode,
    ph.companycode,
    ph.realmname,
    ph.ordereddate,
    ph.approveddate,
    ph.invoiceddate,
    ph.receiveddate,
    ph.statusstring as po_status,
    ph.closed,
    ph.active,
    ph.ishistorical,

    --period breakdown
    date_trunc('MONTH', ph.ordereddate) as order_month,
    date_trunc('QUARTER', ph.ordereddate) as order_quarter,

    --location details
    pl.shiptocity,
    pl.shiptostate,
    pl.shiptocountrycode,

    --spend details
    ph.totalcostamount as total_cost,
    ph.totalcostcurrencycode,
    ph.amountinvoicedamount,
    ph.amountinvoicedamountinreportingcurrency as invoiced_Amount,
    ph.amountclearedamount as cleared_amount,
    ph.chargeamountamount as shippingfreightamount,
    ph.chargeamountcurrencycode,

    --accounting details
    ps.generalledgercode as gl_account,
    ps.costcentercode,
    ps.costcenterdescription,
    pl.commoditycodecode,
    --Return and backlog metrics
    -- pl.lineconfirmationstatus,
    pl.linetypecode,
    case when pl.numberconfirmedbackordered > 0 then TRUE
    else FALSE end as BACKORDER_STATUS,
    coalesce(r.return_rate,0) as return_rate,
    ABS(originalpriceamount - descriptionpriceamount) as total_price_difference,
    pl.basepriceamount,
    pl.vatamountamount,
    pl.taxamountamount
    from {{ref('SILVER__TEH_PROCUREMENT__PURCHASEORDER_HEADER')}} AS ph
    left JOIN {{ref('SILVER__TEH_PROCUREMENT__PURCHASEORDER_LINEITEM')}} AS pl ON ph.purchaseorderidkey = pl.purchaseorderidkey 
    left join {{ref('SILVER__TEH_PROCUREMENT__PURCHASEORDER_SPLITACCOUNTING')}} as ps on pl.purchaseorderidkey =ps.purchaseorderidkey and pl.purchaseorderlineitemkey= ps.purchaseorderlineitemkey
    left join return_rate_of_items r on r.purchaseorderidkey = ph.purchaseorderidkey
)
select * 
from transform_data