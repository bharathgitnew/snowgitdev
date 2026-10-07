{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_INVOICEAPPROVALRECORD',
    unique_key = ['RealmName',
    'InvoiceIdKey',
    'InvoiceVersionKey',
    'InvoiceApprovalRecordKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::STRING::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS InvoiceIdKey
        ,JsonField:VersionNumber::NUMBER(38,10) AS InvoiceVersionKey
        ,ApprovalRecord.value:ActivationDate::TIMESTAMP_NTZ AS ActivationDate
        ,ApprovalRecord.value:Comment:Date::TIMESTAMP_NTZ AS CommentDate
        ,ApprovalRecord.value:Comment:ExternalComment::STRING AS CommentExternalComment
        ,ApprovalRecord.value:Comment:Title::STRING AS CommentTitle
        ,ApprovalRecord.value:Comment:UserUniqueName::STRING AS CommentUserCode
        ,ApprovalRecord.value:Date::TIMESTAMP_NTZ AS Date
        ,ApprovalRecord.value:RealUser::STRING AS RealUserName
        ,ApprovalRecord.value:ReceivedFromEmail::STRING AS ReceivedFromEmail
        ,ApprovalRecord.value:State::INTEGER AS State
        ,ApprovalRecord.value:User:UniqueName::STRING AS UserCode
        FROM {{ source("ARIBA", "INVOICE") }} LZData
        ,LATERAL FLATTEN (input => parse_json(JsonField:ApprovalRecords)) ApprovalRecord
        WHERE 1=2
        /* Adding false filter to the model so that we can enable it for DBT Project Consolidation, related to changes in k-card 34754 */

        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                                --,LineItem.value:NumberInCollection::INTEGER
                                ,ApprovalRecord.value:ActivationDate::TIMESTAMP_NTZ
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
)
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.INVOICEIDKEY AS InvoiceIdKey,
        source_data.INVOICEVERSIONKEY AS InvoiceVersionKey,
        source_data.ACTIVATIONDATE AS InvoiceApprovalRecordKey,
        source_data.ACTIVATIONDATE AS ActivationDate,
        source_data.COMMENTDATE AS CommentDate,
        source_data.COMMENTEXTERNALCOMMENT AS CommentExternalComment,
        source_data.COMMENTTITLE AS CommentTitle,
        source_data.COMMENTUSERCODE AS CommentUser,
        source_data.DATE AS Date,
        source_data.REALUSERNAME AS RealUser,
        source_data.RECEIVEDFROMEMAIL AS ReceivedFromEmail,
        source_data.STATE AS State,
        source_data.USERCODE AS User,
        'No' AS IsHistorical,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        REALMNAME,
        INVOICEIDKEY,
        cast(INVOICEVERSIONKEY as NUMBER(38,0)) as INVOICEVERSIONKEY,
        cast(ACTIVATIONDATE as TIMESTAMP_NTZ(9)) as ACTIVATIONDATE,
        cast(COMMENTDATE as TIMESTAMP_NTZ(9)) as COMMENTDATE,
        COMMENTEXTERNALCOMMENT,
        COMMENTTITLE,
        COMMENTUSER,
        cast(DATE as TIMESTAMP_NTZ(9)) as DATE,
        REALUSER,
        RECEIVEDFROMEMAIL,
        cast(STATE as NUMBER(38,0)) as STATE,
        USER,
        cast(INVOICEAPPROVALRECORDKEY as TIMESTAMP_NTZ(9)) as INVOICEAPPROVALRECORDKEY,
        ISHISTORICAL
    from transform_data
    )
select distinct * from type_data