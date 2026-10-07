/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONENTERPRISEMANAGEMENTMODULE_COMPANIES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONENTERPRISEMANAGEMENTMODULE_COMPANIES.SQL 
-materialized incremental
-alias BAANCOMMONENTERPRISEMANAGEMENTMODULE_COMPANIES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCOMMONENTERPRISEMANAGEMENTMODULE_COMPANIES',
    unique_key = ['COMPANY']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                         AS CALENDARCODE 
            ,CAST(T$COMP AS INT)                                                                                                                 AS COMPANY 
            ,T$CTYP.CONSTANTDESCRIPTION                                                                                                          AS COMPANYTYPEDESCRIPTION 
            ,CAST(T$CTYP AS INT)                                                                                                                 AS COMPANYTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLCU)),'')                                                                                         AS CREDITLIMITCURRENCY 
            ,T$CSYS.CONSTANTDESCRIPTION                                                                                                          AS CURRENCYSYSTEMDESCRIPTION 
            ,CAST(T$CSYS AS INT)                                                                                                                 AS CURRENCYSYSTEMID 
            ,T$CTYA.CONSTANTDESCRIPTION                                                                                                          AS CURRENCYTYPE_CTYADESCRIPTION 
            ,CAST(T$CTYA AS INT)                                                                                                                 AS CURRENCYTYPE_CTYAID 
            ,T$CTYB.CONSTANTDESCRIPTION                                                                                                          AS CURRENCYTYPE_CTYBDESCRIPTION 
            ,CAST(T$CTYB AS INT)                                                                                                                 AS CURRENCYTYPE_CTYBID 
            ,T$CTYC.CONSTANTDESCRIPTION                                                                                                          AS CURRENCYTYPE_CTYCDESCRIPTION 
            ,CAST(T$CTYC AS INT)                                                                                                                 AS CURRENCYTYPE_CTYCID 
            ,CAST(CASE WHEN T$DATE<= '1/1/1970' THEN NULL ELSE T$DATE  END AS DATETIME) AS DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION_percent_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EURO)),'')                                                                                         AS EUROCURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EXEU)),'')                                                                                         AS EXCHANGERATETYPEEUTRANSACTIONS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EXPU)),'')                                                                                         AS EXCHANGERATETYPEPURCHASE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EXSA)),'')                                                                                         AS EXCHANGERATETYPESALES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FCUA)),'')                                                                                         AS LOCALCURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LCUR)),'')                                                                                         AS LOGISTICCURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FCUB)),'')                                                                                         AS REPORTINGCURRENCY1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FCUC)),'')                                                                                         AS REPORTINGCURRENCY2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TZID)),'')                                                                                         AS TIMEZONECODE 
            ,T$TTRC.CONSTANTDESCRIPTION                                                                                                          AS USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESDESCRIPTION 
            ,CAST(T$TTRC AS INT)                                                                                                                   AS USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESID 
           
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCEMM170200") }} AS SOURCETABLE  
            /*COMPANYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYP 
             ON   T$CTYP.TABLENAME  = 'TCEMM170' 
              AND T$CTYP.COLUMNNAME = 'T$CTYP' 
              AND T$CTYP.CONSTANT   = SOURCETABLE.T$CTYP 
            /*CURRENCYSYSTEM*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CSYS 
             ON   T$CSYS.TABLENAME  = 'TCEMM170' 
              AND T$CSYS.COLUMNNAME = 'T$CSYS' 
              AND T$CSYS.CONSTANT   = SOURCETABLE.T$CSYS 
            /*CURRENCYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYA 
             ON   T$CTYA.TABLENAME  = 'TCEMM170' 
              AND T$CTYA.COLUMNNAME = 'T$CTYA' 
              AND T$CTYA.CONSTANT   = SOURCETABLE.T$CTYA 
            /*CURRENCYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYB 
             ON   T$CTYB.TABLENAME  = 'TCEMM170' 
              AND T$CTYB.COLUMNNAME = 'T$CTYB' 
              AND T$CTYB.CONSTANT   = SOURCETABLE.T$CTYB 
            /*CURRENCYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYC 
             ON   T$CTYC.TABLENAME  = 'TCEMM170' 
              AND T$CTYC.COLUMNNAME = 'T$CTYC' 
              AND T$CTYC.CONSTANT   = SOURCETABLE.T$CTYC 
            /*USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIES*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TTRC 
             ON   T$TTRC.TABLENAME  = 'TCEMM170' 
              AND T$TTRC.COLUMNNAME = 'T$TTRC' 
              AND T$TTRC.CONSTANT   = SOURCETABLE.T$TTRC 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CALENDARCODE AS CALENDARCODE, 
        source_data.COMPANY AS COMPANY, 
        source_data.COMPANYTYPEDESCRIPTION AS COMPANYTYPEDESCRIPTION, 
        source_data.COMPANYTYPEID AS COMPANYTYPEID, 
        source_data.CREDITLIMITCURRENCY AS CREDITLIMITCURRENCY, 
        source_data.CURRENCYSYSTEMDESCRIPTION AS CURRENCYSYSTEMDESCRIPTION, 
        source_data.CURRENCYSYSTEMID AS CURRENCYSYSTEMID, 
        source_data.CURRENCYTYPE_CTYADESCRIPTION AS CURRENCYTYPE_CTYADESCRIPTION, 
        source_data.CURRENCYTYPE_CTYAID AS CURRENCYTYPE_CTYAID, 
        source_data.CURRENCYTYPE_CTYBDESCRIPTION AS CURRENCYTYPE_CTYBDESCRIPTION, 
        source_data.CURRENCYTYPE_CTYBID AS CURRENCYTYPE_CTYBID, 
        source_data.CURRENCYTYPE_CTYCDESCRIPTION AS CURRENCYTYPE_CTYCDESCRIPTION, 
        source_data.CURRENCYTYPE_CTYCID AS CURRENCYTYPE_CTYCID, 
        source_data.DATE AS DATE, 
        source_data.DESCRIPTION_PERCENT_ AS DESCRIPTION_PERCENT_, 
        source_data.EUROCURRENCY AS EUROCURRENCY, 
        source_data.EXCHANGERATETYPEEUTRANSACTIONS AS EXCHANGERATETYPEEUTRANSACTIONS, 
        source_data.EXCHANGERATETYPEPURCHASE AS EXCHANGERATETYPEPURCHASE, 
        source_data.EXCHANGERATETYPESALES AS EXCHANGERATETYPESALES, 
        source_data.LOCALCURRENCY AS LOCALCURRENCY, 
        source_data.LOGISTICCURRENCY AS LOGISTICCURRENCY, 
        source_data.REPORTINGCURRENCY1 AS REPORTINGCURRENCY1, 
        source_data.REPORTINGCURRENCY2 AS REPORTINGCURRENCY2, 
        source_data.TIMEZONECODE AS TIMEZONECODE, 
        source_data.USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESDESCRIPTION AS USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESDESCRIPTION, 
        source_data.USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESID AS USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CALENDARCODE as VARCHAR(9)) as CALENDARCODE,
        cast(COMPANY as NUMBER(38,0)) as COMPANY,
        cast(COMPANYTYPEDESCRIPTION as VARCHAR(16777216)) as COMPANYTYPEDESCRIPTION,
        cast(COMPANYTYPEID as NUMBER(38,0)) as COMPANYTYPEID,
        cast(CREDITLIMITCURRENCY as VARCHAR(3)) as CREDITLIMITCURRENCY,
        cast(CURRENCYSYSTEMDESCRIPTION as VARCHAR(16777216)) as CURRENCYSYSTEMDESCRIPTION,
        cast(CURRENCYSYSTEMID as NUMBER(38,0)) as CURRENCYSYSTEMID,
        cast(CURRENCYTYPE_CTYADESCRIPTION as VARCHAR(16777216)) as CURRENCYTYPE_CTYADESCRIPTION,
        cast(CURRENCYTYPE_CTYAID as NUMBER(38,0)) as CURRENCYTYPE_CTYAID,
        cast(CURRENCYTYPE_CTYBDESCRIPTION as VARCHAR(16777216)) as CURRENCYTYPE_CTYBDESCRIPTION,
        cast(CURRENCYTYPE_CTYBID as NUMBER(38,0)) as CURRENCYTYPE_CTYBID,
        cast(CURRENCYTYPE_CTYCDESCRIPTION as VARCHAR(16777216)) as CURRENCYTYPE_CTYCDESCRIPTION,
        cast(CURRENCYTYPE_CTYCID as NUMBER(38,0)) as CURRENCYTYPE_CTYCID,
        cast(DATE as TIMESTAMP_NTZ(9)) as DATE,
        cast(DESCRIPTION_PERCENT_ as VARCHAR(50)) as DESCRIPTION_PERCENT_,
        cast(EUROCURRENCY as VARCHAR(3)) as EUROCURRENCY,
        cast(EXCHANGERATETYPEEUTRANSACTIONS as VARCHAR(3)) as EXCHANGERATETYPEEUTRANSACTIONS,
        cast(EXCHANGERATETYPEPURCHASE as VARCHAR(3)) as EXCHANGERATETYPEPURCHASE,
        cast(EXCHANGERATETYPESALES as VARCHAR(3)) as EXCHANGERATETYPESALES,
        cast(LOCALCURRENCY as VARCHAR(3)) as LOCALCURRENCY,
        cast(LOGISTICCURRENCY as VARCHAR(3)) as LOGISTICCURRENCY,
        cast(REPORTINGCURRENCY1 as VARCHAR(3)) as REPORTINGCURRENCY1,
        cast(REPORTINGCURRENCY2 as VARCHAR(3)) as REPORTINGCURRENCY2,
        cast(TIMEZONECODE as VARCHAR(3)) as TIMEZONECODE,
        cast(USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESDESCRIPTION as VARCHAR(16777216)) as USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESDESCRIPTION,
        cast(USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESID as NUMBER(38,0)) as USEPURCHSALESRATETYPEBETWEENREFCURRENCYANDHOMECURRENCIESID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data