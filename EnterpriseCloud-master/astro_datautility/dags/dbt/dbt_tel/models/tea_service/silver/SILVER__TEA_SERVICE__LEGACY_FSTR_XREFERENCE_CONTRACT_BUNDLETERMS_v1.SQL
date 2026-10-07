{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='XREFERENCE_CONTRACT_BUNDLETERMS',
      meta = {
          'sunset': '2025-08-28'
      },
) }}

with source_data as (
    SELECT
        AMOUNT1,
        AMOUNT10,
        AMOUNT2,
        AMOUNT3,
        AMOUNT4,
        AMOUNT5,
        AMOUNT6,
        AMOUNT7,
        AMOUNT8,
        AMOUNT9,
        CONTRACTEFFECTIVEDATE,
        CONTRACTEXPIRYDATE,
        CONTRACTTERM1,
        CONTRACTTERM10,
        CONTRACTTERM2,
        CONTRACTTERM3,
        CONTRACTTERM4,
        CONTRACTTERM5,
        CONTRACTTERM6,
        CONTRACTTERM7,
        CONTRACTTERM8,
        CONTRACTTERM9,
        FLEXSUPPORTHOURS,
        INSTALLMENT_PERCENT_1,
        INSTALLMENT_PERCENT_10,
        INSTALLMENT_PERCENT_2,
        INSTALLMENT_PERCENT_3,
        INSTALLMENT_PERCENT_4,
        INSTALLMENT_PERCENT_5,
        INSTALLMENT_PERCENT_6,
        INSTALLMENT_PERCENT_7,
        INSTALLMENT_PERCENT_8,
        INSTALLMENT_PERCENT_9,
        NOOFFES,
        PRODUCTTYPE1,
        PRODUCTTYPE10,
        PRODUCTTYPE2,
        PRODUCTTYPE3,
        PRODUCTTYPE4,
        PRODUCTTYPE5,
        PRODUCTTYPE6,
        PRODUCTTYPE7,
        PRODUCTTYPE8,
        PRODUCTTYPE9,
        SEQUENCENUMBER,
        SERVICECONTRACT,
        STATUSDESCRIPTION,
        STATUSID
    FROM {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONTRACTMANAGEMENT_BUNDLECONTRACTTERMS') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY SERVICECONTRACT ORDER BY CONTRACTEFFECTIVEDATE DESC) = 1
),

transform_data as (
    SELECT 
        SERVICECONTRACT AS Contract_Number,
        CASE
            WHEN FLEXSUPPORTHOURS > 0 
            THEN 'Y'
            ELSE 'N'
        END AS Flex_Flag,  

        FLEXSUPPORTHOURS AS Flex_Hours,

        CASE
            WHEN CONTRACTTERM1 = 'FLX'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'FLX'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'FLX'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'FLX'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'FLX'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'FLX'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'FLX'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'FLX'
            THEN AMOUNT8   
            WHEN CONTRACTTERM9 = 'FLX'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'FLX'
            THEN AMOUNT10
        END AS FLX,

        CASE
            WHEN CONTRACTTERM1 = 'FUL'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'FUL'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'FUL'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'FUL'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'FUL'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'FUL'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'FUL'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'FUL'
            THEN AMOUNT8   
            WHEN CONTRACTTERM9 = 'FUL'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'FUL'
            THEN AMOUNT10
        END AS FUL,

        CASE
            WHEN CONTRACTTERM1 = 'OS2'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'OS2'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'OS2'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'OS2'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'OS2'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'OS2'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'OS2'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'OS2'
            THEN AMOUNT8
            WHEN CONTRACTTERM9 = 'OS2'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'OS2'
            THEN AMOUNT10
        END AS OS2,

        CASE
            WHEN CONTRACTTERM1 = 'OS4'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'OS4'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'OS4'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'OS4'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'OS4'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'OS4'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'OS4'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'OS4'
            THEN AMOUNT8
            WHEN CONTRACTTERM9 = 'OS4'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'OS4'
            THEN AMOUNT10
        END AS OS4,

        CASE
            WHEN CONTRACTTERM1 = 'OS8'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'OS8'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'OS8'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'OS8'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'OS8'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'OS8'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'OS8'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'OS8'
            THEN AMOUNT8
            WHEN CONTRACTTERM9 = 'OS8'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'OS8'
            THEN AMOUNT10
        END AS OS8,

        CASE
            WHEN CONTRACTTERM1 = 'PGR'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'PGR'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'PGR'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'PGR'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'PGR'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'PGR'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'PGR'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'PGR'
            THEN AMOUNT8
            WHEN CONTRACTTERM9 = 'PGR'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'PGR'
            THEN AMOUNT10
        END AS PGR,

        CASE
            WHEN CONTRACTTERM1 = 'PM'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'PM'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'PM'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'PM'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'PM'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'PM'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'PM'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'PM'
            THEN AMOUNT8
            WHEN CONTRACTTERM9 = 'PM'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'PM'
            THEN AMOUNT10
        END AS PM,

        CASE
            WHEN CONTRACTTERM1 = 'PRT'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'PRT'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'PRT'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'PRT'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'PRT'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'PRT'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'PRT'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'PRT'
            THEN AMOUNT8
            WHEN CONTRACTTERM9 = 'PRT'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'PRT'
            THEN AMOUNT10
        END AS PRT,

        CASE
            WHEN CONTRACTTERM1 = 'STC'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'STC'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'STC'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'STC'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'STC'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'STC'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'STC'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'STC'
            THEN AMOUNT8
            WHEN CONTRACTTERM9 = 'STC'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'STC'
            THEN AMOUNT10
        END AS STC,

        CASE
            WHEN CONTRACTTERM1 = 'TSP'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'TSP'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'TSP'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'TSP'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'TSP'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'TSP'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'TSP'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'TSP'
            THEN AMOUNT8
            WHEN CONTRACTTERM9 = 'TSP'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'TSP'
            THEN AMOUNT10
        END AS TSP,

        CASE
            WHEN CONTRACTTERM1 = 'TSS'
            THEN AMOUNT1
            WHEN CONTRACTTERM2 = 'TSS'
            THEN AMOUNT2
            WHEN CONTRACTTERM3 = 'TSS'
            THEN AMOUNT3
            WHEN CONTRACTTERM4 = 'TSS'
            THEN AMOUNT4
            WHEN CONTRACTTERM5 = 'TSS'
            THEN AMOUNT5
            WHEN CONTRACTTERM6 = 'TSS'
            THEN AMOUNT6
            WHEN CONTRACTTERM7 = 'TSS'
            THEN AMOUNT7
            WHEN CONTRACTTERM8 = 'TSS'
            THEN AMOUNT8
            WHEN CONTRACTTERM9 = 'TSS'
            THEN AMOUNT9
            WHEN CONTRACTTERM10 = 'TSS'
            THEN AMOUNT10
        END AS TSS,

        CONTRACTEFFECTIVEDATE AS Audit_Date
    FROM source_data 
),

type_data as (
    SELECT 
        CAST(Contract_Number AS VARCHAR(16777216)) AS Contract_Number,
        CAST(Flex_Flag AS VARCHAR(16777216)) AS Flex_Flag,
        CAST(FLX AS VARCHAR(16777216)) AS FLX,
        CAST(FUL AS VARCHAR(16777216)) AS FUL,
        CAST(OS2 AS VARCHAR(16777216)) AS OS2,
        CAST(OS4 AS VARCHAR(16777216)) AS OS4,
        CAST(OS8 AS VARCHAR(16777216)) AS OS8,
        CAST(PGR AS VARCHAR(16777216)) AS PGR,
        CAST(PM AS VARCHAR(16777216)) AS PM,
        CAST(PRT AS VARCHAR(16777216)) AS PRT,
        CAST(STC AS VARCHAR(16777216)) AS STC,
        CAST(TSP AS VARCHAR(16777216)) AS TSP,
        CAST(TSS AS VARCHAR(16777216)) AS TSS,
        cast(Audit_Date as DATE) as Audit_Date
    FROM transform_data
)

SELECT * FROM type_data