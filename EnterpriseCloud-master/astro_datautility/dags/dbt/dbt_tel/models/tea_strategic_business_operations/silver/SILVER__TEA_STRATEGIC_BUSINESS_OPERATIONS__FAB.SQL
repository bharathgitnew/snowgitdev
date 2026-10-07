{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FAB',
    unique_key = []
) }}

with fab_notexpired as
(

    SELECT DISTINCT 
        BaanConfigurations.SOLDTOBUSINESSPARTNER as CustomerId,
        SUBSTR ( BaanConfigurations.CONFIGURATION ,
                POSITION('-',BaanConfigurations.CONFIGURATION)+1,
                LENGTH(BaanConfigurations.CONFIGURATION ) - POSITION('-',BaanConfigurations.CONFIGURATION) + 1) as FABId,
        BaanConfigurations.EXPIREDDESCRIPTION as IsExpired,
        SimpleIntegrations.DIMENSIONCODE as ServiceCenterOfficeId,
        SoldToBusinessPartners.INVOICETOBUSINESSPARTNER as SoldToCustomerId
        FROM {{ ref('BRONZE__TEA_STRATEGIC_BUSINESS_OPERATIONS__BAAN_BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS') }} BaanConfigurations
        LEFT OUTER JOIN {{ ref('BRONZE__TEA_STRATEGIC_BUSINESS_OPERATIONS__BAAN_BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS') }} SoldToBusinessPartners
        ON SoldToBusinessPartners.SOLDTOBUSINESSPARTNER = BaanConfigurations.SOLDTOBUSINESSPARTNER
        LEFT OUTER JOIN {{ ref('BRONZE__TEA_STRATEGIC_BUSINESS_OPERATIONS__BAAN_BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT') }} SimpleIntegrations
        ON SimpleIntegrations.STRINGVALUE1 = BaanConfigurations.SERVICECENTER
        AND SimpleIntegrations.INTEGRATIONELEMENT = 'SVC'
        AND  SimpleIntegrations.DIMENSIONTYPE = 3
        WHERE BaanConfigurations.EXPIREDDESCRIPTION = 'No'

),

fab_expired as 
(

    SELECT DISTINCT 
        BaanConfigurations.SOLDTOBUSINESSPARTNER as CustomerId,
        SUBSTR ( BaanConfigurations.CONFIGURATION ,
                POSITION('-',BaanConfigurations.CONFIGURATION)+1,
                LENGTH(BaanConfigurations.CONFIGURATION ) - POSITION('-',BaanConfigurations.CONFIGURATION) + 1) as FABId,
        BaanConfigurations.EXPIREDDESCRIPTION as IsExpired,
        SimpleIntegrations.DIMENSIONCODE as ServiceCenterOfficeId,
        SoldToBusinessPartners.INVOICETOBUSINESSPARTNER as SoldToCustomerId
    FROM {{ ref('BRONZE__TEA_STRATEGIC_BUSINESS_OPERATIONS__BAAN_BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS') }} BaanConfigurations
    LEFT OUTER JOIN {{ ref('BRONZE__TEA_STRATEGIC_BUSINESS_OPERATIONS__BAAN_BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS') }} SoldToBusinessPartners
    ON SoldToBusinessPartners.SOLDTOBUSINESSPARTNER = BaanConfigurations.SOLDTOBUSINESSPARTNER
    LEFT OUTER JOIN {{ ref('BRONZE__TEA_STRATEGIC_BUSINESS_OPERATIONS__BAAN_BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT') }} SimpleIntegrations
    ON SimpleIntegrations.STRINGVALUE1 = BaanConfigurations.SERVICECENTER
    AND SimpleIntegrations.INTEGRATIONELEMENT = 'SVC'
    AND  SimpleIntegrations.DIMENSIONTYPE = 3
    LEFT OUTER JOIN fab_notexpired CurrentFabTable
    ON CurrentFabTable.FABId = SUBSTR ( BaanConfigurations.CONFIGURATION ,
    POSITION('-',BaanConfigurations.CONFIGURATION)+1,
    LENGTH(BaanConfigurations.CONFIGURATION ) - POSITION('-',BaanConfigurations.CONFIGURATION) + 1)
    WHERE BaanConfigurations.EXPIREDDESCRIPTION = 'Yes'
    AND  CurrentFabTable.FABId IS NULL


),

source_data as
(
    select * from fab_notexpired

    union 

    select * from fab_expired

),

transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,-- Adds column to table on full refresh.
        CustomerId,
        FABId,
        IsExpired,
        ServiceCenterOfficeId,
        SoldToCustomerId
        
    FROM source_data
)

,type_data as 
(
    select
        _AUDIT_LOG_ID AS _AUDIT_LOG_ID,
        _ROW_HASH as _ROW_HASH,
        FABID as FABID,
        CUSTOMERID as CUSTOMERID,
        SOLDTOCUSTOMERID as SOLDTOCUSTOMERID,
        SERVICECENTEROFFICEID as SERVICECENTEROFFICEID,
        ISEXPIRED as ISEXPIRED
    from transform_data
    )
select * from type_data