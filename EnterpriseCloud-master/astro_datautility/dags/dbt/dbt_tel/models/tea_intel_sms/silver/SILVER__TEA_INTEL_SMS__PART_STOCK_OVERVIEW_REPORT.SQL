{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='REPORTS_PART_STOCK_OVERVIEW_REPORT'
        
) }}


with nsdm_e_mard_agg as (
  select matbf     as matnr,
  werks,
  lgortsid as lgort,
  lbbsasid     as lbbsa,
  sobkz,
  sum(stockqtyl2)      as stock_qty,
  sum(STOCKVKWRTL2)    as stock_vkwrt,
  max(GJPERCURRPER)    as gjper_max,
  sum(CWM_STOCK_QTY_L2) as CWM_STOCK_QTY_L2
  from {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU103_MATDOC_EXTRACT') }}
  where stockindl2 = ''
    and (((sobkz = '' or sobkz = 'K')
          and (lbbsasid = '01' or lbbsasid = '02' or lbbsasid = '07' or lbbsasid = '08'))
    or   (sobkz = ''
          and (lbbsasid = '03' or lbbsasid = '04')))
  group by mandt, matbf, werks, lgortsid, lbbsasid, sobkz
),
--* PERFORM  F_GET_SL_STOCK Get from Storage Location Data for Material
Unrestricted_stock as ( select matnr,werks,lgort,
max(gjper_max) as gjper,
sum(case lbbsa when '01' then case sobkz when '' then stock_qty else 0 end else 0 end) as labst,
'X' as mdrue
from nsdm_e_mard_agg
group by  matnr, werks, lgort),
 
--PERFORM F_GET_BATCH_STOCK* Get data from Batch Stocks
Batch_stock as (
SELECT WERKS,
       LGORT,
       MATNR,
       sum(CLABS) as batch_stock,
       sum(CUMLM) as STOCK_TRANSFER
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU105_MCHB') }}
    where LVORM = 'false' 
  group by werks,lgort,matnr
),
--*   Get from Landing  & consignment Stock with Customer
Special_stock as (
SELECT MSKU.WERKS,
           MSKU.MATNR,
           MSKU.KUNNR,
           MSKU.SOBKZ,
           sum(MSKU.KULAB) as KULAB
      FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU110_MSKU') }} as MSKU
      WHERE   MSKU.SOBKZ = 'W'
  group by MSKU.WERKS,MSKU.MATNR,MSKU.KUNNR,MSKU.SOBKZ
),
-- Get from Sales Order Stock, stock info kept for specific sales order
SO_ORDER_STOCK as (SELECT WERKS,
           LGORT,
           MATNR,
           VBELN,
           POSNR,
           sum(KALAB) as KALAB
           FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU109_MSKA') }}
          group by WERKS,LGORT,MATNR,VBELN,POSNR
),
 
SO_ORDER_sum as (SELECT WERKS,
           LGORT,
           MATNR,
           sum(KALAB) as KALAB
           FROM SO_ORDER_STOCK
          group by WERKS,LGORT,MATNR
) ,
 
-- GR & PGI & Invoice
EKBE_GR as (
select EBELN,
  EBELP,
case when shkzg = 'S' then MENGE else menge * -1 end as GR_Qty
from {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU217_EKBE') }}
where BEWTP = 'E' and BWART in ('101','102') 
),
GR as (
select EBELN,
  EBELP,
  sum(GR_Qty) as gr
  from EKBE_GR 
  group by EBELN,EBELP
),
 
EKBE_Inv as (
select EBELN,
  EBELP,
case when shkzg = 'S' then bpmng else bpmng * -1 end as inv_Qty
from {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU217_EKBE') }}
where BEWTP = 'Q' 
),
Inv as (
select EBELN,
  EBELP,
  sum(inv_Qty) as inv
  from EKBE_Inv 
  group by EBELN,EBELP
),
 
 
EKBE_PGI as (

select EBELN,
EBELP,
case when shkzg = 'H' then MENGE else menge * -1 end as PGI_Qty
from {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU217_EKBE') }}
where BEWTP = 'U' and BWART in ('641','642','647','648') 
),
 
 
PGI as (
select
  EBELN,
  EBELP,
-- lgort,
-- lgort,
  sum(PGI_Qty) as PGI_qty
  from EKBE_PGI
  group by   EBELN,EBELP
-- ,lgort
),
 
EKET as (
  select
EBELN,
EBELP, 
sum(WAMNG) as WAMNG,--Issued Quantity
sum(MENGE) as menge,--Scheduled Quantity
sum(WEMNG) as WEMNG--Quantity of goods_dev received
from   {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU048_EKET') }}
group by EBELN,EBELP
),
 
--On_order_stock
C_IT_EKPO as (
  SELECT EKPO.WERKS,
       EKPO.LGORT,
       EKPO.MATNR,
       EKPO.EBELN,
       EKPO.EBELP,  
       EKPO.RESLO,
       EKKO.BSART,
       sum(EKET.WAMNG) as WAMNG,--Issued Quantity
       sum(EKET.MENGE) as menge,--Scheduled Quantity
       sum(EKET.WEMNG) as WEMNG,--Quantity of goods_dev received
       ZEROIFNULL(sum(gr.gr)) as gr ,--Quantity of goods_dev received
       zeroifnull(sum(inv.inv)) as inv,
       case when sum(EKET.MENGE) - zeroifnull(sum(inv.inv))  = 0 then 'X' else '' end as inv_flag,
       case when sum(EKET.MENGE) - ZEROIFNULL(sum(gr.gr))  = 0 then 'X' else '' end as del_flag
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU028_EKPO') }} as EKPO
    INNER JOIN eket as EKET
       ON EKET.EBELN = EKPO.EBELN
      AND EKET.EBELP = EKPO.EBELP
    left JOIN gr as gr
       ON gr.EBELN = EKPO.EBELN
      AND gr.EBELP = EKPO.EBELP
    left join inv as inv
      ON inv.EBELN = EKPO.EBELN
      AND inv.EBELP = EKPO.EBELP
    INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU027_EKKO') }} as EKKO ON EKKO.EBELN = EKPO.EBELN
where  EKKO.BSART <> 'ZP25' and EKPO.LOEKZ = '' and  EKPO.ELIKZ = 'false' 
  and matnr <> '' 
group by EKPO.WERKS,EKPO.LGORT,EKPO.MATNR,EKPO.EBELN,EKPO.EBELP,EKPO.RESLO,EKKO.BSART
),
 
 
--remove all the completed PO
C_IT_EKPO_n as ( select 
         WERKS,LGORT,MATNR,EBELN,EBELP,RESLO,BSART,WAMNG,menge,WEMNG,gr,inv,
                menge - gr as qty
--                case when gr > 0 then ( case when inv = menge then 0 else menge- gr end ) else menge end as qty
                from C_IT_EKPO 
                where inv_flag <> 'X' or del_flag <> 'X'
               ),
--
--LIT_EKPO_NOSTO as (
--select * from C_IT_EKPO_n where  BSART <> 'ZP26' ),
 
--NON STO 
LIT_EKES as(  SELECT a.BSART,EKES.EBELN,
           EKES.EBELP,
           EKES.ETENS,
           Sum(EKES.MENGE) as menge,
           LIPS.LGORT,
           LIKP.VBTYP
            from C_IT_EKPO_n as a 
--          FROM LIT_EKPO_NOSTO AS A 
           INNER JOIN 	{{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU050_EKES') }} as EKES ON EKES.EBELN = A.EBELN AND EKES.EBELP = A.EBELP
           INNER JOIN	{{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU013_LIPS') }} AS LIPS ON LIPS.VBELN = EKES.VBELN  AND LIPS.POSNR = EKES.VBELP
           INNER JOIN 	{{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU012_LIKP') }} as LIKP ON LIKP.VBELN = LIPS.VBELN   AND LIKP.VBTYP = '7'
           WHERE  EKES.EBTYP = 'LA' and BSART <> 'ZP26'
            AND EKES.VBELN <> ''
             AND EKES.MENGE > 0
          group by EKES.EBELN,EKES.EBELP, EKES.ETENS,LIPS.LGORT,LIKP.VBTYP,a.BSART
),
 
 
LIT_EKES_sum as (
select EBELN,
       EBELP,
       sum(Menge) as menge
  from LIT_EKES group by EBELN,EBELP
),
 
GIT_EKPO as ( select C_IT_EKPO.WERKS,C_IT_EKPO.LGORT,C_IT_EKPO.MATNR,C_IT_EKPO.EBELN,C_IT_EKPO.EBELP,C_IT_EKPO.RESLO,
             C_IT_EKPO.BSART,C_IT_EKPO.menge,
             C_IT_EKPO.gr as WEMNG,
             case when C_IT_EKPO.BSART = 'ZP26' then 0 else
             (case when  ZEROIFNULL(LIT_EKES_sum.MENGE) > 0 then ZEROIFNULL(LIT_EKES_sum.MENGE) - ZEROIFNULL(C_IT_EKPO.gr) else 0 end) end as TRANSIT, 
            case when C_IT_EKPO.BSART = 'ZP26' then (case when pgi.PGI_qty > 0 then 0 else C_IT_EKPO.Qty end) else C_IT_EKPO.Qty end as order_qty
from  C_IT_EKPO_n as C_IT_EKPO
left join  LIT_EKES_sum  as LIT_EKES_sum on LIT_EKES_sum.EBELN = C_IT_EKPO.EBELN and LIT_EKES_sum.EBELP  = C_IT_EKPO.EBELP 
left join  pgi  as pgi on pgi.EBELN = C_IT_EKPO.EBELN and pgi.EBELP  = C_IT_EKPO.EBELP 
),

 
LIT_ONSTO as (
SELECT ekpo.EBELN,
       ekpo.EBELP,
       EKPO.MATNR,
       EKPO.WERKS,
       EKPO.LGORT,
       EKET.MENGE,
       EKET.WAMNG,
       ZEROIFNULL(pgi.PGI_qty) as PGI_qty
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU028_EKPO') }} as EKPO 
    INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU048_EKET') }} as EKET
       ON EKET.EBELN = EKPO.EBELN             
      AND EKET.EBELP = EKPO.EBELP               
    INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU027_EKKO') }} as EKKO
       ON EKKO.EBELN = EKPO.EBELN
      left  JOIN pgi as pgi
       ON pgi.EBELN = EKPO.EBELN             
      AND pgi.EBELP = EKPO.EBELP 
    WHERE EKET.MENGE > 0
    AND EKKO.BSART IN ( 'ZP25' )
     AND EKPO.ELIKZ = 'false'  AND EKPO.LOEKZ = ''
),
 
 
GIT_EKPO_sum as (
select 
  WERKS,MATNR,LGORT,
  '' as KUNNR, 0 as  Unrestricted_stock, 0 as consg_stock,0 as allocated_stock,
   0 as sO_stock,0 as batch_stock,sum(order_qty) as Order_stock,
  sum(TRANSIT) as STOCK_IN_TRANSIT
   from GIT_EKPO
   group by WERKS,MATNR,LGORT
union
  select 
  WERKS,MATNR,LGORT,
  '' as KUNNR, 0 as  Unrestricted_stock, 0 as consg_stock,0 as allocated_stock,
   0 as sO_stock,0 as batch_stock,sum(menge)- sum(PGI_qty) as Order_stock,
    0 as STOCK_IN_TRANSIT
  from LIT_ONSTO 
   group by WERKS,MATNR,LGORT
),
 
Allocated_stock_so as (
SELECT VBAP.VBELN,
       VBAP.POSNR,
       vbak.AUART,
    case when vbak.AUART in ('ZP12','ZPR1','ZSR0') then  vbbe.kunnr else '' end as kunnr,
           VBBE.MATNR,
           VBBE.WERKS,
           VBBE.LGORT,
           sum(VBBE.VMENG) as BMENG
           FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU010_VBAP') }} as VBAP
           INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU009_VBAK') }} as VBAK ON VBAK.VBELN = VBAP.VBELN
           INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU233_VBBE') }} as VBBE ON VBBE.VBELN = VBAP.VBELN
                          AND VBBE.POSNR = VBAP.POSNR
           WHERE VBAK.AUART NOT IN ( 'ZSQT', 'ZSQU' )
           AND VBAP.ABGRU = ''
           AND VBBE.VMENG IS NOT NULL
           AND  ( VBAP.LFSTA is null or VBAP.LFSTA in ('A','B') )
           --AND VBAP.LFSTA <> 'C' 
           group by VBAP.VBELN,VBAP.POSNR,vbak.AUART,vbak.AUART,vbbe.kunnr,VBBE.MATNR,VBBE.WERKS,VBBE.LGORT
  union 
   SELECT VBAP.VBELN,
          VBAP.POSNR,
          vbak.AUART,
          case when vbak.AUART in ('ZP12','ZPR1','ZSR0') then  VBBE.kunnr else '' end as kunnr,
           VBBE.MATNR,
           VBBE.WERKS,
           VBBE.LGORT,
           sum(VBBE.VMENG) as BMENG
           FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU010_VBAP') }} as VBAP                  
           INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU009_VBAK') }}  as VBAK ON VBAK.VBELN = VBAP.VBELN
           inner JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU013_LIPS') }} as LIPS ON LIPS.VGBEL = VBAP.VBELN
                          AND LIPS.VGPOS = VBAP.POSNR
           INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU012_LIKP') }} as LIKP ON LIPS.VBELN = LIKP.VBELN
          left JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU233_VBBE') }} as VBBE ON VBBE.VBELN = LIPS.VBELN 
                         AND VBBE.POSNR = LIPS.POSNR
           WHERE
            VBAK.AUART NOT IN ( 'ZSQT', 'ZSQU' )
           AND VBAP.ABGRU = ''
           AND VBBE.VMENG IS NOT null
           AND LIPS.WBSTA <> 'C' 
  group by VBAP.VBELN,VBAP.POSNR, vbak.AUART,VBBE.kunnr,VBBE.MATNR,VBBE.WERKS,VBBE.LGORT
),
 
 
Allocated_stock_Po as (
  select  A.EBELN,A.EBELP,B.BSART,A.matnr,a.werks,a.lgort,sum(c.MNG02) as sch_qty,SUM(C.WAMNG),
  CASE WHEN sum(C.WAMNG) > 0  THEN ( CASE WHEN SUM(WEMNG) = SUM(C.WAMNG) THEN 0  END ) ELSE  Sum(c.MNG02-C.WAMNG) END AS MNG02,
  CASE WHEN sum(C.WAMNG) > 0 THEN   SUM(C.WAMNG) -SUM(WEMNG) ELSE 0  END AS TRANFER,
  A.RESLO  --added A.RESLO 3/7/2025
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU028_EKPO') }} AS A  
      left join  {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU027_EKKO') }} AS B
      ON B.EBELN = A.EBELN  
   INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU048_EKET') }} AS C  ON C.EBELN = A.EBELN          
     AND C.EBELP = A.EBELP 
   WHERE B.BSART IN ( 'ZP25','ZP26' )
    AND ( A.SPE_ABGRU = '' or A.SPE_ABGRU is NULL )
    AND C.MNG02 <> 0 
    AND A.ELIKZ = 'false'     AND A.LOEKZ = '' 
group by A.EBELN,A.EBELP,B.BSART,A.matnr,A.werks,A.lgort,A.RESLO   --added A.RESLO 3/7/2025
),
 
Allocated_stock_Po_sum as (
select A.EBELN,A.EBELP,A.BSART,a.matnr,a.werks,a.lgort,sum(a.sch_qty) AS SCHED_QTY,
ZEROIFNULL(suM(GR.GR)) AS gr ,ZEROIFNULL(sum(PGI.PGI_qty)) AS pgi,A.RESLO   --3/7/2025
from Allocated_stock_Po AS A
  left join gr as gr  ON GR.EBELN = a.EBELN  AND GR.EBELP = A.EBELP 
  left join pgi as pgi ON pgi .EBELN = a.EBELN  AND PGI.EBELP = A.EBELP  
  group by  A.EBELN,A.EBELP,a.BSART,a.matnr,a.werks,a.lgort,A.RESLO   --3/7/2025 
),
 
Allocated_stock_so_new as (SELECT
           VBAP.VBELN,
            vbak.AUART,
           VBAP.POSNR,
           VBAP.MATNR,
           VBAP.WERKS,
           VBAP.LGORT,
           VBAP.KBMENG,
           LIPS.LFIMG,
           LIPS.WBSTA,
           CASE WHEN LIPS.WBSTA IS NULL THEN 'X'
                ELSE '' END AS FLG
      FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU010_VBAP') }} as VBAP
    INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU009_VBAK') }} as VBAK ON VBAK.VBELN = VBAP.VBELN
      LEFT JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU013_LIPS') }} as LIPS
        ON LIPS.VGBEL = VBAP.VBELN
       AND to_number(LIPS.VGPOS) = to_number(VBAP.POSNR)
    WHERE ( VBAP.ABGRU = '' or vbap.ABGRU is null )      
   and exists ( SELECT VBEP.VBELN,VBEP.BMENG,EBAN.LOEKZ
                     FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU011_VBEP') }} as VBEP
                   inner JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU242_EBAN') }} EBAN
                     ON LTRIM(EBAN.BANFN,0) = LTRIM(VBEP.BANFN,0)
                   AND LTRIM(EBAN.BNFPO,0) = LTRIM(VBEP.BNFPO,0)
               WHERE to_number(VBEP.VBELN) = to_number(VBAP.VBELN)
                   AND to_number(VBEP.POSNR) = to_number(VBAP.POSNR)
                   AND VBEP.BMENG <> '' AND ( EBAN.LOEKZ is null or EBAN.LOEKZ  = '' ) ) 
      AND NOT EXISTS ( SELECT VBBE.VBELN
                         FROM {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU233_VBBE') }} as VBBE
                where       
                      VBBE.VBELE = VBAP.VBELN
                          AND to_number(VBBE.POSNE) = to_number(VBAP.POSNR)
                          AND to_number(VBBE.VMENG) = to_number(VBAP.KBMENG)
                          AND VBBE.VMENG > 0 )
),
 
 
Allocated_stock_so_Unique as (
select distinct VBELN,POSNR,AUART,KBMENG,MATNR,WERKS,LGORT,FLG
from Allocated_stock_so_new
),
 
Allocated_stock_so_sum as (
select VBELN,POSNR,AUART,WBSTA,
  case when WBSTA = 'C' then sum(LFIMG ) else 0 end as LV_BMENG,
  case when WBSTA <> 'C' then sum(LFIMG) else 0 end as LV_MENGE
  from Allocated_stock_so_new
  group by VBELN,POSNR,AUART,WBSTA
),
 
Allocated_stock_new as (
select 
ls.VBELN,ls.POSNR,ls.AUART,ls.MATNR,ls.WERKS,ls.LGORT,so.vbeln,so.POSNR,
  case when ls.FLG = ''  then ls.KBMENG - grp.LV_BMENG else KBMENG end as BMENG
  from Allocated_stock_so_Unique as LS
  left join Allocated_stock_so_sum as grp on ls.vbeln = grp.vbeln and ls.posnr = grp.POSNR
  left join Allocated_stock_so as so on ls.vbeln = so.vbeln and ls.posnr = so.POSNR
   where so.vbeln is null
),
allocated_stock_agg as (
select    'SO' as  PO_SO_TYPE, 
matnr,
werks,
kunnr,
--lgort,
case when kunnr <> '' then '' else lgort end as lgort,
sum(BMENG) as allocated_stock,
0 as transfer
from Allocated_stock_so
group by matnr,werks,kunnr, lgort
/*UNION
  SELECT 
     'PO' as  PO_SO_TYPE,
  matnr,werks,'' AS KUNNR,
  --lgort,  3/7/2025
  RESLO AS LGORT,
  CASE WHEN sum(PGI) > 0 THEN ( sum (SCHED_QTY) - sum(PGI)  ) ELSE  sum(SCHED_QTY)  END AS allocated_stock,
  sum(PGI)-sum(GR) as transfer
  from Allocated_stock_Po_sum
  group by matnr,werks,RESLO ----,lgort 3/7/2025  */
UNION
  SELECT 
     'PO' as  PO_SO_TYPE,
  matnr,werks,'' AS KUNNR,
  RESLO as lgort,
  CASE WHEN sum(PGI) > 0 THEN ( sum (SCHED_QTY) - sum(PGI)  ) ELSE  sum(SCHED_QTY)  END AS allocated_stock,
   case when BSART = 'ZP25' then    sum(PGI)-sum(GR) end   as transfer
--   sum(PGI)-sum(GR) as transfer
  from Allocated_stock_Po_sum
  group by matnr,werks,RESLO,BSART
union
  SELECT 
     'PO' as  PO_SO_TYPE,
  matnr,werks,'' AS KUNNR,
  lgort as lgort,
  0 AS allocated_stock,
   case when BSART = 'ZP26' then    sum(PGI)-sum(GR) end  as transfer
--  sum(PGI)-sum(GR) as transfer
  from Allocated_stock_Po_sum
  group by matnr,werks,LGORT,BSART  
union 
  select
   'SO_PENDING' as PO_SO_TYPE,
  matnr,
  werks,
   '' as  KUNNR,
  lgort,
sum(BMENG) as allocated_stock,
  0 as transfer
from  Allocated_stock_new 
  group by matnr,werks,lgort
),
 
 
allocated_stock as (
select  matnr,
  werks,
  KUNNR,
  lgort,
  sum(allocated_stock) as allocated_stock,
  sum(transfer) as transfer
  from allocated_stock_agg
  group by matnr,
  werks,
  KUNNR,
  lgort ),
 
 
U_IT_SUM  as ( 
--Unrestricted Stock
select WERKS ,
       MATNR ,
       LGORT ,
       ''  as KUNNR,
       labst as Unrestricted_stock,
       0 as consg_stock,0 as allocated_stock,0 as sO_stock,0 as batch_stock,0 as Order_stock,0 as STOCK_IN_TRANSIT,0 as TRANSFER
       from Unrestricted_stock 
       where Unrestricted_stock > 0
union  
--batch Stock
select st.WERKS ,
       st.MATNR ,
       st.LGORT ,
       ''  as KUNNR,
       0 as Unrestricted_stock,
       0 as consg_stock,
       0 as allocated_stock,
       0 as sO_stock,  
       batch_stock,
       0 as Order_stock,
  0 as STOCK_IN_TRANSIT,0 as TRANSFER
       from batch_stock as st
       where batch_stock > 0 
union
--Landing & Consignment Stock
  select 
     WERKS,
     MATNR,
     ''  as LGORT,
     KUNNR,
     0 as  Unrestricted_stock,
     KULAB as consg_stock,
     0 as allocated_stock,
     0 as sO_stock,
     0 as batch_stock,
     0 as Order_stock,
     0 as STOCK_IN_TRANSIT,0 as TRANSFER
     from Special_stock 
  where KULAB > 0
  union
----Sales order Stock 
   select WERKS,MATNR,LGORT,
  '' as KUNNR, 0 as  Unrestricted_stock, 0 as consg_stock,0 as allocated_stock,
     KALAB as sO_stock,0 as batch_stock,0 as Order_stock,0 as STOCK_IN_TRANSIT,0 as TRANSFER
  from SO_ORDER_sum
union 
----Order Stock &nTransit
  select 
  WERKS,MATNR,LGORT,
  '' as KUNNR, 0 as  Unrestricted_stock, 0 as consg_stock,0 as allocated_stock,
   0 as sO_stock,0 as batch_stock, Order_stock,STOCK_IN_TRANSIT,0 as TRANSFER
  from GIT_EKPO_sum 
--  where Order_stock > 0 
union
--allocated stock & Transfer
   select 
  WERKS,MATNR,LGORT,
  KUNNR, 0 as  Unrestricted_stock, 0 as consg_stock, allocated_stock,
   0 as sO_stock,0 as batch_stock, 0 as Order_stock,0 as STOCK_IN_TRANSIT,TRANSFER
  from allocated_stock 
),
U_IT_output as 
(
  select
    U_IT_SUM.WERKS,U_IT_SUM.MATNR,U_IT_SUM.LGORT,T001L.LGOBE,U_IT_SUM.KUNNR,
  sum(unrestricted_stock) as unrestricted,
  sum(consg_stock) as consg
  ,sum(allocated_stock) as allocated,
  sum(sO_stock) as SO_St,
  sum(batch_stock) as batch,
  sum(Order_stock) as or_stock,
  sum(STOCK_IN_TRANSIT) as SIT,
  sum(TRANSFER) as TRANS
  from U_IT_SUM as U_IT_SUM
   left join {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU080_T001L') }} as T001L on T001L.WERKS = U_IT_SUM.WERKS and T001L.LGORT = U_IT_SUM.LGORT
  group by U_IT_SUM.WERKS,U_IT_SUM.MATNR,U_IT_SUM.LGORT,U_IT_SUM.KUNNR,T001L.LGOBE
),
 
-- Get Vendor's account number from Purchasing Source List table
EORD as (
select EORD.WERKS,
         EORD.MATNR,
         EORD.LIFNR,
         BUT000.NAME_ORG1,
         EINE.APLFZ,
         eord.FLIFN
         from {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU234_EORD') }} AS EORD
INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU053_BUT000') }} as BUT000 on  BUT000.PARTNER =  EORD.LIFNR
      INNER JOIN  {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU074_EINA') }} as EINA on 
         EINA.LIFNR = EORD.LIFNR  AND EINA.MATNR = EORD.MATNR
    INNER JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU073_EINE') }} as EINE 
       ON EINE.INFNR = EINA.INFNR
WHERE EORD.FLIFN = 'true' and EINE.werks ='3200'
),
KNVV as (
  select KUNNR,ZZDWC from {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU021_KNVV') }}
where ZZDWC = '1' and vkorg = '3200'
),
A902 as (select SALES_ORGANIZATION,MATERIAL_NUMBER,CONDITION_AMOUNT_OR_PERCENTAGE_WHERE_NO_SCALE_EXISTS,CONDITION_UNIT_KONWA,
         CONDITION_PRICING_UNIT,CONDITION_UNIT_KMEIN
from  {{ ref('SILVER__TEA_INTEL_SMS__SAPH_PRICE_MATRIX') }} 
  where CONDITION = 'A902' and CONDITION_TYPE = 'ZP11' and CONDITION_TYPE_KONP = 'ZP11'
  and SALES_ORGANIZATION in ('3200','3300')
  and DELETION_INDICATOR_FOR_CONDITION_RECORD = 'false'
  and try_to_date(VALIDITY_START_DATE_OF_THE_CONDITION_RECORD,'YYYYMMDD') <= current_date
  and try_to_date(VALIDITY_END_DATE_OF_THE_CONDITION_RECORD,'YYYYMMDD') >= current_date
),
source_data as (
select output.WERKS as plant,
       output.MATNR as material_number,
       MARA.MAKTX as material_number_description,
       case when output.KUNNR <> '' then '' else output.LGORT end as Storage_location,
       case when output.KUNNR <> '' then '' else output.LGOBE end as Storage_location_name,
       output.KUNNR as SPEC_STOCK_PARTNER,
       case when output.KUNNR = '' then '' else BUT000.NAME_ORG1 end as SPEC_STOCK_PARTNER_NAME,
       substr(output.matnr,0,2) as Product_code,
       MARC.ZZSAAVA as Available_for_sale,
       MARA.ZZSCSI  as Specific_customer_sellable_indicator,
       mara.ZZFORC as Forecast_classification,
       EORD.LIFNR as Vendor,
       EORD.NAME_ORG1 as vendor_name,
       EORD.APLFZ as Delivery_time_days,
       MARC.ZZSLTR as Sales_lead_time_region,
       MARC.ZZSLTO as Sales_lead_time_Overseas,
       MARC.ZZAAUT as Alloc_Authority_Flag,
       MARA.MEINS  as Unit_of_measure,  
       MDMA.EISBE as Safety_stock,
       MDMA.MINBE as Reorder_Point,
       MDMA.MABST as Maximum_Stock_Level,
       A902.CONDITION_AMOUNT_OR_PERCENTAGE_WHERE_NO_SCALE_EXISTS as LIST_PRICE,
       A902.CONDITION_UNIT_KONWA as LIST_PRICE_CURRENCY,
       A902.CONDITION_PRICING_UNIT as Condition_pricing_unit,
       A902.CONDITION_UNIT_KMEIN as LIST_PRICE_UOM,
       MBEW.STPRS as Standard_cost,
       MBEW.PEINH as Standard_cost_Currency,
--       MBEW.MEINS as Standard_cost_UOM,
       case when output.KUNNR = '' then 'P'
       else (case when knvv.ZZDWC = 1 then 'C' else 'L'end) end Stock,
        ZEROIFNULL(case when substr(output.LGORT,4,1) <> '2' then 
        (case when mara.XCHPF = 'X' or mara.XCHPF = 'true' then output.Batch else 
        output.Unrestricted  end) end) as Unrestricted_Stock,
        ZEROIFNULL(case when substr(output.LGORT,4,1) = '2' then 
        (case when mara.XCHPF = 'X' or mara.XCHPF = 'true' then output.Batch else 
       output.Unrestricted end) end) as Quality_inpection_Stock,
       output.SO_St as sales_order_stock,
       Unrestricted_Stock + Quality_inpection_Stock + sales_order_stock as Total_stock_on_hand,
       output.or_stock as On_order_stock,
       output.SIT as Stock_in_transit,
       output.TRANS as Stock_in_transfer,
       Total_stock_on_hand + On_order_stock + Stock_in_transfer as Stock_total,
       case when Stock = 'C' then output.consg else 0 end as Customer_consignment_Qty,
       ZEROIFNULL(output.allocated) as Allocated_stock,
       --case when       Stock_total  - Allocated_stock else output.consg_stock  - Allocated_stock end as Effective_stock,
       Customer_consignment_Qty * A902.CONDITION_AMOUNT_OR_PERCENTAGE_WHERE_NO_SCALE_EXISTS  as Total_list_price_in_consignment,
       Customer_consignment_Qty * MBEW.STPRS  as Total_standard_cost_in_consignment,
        case when Stock = 'L' then output.consg else 0 end as  lending_stock_quanity,
       Total_stock_on_hand - Allocated_stock + Customer_consignment_Qty + lending_stock_quanity as EFFECTIVE_STOCK,
--       case when Stock = 'L' then output.land else 0 end as lending_stock_quanity,
       lending_stock_quanity * A902.CONDITION_AMOUNT_OR_PERCENTAGE_WHERE_NO_SCALE_EXISTS  as Total_list_price_in_lending_stock,
       lending_stock_quanity * MBEW.STPRS  as Total_standard_cost_in_lending_stock,
       case when  lending_stock_quanity = 0 and Customer_consignment_Qty  = 0 and Stock_in_transfer= 0 and  Stock_in_transit = 0 and On_order_stock = 0 and
       sales_order_stock = 0 and Quality_inpection_Stock = 0 and Unrestricted_Stock = 0 and Allocated_stock = 0 then '' else 'X' end as flag
       from U_IT_output as output
       left JOIN {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU053_BUT000') }} as BUT000  ON BUT000.PARTNER = output.KUNNR
      left join {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU026_MARC') }} as MARC on marc.matnr = output.MATNR and marc.werks = output.werks
      left join {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU017_MARA') }} as mara on mara.matnr = output.MATNR
      left join {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU106_MDMA') }} as MDMA on MDMA.MATNR = output.MATNR and MDMA.WERKS = output.WERKS and SUBSTR(MDMA.BERID,6,4) = output.lgort
      left join EORD as EORD on   EORD.MATNR = output.MATNR and EORD.WERKS = output.WERKS 
      left join A902 as A902 on output.werks = A902.SALES_ORGANIZATION and output.matnr = A902.material_number 
      left join KNVV as KNVV on output.KUNNR = KNVV.KUNNR 
      left join  {{ ref('BRONZE__TEA_INTEL_SMS__SAPH_SAP_US_MMT_EV_MBEW') }} as MBEW on output.matnr = mbew.matnr and output.werks = mbew.bwkey
  where ( output.werks = '3200' ) 
  and flag = 'X'
),
SourceDatafromCopper AS (
    SELECT
        PLANT,
        MATERIAL_NUMBER,
        MATERIAL_NUMBER_DESCRIPTION,
        STORAGE_LOCATION,
        STORAGE_LOCATION_NAME,
        SPEC_STOCK_PARTNER,
        SPEC_STOCK_PARTNER_NAME,
        CASE 
            WHEN SPEC_STOCK_PARTNER_NAME IS NULL OR LENGTH(SPEC_STOCK_PARTNER_NAME) = 0 THEN 'In Storage'
            WHEN STORAGE_LOCATION IS NULL OR LENGTH(STORAGE_LOCATION) = 0 THEN 'In Consignment'
            ELSE 'UNKNOWN'
        END AS EXPECTED_STATUS,
        CASE 
            WHEN SPEC_STOCK_PARTNER IS NULL OR LENGTH(SPEC_STOCK_PARTNER) = 0 THEN STORAGE_LOCATION
            WHEN STORAGE_LOCATION IS NULL OR LENGTH(STORAGE_LOCATION) = 0 THEN SPEC_STOCK_PARTNER
            ELSE 'UNKNOWN'
        END AS LOCATION,
        CASE 
            WHEN SPEC_STOCK_PARTNER IS NULL OR LENGTH(SPEC_STOCK_PARTNER) = 0 THEN STORAGE_LOCATION_NAME
            WHEN STORAGE_LOCATION IS NULL OR LENGTH(STORAGE_LOCATION) = 0 THEN SPEC_STOCK_PARTNER_NAME
            ELSE 'UNKNOWN'
        END AS LOCATION_NAME,
        CASE 
            WHEN UPPER(STORAGE_LOCATION) = 'A120' OR UPPER(STORAGE_LOCATION) = 'A530' THEN 'RDC'
            WHEN UPPER(STORAGE_LOCATION) = 'Z100' THEN 'Drop Ship'
            WHEN UPPER(STORAGE_LOCATION) LIKE 'A%' AND UPPER(STORAGE_LOCATION) NOT IN ('A120', 'A530') THEN 'Depot'
            WHEN UPPER(STORAGE_LOCATION) LIKE 'B%' THEN 'Regional Depot'
            WHEN UPPER(STORAGE_LOCATION_NAME) LIKE '%FCN%' THEN 'FCN'
            WHEN UPPER(STOCK) = 'L' THEN 'Loan'
            WHEN UPPER(STOCK) = 'C' THEN 'Consignment'
            ELSE 'Consignment In Transit'
        END AS SLOC_TYPE,
        PRODUCT_CODE,
        AVAILABLE_FOR_SALE,
        SPECIFIC_CUSTOMER_SELLABLE_INDICATOR,
        FORECAST_CLASSIFICATION,
        VENDOR,
        VENDOR_NAME,
        DELIVERY_TIME_DAYS,
        SALES_LEAD_TIME_REGION,
        SALES_LEAD_TIME_OVERSEAS,
        ALLOC_AUTHORITY_FLAG,
        UNIT_OF_MEASURE,
        SAFETY_STOCK,
        REORDER_POINT,
        MAXIMUM_STOCK_LEVEL,
        LIST_PRICE,
        LIST_PRICE_CURRENCY,
        CONDITION_PRICING_UNIT,
        LIST_PRICE_UOM,
        STANDARD_COST,
        STANDARD_COST_CURRENCY,
        STOCK,
        UNRESTRICTED_STOCK,
        QUALITY_INPECTION_STOCK,
        SALES_ORDER_STOCK,
        TOTAL_STOCK_ON_HAND,
        ON_ORDER_STOCK,
        STOCK_IN_TRANSIT,
        STOCK_IN_TRANSFER,
        STOCK_TOTAL,
        CUSTOMER_CONSIGNMENT_QTY,
        ALLOCATED_STOCK,
        TOTAL_LIST_PRICE_IN_CONSIGNMENT,
        TOTAL_STANDARD_COST_IN_CONSIGNMENT,
        LENDING_STOCK_QUANITY,
        EFFECTIVE_STOCK,
        TOTAL_LIST_PRICE_IN_LENDING_STOCK,
        TOTAL_STANDARD_COST_IN_LENDING_STOCK,
        FLAG
    from source_data
    QUALIFY ROW_NUMBER() OVER (PARTITION BY MATERIAL_NUMBER, LOCATION ORDER BY MATERIAL_NUMBER DESC NULLS FIRST) = 1
    and VENDOR_NAME NOT ILIKE '%DO NOT USE%' 
),
TYPE_DATA AS (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH ,
        PLANT,
        MATERIAL_NUMBER,
        MATERIAL_NUMBER_DESCRIPTION,
        EXPECTED_STATUS,
        LOCATION,
        LOCATION_NAME,
        SLOC_TYPE,
        STORAGE_LOCATION,
        STORAGE_LOCATION_NAME,
        SPEC_STOCK_PARTNER,
        SPEC_STOCK_PARTNER_NAME,
        PRODUCT_CODE,
        AVAILABLE_FOR_SALE,
        SPECIFIC_CUSTOMER_SELLABLE_INDICATOR,
        FORECAST_CLASSIFICATION,
        VENDOR,
        VENDOR_NAME,
        DELIVERY_TIME_DAYS,
        SALES_LEAD_TIME_REGION,
        SALES_LEAD_TIME_OVERSEAS,
        ALLOC_AUTHORITY_FLAG,
        UNIT_OF_MEASURE,
        SAFETY_STOCK,
        REORDER_POINT,
        MAXIMUM_STOCK_LEVEL,
        LIST_PRICE,
        LIST_PRICE_CURRENCY,
        CONDITION_PRICING_UNIT,
        LIST_PRICE_UOM,
        STANDARD_COST,
        STANDARD_COST_CURRENCY,
        STOCK,
        UNRESTRICTED_STOCK,
        QUALITY_INPECTION_STOCK,
        SALES_ORDER_STOCK,
        TOTAL_STOCK_ON_HAND,
        ON_ORDER_STOCK,
        STOCK_IN_TRANSIT,
        STOCK_IN_TRANSFER,
        STOCK_TOTAL,
        CUSTOMER_CONSIGNMENT_QTY,
        ALLOCATED_STOCK,
        TOTAL_LIST_PRICE_IN_CONSIGNMENT,
        TOTAL_STANDARD_COST_IN_CONSIGNMENT,
        LENDING_STOCK_QUANITY,
        EFFECTIVE_STOCK,
        TOTAL_LIST_PRICE_IN_LENDING_STOCK,
        TOTAL_STANDARD_COST_IN_LENDING_STOCK,
        FLAG
        from SourceDatafromCopper
),
TRANSFORM_DATA AS (
    SELECT 
      '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH ,
        PLANT,
        MATERIAL_NUMBER,
        MATERIAL_NUMBER_DESCRIPTION,
        EXPECTED_STATUS,
        LOCATION,
        LOCATION_NAME,
        SLOC_TYPE,
        STORAGE_LOCATION,
        STORAGE_LOCATION_NAME,
        SPEC_STOCK_PARTNER,
        SPEC_STOCK_PARTNER_NAME,
        PRODUCT_CODE,
        AVAILABLE_FOR_SALE,
        SPECIFIC_CUSTOMER_SELLABLE_INDICATOR,
        FORECAST_CLASSIFICATION,
        VENDOR,
        VENDOR_NAME,
        DELIVERY_TIME_DAYS,
        SALES_LEAD_TIME_REGION,
        SALES_LEAD_TIME_OVERSEAS,
        ALLOC_AUTHORITY_FLAG,
        UNIT_OF_MEASURE,
        SAFETY_STOCK,
        REORDER_POINT,
        MAXIMUM_STOCK_LEVEL,
        LIST_PRICE,
        LIST_PRICE_CURRENCY,
        CONDITION_PRICING_UNIT,
        LIST_PRICE_UOM,
        STANDARD_COST,
        STANDARD_COST_CURRENCY,
        STOCK,
        CAST(UNRESTRICTED_STOCK as FLOAT) AS UNRESTRICTED_STOCK,
        CAST(QUALITY_INPECTION_STOCK as FLOAT) AS QUALITY_INPECTION_STOCK,
        CAST(SALES_ORDER_STOCK as FLOAT) AS SALES_ORDER_STOCK,
        CAST(TOTAL_STOCK_ON_HAND as FLOAT) AS TOTAL_STOCK_ON_HAND,
        CAST(ON_ORDER_STOCK as FLOAT) AS ON_ORDER_STOCK,
        CAST(STOCK_IN_TRANSIT as FLOAT) AS STOCK_IN_TRANSIT,
        CAST(STOCK_IN_TRANSFER as NUMBER(38,10)) AS STOCK_IN_TRANSFER,
        CAST(STOCK_TOTAL as FLOAT) AS STOCK_TOTAL,
        CAST(CUSTOMER_CONSIGNMENT_QTY as FLOAT) AS CUSTOMER_CONSIGNMENT_QTY,
        CAST(ALLOCATED_STOCK as FLOAT) AS ALLOCATED_STOCK,
        CAST(TOTAL_LIST_PRICE_IN_CONSIGNMENT as FLOAT) AS TOTAL_LIST_PRICE_IN_CONSIGNMENT,
        CAST(TOTAL_STANDARD_COST_IN_CONSIGNMENT as FLOAT) AS TOTAL_STANDARD_COST_IN_CONSIGNMENT,
        CAST(LENDING_STOCK_QUANITY as FLOAT) AS LENDING_STOCK_QUANITY,
        CAST(EFFECTIVE_STOCK as FLOAT) AS EFFECTIVE_STOCK,
        CAST(TOTAL_LIST_PRICE_IN_LENDING_STOCK as FLOAT) AS TOTAL_LIST_PRICE_IN_LENDING_STOCK,
        CAST(TOTAL_STANDARD_COST_IN_LENDING_STOCK as FLOAT) AS TOTAL_STANDARD_COST_IN_LENDING_STOCK,
        FLAG
FROM TYPE_DATA
)
SELECT * FROM TRANSFORM_DATA