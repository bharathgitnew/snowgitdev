{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='ARIBA_REQUISITIONAPPROVALRECORD',
    unique_key = []
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS RequisitionIDKey
        ,JsonField:Version::INTEGER AS RequisitionVersionKey
        ,ApprovalRecord.value:ActivationDate::TIMESTAMP_NTZ AS ActivationDate
        ,ApprovalRecord.value:Comment:Date::TIMESTAMP_NTZ AS CommentDate
        ,ApprovalRecord.value:Comment:ExternalComment::STRING AS CommentExternalComment
        ,ApprovalRecord.value:Comment:Title::STRING AS CommentTitle
        ,ApprovalRecord.value:Comment:User:UniqueName::STRING AS CommentUserCode
        ,ApprovalRecord.value:Date::TIMESTAMP_NTZ AS Date
        ,ApprovalRecord.value:RealUser::STRING AS RealUser
        ,ApprovalRecord.value:ReceivedFromEmail::STRING AS ReceivedFromEmail
        ,ApprovalRecord.value:State::INTEGER AS State
        ,ApprovalRecord.value:User:UniqueName::STRING AS UserCode
        FROM {{ source("ARIBA", "REQUISITION") }} LZData
        ,LATERAL FLATTEN (input => parse_json(JsonField:ApprovalRecords)) ApprovalRecord
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                        regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                        ,LZData.JSonField:UniqueName::STRING
                        ,LZData.JSonField:Version::INTEGER
                        ,ApprovalRecord.value:ActivationDate::TIMESTAMP_NTZ
                    ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
        )
,transform_data as
(
    SELECT
        source_data.ACTIVATIONDATE,
        source_data.COMMENTDATE,
        source_data.COMMENTEXTERNALCOMMENT,
        source_data.COMMENTTITLE,
        source_data.COMMENTUSERCODE,
        source_data.DATE,
        'No' as ISHISTORICAL,
        source_data.LASTUPDATED,
        source_data.REALUSER,
        source_data.REALMNAME,
        source_data.RECEIVEDFROMEMAIL,
        IFNULL( source_data.USERCODE ,'---') ||':'|| IFNULL( TO_VARCHAR(source_data.ACTIVATIONDATE,'YYYYMMDD-HH24MISS'),'---') as REQUISITIONAPPROVALRECORDKEY,
        source_data.REQUISITIONIDKEY,
        source_data.REQUISITIONVERSIONKEY,
        source_data.STATE,
        source_data.USERCODE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as
(
    select
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(REALMNAME as VARCHAR(16777216)) as REALMNAME,
        cast(REQUISITIONIDKEY as VARCHAR(16777216)) as REQUISITIONIDKEY,
        cast(REQUISITIONVERSIONKEY as NUMBER(38,0)) as REQUISITIONVERSIONKEY,
        cast(REQUISITIONAPPROVALRECORDKEY as VARCHAR(16777216)) as REQUISITIONAPPROVALRECORDKEY,
        cast(ACTIVATIONDATE as TIMESTAMP_NTZ(9)) as ACTIVATIONDATE,
        cast(COMMENTDATE as TIMESTAMP_NTZ(9)) as COMMENTDATE,
        cast(COMMENTEXTERNALCOMMENT as VARCHAR(16777216)) as COMMENTEXTERNALCOMMENT,
        cast(COMMENTTITLE as VARCHAR(16777216)) as COMMENTTITLE,
        cast(COMMENTUSERCODE as VARCHAR(16777216)) as COMMENTUSERCODE,
        cast(DATE as TIMESTAMP_NTZ(9)) as DATE,
        cast(REALUSER as VARCHAR(16777216)) as REALUSER,
        cast(RECEIVEDFROMEMAIL as VARCHAR(16777216)) as RECEIVEDFROMEMAIL,
        cast(STATE as NUMBER(38,0)) as STATE,
        cast(USERCODE as VARCHAR(16777216)) as USERCODE,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select distinct * from type_data