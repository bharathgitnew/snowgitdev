{{ config(
      materialized='view',
      alias='Thoughtspot_Calendar_Date',
      transient=false
) }}

with Source_Data AS
(
	SELECT *
    FROM {{ source('COMMON__DE_SAP_MASTER_DATA', 'CALENDAR_DATE') }}
    WHERE Year_Number >= 2010
)
, Transform_Data AS
(
	SELECT
     CALENDAR_DATE AS Date
    ,DAY_TEXT AS Day_Of_Week
    ,Month_Text AS Month
    ,Quarter_Short_Text AS Quarter
    ,Year_Text AS Year
    ,CASE WHEN DAY_OF_WEEK_NUMBER > 0 THEN DAY_OF_WEEK_NUMBER ELSE 7 END AS Day_Number_Of_Week
    ,Work_WEEK_OF_Month_NUMBER AS Week_Number_Of_Month
    ,Work_WEEK_OF_Quarter_NUMBER AS Week_Number_Of_Quarter
    ,Work_Week_Of_Year_Number AS Week_Number_Of_Year
    ,CASE WHEN is_Weekend = 'Yes' THEN 'TRUE' ELSE 'FALSE' END AS IS_Weekend
    ,Month_Year_Short_Text AS Monthly
    ,Quarter_Year_Text AS Quarterly
    ,Day_Of_Month_Number AS Day_Number_Of_Month
    ,Day_Of_Quarter_Number AS Day_Number_Of_Quarter
    ,Day_Of_Year_Number AS Day_Number_Of_Year
    ,Month_Of_Quarter_Number AS Month_Number_Of_Quarter
    ,Month_Of_Year_Number AS Month_Number_Of_Year
    ,Quarter_Of_Year_Number AS Quarter_Number_Of_Year
    ,Work_Week_Key AS Absolute_Week_Number
    ,Work_Week_Beginning_Date AS Start_Of_Week_Epoch
    ,DATEADD(day,1,Work_Week_Ending_Date)  AS End_Of_Week_Epoch
    ,Month_Key AS Absolute_Month_Number
    ,Month_Beginning_Date AS Start_Of_Month_Epoch
    ,DATEADD(day,1,Month_Ending_Date)  AS End_Of_Month_Epoch
    ,Quarter_Key AS Absolute_Quarter_Number
    ,Quarter_Beginning_Date AS Start_Of_Quarter_Epoch
    ,DATEADD(day,1,Quarter_Ending_Date)  AS End_Of_Quarter_Epoch
    ,Year_Key AS Absolute_Year_Number
    ,Year_Beginning_DATE AS Start_Of_Year_Epoch
    ,DATEADD(day,1,Year_Ending_Date)  AS End_Of_Year_Epoch
  from Source_Data
)
SELECT * FROM Transform_Data