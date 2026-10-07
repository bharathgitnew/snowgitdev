/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_COSTCOMPONENTS.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_COSTCOMPONENTS.SQL
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_COSTCOMPONENTS
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCOMMONSYSTEMTABLES_COSTCOMPONENTS',
    unique_key = ['COSTCOMPONENT']
) }}


with source_data as
(
    SELECT
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME
            ,200                                           AS _COMPANYID
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'') AS COSTCOMPONENT
            ,T$CREF.CONSTANTDESCRIPTION                  AS COSTTYPEDESCRIPTION
            ,CAST(T$CREF AS INT)                         AS COSTTYPEID
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION

        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS048200") }} AS SOURCETABLE
            /*COSTTYPE*/
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CREF
             ON   T$CREF.TABLENAME  = 'TCMCS048'
              AND T$CREF.COLUMNNAME = 'T$CREF'
              AND T$CREF.CONSTANT   = SOURCETABLE.T$CREF
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        )
,	transform_data as
(
    SELECT
		source_data._CAPTUREDATETIME AS _CAPTUREDATETIME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		source_data.COSTCOMPONENT AS COSTCOMPONENT,
		source_data._COMPANYID AS _COMPANYID,
		source_data.COSTTYPEDESCRIPTION AS COSTTYPEDESCRIPTION,
		source_data.COSTTYPEID AS COSTTYPEID,
		source_data.DESCRIPTION AS DESCRIPTION 
        FROM source_data
        )
,	type_data as
(
    select
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
		cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
		cast(COSTTYPEDESCRIPTION as VARCHAR(16777216)) as COSTTYPEDESCRIPTION,
		cast(COSTTYPEID as NUMBER(38,0)) as COSTTYPEID,
		cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION
    from transform_data
    )
select * from type_data