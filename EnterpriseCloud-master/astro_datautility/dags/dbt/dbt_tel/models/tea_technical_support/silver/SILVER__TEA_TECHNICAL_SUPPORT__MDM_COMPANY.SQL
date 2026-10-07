/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Company__Company.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\Company.SQL
-materialized incremental
-alias Company
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:03 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_COMPANY',
    unique_key=['CompanyId']
) }}

with source_data as
(
SELECT
SourceCompany.COMPANYCODE AS CompanyId,
SourceCompany.LONGNAME AS Name,
SourceCompany.COMPANYNAME AS ShortName,
SourceCompany.ACTIVEINDICATOR AS ActiveIndicator
FROM {{ ref('BRONZE__TEA_TECHNICAL_SUPPORT__MDM_COMPANY') }} SourceCompany
    )
,transform_data as
(   SELECT
    CompanyId,
    Name,
    ShortName,
    ActiveIndicator,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
 )
,type_data as 
(
    select
        cast(COMPANYID as VARCHAR(16777216)) as COMPANYID,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(SHORTNAME as VARCHAR(16777216)) as SHORTNAME,
        cast(ACTIVEINDICATOR as VARCHAR(16777216)) as ACTIVEINDICATOR,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data