{{ config(
	materialized='incremental',
	incremental_strategy='insert_overwrite',
	alias='RTISSTROUBLE',
	transient=false
) }}

with ct as(
SELECT
    No AS "RTISS Number"
    ,'CT' AS BU
    ,Author
    ,CloseDate AS "Close Date"
    ,ContributionDivisionName AS "Contribution Division Name"
    ,CountryName AS Country
    ,CustomerName AS Customer
    ,Emergency AS Emergency
    ,LastReplyDate AS "Last Reply Date"
    ,MachineNo AS "Serial Number"
    ,MachineState AS "Machine Warranty Status"
    ,Model
    ,Module
    ,NCDRNo AS "NCDR Number"
    ,NeededReplyDate AS "Needed Reply Date"
    ,OpenDate AS "Open Date"
    ,Status
    ,Subject
    ,NULL AS "Occurrence Date"
    ,NULL AS Details
    ,NULL AS "Dept In Charge"
    ,NULL AS "Person In Charge"
    ,CONCAT('http://web.tkl.tel.com/rtiss/index.cfm?&RTISS_No=' , No) AS URL
FROM {{ source('LEGACYPROD1', 'LEGACY_USDW_CT') }}
),

sps as (
SELECT
    No AS "RTISS Number"
    ,'SPS' as BU
    ,Author
    ,CloseDate as "Close Date"
    ,ContributionDivisionName AS "Contribution Division Name"
    ,CountryName as Country
    ,CustomerName as Customer
    ,Emergency as Emergency
    ,LastReplyDate AS "Last Reply Date"
    ,MachineNo as "Serial Number"
    ,MachineState AS "Machine Warranty Status"
    ,Model
    ,Module
    ,NCDRNo as "NCDR Number"
    ,NeededReplyDate AS "Needed Reply Date"
    ,OpenDate AS "Open Date"
    ,Status
    ,Subject
    ,NULL AS "Occurrence Date"
    ,NULL AS Details
    ,NULL AS "Dept In Charge"
    ,NULL AS "Person In Charge"
    ,CONCAT('http://web.tkl.tel.com/tiss_swe/Index.cfm?TISS_No=', No) AS URL
FROM {{ source('LEGACYPROD1', 'LEGACY_USDW_SPS') }}
),

tps as(
SELECT
    RTISS_No AS "RTISS Number"
    ,BU
    ,Author
    ,CompletionDate AS "Close Date"
    ,NULL AS "Contribution Division Name"
    ,NULL AS Country
    ,CustomerName AS Customer
    ,NULL AS Emergency
    ,LASTUPDATEDAT AS "Last Reply Date"
    ,Mac_sn AS "Serial Number"
    ,MachineWarrantyStatus AS "Machine Warranty Status"
    ,ModelName AS Model
    ,ModuleName AS Module
    ,NCDRNo AS "NCDR Number"
    ,DueDate AS "Needed Reply Date"
    ,NULL AS "Open Date"
    ,Status
    ,Subject
    ,OccurrenceDate AS "Occurrence Date"
    ,Details
    ,DeptInCharge AS "Dept In Charge"
    ,PersonInCharge AS "Person In Charge"
    ,URL
FROM {{ ref('COMMON__RTISS__TPS') }}
),

source_data as (
select
    "RTISS Number"
    ,BU
    ,Author
    ,"Close Date"
    ,"Contribution Division Name"
    ,Country
    ,Customer
    ,Emergency
    ,"Last Reply Date"
    ,"Serial Number"
    ,"Machine Warranty Status"
    ,Model
    ,Module
    ,"NCDR Number"
    ,"Needed Reply Date"
    ,"Open Date"
    ,Status
    ,Subject
    ,"Occurrence Date"
    ,Details
    ,"Dept In Charge"
    ,"Person In Charge"
    ,URL
from ct
union all
select
    "RTISS Number"
    ,BU
    ,Author
    ,"Close Date"
    ,"Contribution Division Name"
    ,Country
    ,Customer
    ,Emergency
    ,"Last Reply Date"
    ,"Serial Number"
    ,"Machine Warranty Status"
    ,Model
    ,Module
    ,"NCDR Number"
    ,"Needed Reply Date"
    ,"Open Date"
    ,Status
    ,Subject
    ,"Occurrence Date"
    ,Details
    ,"Dept In Charge"
    ,"Person In Charge"
    ,URL
from sps
union all
select
    "RTISS Number"
    ,BU
    ,Author
    ,"Close Date"
    ,"Contribution Division Name"
    ,Country
    ,Customer
    ,Emergency
    ,"Last Reply Date"
    ,"Serial Number"
    ,"Machine Warranty Status"
    ,Model
    ,Module
    ,"NCDR Number"
    ,"Needed Reply Date"
    ,"Open Date"
    ,Status
    ,Subject
    ,"Occurrence Date"
    ,Details
    ,"Dept In Charge"
    ,"Person In Charge"
    ,URL
from tps
)
,
transform_data as (
select
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') as _ROW_HASH,
    "RTISS Number"
    ,BU
    ,Author
    ,"Close Date"
    ,"Contribution Division Name"
    ,Country
    ,Customer
    ,Emergency
    ,"Last Reply Date"
    ,"Serial Number"
    ,"Machine Warranty Status"
    ,Model
    ,Module
    ,"NCDR Number"
    ,"Needed Reply Date"
    ,"Open Date"
    ,Status
    ,Subject
    ,"Occurrence Date"
    ,Details
    ,"Dept In Charge"
    ,"Person In Charge"
    ,URL
from source_data
)

select * from transform_data