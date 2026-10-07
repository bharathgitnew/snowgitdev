/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Sirfis\sirfis_forecast.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\sirfis\Sirfis_Forecast.SQL
-materialized incremental
-alias Sirfis_Forecast
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema sirfis
-sourceDatabase LZ_DEV
-useDistinct $false
model file generated on: 1/10/2022 11:04:06 AM
***********************************/
{{ config(
     materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SIRFIS_SIRFIS_FORECAST_BASE'
) }}


with source_data as
(
    SELECT
         _Filename
        ,_Filedate
        ,jsonfield:forecastId::INT AS forecastId
        ,jsonfield:ueid::INT AS ueid
        ,jsonfield:supplierCsiChildCount::INT AS supplierCsiChildCount
        ,jsonfield:childCsiGaps::INT AS childCsiGaps
        ,jsonfield:stateCode::STRING AS stateCode
        ,jsonfield:statusCode::STRING AS statusCode
        ,jsonfield:category::STRING AS category
        ,jsonfield:model::STRING AS model
        ,jsonfield:ceid::STRING AS ceid
        ,jsonfield:entityCode::STRING AS entityCode
        ,jsonfield:capacityProcess::STRING AS capacityProcess
        ,jsonfield:site::STRING AS site
        ,jsonfield:description::STRING AS description
        ,jsonfield:supplierNumber::STRING AS supplierNumber
        ,jsonfield:supplierName::STRING AS supplierName
        ,jsonfield:transitMode::STRING AS transitMode
        ,jsonfield:transitOrigin::STRING AS transitOrigin
        ,jsonfield:transitTime::INT AS transitTime
        ,jsonfield:parentForecastId::INT AS parentForecastId
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:rdd::STRING,'/Date()/')) AS rdd
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:ctd::STRING,'/Date()/')) AS ctd
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:rtd::STRING,'/Date()/')) AS rtd
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:responseStd::STRING,'/Date()/')) AS responseStd
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:std::STRING,'/Date()/')) AS std
        ,jsonfield:supplierMap::STRING AS supplierMap
        ,jsonfield:reuseCapacityProcess::STRING AS reuseCapacityProcess
        ,jsonfield:reuseEntityCode::STRING AS reuseEntityCode
        ,jsonfield:reuseCeid::STRING AS reuseCeid
        ,jsonfield:reuseSite::STRING AS reuseSite
        ,jsonfield:hand::STRING AS hand
        ,jsonfield:impact::STRING AS impact
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:releaseDate::STRING,'/Date()/')) AS releaseDate
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:responseDate::STRING,'/Date()/')) AS responseDate
        ,jsonfield:poNumber::STRING AS poNumber
        ,jsonfield:poLineNumber::STRING AS poLineNumber
        ,jsonfield:quantity::DECIMAL AS quantity
        ,jsonfield:buildTime::STRING AS buildTime
        ,jsonfield:conversionLocation::STRING AS conversionLocation
        ,jsonfield:action::STRING AS action
        ,jsonfield:serialNumber::STRING AS serialNumber
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:actionDate::STRING,'/Date()/')) AS actionDate
        ,jsonfield:campus::STRING AS campus
        ,jsonfield:cpid::INT AS cpid
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:createdDate::STRING,'/Date()/')) AS createdDate
        ,jsonfield:csiFulfillment::BOOLEAN AS csiFulfillment
        ,jsonfield:csiType::STRING AS csiType
        ,jsonfield:draft::STRING AS draft
        ,jsonfield:isCsiLine::BOOLEAN AS isCsiLine
        ,jsonfield:maxCsiGap::INT AS maxCsiGap
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:maxCsiStd::STRING,'/Date()/')) AS maxCsiStd
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:minCsiRtd::STRING,'/Date()/')) AS minCsiRtd
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:modifiedDate::STRING,'/Date()/')) AS modifiedDate
        ,jsonfield:pid::INT AS pid
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:poDeliveryDate::STRING,'/Date()/')) AS poDeliveryDate
        ,jsonfield:poReleaseIndicator::STRING AS poReleaseIndicator
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:previousSdd::STRING,'/Date()/')) AS previousSdd
        ,jsonfield:releaseUserId::INT AS releaseUserId
        ,jsonfield:releaseUserName::STRING AS releaseUserName
        ,jsonfield:responseComment::STRING AS responseComment
        ,jsonfield:responseGapReason::STRING AS responseGapReason
        ,jsonfield:responsePullInProbability::STRING AS responsePullInProbability
        ,jsonfield:responseStdConditional::BOOLEAN AS responseStdConditional
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:responseNextUpdate::STRING,'/Date()/')) AS responseNextUpdate
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:responseSupplierConversionRdd::STRING,'/Date()/')) AS responseSupplierConversionRdd
        ,jsonfield:responseUserId::INT AS responseUserId
        ,jsonfield:responseUserName::STRING AS responseUserName
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:sdd::STRING,'/Date()/')) AS sdd
        ,jsonfield:stdConditional::BOOLEAN AS stdConditional
        ,jsonfield:storageLocation::STRING AS storageLocation
        ,jsonfield:supplierComment::STRING AS supplierComment
        ,TO_TIMESTAMP_NTZ(TRIM(jsonfield:supplierConversionRdd::STRING,'/Date()/')) AS supplierConversionRdd
        ,jsonfield:prefacStart::TIMESTAMP_NTZ AS PrefacStart
        ,jsonfield:setStart::TIMESTAMP_NTZ AS SetStart
        ,jsonfield:convertStart::TIMESTAMP_NTZ AS ConvertStart
        ,to_date(regexp_substr(_Filename,'\\d++++\\D+\\d++\\D+\\d++'),'YYYY-MM-DD') as _AppendedDate
        ,row_number() over(partition by forecastId order by _filename desc) as Revision_Desc_Order
    FROM {{ source("SIRFIS", "SIRFIS_FORECAST") }}
)

