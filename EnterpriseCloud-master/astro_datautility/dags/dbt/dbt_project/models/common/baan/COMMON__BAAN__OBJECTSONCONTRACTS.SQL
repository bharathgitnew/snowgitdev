{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='OBJECTSONCONTRACTS',
    unique_key = []
) }}

with source_data as
(
    SELECT DISTINCT
                     a.SERVICECONTRACT AS Contract_No,
                     c.CONFIGURATION AS Configuration,
                     e.Object AS OBJECT,
                     e.ObjectNumber AS Object_Number,
                     e.SerialNumber AS Serial_Number,
                     d.SERVICETYPE AS Service_Type,
                     d.COSTTYPEDESCRIPTION AS Cost_Type,
                     d.COVERAGETERMNUMBER AS Converage_Term_Number,
                     f.OBJECTGROUP AS TEL_BU,
                     g.BUCODETEA AS TEA_BU,
                     m.Dimension_Code,
                     m.Dimension_Description,
                     f.SYSTEMSTATUSDESCRIPTION AS System_Status_Code,
                     f.SYSTEMSTATUSDESCRIPTION AS System_Status,
                     a.CONTRACTSTATUSDESCRIPTION AS Contract_Status_Code,
                     a.CONTRACTSTATUSDESCRIPTION AS Contract_Status,
                     a.DESCRIPTION AS Contract_Desc
                FROM {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_SERVICECONTRACTS') }} a
                     INNER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_CONTRACT_CONFIGURATIONLINES') }} c 
                                               ON a.SERVICECONTRACT = c.SERVICECONTRACT
                     INNER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_COVERAGETERMS') }} d
                         ON c.CONTRACTTERMS = d.TERMID AND c.CONFIGURATION = d.CONFIGURATION
                     LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_OBJECTACTIVITYLINESBYCOVERAGETERM') }} e
                         ON     d.TERMID = e.TermID
                            AND d.CONFIGURATION = e.Configuration_cfgr
                            AND d.SERVICETYPE = e.ServiceType
                            AND d.COSTTYPEID = e.CostTypeId
                            AND d.COVERAGETERMNUMBER = e.CoverageTermNumber
                     INNER JOIN {{ ref('ODS__BAAN__BAANSERVICECONFIGURATIONCONTROL_OBJECTS') }} f
                         ON     e.Configuration_ccfg = f.CONFIGURATION
                            AND e.Object = f.OBJECT
                            AND e.ObjectNumber = f.OBJECTNUMBER
                     LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS') }} z
                                                    ON e.Configuration_ccfg = z.CONFIGURATION
                     LEFT OUTER JOIN
                     (SELECT B.DIMENSIONTYPE     AS DT_Code,
                             D.DIMENSIONDESCRIPTION     AS DimensionType,
                             B.STRINGVALUE1     AS Location,
                             B.DIMENSIONCODE     AS Dimension_Code,
                             C.DIMENSIONDESCRIPTION     AS Dimension_Description,
                             B.INTEGRATIONELEMENT
                        FROM {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT') }} B, 
                      {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_DIMENSIONS') }} C,
                      {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS') }} D
                           WHERE     B.DIMENSIONCODE = C.DIMENSIONCODE
                             AND B.DIMENSIONTYPE = C.DIMENSIONTYPE
                             AND B.DIMENSIONTYPE = D.DIMENSIONTYPE
                             AND B.DIMENSIONTYPE = 3
                             AND B.INTEGRATIONELEMENT = 'SVC') m
                         ON z.SERVICECENTER = m.Location
                     LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_BUCODEMAPPING') }} g
                                                    ON f.OBJECTGROUP = g.BUCODETEL
                     INNER JOIN (SELECT MAX (TERMID) AS term, SERVICECONTRACT
                                     FROM {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_TERMIDLOGGING') }}
                                 GROUP BY SERVICECONTRACT) y
                         ON d.TERMID = y.term
               WHERE TRIM (e.SerialNumber) IS NOT NULL
            ORDER BY a.SERVICECONTRACT, c.CONFIGURATION, e.SerialNumber
        )

,transform_data as
(
    SELECT
        source_data.CONFIGURATION,
        source_data.CONTRACT_DESC,
        source_data.CONTRACT_NO,
        source_data.CONTRACT_STATUS,
        source_data.CONTRACT_STATUS_CODE,
        source_data.CONVERAGE_TERM_NUMBER,
        source_data.COST_TYPE,
        source_data.DIMENSION_CODE,
        source_data.DIMENSION_DESCRIPTION,
        source_data.OBJECT,
        source_data.OBJECT_NUMBER,
        source_data.SERIAL_NUMBER,
        source_data.SERVICE_TYPE,
        source_data.SYSTEM_STATUS,
        source_data.SYSTEM_STATUS_CODE,
        source_data.TEA_BU,
        source_data.TEL_BU,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(CONTRACT_NO as VARCHAR(16777216)) as CONTRACT_NO,
        cast(CONFIGURATION as VARCHAR(16777216)) as CONFIGURATION,
        cast(OBJECT as VARCHAR(16777216)) as OBJECT,
        cast(OBJECT_NUMBER as NUMBER(38,0)) as OBJECT_NUMBER,
        cast(SERIAL_NUMBER as VARCHAR(16777216)) as SERIAL_NUMBER,
        cast(SERVICE_TYPE as VARCHAR(16777216)) as SERVICE_TYPE,
        cast(COST_TYPE as VARCHAR(16777216)) as COST_TYPE,
        cast(CONVERAGE_TERM_NUMBER as NUMBER(38,0)) as CONVERAGE_TERM_NUMBER,
        cast(TEL_BU as VARCHAR(16777216)) as TEL_BU,
        cast(TEA_BU as VARCHAR(16777216)) as TEA_BU,
        cast(DIMENSION_CODE as VARCHAR(16777216)) as DIMENSION_CODE,
        cast(DIMENSION_DESCRIPTION as VARCHAR(16777216)) as DIMENSION_DESCRIPTION,
        cast(SYSTEM_STATUS_CODE as VARCHAR(16777216)) as SYSTEM_STATUS_CODE,
        cast(SYSTEM_STATUS as VARCHAR(16777216)) as SYSTEM_STATUS,
        cast(CONTRACT_STATUS_CODE as VARCHAR(16777216)) as CONTRACT_STATUS_CODE,
        cast(CONTRACT_STATUS as VARCHAR(16777216)) as CONTRACT_STATUS,
        cast(CONTRACT_DESC as VARCHAR(16777216)) as CONTRACT_DESC,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data