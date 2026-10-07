/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\ContractBundleTerms__MDM_ContractBundleTerms.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\ContractBundleTerms.SQL 
-materialized incremental
-alias ContractBundleTerms 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ContractBundleTerms',
    unique_key = ['ContractNumber']
) }}


with source_data as 
(
    SELECT 
            jsonfield:"Contract Number"::VARCHAR AS ContractNumber,  
        	jsonfield:"Flex Flag"::VARCHAR AS FlexFlag, 
        	jsonfield:"Flex Hours"::NUMBER(38,10) AS FlexHours, 
        	jsonfield:"FLX"::NUMBER(38,10) AS FLX, 
        	jsonfield:"FUL"::NUMBER(38,10) AS FUL, 
        	jsonfield:"OS2"::NUMBER(38,10) AS OS2, 
        	jsonfield:"OS4"::NUMBER(38,10) AS OS4, 
        	jsonfield:"OS8"::NUMBER(38,10) AS OS8, 
        	jsonfield:"PGR"::NUMBER(38,10) AS PGR, 
        	jsonfield:"PM"::NUMBER(38,10) AS PM, 
        	jsonfield:"PRT"::NUMBER(38,10) AS PRT, 
        	jsonfield:"STC"::NUMBER(38,10) AS STC, 
        	jsonfield:"TSP"::NUMBER(38,10) AS TSP, 
        	jsonfield:"TSS"::NUMBER(38,10) AS TSS, 
        	jsonfield:"Audit Date"::VARCHAR AS AuditDate, 
        	jsonfield:"Bundle Terms Desc"::VARCHAR AS BundleTermsDesc 
        FROM {{ source("MDM", "CONTRACTBUNDLETERMS") }} 
        )
,transform_data as
(
    SELECT 
        source_data.CONTRACTNUMBER AS ContractNumber, 
        source_data.FLEXFLAG AS FlexFlag, 
        source_data.FLEXHOURS AS FlexHours, 
        source_data.FLX AS FLX, 
        source_data.FUL AS FUL, 
        source_data.OS2 AS OS2, 
        source_data.OS4 AS OS4, 
        source_data.OS8 AS OS8, 
        source_data.PGR AS PGR, 
        source_data.PM AS PM, 
        source_data.PRT AS PRT, 
        source_data.STC AS STC, 
        source_data.TSP AS TSP, 
        source_data.TSS AS TSS, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.AUDITDATE , '/Date(' , '' ) , ')/' , '' ) ) AS AuditDate, 
        source_data.BUNDLETERMSDESC AS BundleTermsDesc, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(CONTRACTNUMBER as VARCHAR(16777216)) as CONTRACTNUMBER,
        cast(FLEXFLAG as VARCHAR(16777216)) as FLEXFLAG,
        cast(FLEXHOURS as NUMBER(38,10)) as FLEXHOURS,
        cast(FLX as NUMBER(38,10)) as FLX,
        cast(FUL as NUMBER(38,10)) as FUL,
        cast(OS2 as NUMBER(38,10)) as OS2,
        cast(OS4 as NUMBER(38,10)) as OS4,
        cast(OS8 as NUMBER(38,10)) as OS8,
        cast(PGR as NUMBER(38,10)) as PGR,
        cast(PM as NUMBER(38,10)) as PM,
        cast(PRT as NUMBER(38,10)) as PRT,
        cast(STC as NUMBER(38,10)) as STC,
        cast(TSP as NUMBER(38,10)) as TSP,
        cast(TSS as NUMBER(38,10)) as TSS,
        cast(AUDITDATE as TIMESTAMP_NTZ(9)) as AUDITDATE,
        cast(BUNDLETERMSDESC as VARCHAR(16777216)) as BUNDLETERMSDESC,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data