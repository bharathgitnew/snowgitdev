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
    materialized = 'tel_incremental',
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
FROM {{ ref('BRONZE__TEH_APPLICATIONS__MDM_COMPANY') }} SourceCompany
    )
,transform_data as
(   SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') AS _ROW_HASH,
    CompanyId,
    Name,
    ShortName,
    ActiveIndicator-- Adds column to table on full refresh.
    FROM source_data
 )
,type_data as 
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        COMPANYID,
        NAME,
        SHORTNAME,
        ACTIVEINDICATOR
    from transform_data
    )
select * from type_data