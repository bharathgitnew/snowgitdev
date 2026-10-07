{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='DATASETS'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename,
        _Filedate as _Filedate,
        jsonfield:"@odata.context"::string as Context,
        jsonfield:"@odata.count"::string as Count,
        r.value:"addRowsAPIEnabled"::string as AddRowsAPIEnabled,
        r.value:"configuredBy"::string as Configured_By,
        r.value:"contentProviderType"::string as ContentProviderType,
        r.value:"createReportEmbedURL"::string as CreateReportEmbedURL,
        r.value:"createdDate"::string as CreatedDate,
        r.value:"id"::string as ID,
        r.value:"isEffectiveIdentityRequired"::string as IsEffectiveIdentityRequired,
        r.value:"isEffectiveIdentityRolesRequired"::string as IsEffectiveIdentityRolesRequired,
        r.value:"isInPlaceSharingEnabled"::string as IsInPlaceSharingEnabled,
        r.value:"isRefreshable"::string as IsRefreshable,
        r.value:"name"::string as Name,
        r.value:"queryScaleOutSettings"::string as QueryScaleOutSettings,
        r.value:"queryScaleOutSettings"."autoSyncReadOnlyReplicas"::string as AutoSyncReadOnlyReplicas,
        r.value:"queryScaleOutSettings"."maxReadOnlyReplicas"::string as MaxReadOnlyReplicas,
        r.value:"targetStorageMode"::string as TargetStorageMode,
        r.value:"upstreamDatasets"::string as UpstreamDatasets,
        r.value:"users"::string as Users,
        r.value:"webUrl"::string as WebURL,
        r.value:"workspaceId"::string as WorkspaceId
    FROM {{ source("POWERBI", "DATASETS") }} Dt,
        lateral flatten ( input => dt.jsonfield:"value", outer => true) r
)
,transform_data as
(
    SELECT
        _FILENAME as _FILENAME,
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        Context,
        Count,
        AddRowsAPIEnabled AS AddRows_API_Enabled,
        Configured_By AS CONFIGURED_BY,
        ContentProviderType AS CONTENTPROVIDER_TYPE,
        CreateReportEmbedURL AS CREATEREPORT_EMBEDURL,
        CreatedDate AS CREATED_DATE,
        ID,
        IsEffectiveIdentityRequired AS ISEFFECTIVE_IDENTITYREQUIRED,
        IsEffectiveIdentityRolesRequired AS ISEFFECTIVE_IDENTITYROLESREQUIRED,
        IsInPlaceSharingEnabled AS ISINPLACE_SHARINGENABLED,
        IsRefreshable AS IS_REFRESHABLE,
        Name,
        QueryScaleOutSettings AS QUERY_SCALEOUT_SETTINGS,
        AutoSyncReadOnlyReplicas AS AUTOSYNC_READONLYREPLICAS,
        MaxReadOnlyReplicas AS MAX_READONLYREPLICAS,
        TargetStorageMode AS TARGET_STORAGE_MODE,
        UpstreamDatasets AS UPSTREAM_DATASETS,
        Users AS USERS,
        WebURL AS WEB_URL,
        WorkspaceId AS WORKSPACE_ID
    FROM source_data
)
, type_data AS
(
    SELECT
        CAST(_Audit_Log_Id AS VARCHAR(128))  AS _Audit_Log_Id,
        CAST(_Row_Hash AS VARCHAR(128))  AS _Row_Hash,
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE,
        Context,
        Count,
        AddRows_API_Enabled,
        CONFIGURED_BY,
        CONTENTPROVIDER_TYPE,
        CREATEREPORT_EMBEDURL,
        CREATED_DATE,
        ID,
        ISEFFECTIVE_IDENTITYREQUIRED,
        ISEFFECTIVE_IDENTITYROLESREQUIRED,
        ISINPLACE_SHARINGENABLED,
        IS_REFRESHABLE,
        Name,
        QUERY_SCALEOUT_SETTINGS,
        AUTOSYNC_READONLYREPLICAS,
        MAX_READONLYREPLICAS,
        TARGET_STORAGE_MODE,
        UPSTREAM_DATASETS,
        USERS,
        WEB_URL,
        WORKSPACE_ID
    FROM transform_data
)
select * from type_data