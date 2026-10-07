{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='ContractTotals'
) }}


with SourceData as (
SELECT DISTINCT
Contract_Distinct.CONTRACTNUMBER,
IFNULL(QRY_Contract_Totals.TOTALCONTRACTHOURS,0) AS CoveredHours,
IFNULL(CASE
 WHEN Contract_Distinct.CONTRACTTYPE = 'BND' THEN Contract_Distinct.ContractFlexHours
 WHEN Contract_Distinct.CONTRACTTYPE = 'FLX' THEN QRY_Contract_Totals.TOTALCONTRACTHOURS
 ELSE NULL
END,0) AS CoveredHours_Flex,
CoveredHours - IFNULL( QRY_Contract_TotalKronosHours.TOTALKRONOSHOURS ,0) as KronosDelta,
CoveredHours_Flex - IFNULL( QRY_Contract_TotalKronosHours.TOTALKRONOSHOURS_FLEX ,0) as KronosDelta_Flex,
IFNULL( QRY_Contract_TotalKronosHours.TOTALKRONOSHOURS ,0) as KronosHours,
IFNULL( QRY_Contract_TotalKronosHours.TOTALKRONOSHOURS_FLEX ,0) as KronosHours_Flex,
CASE
  WHEN IFNULL(QRY_Contract_Totals.TOTALCONTRACTHOURS,0) = 0 THEN 0
  WHEN IFNULL( QRY_Contract_TotalKronosHours.TOTALKRONOSHOURS ,0) = 0 THEN 0
  ELSE  QRY_Contract_TotalKronosHours.TOTALKRONOSHOURS  / QRY_Contract_Totals.TOTALCONTRACTHOURS
END as KronosPercentage,
CASE
  WHEN CoveredHours_Flex = 0 THEN 0
  WHEN IFNULL( QRY_Contract_TotalKronosHours.TOTALKRONOSHOURS_FLEX ,0) = 0 THEN 0
  ELSE  QRY_Contract_TotalKronosHours.TOTALKRONOSHOURS_FLEX  / CoveredHours_Flex
END as KronosPercentage_Flex,
CoveredHours - IFNULL(QRY_Contract_TSRHourTotals.TSRHours,0) as TSRDelta,
CoveredHours_Flex - IFNULL(QRY_Contract_TSRHourTotals.TSRHours,0) as TSRDelta_Flex,
IFNULL(QRY_Contract_TSRHourTotals.TSRHOURS,0) as TSRHours,
CASE
  WHEN IFNULL(CoveredHours,0) = 0 THEN 0
  WHEN IFNULL(QRY_Contract_TSRHourTotals.TSRHours,0) = 0 THEN 0
  ELSE QRY_Contract_TSRHourTotals.TSRHours / CoveredHours
END as TSRPercentage,
CASE
  WHEN CoveredHours_Flex = 0 THEN 0
  WHEN IFNULL(QRY_Contract_TSRHourTotals.TSRHours,0) = 0 THEN 0
  ELSE QRY_Contract_TSRHourTotals.TSRHours / CoveredHours_Flex
END as TSRPercentage_Flex,
IFNULL(QRY_Contract_Totals.TOTALCONTRACTAMOUNT,0) as TotalContractAmount
FROM
{{ ref('COMMON__BAAN__CONTRACT_DISTINCT') }} Contract_Distinct
LEFT OUTER JOIN (
SELECT
  ContractNumber
  ,SUM(Amount) AS TotalContractAmount
  ,CASE WHEN ContractNumber = 'CN0002903' THEN 930 ELSE SUM(CoveredTime) END AS TotalContractHours
FROM {{ ref('COMMON__BAAN__CONTRACT') }}
GROUP BY ContractNumber
) QRY_Contract_Totals ON QRY_Contract_Totals.CONTRACTNUMBER =  Contract_Distinct.CONTRACTNUMBER
LEFT OUTER JOIN (
SELECT
    Contract_Number
   ,SUM(Finance_TSR_Hours) AS TSRHours
FROM {{ ref('COMMON__SHAREPOINT__SERVICECONTRACTSFLEXTSRS') }} 
GROUP BY Contract_Number
) QRY_Contract_TSRHourTotals ON Contract_Distinct.CONTRACTNUMBER =  QRY_Contract_TSRHourTotals.CONTRACT_NUMBER
LEFT OUTER JOIN (
SELECT
SO.Contract_No
,SUM(Timesheet.HoursCharged) AS TotalKronosHours
,SUM(CASE WHEN LEFT(SERVICEORDER,3) = 'FLX' THEN Timesheet.HoursCharged ELSE 0 END ) AS TotalKronosHours_Flex
FROM {{ ref('COMMON__KRONOS__TIMESHEET') }}  Timesheet
LEFT JOIN {{ ref('COMMON__BAAN__SERVICEORDER_DISTINCT') }} SO
ON Timesheet.ServiceOrder = SO.Service_Order_NO
AND SO.IsReportingHeader = 'Yes'
GROUP BY SO.Contract_No
) QRY_Contract_TotalKronosHours ON Contract_Distinct.CONTRACTNUMBER =  QRY_Contract_TotalKronosHours.CONTRACT_NO
)

,transform_data as (
   select 
      CONTRACTNUMBER,
      COVEREDHOURS,
      COVEREDHOURS_FLEX,
      KRONOSDELTA,
      KRONOSDELTA_FLEX,
      KRONOSHOURS,
      KRONOSHOURS_FLEX,
      KRONOSPERCENTAGE,
      KRONOSPERCENTAGE_FLEX,
      TSRDELTA,
      TSRDELTA_FLEX,
      TSRHOURS,
      TSRPERCENTAGE,
      TSRPERCENTAGE_FLEX,
      TOTALCONTRACTAMOUNT,
      '{{ invocation_id }}' AS AUDIT_LOG_ID
  from SourceData
)

,type_data as (
    SELECT
        CAST(CONTRACTNUMBER AS VARCHAR(16777216)) AS CONTRACTNUMBER,
        CAST(COVEREDHOURS AS NUMBER(38,10)) AS COVEREDHOURS,
        CAST(COVEREDHOURS_FLEX AS NUMBER(38,10)) AS COVEREDHOURS_FLEX,
        CAST(KRONOSDELTA AS NUMBER(38,12)) AS KRONOSDELTA,
        CAST(KRONOSDELTA_FLEX AS NUMBER(38,12)) AS KRONOSDELTA_FLEX,
        CAST(KRONOSHOURS AS NUMBER(38,12)) AS KRONOSHOURS,
        CAST(KRONOSHOURS_FLEX AS NUMBER(38,12)) AS KRONOSHOURS_FLEX,
        CAST(KRONOSPERCENTAGE AS NUMBER(38,12)) AS KRONOSPERCENTAGE,
        CAST(KRONOSPERCENTAGE_FLEX AS NUMBER(38,12)) AS KRONOSPERCENTAGE_FLEX,
        CAST(TSRDELTA AS NUMBER(38,10)) AS TSRDELTA,
        CAST(TSRDELTA_FLEX AS NUMBER(38,10)) AS TSRDELTA_FLEX,
        CAST(TSRHOURS AS NUMBER(38,10)) AS TSRHOURS,
        CAST(TSRPERCENTAGE AS NUMBER(38,12)) AS TSRPERCENTAGE,
        CAST(TSRPERCENTAGE_FLEX AS NUMBER(38,12)) AS TSRPERCENTAGE_FLEX,
        CAST(TOTALCONTRACTAMOUNT AS NUMBER(38,10)) AS TOTALCONTRACTAMOUNT,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID
    FROM transform_data
)

SELECT * from type_data