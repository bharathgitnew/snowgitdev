/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTVALUES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTVALUES.SQL 
-materialized incremental
-alias BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTVALUES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:52 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTVALUES',
    unique_key = ['BUDGETACTUALCODE',
    'COMPANY',
    'DIMENSION1',
    'DIMENSION2',
    'DIMENSION3',
    'DIMENSION4',
    'DIMENSION5',
    'FINANCIALSTATEMENT',
    'HOMECURRENCY',
    'LEDGERACCOUNT',
    'PERIOD',
    'PERIODTYPEID',
    'STATEMENTACCOUNT',
    'YEAR']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$NBAH AS NUMERIC(15,2))                                                                                                       AS BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBAH 
            ,CAST(T$NBYD AS NUMERIC(15,2))                                                                                                       AS BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBYD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BUDG)),'')                                                                                         AS BUDGETACTUALCODE 
            ,CAST(T$FCOM AS INT)                                                                                                                 AS COMPANY 
            ,CAST(CASE WHEN T$DATE<= '1/1/1970' THEN NULL ELSE T$DATE  END AS DATETIME) AS DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D1DC)),'')                                                                                         AS DIMENSION1DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D2DC)),'')                                                                                         AS DIMENSION2DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D3DC)),'')                                                                                         AS DIMENSION3DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D4DC)),'')                                                                                         AS DIMENSION4DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D5DC)),'')                                                                                         AS DIMENSION5DESCRIPTION 
            ,CAST(T$FBAH AS NUMERIC(15,2))                                                                                                       AS FINALIZEDBALANCESHEETAMOUNT 
            ,CAST(T$FBYD AS NUMERIC(15,2))                                                                                                       AS FINALIZEDBALANCESHEETAMOUNTYEARTO_DATE 
            ,CAST(T$FCAH AS NUMERIC(15,2))                                                                                                       AS FINALIZEDCREDITAMOUNT 
            ,CAST(T$FCYD AS NUMERIC(15,2))                                                                                                       AS FINALIZEDCREDITAMOUNTYEARTO_DATE 
            ,CAST(T$FDAH AS NUMERIC(15,2))                                                                                                       AS FINALIZEDDEBITAMOUNT 
            ,CAST(T$FDYD AS NUMERIC(15,2))                                                                                                       AS FINALIZEDDEBITAMOUNTYEARTO_DATE 
            ,CAST(T$FINH AS NUMERIC(15,2))                                                                                                       AS FINALIZEDINCOMEAMOUNT 
            ,CAST(T$FIYD AS NUMERIC(15,2))                                                                                                       AS FINALIZEDINCOMEAMOUNTYEARTO_DATE 
            ,CAST(T$FQT1 AS NUMERIC(15,2))                                                                                                       AS FINALIZEDQUANTITY1 
            ,CAST(T$FQY1 AS NUMERIC(15,2))                                                                                                       AS FINALIZEDQUANTITY1YEARTO__DATE 
            ,CAST(T$FQT2 AS NUMERIC(15,2))                                                                                                       AS FINALIZEDQUANTITY2 
            ,CAST(T$FQY2 AS NUMERIC(15,2))                                                                                                       AS FINALIZEDQUANTITY2YEARTO_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FSTM)),'')                                                                                         AS FINANCIALSTATEMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$HCUR)),'')                                                                                         AS HOMECURRENCY 
            ,CAST(T$NINH AS NUMERIC(15,2))                                                                                                       AS INCOMESTATEMENTAMOUNTINCLNONFINALIZED 
            ,CAST(T$NIYD AS NUMERIC(15,2))                                                                                                       AS INCOMESTATEMENTAMOUNTINCLNONFINYEARTO_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LDES)),'')                                                                                         AS LEDGERACCOUNTDESCRIPTION 
            ,CAST(T$NCYD AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDCREDITYEARTO_DATE 
            ,CAST(T$NDYD AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDDEBITYEARTO_DATE 
            ,CAST(T$NQT1 AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDQUANTITY1 
            ,CAST(T$NQY1 AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDQUANTITY1YEARTO_DATE 
            ,CAST(T$NQT2 AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDQUANTITY2 
            ,CAST(T$NQY2 AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDQUANTITY2YEARTO_DATE 
            ,CAST(T$NCAH AS NUMERIC(15,2))                                                                                                       AS NOTFINALCREDITAMOUNT 
            ,CAST(T$NDAH AS NUMERIC(15,2))                                                                                                       AS NOTFINALDEBITAMOUNT 
            ,CAST(T$PERD AS INT)                                                                                                                 AS PERIOD 
            ,CAST(T$PRFR AS INT)                                                                                                                 AS PERIODFROM 
            ,CAST(T$PRTO AS INT)                                                                                                                 AS PERIODTO 
            ,T$PTYP.CONSTANTDESCRIPTION                                                                                                          AS PERIODTYPEDESCRIPTION 
            ,CAST(T$PTYP AS INT)                                                                                                                 AS PERIODTYPEID 
            ,CAST(T$TQT1 AS NUMERIC(15,2))                                                                                                       AS QUANTITY1INCLNONFINALIZED 
            ,CAST(T$TQY1 AS NUMERIC(15,2))                                                                                                       AS QUANTITY1INCLNONFINALIZEDYEARTO_DATE 
            ,CAST(T$TQT2 AS NUMERIC(15,2))                                                                                                       AS QUANTITY2INCLNONFINALIZED 
            ,CAST(T$TQY2 AS NUMERIC(15,2))                                                                                                       AS QUANTITY2INCLNONFINALIZEDYEARTO_DATE 
            ,CAST(T$RUNN AS BIGINT)                                                                                                              AS RUNNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LV00)),'')                                                                                         AS STATEMENTACCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$L00D)),'')                                                                                         AS STATEMENTACCOUNTDESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USER)),'')                                                                                         AS USER 
            ,CAST(T$YEAR AS INT)                                                                                                                 AS YEAR 
            ,CAST(T$YRFR AS INT)                                                                                                                 AS YEARFROM 
            ,CAST(T$YRTO AS INT)                                                                                                                 AS YEARTO 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFFST300200") }} AS SOURCETABLE  
            /*PERIODTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PTYP 
             ON   T$PTYP.TABLENAME  = 'TFFST300' 
              AND T$PTYP.COLUMNNAME = 'T$PTYP' 
              AND T$PTYP.CONSTANT   = SOURCETABLE.T$PTYP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$NBAH AS NUMERIC(15,2))                                                                                                       AS BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBAH 
            ,CAST(T$NBYD AS NUMERIC(15,2))                                                                                                       AS BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBYD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BUDG)),'')                                                                                         AS BUDGETACTUALCODE 
            ,CAST(T$FCOM AS INT)                                                                                                                 AS COMPANY 
            ,CAST(CASE WHEN T$DATE<= '1/1/1970' THEN NULL ELSE T$DATE  END AS DATETIME) AS DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D1DC)),'')                                                                                         AS DIMENSION1DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D2DC)),'')                                                                                         AS DIMENSION2DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D3DC)),'')                                                                                         AS DIMENSION3DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D4DC)),'')                                                                                         AS DIMENSION4DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$D5DC)),'')                                                                                         AS DIMENSION5DESCRIPTION 
            ,CAST(T$FBAH AS NUMERIC(15,2))                                                                                                       AS FINALIZEDBALANCESHEETAMOUNT 
            ,CAST(T$FBYD AS NUMERIC(15,2))                                                                                                       AS FINALIZEDBALANCESHEETAMOUNTYEARTO_DATE 
            ,CAST(T$FCAH AS NUMERIC(15,2))                                                                                                       AS FINALIZEDCREDITAMOUNT 
            ,CAST(T$FCYD AS NUMERIC(15,2))                                                                                                       AS FINALIZEDCREDITAMOUNTYEARTO_DATE 
            ,CAST(T$FDAH AS NUMERIC(15,2))                                                                                                       AS FINALIZEDDEBITAMOUNT 
            ,CAST(T$FDYD AS NUMERIC(15,2))                                                                                                       AS FINALIZEDDEBITAMOUNTYEARTO_DATE 
            ,CAST(T$FINH AS NUMERIC(15,2))                                                                                                       AS FINALIZEDINCOMEAMOUNT 
            ,CAST(T$FIYD AS NUMERIC(15,2))                                                                                                       AS FINALIZEDINCOMEAMOUNTYEARTO_DATE 
            ,CAST(T$FQT1 AS NUMERIC(15,2))                                                                                                       AS FINALIZEDQUANTITY1 
            ,CAST(T$FQY1 AS NUMERIC(15,2))                                                                                                       AS FINALIZEDQUANTITY1YEARTO__DATE 
            ,CAST(T$FQT2 AS NUMERIC(15,2))                                                                                                       AS FINALIZEDQUANTITY2 
            ,CAST(T$FQY2 AS NUMERIC(15,2))                                                                                                       AS FINALIZEDQUANTITY2YEARTO_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FSTM)),'')                                                                                         AS FINANCIALSTATEMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$HCUR)),'')                                                                                         AS HOMECURRENCY 
            ,CAST(T$NINH AS NUMERIC(15,2))                                                                                                       AS INCOMESTATEMENTAMOUNTINCLNONFINALIZED 
            ,CAST(T$NIYD AS NUMERIC(15,2))                                                                                                       AS INCOMESTATEMENTAMOUNTINCLNONFINYEARTO_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LDES)),'')                                                                                         AS LEDGERACCOUNTDESCRIPTION 
            ,CAST(T$NCYD AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDCREDITYEARTO_DATE 
            ,CAST(T$NDYD AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDDEBITYEARTO_DATE 
            ,CAST(T$NQT1 AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDQUANTITY1 
            ,CAST(T$NQY1 AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDQUANTITY1YEARTO_DATE 
            ,CAST(T$NQT2 AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDQUANTITY2 
            ,CAST(T$NQY2 AS NUMERIC(15,2))                                                                                                       AS NONFINALIZEDQUANTITY2YEARTO_DATE 
            ,CAST(T$NCAH AS NUMERIC(15,2))                                                                                                       AS NOTFINALCREDITAMOUNT 
            ,CAST(T$NDAH AS NUMERIC(15,2))                                                                                                       AS NOTFINALDEBITAMOUNT 
            ,CAST(T$PERD AS INT)                                                                                                                 AS PERIOD 
            ,CAST(T$PRFR AS INT)                                                                                                                 AS PERIODFROM 
            ,CAST(T$PRTO AS INT)                                                                                                                 AS PERIODTO 
            ,T$PTYP.CONSTANTDESCRIPTION                                                                                                          AS PERIODTYPEDESCRIPTION 
            ,CAST(T$PTYP AS INT)                                                                                                                 AS PERIODTYPEID 
            ,CAST(T$TQT1 AS NUMERIC(15,2))                                                                                                       AS QUANTITY1INCLNONFINALIZED 
            ,CAST(T$TQY1 AS NUMERIC(15,2))                                                                                                       AS QUANTITY1INCLNONFINALIZEDYEARTO_DATE 
            ,CAST(T$TQT2 AS NUMERIC(15,2))                                                                                                       AS QUANTITY2INCLNONFINALIZED 
            ,CAST(T$TQY2 AS NUMERIC(15,2))                                                                                                       AS QUANTITY2INCLNONFINALIZEDYEARTO_DATE 
            ,CAST(T$RUNN AS BIGINT)                                                                                                              AS RUNNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LV00)),'')                                                                                         AS STATEMENTACCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$L00D)),'')                                                                                         AS STATEMENTACCOUNTDESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USER)),'')                                                                                         AS USER 
            ,CAST(T$YEAR AS INT)                                                                                                                 AS YEAR 
            ,CAST(T$YRFR AS INT)                                                                                                                 AS YEARFROM 
            ,CAST(T$YRTO AS INT)                                                                                                                 AS YEARTO 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFFST300201") }} AS SOURCETABLE  
            /*PERIODTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PTYP 
             ON   T$PTYP.TABLENAME  = 'TFFST300' 
              AND T$PTYP.COLUMNNAME = 'T$PTYP' 
              AND T$PTYP.CONSTANT   = SOURCETABLE.T$PTYP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBAH AS BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBAH, 
        source_data.BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBYD AS BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBYD, 
        source_data.BUDGETACTUALCODE AS BUDGETACTUALCODE, 
        source_data.COMPANY AS COMPANY, 
        source_data.DATE AS DATE, 
        source_data.DIMENSION1 AS DIMENSION1, 
        source_data.DIMENSION1DESCRIPTION AS DIMENSION1DESCRIPTION, 
        source_data.DIMENSION2 AS DIMENSION2, 
        source_data.DIMENSION2DESCRIPTION AS DIMENSION2DESCRIPTION, 
        source_data.DIMENSION3 AS DIMENSION3, 
        source_data.DIMENSION3DESCRIPTION AS DIMENSION3DESCRIPTION, 
        source_data.DIMENSION4 AS DIMENSION4, 
        source_data.DIMENSION4DESCRIPTION AS DIMENSION4DESCRIPTION, 
        source_data.DIMENSION5 AS DIMENSION5, 
        source_data.DIMENSION5DESCRIPTION AS DIMENSION5DESCRIPTION, 
        source_data.FINALIZEDBALANCESHEETAMOUNT AS FINALIZEDBALANCESHEETAMOUNT, 
        source_data.FINALIZEDBALANCESHEETAMOUNTYEARTO_DATE AS FINALIZEDBALANCESHEETAMOUNTYEARTO_DATE, 
        source_data.FINALIZEDCREDITAMOUNT AS FINALIZEDCREDITAMOUNT, 
        source_data.FINALIZEDCREDITAMOUNTYEARTO_DATE AS FINALIZEDCREDITAMOUNTYEARTO_DATE, 
        source_data.FINALIZEDDEBITAMOUNT AS FINALIZEDDEBITAMOUNT, 
        source_data.FINALIZEDDEBITAMOUNTYEARTO_DATE AS FINALIZEDDEBITAMOUNTYEARTO_DATE, 
        source_data.FINALIZEDINCOMEAMOUNT AS FINALIZEDINCOMEAMOUNT, 
        source_data.FINALIZEDINCOMEAMOUNTYEARTO_DATE AS FINALIZEDINCOMEAMOUNTYEARTO_DATE, 
        source_data.FINALIZEDQUANTITY1 AS FINALIZEDQUANTITY1, 
        source_data.FINALIZEDQUANTITY1YEARTO__DATE AS FINALIZEDQUANTITY1YEARTO__DATE, 
        source_data.FINALIZEDQUANTITY2 AS FINALIZEDQUANTITY2, 
        source_data.FINALIZEDQUANTITY2YEARTO_DATE AS FINALIZEDQUANTITY2YEARTO_DATE, 
        source_data.FINANCIALSTATEMENT AS FINANCIALSTATEMENT, 
        source_data.HOMECURRENCY AS HOMECURRENCY, 
        source_data.INCOMESTATEMENTAMOUNTINCLNONFINALIZED AS INCOMESTATEMENTAMOUNTINCLNONFINALIZED, 
        source_data.INCOMESTATEMENTAMOUNTINCLNONFINYEARTO_DATE AS INCOMESTATEMENTAMOUNTINCLNONFINYEARTO_DATE, 
        source_data.LEDGERACCOUNT AS LEDGERACCOUNT, 
        source_data.LEDGERACCOUNTDESCRIPTION AS LEDGERACCOUNTDESCRIPTION, 
        source_data.NONFINALIZEDCREDITYEARTO_DATE AS NONFINALIZEDCREDITYEARTO_DATE, 
        source_data.NONFINALIZEDDEBITYEARTO_DATE AS NONFINALIZEDDEBITYEARTO_DATE, 
        source_data.NONFINALIZEDQUANTITY1 AS NONFINALIZEDQUANTITY1, 
        source_data.NONFINALIZEDQUANTITY1YEARTO_DATE AS NONFINALIZEDQUANTITY1YEARTO_DATE, 
        source_data.NONFINALIZEDQUANTITY2 AS NONFINALIZEDQUANTITY2, 
        source_data.NONFINALIZEDQUANTITY2YEARTO_DATE AS NONFINALIZEDQUANTITY2YEARTO_DATE, 
        source_data.NOTFINALCREDITAMOUNT AS NOTFINALCREDITAMOUNT, 
        source_data.NOTFINALDEBITAMOUNT AS NOTFINALDEBITAMOUNT, 
        source_data.PERIOD AS PERIOD, 
        source_data.PERIODFROM AS PERIODFROM, 
        source_data.PERIODTO AS PERIODTO, 
        source_data.PERIODTYPEDESCRIPTION AS PERIODTYPEDESCRIPTION, 
        source_data.PERIODTYPEID AS PERIODTYPEID, 
        source_data.QUANTITY1INCLNONFINALIZED AS QUANTITY1INCLNONFINALIZED, 
        source_data.QUANTITY1INCLNONFINALIZEDYEARTO_DATE AS QUANTITY1INCLNONFINALIZEDYEARTO_DATE, 
        source_data.QUANTITY2INCLNONFINALIZED AS QUANTITY2INCLNONFINALIZED, 
        source_data.QUANTITY2INCLNONFINALIZEDYEARTO_DATE AS QUANTITY2INCLNONFINALIZEDYEARTO_DATE, 
        source_data.RUNNUMBER AS RUNNUMBER, 
        source_data.STATEMENTACCOUNT AS STATEMENTACCOUNT, 
        source_data.STATEMENTACCOUNTDESCRIPTION AS STATEMENTACCOUNTDESCRIPTION, 
        source_data.USER AS USER, 
        source_data.YEAR AS YEAR, 
        source_data.YEARFROM AS YEARFROM, 
        source_data.YEARTO AS YEARTO
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBAH as NUMBER(15,2)) as BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBAH,
        cast(BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBYD as NUMBER(15,2)) as BALANCESHEETAMOUNTFINANDNONFINYEARTO_DATE_NBYD,
        cast(BUDGETACTUALCODE as VARCHAR(3)) as BUDGETACTUALCODE,
        cast(COMPANY as NUMBER(38,0)) as COMPANY,
        cast(DATE as TIMESTAMP_NTZ(9)) as DATE,
        cast(DIMENSION1 as VARCHAR(6)) as DIMENSION1,
        cast(DIMENSION1DESCRIPTION as VARCHAR(30)) as DIMENSION1DESCRIPTION,
        cast(DIMENSION2 as VARCHAR(6)) as DIMENSION2,
        cast(DIMENSION2DESCRIPTION as VARCHAR(30)) as DIMENSION2DESCRIPTION,
        cast(DIMENSION3 as VARCHAR(6)) as DIMENSION3,
        cast(DIMENSION3DESCRIPTION as VARCHAR(30)) as DIMENSION3DESCRIPTION,
        cast(DIMENSION4 as VARCHAR(6)) as DIMENSION4,
        cast(DIMENSION4DESCRIPTION as VARCHAR(30)) as DIMENSION4DESCRIPTION,
        cast(DIMENSION5 as VARCHAR(6)) as DIMENSION5,
        cast(DIMENSION5DESCRIPTION as VARCHAR(30)) as DIMENSION5DESCRIPTION,
        cast(FINALIZEDBALANCESHEETAMOUNT as NUMBER(15,2)) as FINALIZEDBALANCESHEETAMOUNT,
        cast(FINALIZEDBALANCESHEETAMOUNTYEARTO_DATE as NUMBER(15,2)) as FINALIZEDBALANCESHEETAMOUNTYEARTO_DATE,
        cast(FINALIZEDCREDITAMOUNT as NUMBER(15,2)) as FINALIZEDCREDITAMOUNT,
        cast(FINALIZEDCREDITAMOUNTYEARTO_DATE as NUMBER(15,2)) as FINALIZEDCREDITAMOUNTYEARTO_DATE,
        cast(FINALIZEDDEBITAMOUNT as NUMBER(15,2)) as FINALIZEDDEBITAMOUNT,
        cast(FINALIZEDDEBITAMOUNTYEARTO_DATE as NUMBER(15,2)) as FINALIZEDDEBITAMOUNTYEARTO_DATE,
        cast(FINALIZEDINCOMEAMOUNT as NUMBER(15,2)) as FINALIZEDINCOMEAMOUNT,
        cast(FINALIZEDINCOMEAMOUNTYEARTO_DATE as NUMBER(15,2)) as FINALIZEDINCOMEAMOUNTYEARTO_DATE,
        cast(FINALIZEDQUANTITY1 as NUMBER(15,2)) as FINALIZEDQUANTITY1,
        cast(FINALIZEDQUANTITY1YEARTO__DATE as NUMBER(15,2)) as FINALIZEDQUANTITY1YEARTO__DATE,
        cast(FINALIZEDQUANTITY2 as NUMBER(15,2)) as FINALIZEDQUANTITY2,
        cast(FINALIZEDQUANTITY2YEARTO_DATE as NUMBER(15,2)) as FINALIZEDQUANTITY2YEARTO_DATE,
        cast(FINANCIALSTATEMENT as VARCHAR(8)) as FINANCIALSTATEMENT,
        cast(HOMECURRENCY as VARCHAR(3)) as HOMECURRENCY,
        cast(INCOMESTATEMENTAMOUNTINCLNONFINALIZED as NUMBER(15,2)) as INCOMESTATEMENTAMOUNTINCLNONFINALIZED,
        cast(INCOMESTATEMENTAMOUNTINCLNONFINYEARTO_DATE as NUMBER(15,2)) as INCOMESTATEMENTAMOUNTINCLNONFINYEARTO_DATE,
        cast(LEDGERACCOUNT as VARCHAR(12)) as LEDGERACCOUNT,
        cast(LEDGERACCOUNTDESCRIPTION as VARCHAR(30)) as LEDGERACCOUNTDESCRIPTION,
        cast(NONFINALIZEDCREDITYEARTO_DATE as NUMBER(15,2)) as NONFINALIZEDCREDITYEARTO_DATE,
        cast(NONFINALIZEDDEBITYEARTO_DATE as NUMBER(15,2)) as NONFINALIZEDDEBITYEARTO_DATE,
        cast(NONFINALIZEDQUANTITY1 as NUMBER(15,2)) as NONFINALIZEDQUANTITY1,
        cast(NONFINALIZEDQUANTITY1YEARTO_DATE as NUMBER(15,2)) as NONFINALIZEDQUANTITY1YEARTO_DATE,
        cast(NONFINALIZEDQUANTITY2 as NUMBER(15,2)) as NONFINALIZEDQUANTITY2,
        cast(NONFINALIZEDQUANTITY2YEARTO_DATE as NUMBER(15,2)) as NONFINALIZEDQUANTITY2YEARTO_DATE,
        cast(NOTFINALCREDITAMOUNT as NUMBER(15,2)) as NOTFINALCREDITAMOUNT,
        cast(NOTFINALDEBITAMOUNT as NUMBER(15,2)) as NOTFINALDEBITAMOUNT,
        cast(PERIOD as NUMBER(38,0)) as PERIOD,
        cast(PERIODFROM as NUMBER(38,0)) as PERIODFROM,
        cast(PERIODTO as NUMBER(38,0)) as PERIODTO,
        cast(PERIODTYPEDESCRIPTION as VARCHAR(16777216)) as PERIODTYPEDESCRIPTION,
        cast(PERIODTYPEID as NUMBER(38,0)) as PERIODTYPEID,
        cast(QUANTITY1INCLNONFINALIZED as NUMBER(15,2)) as QUANTITY1INCLNONFINALIZED,
        cast(QUANTITY1INCLNONFINALIZEDYEARTO_DATE as NUMBER(15,2)) as QUANTITY1INCLNONFINALIZEDYEARTO_DATE,
        cast(QUANTITY2INCLNONFINALIZED as NUMBER(15,2)) as QUANTITY2INCLNONFINALIZED,
        cast(QUANTITY2INCLNONFINALIZEDYEARTO_DATE as NUMBER(15,2)) as QUANTITY2INCLNONFINALIZEDYEARTO_DATE,
        cast(RUNNUMBER as NUMBER(38,0)) as RUNNUMBER,
        cast(STATEMENTACCOUNT as VARCHAR(12)) as STATEMENTACCOUNT,
        cast(STATEMENTACCOUNTDESCRIPTION as VARCHAR(40)) as STATEMENTACCOUNTDESCRIPTION,
        cast(USER as VARCHAR(16)) as USER,
        cast(YEAR as NUMBER(38,0)) as YEAR,
        cast(YEARFROM as NUMBER(38,0)) as YEARFROM,
        cast(YEARTO as NUMBER(38,0)) as YEARTO,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data