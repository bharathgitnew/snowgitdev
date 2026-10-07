{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_TEL_GS_BOOKING_BUDGET_FORECAST',
    unique_key = ['']
) }}

with source_data as
(

    
        SELECT
        FISCALYEAR,
        QUARTER,
        BOOKINGMONTH,
        BUSINESSUNITCODE,
        KA,
        BUSINESSUNITNAME,
        SUBBUSINESSUNITNAME,
        SALESORDERNUMBER,
        ACCOUNTCODE,
        ACCOUNTNAME,
        CUSTOMERCODE,
        CUSTOMERNAME,
        ENDUSERCODE,
        ENDUSERNAME,
        OPPORTUNITY,
        PRODUCTNAME,
        LEVEL,
        LEVEL2,
        BOOKINGAMOUNT,
        BOOKINGAMOUNT100M,
        QUANTITY,
        EUROPEREQUESTDATE,
        DELIVERYDATE,
        CUSTOMCLEARENCEDATE,
        ONDOCKDATE,
        SALESDATE,
        MACHINESERIALNUMBER,
        SALESCATEGORYCODE,
        SALESCATEGORYNAME,
        AREA,
        AREANAME,
        DISTRIBUTIONFLAG,
        LOANFLAG,
        CSTFLAG,
        INVESTMENTCODE,
        PROCESSOFRECORD,
        BACKUP,
        DEGREEOFSALESUNCERTAINTY,
        INVESTMENTSUBCODE,
        DEVICE1CODE,
        DEVICE1NAME,
        DEVICE2CODE,
        DEVICE2NAME,
        _FILENAME
    FROM
    {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SALES_OPERATIONS_TEL_GS_BOOKING_BUDGET_FORECAST') }} 
)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        FISCALYEAR,
        QUARTER,
        case
        when length(BOOKINGMONTH) = 10
        then try_to_date(BOOKINGMONTH, 'yyyy-mm-dd')
        when length(BOOKINGMONTH) = 9
        then try_to_date(BOOKINGMONTH, 'mm/dd/yyyy')
        when length(BOOKINGMONTH) = 8
        then try_to_date(BOOKINGMONTH, 'mm/dd/yyyy')
        when length(BOOKINGMONTH) = 7
        then try_to_date(BOOKINGMONTH, 'yyyy/mm')
        else null
        end as BOOKINGMONTH,
        BUSINESSUNITCODE,
        case when length(BUSINESSUNITCODE)=2
        then cast(BUSINESSUNITCODE as text)
        end as BUSINESSUNITCODE_TEXT,
        KA,
        BUSINESSUNITNAME,
        SUBBUSINESSUNITNAME,
        SPLIT_PART(BUSINESSUNITCODE, '-', 3) AS SUBSUSINESSUNITNAME2,
        SALESORDERNUMBER,
        ACCOUNTCODE,
        ACCOUNTNAME,
        CUSTOMERCODE,
        CUSTOMERNAME,
        ENDUSERCODE,
        ENDUSERNAME,
        OPPORTUNITY,
        PRODUCTNAME,
        LEVEL,
        LEVEL2,
        try_to_number(regexp_replace(BOOKINGAMOUNT,','),38,2) as BOOKINGAMOUNT,
        try_to_number(BOOKINGAMOUNT100M,38,0) as BOOKINGAMOUNT100M,
        try_to_number(QUANTITY,38,0) as QUANTITY,
        try_to_date(EUROPEREQUESTDATE,'yyyy-mm-dd') as EUROPEREQUESTDATE,
        try_to_date(DELIVERYDATE,'yyyy-mm-dd') as DELIVERYDATE,
        case
        when length(CUSTOMCLEARENCEDATE)=5
        then dateadd(day,CUSTOMCLEARENCEDATE,to_date('1900-01-01'))
        when length(CUSTOMCLEARENCEDATE)=8 and CUSTOMCLEARENCEDATE like '%/%'
        then try_to_date(to_varchar(try_to_date(CUSTOMCLEARENCEDATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(CUSTOMCLEARENCEDATE)=8
        then try_to_date(CUSTOMCLEARENCEDATE,'yyyymmdd')
        when length(CUSTOMCLEARENCEDATE)=9
        then try_to_date(to_varchar(try_to_date(CUSTOMCLEARENCEDATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(CUSTOMCLEARENCEDATE)=10 and regexp_count(CUSTOMCLEARENCEDATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(CUSTOMCLEARENCEDATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(CUSTOMCLEARENCEDATE)=10 and regexp_count(CUSTOMCLEARENCEDATE,'/',4)=0
        then try_to_date(to_varchar(try_to_date(CUSTOMCLEARENCEDATE,'yyyy-mm-dd'),'yyyymmdd'),'yyyymmdd')
        when length(CUSTOMCLEARENCEDATE)=10 and regexp_count(CUSTOMCLEARENCEDATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(CUSTOMCLEARENCEDATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as CUSTOMCLEARENCEDATE,
        case
        when length(ONDOCKDATE)=5
        then dateadd(day,ONDOCKDATE,to_date('1900-01-01'))
        when length(ONDOCKDATE)=8 and ONDOCKDATE like '%/%'
        then try_to_date(to_varchar(try_to_date(ONDOCKDATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(ONDOCKDATE)=8
        then try_to_date(ONDOCKDATE,'yyyymmdd')
        when length(ONDOCKDATE)=9
        then try_to_date(to_varchar(try_to_date(ONDOCKDATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(ONDOCKDATE)=10 and regexp_count(ONDOCKDATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(ONDOCKDATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(ONDOCKDATE)=10 and regexp_count(ONDOCKDATE,'/',4)=0
        then try_to_date(to_varchar(try_to_date(ONDOCKDATE,'yyyy-mm-dd'),'yyyymmdd'),'yyyymmdd')
        when length(ONDOCKDATE)=10 and regexp_count(ONDOCKDATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(ONDOCKDATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as ONDOCKDATE,
        case
        when length(SALESDATE)=5
        then dateadd(day,SALESDATE,to_date('1900-01-01'))
        when length(SALESDATE)=8 and SALESDATE like '%/%'
        then try_to_date(to_varchar(try_to_date(SALESDATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SALESDATE)=8
        then try_to_date(SALESDATE,'yyyymmdd')
        when length(SALESDATE)=9
        then try_to_date(to_varchar(try_to_date(SALESDATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        when length(SALESDATE)=10 and regexp_count(SALESDATE,'/',4)=2
        then try_to_date(to_varchar(try_to_date(SALESDATE,'yyyy/mm/dd'),'yyyymmdd'),'yyyymmdd')
        when length(SALESDATE)=10 and regexp_count(SALESDATE,'/',4)=0
        then try_to_date(to_varchar(try_to_date(SALESDATE,'yyyy-mm-dd'),'yyyymmdd'),'yyyymmdd')
        when length(SALESDATE)=10 and regexp_count(SALESDATE,'\\D+',2)=2
        then try_to_date(to_varchar(try_to_date(SALESDATE,'mm/dd/yyyy'),'yyyymmdd'),'yyyymmdd')
        else null
        end as SALESDATE,
        MACHINESERIALNUMBER,
        SALESCATEGORYCODE,
        SALESCATEGORYNAME,
        AREA,
        AREANAME,
        DISTRIBUTIONFLAG,
        LOANFLAG,
        CSTFLAG,
        INVESTMENTCODE,
        PROCESSOFRECORD,
        BACKUP,
        DEGREEOFSALESUNCERTAINTY,
        INVESTMENTSUBCODE,
        DEVICE1CODE,
        DEVICE1NAME,
        DEVICE2CODE,
        DEVICE2NAME,
        _FILENAME,
        to_date(regexp_substr(_FILENAME,'\\d+++++++'),'YYYYMMDD') as _FILEDATE,
        CASE WHEN _FILENAME LIKE '%Budget%' THEN 'BUDGET'
        WHEN _FILENAME LIKE '%Actual%' THEN 'ACTUAL'
        ELSE 'FORECAST'
        end	AS SOURCETYPE
FROM source_data
)
,type_data as 
(select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(FISCALYEAR as VARCHAR(16777216)) as FISCALYEAR,
        cast(QUARTER as VARCHAR(16777216)) as QUARTER,
        cast(BOOKINGMONTH as TIMESTAMP_NTZ(9)) as BOOKINGMONTH,
        cast(BUSINESSUNITCODE as VARCHAR(16777216)) as BUSINESSUNITCODE,
        cast(BUSINESSUNITCODE_TEXT as VARCHAR(16777216)) as BUSINESSUNITCODE_TEXT,
        cast(KA as VARCHAR(16777216)) as KA,
        cast(BUSINESSUNITNAME as VARCHAR(16777216)) as BUSINESSUNITNAME,
        cast(SUBBUSINESSUNITNAME as VARCHAR(16777216)) as SUBBUSINESSUNITNAME,
        cast(SUBSUSINESSUNITNAME2 as VARCHAR(16777216)) as SUBUSINESSUNITNAME2,
        cast(SALESORDERNUMBER as VARCHAR(16777216)) as SALESORDERNUMBER,
        cast(ACCOUNTCODE as VARCHAR(16777216)) as ACCOUNTCODE,
        cast(ACCOUNTNAME as VARCHAR(16777216)) as ACCOUNTNAME,
        cast(CUSTOMERCODE as VARCHAR(16777216)) as CUSTOMERCODE,
        cast(CUSTOMERNAME as VARCHAR(16777216)) as CUSTOMERNAME,
        cast(ENDUSERCODE as VARCHAR(16777216)) as ENDUSERCODE,
        cast(ENDUSERNAME as VARCHAR(16777216)) as ENDUSERNAME,
        cast(OPPORTUNITY as VARCHAR(16777216)) as OPPORTUNITY,
        cast(PRODUCTNAME as VARCHAR(16777216)) as PRODUCTNAME,
        cast(LEVEL as VARCHAR(16777216)) as LEVEL,
        cast(LEVEL2 as VARCHAR(16777216)) as LEVEL2,
        cast(BOOKINGAMOUNT as NUMBER(38,0)) as BOOKINGAMOUNT,
        cast(BOOKINGAMOUNT100M as NUMBER(38,0)) as BOOKINGAMOUNT100M,
        cast(QUANTITY as NUMBER(38,0)) as QUANTITY,
        cast(EUROPEREQUESTDATE as TIMESTAMP_NTZ(9)) as EUROPEREQUESTDATE,
        cast(DELIVERYDATE as TIMESTAMP_NTZ(9)) as DELIVERYDATE,
        cast(CUSTOMCLEARENCEDATE as TIMESTAMP_NTZ(9)) as CUSTOMCLEARENCEDATE,
        cast(ONDOCKDATE as TIMESTAMP_NTZ(9)) as ONDOCKDATE,
        cast(SALESDATE as TIMESTAMP_NTZ(9)) as SALESDATE,
        cast(MACHINESERIALNUMBER as VARCHAR(16777216)) as MACHINESERIALNUMBER,
        cast(SALESCATEGORYCODE as VARCHAR(16777216)) as SALESCATEGORYCODE,
        cast(SALESCATEGORYNAME as VARCHAR(16777216)) as SALESCATEGORYNAME,
        cast(AREA as VARCHAR(16777216)) as AREA,
        cast(AREANAME as VARCHAR(16777216)) as AREANAME,
        cast(DISTRIBUTIONFLAG as VARCHAR(16777216)) as DISTRIBUTIONFLAG,
        cast(LOANFLAG as VARCHAR(16777216)) as LOANFLAG,
        cast(CSTFLAG as VARCHAR(16777216)) as CSTFLAG,
        cast(INVESTMENTCODE as VARCHAR(16777216)) as INVESTMENTCODE,
        cast(PROCESSOFRECORD as VARCHAR(16777216)) as PROCESSOFRECORD,
        cast(BACKUP as VARCHAR(16777216)) as BACKUP,
        cast(DEGREEOFSALESUNCERTAINTY as VARCHAR(16777216)) as DEGREEOFSALESUNCERTAINTY,
        cast(INVESTMENTSUBCODE as VARCHAR(16777216)) as INVESTMENTSUBCODE,
        cast(DEVICE1CODE as VARCHAR(16777216)) as DEVICE1CODE,
        cast(DEVICE1NAME as VARCHAR(16777216)) as DEVICE1NAME,
        cast(DEVICE2CODE as VARCHAR(16777216)) as DEVICE2CODE,
        cast(DEVICE2NAME as VARCHAR(16777216)) as DEVICE2NAME,
        cast(_FILENAME as VARCHAR(16777216)) as _FILENAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(SOURCETYPE as VARCHAR(8)) as SOURCETYPE
from transform_data
    )
select * from type_data