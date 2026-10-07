/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\FinancialCostCenter.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\FinancialCostCenter.SQL
-materialized incremental
-alias FinancialCostCenter
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
    alias='FinancialCostCenter',
    unique_key = ['COSTCENTERID']
) }}


with source_data as
(
    SELECT
          dataset._Filename as _Filename
         ,dataset._Filedate as _Filedate
         ,dataset.JSonField:Code::STRING AS CostCenterID
         ,dataset.JSonField:CostCenterSubdivision_Code::STRING AS SubdivisionID
         ,dataset.JSonField:CostCenterSubdivision_Name::STRING AS SubdivisionName
         ,dataset.JSonField:CostCenterDivision_Code::STRING AS DivisionID
         ,dataset.JSonField:CostCenterDivision_Name::STRING AS DivisionName
         ,dataset.JSonField:FinancialSegment_Code::STRING AS SegmentID
         ,dataset.JSonField:FinancialSegment_Name::STRING AS SegmentName
         ,dataset.JSonField:FinancialDepartment_Code::STRING AS DepartmentID
         ,dataset.JSonField:FinancialDepartment_Name::STRING AS DepartmentName
         ,dataset.JSonField:FinancialCostCenterSection_Code::STRING AS SectionID
         ,dataset.JSonField:FinancialCostCenterSection_Name::STRING AS SectionName
         ,dataset.JSonField:Company_Code::STRING AS CompanyID
         ,dataset.JSonField:Company_Name::STRING AS CompanyName
         ,dataset.JSonField:CostCenterSubdivisionOwnerUserID::STRING AS SubdivisionOwnerUserID
         ,dataset.JSonField:CostCenterSubdivisionOwner::STRING AS SubdivisionOwnerUserName
         ,dataset.JSonField:CostCenterDivisionOwnerUserID::STRING AS DivisionOwnerUserID
         ,dataset.JSonField:CostCenterDivisionOwner::STRING AS DivisionOwnerUserName
         ,dataset.JSonField:CostCenterSectionOwnerUserID_Code::STRING AS SectionOwnerUserID
         ,dataset.JSonField:CostCenterSectionOwner::STRING AS SectionOwnerUserName
        FROM {{ source("MDM", "FINANCIALCOSTCENTER") }} as dataset
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "FINANCIALCOSTCENTER") }} as c
            WHERE c.jsonfield:Name::STRING = dataset.jsonfield:Name::STRING)
        )
,transform_data as
(
    SELECT
        source_data.COSTCENTERID AS COSTCENTERID,
        source_data.SUBDIVISIONID AS SUBDIVISIONID,
        source_data.SUBDIVISIONNAME AS SUBDIVISIONNAME,
        source_data.DIVISIONID AS DIVISIONID,
        source_data.DIVISIONNAME AS DIVISIONNAME,
        source_data.SEGMENTID AS SEGMENTID,
        source_data.SEGMENTNAME AS SEGMENTNAME,
        source_data.DepartmentID  AS DEPARTMENTID,
        source_data.DepartmentName AS DEPARTMENTNAME,
        source_data.SECTIONID AS SECTIONID,
        source_data.SECTIONNAME AS SECTIONNAME,
        source_data.COMPANYID AS COMPANYID,
        source_data.COMPANYNAME AS COMPANYNAME,
        source_data.SUBDIVISIONOWNERUSERID AS SUBDIVISIONOWNERUSERID,
        source_data.SUBDIVISIONOWNERUSERNAME AS SUBDIVISIONOWNERUSERNAME,
        source_data.DIVISIONOWNERUSERID AS DIVISIONOWNERUSERID,
        source_data.DIVISIONOWNERUSERNAME AS DIVISIONOWNERUSERNAME,
        source_data.SECTIONOWNERUSERID AS SECTIONOWNERUSERID,
        source_data.SECTIONOWNERUSERNAME AS SECTIONOWNERUSERNAME,
        CAST ( NULL AS STRING ( 1677721 ) ) AS EFFECTIVEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(COSTCENTERID as VARCHAR(16777216)) as COSTCENTERID,
        cast(SUBDIVISIONID as VARCHAR(16777216)) as SUBDIVISIONID,
        cast(SUBDIVISIONNAME as VARCHAR(16777216)) as SUBDIVISIONNAME,
        cast(DIVISIONID as VARCHAR(16777216)) as DIVISIONID,
        cast(DIVISIONNAME as VARCHAR(16777216)) as DIVISIONNAME,
        cast(SEGMENTID as VARCHAR(16777216)) as SEGMENTID,
        cast(SEGMENTNAME as VARCHAR(16777216)) as SEGMENTNAME,
        cast(DEPARTMENTID as VARCHAR(16777216)) as DEPARTMENTID,
        cast(DEPARTMENTNAME as VARCHAR(16777216)) as DEPARTMENTNAME,
        cast(SECTIONID as VARCHAR(16777216)) as SECTIONID,
        cast(SECTIONNAME as VARCHAR(16777216)) as SECTIONNAME,
        cast(COMPANYID as VARCHAR(16777216)) as COMPANYID,
        cast(COMPANYNAME as VARCHAR(16777216)) as COMPANYNAME,
        cast(SUBDIVISIONOWNERUSERID as VARCHAR(16777216)) as SUBDIVISIONOWNERUSERID,
        cast(SUBDIVISIONOWNERUSERNAME as VARCHAR(16777216)) as SUBDIVISIONOWNERUSERNAME,
        cast(DIVISIONOWNERUSERID as VARCHAR(16777216)) as DIVISIONOWNERUSERID,
        cast(DIVISIONOWNERUSERNAME as VARCHAR(16777216)) as DIVISIONOWNERUSERNAME,
        cast(SECTIONOWNERUSERNAME as VARCHAR(16777216)) as SECTIONOWNERUSERNAME,
        cast(EFFECTIVEDATE as VARCHAR(16777216)) as EFFECTIVEDATE,
        cast(SECTIONOWNERUSERID as VARCHAR(16777216)) as SECTIONOWNERUSERID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data