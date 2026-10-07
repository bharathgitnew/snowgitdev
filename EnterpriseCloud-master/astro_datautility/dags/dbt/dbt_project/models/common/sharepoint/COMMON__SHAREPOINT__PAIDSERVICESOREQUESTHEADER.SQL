/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-Sharepoint\PaidServiceSORequest__SORequestHeader.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\sharepoint\PAIDSERVICESOREQUESTHEADER.SQL
-materialized incremental
-alias PAIDSERVICESOREQUESTHEADER
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema SHAREPOINT
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 03-Feb-22 6:51:36 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='PAIDSERVICESOREQUESTHEADER',
    unique_key = ['DocumentID']
) }}

with
    source_data
    as
    (
        SELECT
            SourceData.DOCUMENTID AS DocumentID,
SourceData.SOREQUESTDATE AS SORequestDate,
SourceData.SONUMBER AS SONumber,
SourceData.REQUESTOR AS Requestor,
SourceData.CUSTOMERFABGROUP AS CustomerFabGroup,
SourceData.CUSTOMERFABOFFICE AS CustomerFabOffice,
SourceData.FAB AS Fab,
SourceData.BU AS BU,
SourceData.PONUMBER AS PONumber,
SourceData.QUOTENUMBER AS QuoteNumber,
SourceData.CUSTOMERFAB AS CustomerFab,
SourceData.ESTIMATEDHOURS AS EstimatedHours,
SourceData.SOSTART AS SOStart,
SourceData.SOEND AS SOEnd,
SourceData.BUSINESS AS Business,
SourceData.SERVICETYPE AS ServiceType,
SourceData.DESCRIPTION AS Description,
SourceData.SERIALNUMBER AS SerialNumber,
SourceData.CREDITCHECK AS CreditCheck,
SourceData.DECOMISSION AS Decomission,
SourceData.REQUESTCOMMENTS AS RequestComments,
SourceData.SIGCOMMENTS AS SIGComments,
SourceData.FIELDUPDATES AS FieldUpdates,
SourceData.SIGNOTESTOFIELD AS SIGNotesToField,
SourceData.TOTALTSRAMOUNTINPUT AS TotalTSRAmountInput,
SourceData.INVOICINGSTATUS AS InvoicingStatus,
SourceData.TSRAMOUNT AS TSRAmount,
SourceData.POINMODULECONFIGURATION AS POInModuleConfiguration
        FROM
            {{ ref('ODS__SHAREPOINT__PAIDSERVICESOREQUEST') }} AS SourceData
        WHERE  SONumber IS NOT NULL
    )

,
transform_data as
(
        SELECT
DocumentID,
SORequestDate,
SONumber,
Requestor,
CustomerFabGroup,
CustomerFabOffice,
Fab,
BU,
PONumber,
QuoteNumber,
CustomerFab,
EstimatedHours,
SOStart,
SOEnd,
Business,
ServiceType,
Description,
SerialNumber,
CreditCheck,
Decomission,
RequestComments,
SIGComments,
FieldUpdates,
SIGNotesToField,
TotalTSRAmountInput,
InvoicingStatus,
TSRAmount,
POInModuleConfiguration,
ROW_NUMBER() OVER (PARTITION BY SONumber ORDER BY SORequestDate DESC) AS SORequestRowNumber,
    '{{ invocation_id }}' AS AUDIT_LOG_ID
        , SHA2('hash_me') as _ROW_HASH
-- Adds column to table on full refresh.
FROM source_data
    )

,type_data as 
(
    select
        cast(DOCUMENTID as NUMBER(38,0)) as DOCUMENTID,
        cast(SOREQUESTDATE as TIMESTAMP_NTZ(9)) as SOREQUESTDATE,
        cast(SONUMBER as VARCHAR(16777216)) as SONUMBER,
        cast(REQUESTOR as VARCHAR(16777216)) as REQUESTOR,
        cast(CUSTOMERFABGROUP as VARCHAR(16777216)) as CUSTOMERFABGROUP,
        cast(CUSTOMERFABOFFICE as VARCHAR(16777216)) as CUSTOMERFABOFFICE,
        cast(FAB as VARCHAR(16777216)) as FAB,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(QUOTENUMBER as VARCHAR(16777216)) as QUOTENUMBER,
        cast(CUSTOMERFAB as VARCHAR(16777216)) as CUSTOMERFAB,
        cast(ESTIMATEDHOURS as NUMBER(38,10)) as ESTIMATEDHOURS,
        cast(SOSTART as TIMESTAMP_NTZ(9)) as SOSTART,
        cast(SOEND as TIMESTAMP_NTZ(9)) as SOEND,
        cast(BUSINESS as VARCHAR(16777216)) as BUSINESS,
        cast(SERVICETYPE as VARCHAR(16777216)) as SERVICETYPE,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(SERIALNUMBER as VARCHAR(16777216)) as SERIALNUMBER,
        cast(CREDITCHECK as VARCHAR(16777216)) as CREDITCHECK,
        cast(DECOMISSION as VARCHAR(16777216)) as DECOMISSION,
        cast(REQUESTCOMMENTS as VARCHAR(16777216)) as REQUESTCOMMENTS,
        cast(SIGCOMMENTS as VARCHAR(16777216)) as SIGCOMMENTS,
        cast(FIELDUPDATES as VARCHAR(16777216)) as FIELDUPDATES,
        cast(SIGNOTESTOFIELD as VARCHAR(16777216)) as SIGNOTESTOFIELD,
        cast(TOTALTSRAMOUNTINPUT as NUMBER(38,10)) as TOTALTSRAMOUNTINPUT,
        cast(INVOICINGSTATUS as VARCHAR(16777216)) as INVOICINGSTATUS,
        cast(TSRAMOUNT as NUMBER(38,10)) as TSRAMOUNT,
        cast(POINMODULECONFIGURATION as VARCHAR(16777216)) as POINMODULECONFIGURATION,
        cast(SOREQUESTROWNUMBER as NUMBER(38,0)) as SOREQUESTROWNUMBER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data