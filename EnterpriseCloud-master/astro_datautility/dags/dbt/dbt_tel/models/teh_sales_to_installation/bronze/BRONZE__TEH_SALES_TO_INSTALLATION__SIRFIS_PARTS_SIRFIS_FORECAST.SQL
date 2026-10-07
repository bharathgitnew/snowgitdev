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
    alias='SIRFIS_PARTS_SIRFIS_FORECAST'
) }}


with source_data as
(
    SELECT
         _Filename
        ,_Filedate
        ,jsonfield:forecastId::INT AS Id
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
        
        ,jsonfield:requestCancellationFee::STRING AS requestCancellationFee
        ,jsonfield:responseCurrentCancellationFee::STRING AS responseCurrentCancellationFee
        ,jsonfield:responseHasNextCancellationFee::STRING AS responseHasNextCancellationFee
        ,jsonfield:responseIsPartOfNegotiation::STRING AS responseIsPartOfNegotiation
        
        ,to_date(regexp_substr(_Filename,'\\d++++\\D+\\d++\\D+\\d++'),'YYYY-MM-DD') as _AppendedDate
        ,row_number() over(partition by Id order by _filename desc) as Revision_Desc_Order
    FROM 
    {{ source("SIRFIS", "PARTS_SIRFIS_FORECAST") }}
)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
        ,source_data._FILENAME AS _FILENAME
        ,source_data._FILEDATE AS _FILEDATE 
        ,source_data.ID AS ID
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
        
        ,source_data.requestCancellationFee AS requestCancellationFee
        ,source_data.responseCurrentCancellationFee AS responseCurrentCancellationFee
        ,source_data.responseHasNextCancellationFee AS responseHasNextCancellationFee
        ,source_data.responseIsPartOfNegotiation responseIsPartOfNegotiation

        ,source_data._AppendedDate
        ,source_data.Revision_Desc_Order
    FROM source_data
)
,type_data as 
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _FILENAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(ID as NUMBER(38,0)) as ID,
        cast(UEID as NUMBER(38,0)) as UEID,
        cast(SUPPLIERCSICHILDCOUNT as NUMBER(38,0)) as SUPPLIERCSICHILDCOUNT,
        cast(CHILDCSIGAPS as NUMBER(38,0)) as CHILDCSIGAPS,
        STATECODE,
        STATUSCODE,
        CATEGORY,
        MODEL,
        CEID,
        ENTITYCODE,
        CAPACITYPROCESS,
        SITE,
        DESCRIPTION,
        SUPPLIERNUMBER,
        SUPPLIERNAME,
        TRANSITMODE,
        TRANSITORIGIN,
        cast(TRANSITTIME as NUMBER(38,0)) as TRANSITTIME,
        cast(PARENTFORECASTID as NUMBER(38,0)) as PARENTFORECASTID,
        cast(RDD as TIMESTAMP_NTZ(9)) as RDD,
        cast(CTD as TIMESTAMP_NTZ(9)) as CTD,
        cast(RTD as TIMESTAMP_NTZ(9)) as RTD,
        cast(RESPONSESTD as TIMESTAMP_NTZ(9)) as RESPONSESTD,
        cast(STD as TIMESTAMP_NTZ(9)) as STD,
        SUPPLIERMAP,
        REUSECAPACITYPROCESS,
        REUSEENTITYCODE,
        REUSECEID,
        REUSESITE,
        HAND,
        IMPACT,
        cast(RELEASEDATE as TIMESTAMP_NTZ(9)) as RELEASEDATE,
        cast(RESPONSEDATE as TIMESTAMP_NTZ(9)) as RESPONSEDATE,
        PONUMBER,
        POLINENUMBER,
        cast(QUANTITY as NUMBER(38,0)) as QUANTITY,
        BUILDTIME,
        CONVERSIONLOCATION,
        ACTION,
        SERIALNUMBER,
        cast(ACTIONDATE as TIMESTAMP_NTZ(9)) as ACTIONDATE,
        CAMPUS,
        cast(CPID as NUMBER(38,0)) as CPID,
        cast(CREATEDDATE as TIMESTAMP_NTZ(9)) as CREATEDDATE,
        CSIFULFILLMENT,
        CSITYPE,
        DRAFT,
        ISCSILINE,
        cast(MAXCSIGAP as NUMBER(38,0)) as MAXCSIGAP,
        cast(MAXCSISTD as TIMESTAMP_NTZ(9)) as MAXCSISTD,
        cast(MINCSIRTD as TIMESTAMP_NTZ(9)) as MINCSIRTD,
        cast(MODIFIEDDATE as TIMESTAMP_NTZ(9)) as MODIFIEDDATE,
        cast(PID as NUMBER(38,0)) as PID,
        cast(PODELIVERYDATE as TIMESTAMP_NTZ(9)) as PODELIVERYDATE,
        PORELEASEINDICATOR,
        cast(PREVIOUSSDD as TIMESTAMP_NTZ(9)) as PREVIOUSSDD,
        cast(RELEASEUSERID as NUMBER(38,0)) as RELEASEUSERID,
        RELEASEUSERNAME,
        RESPONSECOMMENT,
        RESPONSEGAPREASON,
        RESPONSEPULLINPROBABILITY,
        RESPONSESTDCONDITIONAL,
        cast(RESPONSENEXTUPDATE as TIMESTAMP_NTZ(9)) as RESPONSENEXTUPDATE,
        cast(RESPONSESUPPLIERCONVERSIONRDD as TIMESTAMP_NTZ(9)) as RESPONSESUPPLIERCONVERSIONRDD,
        cast(RESPONSEUSERID as NUMBER(38,0)) as RESPONSEUSERID,
        RESPONSEUSERNAME,
        cast(SDD as TIMESTAMP_NTZ(9)) as SDD,
        STDCONDITIONAL,
        STORAGELOCATION,
        SUPPLIERCOMMENT,
        cast(SUPPLIERCONVERSIONRDD as TIMESTAMP_NTZ(9)) as SUPPLIERCONVERSIONRDD,
        cast(PREFACSTART as TIMESTAMP_NTZ(9)) as PREFACSTART,
        cast(SETSTART as TIMESTAMP_NTZ(9)) as SETSTART,
        cast(CONVERTSTART as TIMESTAMP_NTZ(9)) as CONVERTSTART

        ,CASE 
            WHEN UPPER(requestCancellationFee) = 'NULL' THEN NULL
            WHEN UPPER(requestCancellationFee) = 'TRUE' THEN TRUE
            WHEN UPPER(requestCancellationFee) = 'FALSE' THEN FALSE
            ELSE requestCancellationFee
        END AS requestCancellationFee

        ,responseCurrentCancellationFee::NUMBER(38,0) as responseCurrentCancellationFee
        
        , CASE 
            WHEN UPPER(responseHasNextCancellationFee) = 'NULL' THEN NULL
            WHEN UPPER(responseHasNextCancellationFee) = 'TRUE' THEN TRUE
            WHEN UPPER(responseHasNextCancellationFee) = 'FALSE' THEN FALSE
            ELSE responseHasNextCancellationFee
        END AS responseHasNextCancellationFee
        
        ,CASE 
            WHEN UPPER(responseIsPartOfNegotiation) = 'NULL' THEN NULL
            WHEN UPPER(responseIsPartOfNegotiation) = 'TRUE' THEN TRUE
            WHEN UPPER(responseIsPartOfNegotiation) = 'FALSE' THEN FALSE
            ELSE responseIsPartOfNegotiation
        END AS responseIsPartOfNegotiation
        ,cast(_APPENDEDDATE as DATE) as _APPENDEDDATE
        ,cast(Revision_Desc_Order as NUMBER(38,0)) as Revision_Desc_Order

    from transform_data
    )
select * from type_data