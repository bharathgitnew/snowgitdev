/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-Baan\Address.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\baan\ADDRESS.SQL
-materialized incremental
-alias ADDRESS
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema BAAN
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 1/24/2022 3:52:09 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ADDRESS',
    unique_key = ['AddressId']
) }}

with source_data as
(       SELECT
        BAANCOMMONCOMMONDATA_ADDRESSES.ADDRESSCODE AS AddressId,
        BAANCOMMONCOMMONDATA_ADDRESSES.NAME AS Name,
        BAANCOMMONCOMMONDATA_ADDRESSES.NAME2 AS Name2,
        BAANCOMMONCOMMONDATA_ADDRESSES.ADDRESS AS Address,
        BAANCOMMONCOMMONDATA_ADDRESSES.ADDRESS2 AS Address2,
        BAANCOMMONCOMMONDATA_ADDRESSES.HOUSENUMBER AS HouseNumber,
        BAANCOMMONCOMMONDATA_ADDRESSES.POBOXNUMBER AS POBoxNumber,
        BAANCOMMONCOMMONDATA_ADDRESSES.CITY AS City,
        BAANCOMMONCOMMONDATA_ADDRESSES.CITY2 AS City2,
        BAANCOMMONCOMMONDATA_ADDRESSES.ZIPCODEPOSTALCODE AS ZipCodePostalCode,
        BAANCOMMONCOMMONDATA_ADDRESSES.TELEPHONE AS Telephone,
        BAANCOMMONCOMMONDATA_ADDRESSES.TELEX AS Telex,
        BAANCOMMONCOMMONDATA_ADDRESSES.FAX AS Fax,
        BAANCOMMONCOMMONDATA_ADDRESSES.COUNTRY AS Country,
        BAANCOMMONCOMMONDATA_ADDRESSES.STATEPROVINCE AS StateProvince,
        BAANCOMMONCOMMONDATA_ADDRESSES.SEARCHKEY AS SearchKey,
        BAANCOMMONCOMMONDATA_ADDRESSES.TAXNUMBER AS TaxNumber,
        BAANCOMMONCOMMONDATA_ADDRESSES.VERIFICATIONDATE AS VerificationDate,
        BAANCOMMONCOMMONDATA_ADDRESSES.ADDRESSFORMAT AS AddressFormat,
        BAANCOMMONCOMMONDATA_ADDRESSES.GEOCODE AS GeoCode,
        BAANCOMMONCOMMONDATA_ADDRESSES.TIMEZONE AS Timezone,
        BAANCOMMONCOMMONDATA_ADDRESSES.INTERNET AS Internet,
        BAANCOMMONCOMMONDATA_ADDRESSES.E_MAIL AS EMail,
        BAANCOMMONCOMMONDATA_ADDRESSES.TEXT AS Text
        FROM {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_ADDRESSES') }} BAANCOMMONCOMMONDATA_ADDRESSES    
    )
,transform_data as
(
        SELECT 
        TaxNumber,
        Address2,
        Timezone,
        AddressFormat,
        Address,
        ZipCodePostalCode,
        VerificationDate,
        City,
        EMail,
        Telex,
        Text,
        GeoCode,
        POBoxNumber,
        Name2,
        City2,
        SearchKey,
        HouseNumber,
        AddressId,
        Internet,
        Telephone,
        StateProvince,
        Country,
        Name,
        Fax,
        ROW_NUMBER() OVER (ORDER BY 1) AS SRC_ROW_NUMBER, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
       SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(ADDRESSID as VARCHAR(16777216)) as ADDRESSID,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(NAME2 as VARCHAR(16777216)) as NAME2,
        cast(ADDRESS as VARCHAR(16777216)) as ADDRESS,
        cast(ADDRESS2 as VARCHAR(16777216)) as ADDRESS2,
        cast(HOUSENUMBER as VARCHAR(16777216)) as HOUSENUMBER,
        cast(POBOXNUMBER as VARCHAR(16777216)) as POBOXNUMBER,
        cast(CITY as VARCHAR(16777216)) as CITY,
        cast(CITY2 as VARCHAR(16777216)) as CITY2,
        cast(ZIPCODEPOSTALCODE as VARCHAR(16777216)) as ZIPCODEPOSTALCODE,
        cast(TELEPHONE as VARCHAR(16777216)) as TELEPHONE,
        cast(TELEX as VARCHAR(16777216)) as TELEX,
        cast(FAX as VARCHAR(16777216)) as FAX,
        cast(COUNTRY as VARCHAR(16777216)) as COUNTRY,
        cast(STATEPROVINCE as VARCHAR(16777216)) as STATEPROVINCE,
        cast(SEARCHKEY as VARCHAR(16777216)) as SEARCHKEY,
        cast(TAXNUMBER as VARCHAR(16777216)) as TAXNUMBER,
        cast(VERIFICATIONDATE as TIMESTAMP_NTZ(9)) as VERIFICATIONDATE,
        cast(ADDRESSFORMAT as VARCHAR(16777216)) as ADDRESSFORMAT,
        cast(GEOCODE as VARCHAR(16777216)) as GEOCODE,
        cast(TIMEZONE as VARCHAR(16777216)) as TIMEZONE,
        cast(INTERNET as VARCHAR(16777216)) as INTERNET,
        cast(EMAIL as VARCHAR(16777216)) as EMAIL,
        cast(TEXT as NUMBER(38,0)) as TEXT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data