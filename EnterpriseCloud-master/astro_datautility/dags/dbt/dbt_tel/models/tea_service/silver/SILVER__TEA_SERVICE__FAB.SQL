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
        FROM {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS') }} BaanConfigurations
        LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS') }} SoldToBusinessPartners
        ON SoldToBusinessPartners.SOLDTOBUSINESSPARTNER = BaanConfigurations.SOLDTOBUSINESSPARTNER
        LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT') }} SimpleIntegrations
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
    FROM {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS') }} BaanConfigurations
    LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS') }} SoldToBusinessPartners
    ON SoldToBusinessPartners.SOLDTOBUSINESSPARTNER = BaanConfigurations.SOLDTOBUSINESSPARTNER
    LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT') }} SimpleIntegrations
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
        CustomerId,
        FABId,
        IsExpired,
        ServiceCenterOfficeId,
        SoldToCustomerId,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
    FROM source_data
)

,type_data as 
(
    select
        cast(FABID as VARCHAR(16777216)) as FABID,
        cast(CUSTOMERID as VARCHAR(16777216)) as CUSTOMERID,
        cast(SOLDTOCUSTOMERID as VARCHAR(16777216)) as SOLDTOCUSTOMERID,
        cast(SERVICECENTEROFFICEID as VARCHAR(16777216)) as SERVICECENTEROFFICEID,
        cast(ISEXPIRED as VARCHAR(16777216)) as ISEXPIRED,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data