,transform_data as
(
    SELECT
        _Filename AS _Filename
        ,_Filedate AS _Filedate
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
        ,source_data.FORECASTID AS FORECASTID
        ,source_data.UEID AS UEID
        ,source_data.SUPPLIERCSICHILDCOUNT AS SUPPLIERCSICHILDCOUNT
        ,source_data.CHILDCSIGAPS AS CHILDCSIGAPS
        ,source_data.STATECODE AS STATECODE
        ,source_data.STATUSCODE AS STATUSCODE
        ,source_data.CATEGORY AS CATEGORY
        ,source_data.MODEL AS MODEL
        ,source_data.CEID AS CEID
        ,source_data.ENTITYCODE AS ENTITYCODE
        ,source_data.CAPACITYPROCESS AS CAPACITYPROCESS
        ,source_data.SITE AS SITE
        ,source_data.DESCRIPTION AS DESCRIPTION
        ,source_data.SUPPLIERNUMBER AS SUPPLIERNUMBER
        ,source_data.SUPPLIERNAME AS SUPPLIERNAME
        ,source_data.TRANSITMODE AS TRANSITMODE
        ,source_data.TRANSITORIGIN AS TRANSITORIGIN
        ,source_data.TRANSITTIME AS TRANSITTIME
        ,source_data.PARENTFORECASTID AS PARENTFORECASTID
        ,source_data.RDD AS RDD
        ,source_data.CTD AS CTD
        ,source_data.RTD AS RTD
        ,source_data.RESPONSESTD AS RESPONSESTD
        ,source_data.STD AS STD
        ,source_data.SUPPLIERMAP AS SUPPLIERMAP
        ,source_data.REUSECAPACITYPROCESS AS REUSECAPACITYPROCESS
        ,source_data.REUSEENTITYCODE AS REUSEENTITYCODE
        ,source_data.REUSECEID AS REUSECEID
        ,source_data.REUSESITE AS REUSESITE
        ,source_data.HAND AS HAND
        ,source_data.IMPACT AS IMPACT
        ,source_data.RELEASEDATE AS RELEASEDATE
        ,source_data.RESPONSEDATE AS RESPONSEDATE
        ,source_data.PONUMBER AS PONUMBER
        ,source_data.POLINENUMBER AS POLINENUMBER
        ,source_data.QUANTITY AS QUANTITY
        ,source_data.BUILDTIME AS BUILDTIME
        ,source_data.CONVERSIONLOCATION AS CONVERSIONLOCATION
        ,source_data.ACTION AS ACTION
        ,source_data.SERIALNUMBER AS SERIALNUMBER
        ,source_data.ACTIONDATE AS ACTIONDATE
        ,source_data.CAMPUS AS CAMPUS
        ,source_data.CPID AS CPID
        ,source_data.CREATEDDATE AS CREATEDDATE
        ,source_data.CSIFULFILLMENT AS CSIFULFILLMENT
        ,source_data.CSITYPE AS CSITYPE
        ,source_data.DRAFT AS DRAFT
        ,source_data.ISCSILINE AS ISCSILINE
        ,source_data.MAXCSIGAP AS MAXCSIGAP
        ,source_data.MAXCSISTD AS MAXCSISTD
        ,source_data.MINCSIRTD AS MINCSIRTD
        ,source_data.MODIFIEDDATE AS MODIFIEDDATE
        ,source_data.PID AS PID
        ,source_data.PODELIVERYDATE AS PODELIVERYDATE
        ,source_data.PORELEASEINDICATOR AS PORELEASEINDICATOR
        ,source_data.PREVIOUSSDD AS PREVIOUSSDD
        ,source_data.RELEASEUSERID AS RELEASEUSERID
        ,source_data.RELEASEUSERNAME AS RELEASEUSERNAME
        ,source_data.RESPONSECOMMENT AS RESPONSECOMMENT
        ,source_data.RESPONSEGAPREASON AS RESPONSEGAPREASON
        ,source_data.RESPONSEPULLINPROBABILITY AS RESPONSEPULLINPROBABILITY
        ,source_data.RESPONSESTDCONDITIONAL AS RESPONSESTDCONDITIONAL
        ,source_data.RESPONSENEXTUPDATE AS RESPONSENEXTUPDATE
        ,source_data.RESPONSESUPPLIERCONVERSIONRDD AS RESPONSESUPPLIERCONVERSIONRDD
        ,source_data.RESPONSEUSERID AS RESPONSEUSERID
        ,source_data.RESPONSEUSERNAME AS RESPONSEUSERNAME
        ,source_data.SDD AS SDD
        ,source_data.STDCONDITIONAL AS STDCONDITIONAL
        ,source_data.STORAGELOCATION AS STORAGELOCATION
        ,source_data.SUPPLIERCOMMENT AS SUPPLIERCOMMENT
        ,source_data.SUPPLIERCONVERSIONRDD AS SUPPLIERCONVERSIONRDD
        ,source_data.PREFACSTART AS PrefacStart
        ,source_data.SETSTART AS SetStart
        ,source_data.CONVERTSTART AS ConvertStart
        ,'{{ invocation_id }}' AS Audit_Log_Id
        ,source_data._AppendedDate
        ,source_data.Revision_Desc_Order
FROM source_data
    WHERE source_data.site<>'GW'
)
,type_data as 
(
    select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(FORECASTID as NUMBER(38,0)) as FORECASTID,
        cast(UEID as NUMBER(38,0)) as UEID,
        cast(SUPPLIERCSICHILDCOUNT as NUMBER(38,0)) as SUPPLIERCSICHILDCOUNT,
        cast(CHILDCSIGAPS as NUMBER(38,0)) as CHILDCSIGAPS,
        cast(STATECODE as VARCHAR(16777216)) as STATECODE,
        cast(STATUSCODE as VARCHAR(16777216)) as STATUSCODE,
        cast(CATEGORY as VARCHAR(16777216)) as CATEGORY,
        cast(MODEL as VARCHAR(16777216)) as MODEL,
        cast(CEID as VARCHAR(16777216)) as CEID,
        cast(ENTITYCODE as VARCHAR(16777216)) as ENTITYCODE,
        cast(CAPACITYPROCESS as VARCHAR(16777216)) as CAPACITYPROCESS,
        cast(SITE as VARCHAR(16777216)) as SITE,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(SUPPLIERNUMBER as VARCHAR(16777216)) as SUPPLIERNUMBER,
        cast(SUPPLIERNAME as VARCHAR(16777216)) as SUPPLIERNAME,
        cast(TRANSITMODE as VARCHAR(16777216)) as TRANSITMODE,
        cast(TRANSITORIGIN as VARCHAR(16777216)) as TRANSITORIGIN,
        cast(TRANSITTIME as NUMBER(38,0)) as TRANSITTIME,
        cast(PARENTFORECASTID as NUMBER(38,0)) as PARENTFORECASTID,
        cast(RDD as TIMESTAMP_NTZ(9)) as RDD,
        cast(CTD as TIMESTAMP_NTZ(9)) as CTD,
        cast(RTD as TIMESTAMP_NTZ(9)) as RTD,
        cast(RESPONSESTD as TIMESTAMP_NTZ(9)) as RESPONSESTD,
        cast(STD as TIMESTAMP_NTZ(9)) as STD,
        cast(SUPPLIERMAP as VARCHAR(16777216)) as SUPPLIERMAP,
        cast(REUSECAPACITYPROCESS as VARCHAR(16777216)) as REUSECAPACITYPROCESS,
        cast(REUSEENTITYCODE as VARCHAR(16777216)) as REUSEENTITYCODE,
        cast(REUSECEID as VARCHAR(16777216)) as REUSECEID,
        cast(REUSESITE as VARCHAR(16777216)) as REUSESITE,
        cast(HAND as VARCHAR(16777216)) as HAND,
        cast(IMPACT as VARCHAR(16777216)) as IMPACT,
        cast(RELEASEDATE as TIMESTAMP_NTZ(9)) as RELEASEDATE,
        cast(RESPONSEDATE as TIMESTAMP_NTZ(9)) as RESPONSEDATE,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(POLINENUMBER as VARCHAR(16777216)) as POLINENUMBER,
        cast(QUANTITY as NUMBER(38,0)) as QUANTITY,
        cast(BUILDTIME as VARCHAR(16777216)) as BUILDTIME,
        cast(CONVERSIONLOCATION as VARCHAR(16777216)) as CONVERSIONLOCATION,
        cast(ACTION as VARCHAR(16777216)) as ACTION,
        cast(SERIALNUMBER as VARCHAR(16777216)) as SERIALNUMBER,
        cast(ACTIONDATE as TIMESTAMP_NTZ(9)) as ACTIONDATE,
        cast(CAMPUS as VARCHAR(16777216)) as CAMPUS,
        cast(CPID as NUMBER(38,0)) as CPID,
        cast(CREATEDDATE as TIMESTAMP_NTZ(9)) as CREATEDDATE,
        cast(CSIFULFILLMENT as BOOLEAN) as CSIFULFILLMENT,
        cast(CSITYPE as VARCHAR(16777216)) as CSITYPE,
        cast(DRAFT as VARCHAR(16777216)) as DRAFT,
        cast(ISCSILINE as BOOLEAN) as ISCSILINE,
        cast(MAXCSIGAP as NUMBER(38,0)) as MAXCSIGAP,
        cast(MAXCSISTD as TIMESTAMP_NTZ(9)) as MAXCSISTD,
        cast(MINCSIRTD as TIMESTAMP_NTZ(9)) as MINCSIRTD,
        cast(MODIFIEDDATE as TIMESTAMP_NTZ(9)) as MODIFIEDDATE,
        cast(PID as NUMBER(38,0)) as PID,
        cast(PODELIVERYDATE as TIMESTAMP_NTZ(9)) as PODELIVERYDATE,
        cast(PORELEASEINDICATOR as VARCHAR(16777216)) as PORELEASEINDICATOR,
        cast(PREVIOUSSDD as TIMESTAMP_NTZ(9)) as PREVIOUSSDD,
        cast(RELEASEUSERID as NUMBER(38,0)) as RELEASEUSERID,
        cast(RELEASEUSERNAME as VARCHAR(16777216)) as RELEASEUSERNAME,
        cast(RESPONSECOMMENT as VARCHAR(16777216)) as RESPONSECOMMENT,
        cast(RESPONSEGAPREASON as VARCHAR(16777216)) as RESPONSEGAPREASON,
        cast(RESPONSEPULLINPROBABILITY as VARCHAR(16777216)) as RESPONSEPULLINPROBABILITY,
        cast(RESPONSESTDCONDITIONAL as BOOLEAN) as RESPONSESTDCONDITIONAL,
        cast(RESPONSENEXTUPDATE as TIMESTAMP_NTZ(9)) as RESPONSENEXTUPDATE,
        cast(RESPONSESUPPLIERCONVERSIONRDD as TIMESTAMP_NTZ(9)) as RESPONSESUPPLIERCONVERSIONRDD,
        cast(RESPONSEUSERID as NUMBER(38,0)) as RESPONSEUSERID,
        cast(RESPONSEUSERNAME as VARCHAR(16777216)) as RESPONSEUSERNAME,
        cast(SDD as TIMESTAMP_NTZ(9)) as SDD,
        cast(STDCONDITIONAL as BOOLEAN) as STDCONDITIONAL,
        cast(STORAGELOCATION as VARCHAR(16777216)) as STORAGELOCATION,
        cast(SUPPLIERCOMMENT as VARCHAR(16777216)) as SUPPLIERCOMMENT,
        cast(SUPPLIERCONVERSIONRDD as TIMESTAMP_NTZ(9)) as SUPPLIERCONVERSIONRDD,
        cast(PREFACSTART as TIMESTAMP_NTZ(9)) as PREFACSTART,
        cast(SETSTART as TIMESTAMP_NTZ(9)) as SETSTART,
        cast(CONVERTSTART as TIMESTAMP_NTZ(9)) as CONVERTSTART,
        cast(_APPENDEDDATE as DATE) as _APPENDEDDATE,
        cast(Revision_Desc_Order as NUMBER(38,0)) as Revision_Desc_Order
from transform_data
    )
select * from type_data