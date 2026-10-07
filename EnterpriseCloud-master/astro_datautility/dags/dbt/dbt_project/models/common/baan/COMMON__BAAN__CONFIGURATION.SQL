{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='CONFIGURATION',
    unique_key = ['ConfigurationId']
) }}

with source_data as
(
    SELECT
        BaanConfigurations.CONFIGURATION AS ConfigurationId,
        LEFT ( BaanConfigurations.CONFIGURATION , 2 ) AS BU,
        SUBSTR ( BaanConfigurations.CONFIGURATION , POSITION ( '-' , BaanConfigurations.CONFIGURATION ) + 1 , LENGTH ( BaanConfigurations.CONFIGURATION ) - POSITION ( '-' , BaanConfigurations.CONFIGURATION ) + 1 ) AS FabId,
        UPPER ( TRIM ( BaanConfigurations.DESCRIPTION ) ) AS Description,
        BaanConfigurations.LOCATIONADDRESS AS AddressId,
        BaanConfigurations.RESPONSIBLEENGINEER AS ResposibleEmployeeId,
        BaanConfigurations.EXPIRYDATE AS ExpirationDate,
        BaanConfigurations.EXPIREDDESCRIPTION AS IsExpired,
        ROW_NUMBER() OVER (ORDER BY 1) AS SRC_ROW_NUMBER
        FROM
        {{ ref('ODS__BAAN__BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS') }} BaanConfigurations
        LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS') }} SoldToBusinessPartners ON SoldToBusinessPartners.SOLDTOBUSINESSPARTNER = BaanConfigurations.SOLDTOBUSINESSPARTNER
        LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT') }} SimpleIntegrations ON SimpleIntegrations.STRINGVALUE1 = BaanConfigurations.SERVICECENTER
        AND SimpleIntegrations.INTEGRATIONELEMENT = 'SVC'
        AND  SimpleIntegrations.DIMENSIONTYPE = 3
)
,transform_data as
(
    SELECT
        ConfigurationId,
        BU,
        FabId,
        Description,
        AddressId,
        ResposibleEmployeeId,
        ExpirationDate,
        IsExpired,
        SRC_ROW_NUMBER
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
 )
,type_data as
(
    select
        cast(CONFIGURATIONID as VARCHAR(16777216)) as CONFIGURATIONID,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(FABID as VARCHAR(16777216)) as FABID,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(ADDRESSID as VARCHAR(16777216)) as ADDRESSID,
        cast(RESPOSIBLEEMPLOYEEID as VARCHAR(16777216)) as RESPOSIBLEEMPLOYEEID,
        cast(EXPIRATIONDATE as TIMESTAMP_NTZ(9)) as EXPIRATIONDATE,
        cast(ISEXPIRED as VARCHAR(16777216)) as ISEXPIRED,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data