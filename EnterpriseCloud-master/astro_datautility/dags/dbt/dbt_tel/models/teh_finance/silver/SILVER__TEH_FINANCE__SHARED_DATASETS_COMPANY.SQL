{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SHARED_DATASETS_COMPANY',
    unique_key = ['WORKDAY_COMPANY_ID',
    'BAAN_COMPANY_ID',
    'COMPANY_NAME',
    'COMPANY_SHORT_NAME']
) }}

with souce_data as
(
    SELECT
        MySkillsCompany.CompanyId AS WORKDAY_COMPANY_ID,
        MDMCompany.CompanyId AS BAAN_COMPANY_ID,
        MySkillsCompany.Name AS COMPANY_NAME,
        MySkillsCompany.ShortName AS COMPANY_SHORT_NAME,
        COALESCE ( MDMCompany.ShortName , MySkillsCompany.ShortName ) AS COMPANY_SHORT_NAME_BAAN,
        CASE MDMCompany.ActiveIndicator WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE NULL END AS BAAN_ACTIVE_INDICATOR,
        CASE WHEN MDMCompany.CompanyId IS NOT NULL THEN 'Yes' ELSE 'No' END AS IS_TUFA_COMPANY,
        CASE WHEN MySkillsCompany.CountryCode = 'USA' THEN 'Yes' ELSE 'No' END AS IS_USA_COMPANY,
        CAST ( NULL AS STRING ( 16777216 ) ) AS DW_CURRENT_INDICATOR,
        CAST ( NULL AS TIMESTAMP_NTZ ) AS DW_EFFECTIVE_DATETIME,
        CAST ( NULL AS TIMESTAMP_NTZ ) AS DW_EXPIRATION_DATETIME,
        CAST ( NULL AS STRING ( 16777216 ) ) AS DW_HASHVALUE_SCDTYPE1,
        CAST ( NULL AS STRING ( 16777216 ) ) AS DW_HASHVALUE_SCDTYPE2,
        CAST ( NULL AS TIMESTAMP_NTZ ) AS DW_INSERT_DATETIME,
        CAST ( NULL AS TIMESTAMP_NTZ ) AS DW_UPDATE_DATETIME,
        0 AS ERROR_FLAG,
        CAST('' AS VARCHAR(200)) AS ERROR_REASON,
        CAST('' AS VARCHAR(100)) AS ERROR_CODE,
        CAST(LOCALTIMESTAMP AS TIMESTAMP) AS RECORD_INSERT_TIMESTAMP,
        CAST('INSERT' AS VARCHAR(100)) AS OPERATION_TYPE,
        ROW_NUMBER() OVER (ORDER BY 1) AS SRC_ROW_NUMBER
        FROM
            {{ ref('SILVER__TEH_FINANCE__MYSKILLS_COMPANY') }} MySkillsCompany
        LEFT OUTER JOIN 
        (
                SELECT 
                    122 WorkdayCompanyId, 
                    200 AS BaanCompanyId
                UNION 
                SELECT 
                    101 WorkdayCompanyId, 
                    201 AS BaanCompanyId
                UNION 
                SELECT 
                    109 WorkdayCompanyId, 
                    202 AS BaanCompanyId
                UNION 
                SELECT 
                    123 WorkdayCompanyId, 
                    203 AS BaanCompanyId
                UNION 
                SELECT 
                    129 WorkdayCompanyId, 
                    204 AS BaanCompanyId
                UNION 
                SELECT 
                    119 WorkdayCompanyId, 
                    250 AS BaanCompanyId
                UNION 
                SELECT 
                    127 WorkdayCompanyId, 
                    260 AS BaanCompanyId
        ) QRY_CompanyIntersection 
            ON QRY_CompanyIntersection.WORKDAYCOMPANYID =  MySkillsCompany.CompanyId
        LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__MDM_COMPANY') }} MDMCompany 
            ON MDMCompany.CompanyId =  QRY_CompanyIntersection.BAANCOMPANYID
),
transform_data as 
(
    SELECT    
        WORKDAY_COMPANY_ID,
        BAAN_COMPANY_ID,
        COMPANY_NAME,
        COMPANY_SHORT_NAME,
        COMPANY_SHORT_NAME_BAAN,
        BAAN_ACTIVE_INDICATOR,
        IS_TUFA_COMPANY,
        IS_USA_COMPANY,
        DW_CURRENT_INDICATOR,
        DW_EFFECTIVE_DATETIME,
        DW_EXPIRATION_DATETIME,
        DW_HASHVALUE_SCDTYPE1,
        DW_HASHVALUE_SCDTYPE2,
        DW_INSERT_DATETIME,
        DW_UPDATE_DATETIME,
        ERROR_FLAG,
        ERROR_REASON,
        ERROR_CODE,
        RECORD_INSERT_TIMESTAMP,
        OPERATION_TYPE,
        SRC_ROW_NUMBER,
        CURRENT_DATE() AS SNAPSHOT_DATE,
        '{{ invocation_id }}' AS Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash -- Adds column to table on full refresh.
    FROM souce_data
),
type_data as
(
    SELECT
        CAST(WORKDAY_COMPANY_ID as VARCHAR(16777216)) as WORKDAY_COMPANY_ID,
        CAST(BAAN_COMPANY_ID as VARCHAR(16777216)) as BAAN_COMPANY_ID,
        CAST(COMPANY_NAME as VARCHAR(16777216)) as COMPANY_NAME,
        CAST(COMPANY_SHORT_NAME as VARCHAR(16777216)) as COMPANY_SHORT_NAME,
        CAST(COMPANY_SHORT_NAME_BAAN as VARCHAR(16777216)) as COMPANY_SHORT_NAME_BAAN,
        CAST(BAAN_ACTIVE_INDICATOR as VARCHAR(16777216)) as BAAN_ACTIVE_INDICATOR,
        CAST(IS_TUFA_COMPANY as VARCHAR(16777216)) as IS_TUFA_COMPANY,
        CAST(IS_USA_COMPANY as VARCHAR(16777216)) as IS_USA_COMPANY,
        CAST(DW_CURRENT_INDICATOR as VARCHAR(16777216)) as DW_CURRENT_INDICATOR,
        CAST(DW_EFFECTIVE_DATETIME as VARCHAR(16777216)) as DW_EFFECTIVE_DATETIME,
        CAST(DW_EXPIRATION_DATETIME as VARCHAR(16777216)) as DW_EXPIRATION_DATETIME,
        CAST(DW_HASHVALUE_SCDTYPE1 as VARCHAR(16777216)) as DW_HASHVALUE_SCDTYPE1,
        CAST(DW_HASHVALUE_SCDTYPE2 as VARCHAR(16777216)) as DW_HASHVALUE_SCDTYPE2,
        CAST(DW_INSERT_DATETIME as VARCHAR(16777216)) as DW_INSERT_DATETIME,
        CAST(DW_UPDATE_DATETIME as VARCHAR(16777216)) as DW_UPDATE_DATETIME,
        CAST(ERROR_FLAG as VARCHAR(16777216)) as ERROR_FLAG,
        CAST(ERROR_REASON as VARCHAR(16777216)) as ERROR_REASON,
        CAST(ERROR_CODE as VARCHAR(16777216)) as ERROR_CODE,
        CAST(RECORD_INSERT_TIMESTAMP as VARCHAR(16777216)) as RECORD_INSERT_TIMESTAMP,
        CAST(OPERATION_TYPE as VARCHAR(16777216)) as OPERATION_TYPE,
        CAST(SRC_ROW_NUMBER as VARCHAR(16777216)) as SRC_ROW_NUMBER,
        CAST(SNAPSHOT_DATE AS DATE) AS SNAPSHOT_DATE,
        CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        CAST(_Row_Hash as varchar(128)) as _ROW_HASH
    FROM transform_data
)
select * from type_data

