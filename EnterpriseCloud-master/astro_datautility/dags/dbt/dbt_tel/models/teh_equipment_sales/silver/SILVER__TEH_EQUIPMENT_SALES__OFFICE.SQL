{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='OFFICE',
    unique_key = ['CompanyId',
    'OfficeId']
) }}

with source_data as
(

    SELECT
        BAAN_Dimension._COMPANYID AS CompanyId,
        BAAN_Dimension.DIMENSIONCODE AS OfficeId,
        BAAN_Dimension.DIMENSIONDESCRIPTION AS OfficeName,
        BAAN_SimpleIntegrationRelationsByElement.STRINGVALUE1 AS ServiceCenterId,
        CASE WHEN BAAN_Dimension._COMPANYID = '201' THEN 'Yes' ELSE 'No' END AS IsDefault,
        0 AS ERROR_FLAG,
        CAST('' AS VARCHAR(200)) AS ERROR_REASON,
        CAST('' AS VARCHAR(100)) AS ERROR_CODE,
        CAST(LOCALTIMESTAMP AS TIMESTAMP) AS RECORD_INSERT_TIMESTAMP,
        CAST('INSERT' AS VARCHAR(100)) AS OPERATION_TYPE,
        ROW_NUMBER() OVER (ORDER BY 1) AS SRC_ROW_NUMBER
        FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__BAAN_BAANFINANCEGENERALLEDGER_DIMENSIONS') }} BAAN_Dimension
        INNER JOIN {{ ref('BRONZE__TEH_EQUIPMENT_SALES__BAAN_BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS') }} BAAN_DimensionDescriptions
        ON BAAN_DimensionDescriptions._COMPANYID = 200
        AND BAAN_DimensionDescriptions.DIMENSIONTYPE = BAAN_Dimension.DIMENSIONTYPE
        AND BAAN_DimensionDescriptions.DIMENSIONDESCRIPTION = 'Office'
        LEFT OUTER JOIN {{ ref('BRONZE__TEH_EQUIPMENT_SALES__BAAN_BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT') }} BAAN_SimpleIntegrationRelationsByElement
        ON BAAN_SimpleIntegrationRelationsByElement._COMPANYID = 201
        AND BAAN_SimpleIntegrationRelationsByElement.DIMENSIONCODE =  BAAN_Dimension.DIMENSIONCODE
        AND BAAN_SimpleIntegrationRelationsByElement.INTEGRATIONELEMENT  = 'SVC'


),

transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        CompanyId,
        OfficeId,
        OfficeName,
        ServiceCenterId,
        IsDefault
FROM source_data
)

,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(COMPANYID as NUMBER(38,0)) as COMPANYID,
        cast(OFFICEID as VARCHAR(16777216)) as OFFICEID,
        cast(OFFICENAME as VARCHAR(16777216)) as OFFICENAME,
        cast(SERVICECENTERID as VARCHAR(16777216)) as SERVICECENTERID,
        cast(ISDEFAULT as VARCHAR(16777216)) as ISDEFAULT
from transform_data
    )
select * from type_data