{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='EMPLOYEE',
    unique_key = ['EmployeeId'],
    enabled=true
) }}

with source_data as
(
    SELECT 
        RIGHT ( '000000' || BAAN_Dimension.DIMENSIONCODE , 6 ) AS EmployeeId,
        BAAN_Dimension.DIMENSIONDESCRIPTION AS FullName,
        BAAN_Dimension._CAPTUREDATETIME
    FROM {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_DIMENSIONS') }} BAAN_Dimension
    INNER JOIN {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS') }} BAAN_DimensionDescriptions
    ON BAAN_DimensionDescriptions._COMPANYID = BAAN_Dimension._COMPANYID
    AND BAAN_DimensionDescriptions.DIMENSIONTYPE = BAAN_Dimension.DIMENSIONTYPE
    WHERE BAAN_DimensionDescriptions.DIMENSIONDESCRIPTION = 'Customer/Employee'
    AND LEFT( BAAN_Dimension.DIMENSIONCODE,1 ) <> 'C'
    QUALIFY row_number() over (partition by RIGHT ( '000000' || BAAN_Dimension.DIMENSIONCODE , 6 ) order by BAAN_Dimension._CAPTUREDATETIME desc) = 1

),

transform_data as
(
    select
        EmployeeId,
        FullName
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)

,type_data as
(
    select
        cast(EMPLOYEEID as VARCHAR(16777216)) as EMPLOYEEID,
        cast(FULLNAME as VARCHAR(16777216)) as FULLNAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data