/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONSALESCONTROL_LINKEDORDERLINEDATA.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONSALESCONTROL_LINKEDORDERLINEDATA.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONSALESCONTROL_LINKEDORDERLINEDATA 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:50 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANDISTRIBUTIONSALESCONTROL_LINKEDORDERLINEDATA',
    unique_key = ['POSITIONNUMBER_PONO',
    'SALESORDER',
    'SEQUENCENUMBER_SQNB']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CONO)),'')                                                                                         AS CONTRACT 
            ,CAST(CASE WHEN T$IRDT<= '1/1/1970' THEN NULL ELSE T$IRDT  END AS DATETIME) AS INTERFACERECORDCREATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS ORDER_EDATWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ORDER_EDITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ODNO)),'')                                                                                         AS ORIGINALDOCUMENTNUMBER 
            ,T$ODTY.CONSTANTDESCRIPTION                                                                                                          AS ORIGINALDOCUMENTTYPEDESCRIPTION 
            ,CAST(T$ODTY AS INT)                                                                                                                 AS ORIGINALDOCUMENTTYPEID 
            ,CAST(T$OSEQ AS INT)                                                                                                                 AS ORIGINALSEQUENCE 
            ,CAST(T$SRNB AS INT)                                                                                                                 AS PLANDELIVERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRAN)),'')                                                                                         AS PLANNEDPURCHASEADVICENUMBER 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER_PONO 
            ,CAST(T$POSI AS INT)                                                                                                                 AS POSITIONNUMBER_POSI 
            ,CAST(T$PPON AS INT)                                                                                                                 AS POSITIONNUMBER_PPON 
            ,CAST(T$RETP AS INT)                                                                                                                 AS POSITIONNUMBER_RETP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PORN)),'')                                                                                         AS PURCHASEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QONO)),'')                                                                                         AS QUOTATIONNUMBER 
            ,CAST(T$QPON AS INT)                                                                                                                 AS QUOTATIONPOSITION 
            ,T$RFPR.CONSTANTDESCRIPTION                                                                                                          AS READYFORPROCESSINGDESCRIPTION 
            ,CAST(T$RFPR AS INT)                                                                                                                 AS READYFORPROCESSINGID 
            ,CAST(T$RPRI AS TINYINT)                                                                                                             AS RECEIPTPRIORITY 
            ,CAST(T$RQTY AS NUMERIC(15,2))                                                                                                       AS RECEIPTQUANTITY 
            ,CAST(T$RCMP AS INT)                                                                                                                 AS RETURNINVOICECOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RETO)),'')                                                                                         AS RETURNORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RETURNTRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS SALESOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SCHN)),'')                                                                                         AS SCHEDULE 
            ,CAST(T$SCPO AS INT)                                                                                                                 AS SCHEDULEPOSITION 
            ,CAST(T$REVN AS INT)                                                                                                                 AS SCHEDULEREVISION 
            ,CAST(T$PSEQ AS INT)                                                                                                                 AS SEQUENCENUMBER_PSEQ 
            ,CAST(T$RETS AS INT)                                                                                                                 AS SEQUENCENUMBER_RETS 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS SEQUENCENUMBER_SQNB 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                         AS SHIPMENT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDSLS402200") }} AS SOURCETABLE  
            /*ORIGINALDOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ODTY 
             ON   T$ODTY.TABLENAME  = 'TDSLS402' 
              AND T$ODTY.COLUMNNAME = 'T$ODTY' 
              AND T$ODTY.CONSTANT   = SOURCETABLE.T$ODTY 
            /*READYFORPROCESSING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RFPR 
             ON   T$RFPR.TABLENAME  = 'TDSLS402' 
              AND T$RFPR.COLUMNNAME = 'T$RFPR' 
              AND T$RFPR.CONSTANT   = SOURCETABLE.T$RFPR 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CONO)),'')                                                                                         AS CONTRACT 
            ,CAST(CASE WHEN T$IRDT<= '1/1/1970' THEN NULL ELSE T$IRDT  END AS DATETIME) AS INTERFACERECORDCREATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS ORDER_EDATWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ORDER_EDITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ODNO)),'')                                                                                         AS ORIGINALDOCUMENTNUMBER 
            ,T$ODTY.CONSTANTDESCRIPTION                                                                                                          AS ORIGINALDOCUMENTTYPEDESCRIPTION 
            ,CAST(T$ODTY AS INT)                                                                                                                 AS ORIGINALDOCUMENTTYPEID 
            ,CAST(T$OSEQ AS INT)                                                                                                                 AS ORIGINALSEQUENCE 
            ,CAST(T$SRNB AS INT)                                                                                                                 AS PLANDELIVERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRAN)),'')                                                                                         AS PLANNEDPURCHASEADVICENUMBER 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER_PONO 
            ,CAST(T$POSI AS INT)                                                                                                                 AS POSITIONNUMBER_POSI 
            ,CAST(T$PPON AS INT)                                                                                                                 AS POSITIONNUMBER_PPON 
            ,CAST(T$RETP AS INT)                                                                                                                 AS POSITIONNUMBER_RETP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PORN)),'')                                                                                         AS PURCHASEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QONO)),'')                                                                                         AS QUOTATIONNUMBER 
            ,CAST(T$QPON AS INT)                                                                                                                 AS QUOTATIONPOSITION 
            ,T$RFPR.CONSTANTDESCRIPTION                                                                                                          AS READYFORPROCESSINGDESCRIPTION 
            ,CAST(T$RFPR AS INT)                                                                                                                 AS READYFORPROCESSINGID 
            ,CAST(T$RPRI AS TINYINT)                                                                                                             AS RECEIPTPRIORITY 
            ,CAST(T$RQTY AS NUMERIC(15,2))                                                                                                       AS RECEIPTQUANTITY 
            ,CAST(T$RCMP AS INT)                                                                                                                 AS RETURNINVOICECOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RETO)),'')                                                                                         AS RETURNORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RETURNTRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS SALESOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SCHN)),'')                                                                                         AS SCHEDULE 
            ,CAST(T$SCPO AS INT)                                                                                                                 AS SCHEDULEPOSITION 
            ,CAST(T$REVN AS INT)                                                                                                                 AS SCHEDULEREVISION 
            ,CAST(T$PSEQ AS INT)                                                                                                                 AS SEQUENCENUMBER_PSEQ 
            ,CAST(T$RETS AS INT)                                                                                                                 AS SEQUENCENUMBER_RETS 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS SEQUENCENUMBER_SQNB 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                         AS SHIPMENT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDSLS402201") }} AS SOURCETABLE  
            /*ORIGINALDOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ODTY 
             ON   T$ODTY.TABLENAME  = 'TDSLS402' 
              AND T$ODTY.COLUMNNAME = 'T$ODTY' 
              AND T$ODTY.CONSTANT   = SOURCETABLE.T$ODTY 
            /*READYFORPROCESSING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RFPR 
             ON   T$RFPR.TABLENAME  = 'TDSLS402' 
              AND T$RFPR.COLUMNNAME = 'T$RFPR' 
              AND T$RFPR.CONSTANT   = SOURCETABLE.T$RFPR 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONTRACT AS CONTRACT, 
        source_data.INTERFACERECORDCREATIONDATE AS INTERFACERECORDCREATIONDATE, 
        source_data.ORDER_EDATWAREHOUSE AS ORDER_EDATWAREHOUSE, 
        source_data.ORDER_EDITEM AS ORDER_EDITEM, 
        source_data.ORIGINALDOCUMENTNUMBER AS ORIGINALDOCUMENTNUMBER, 
        source_data.ORIGINALDOCUMENTTYPEDESCRIPTION AS ORIGINALDOCUMENTTYPEDESCRIPTION, 
        source_data.ORIGINALDOCUMENTTYPEID AS ORIGINALDOCUMENTTYPEID, 
        source_data.ORIGINALSEQUENCE AS ORIGINALSEQUENCE, 
        source_data.PLANDELIVERY AS PLANDELIVERY, 
        source_data.PLANNEDPURCHASEADVICENUMBER AS PLANNEDPURCHASEADVICENUMBER, 
        source_data.POSITIONNUMBER_PONO AS POSITIONNUMBER_PONO, 
        source_data.POSITIONNUMBER_POSI AS POSITIONNUMBER_POSI, 
        source_data.POSITIONNUMBER_PPON AS POSITIONNUMBER_PPON, 
        source_data.POSITIONNUMBER_RETP AS POSITIONNUMBER_RETP, 
        source_data.PURCHASEORDER AS PURCHASEORDER, 
        source_data.QUOTATIONNUMBER AS QUOTATIONNUMBER, 
        source_data.QUOTATIONPOSITION AS QUOTATIONPOSITION, 
        source_data.READYFORPROCESSINGDESCRIPTION AS READYFORPROCESSINGDESCRIPTION, 
        source_data.READYFORPROCESSINGID AS READYFORPROCESSINGID, 
        source_data.RECEIPTPRIORITY AS RECEIPTPRIORITY, 
        source_data.RECEIPTQUANTITY AS RECEIPTQUANTITY, 
        source_data.RETURNINVOICECOMPANY AS RETURNINVOICECOMPANY, 
        source_data.RETURNORDER AS RETURNORDER, 
        source_data.RETURNTRANSACTIONTYPE AS RETURNTRANSACTIONTYPE, 
        source_data.SALESOFFICE AS SALESOFFICE, 
        source_data.SALESORDER AS SALESORDER, 
        source_data.SCHEDULE AS SCHEDULE, 
        source_data.SCHEDULEPOSITION AS SCHEDULEPOSITION, 
        source_data.SCHEDULEREVISION AS SCHEDULEREVISION, 
        source_data.SEQUENCENUMBER_PSEQ AS SEQUENCENUMBER_PSEQ, 
        source_data.SEQUENCENUMBER_RETS AS SEQUENCENUMBER_RETS, 
        source_data.SEQUENCENUMBER_SQNB AS SEQUENCENUMBER_SQNB, 
        source_data.SHIPMENT AS SHIPMENT
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONTRACT as VARCHAR(9)) as CONTRACT,
        cast(INTERFACERECORDCREATIONDATE as TIMESTAMP_NTZ(9)) as INTERFACERECORDCREATIONDATE,
        cast(ORDER_EDATWAREHOUSE as VARCHAR(6)) as ORDER_EDATWAREHOUSE,
        cast(ORDER_EDITEM as VARCHAR(47)) as ORDER_EDITEM,
        cast(ORIGINALDOCUMENTNUMBER as VARCHAR(9)) as ORIGINALDOCUMENTNUMBER,
        cast(ORIGINALDOCUMENTTYPEDESCRIPTION as VARCHAR(16777216)) as ORIGINALDOCUMENTTYPEDESCRIPTION,
        cast(ORIGINALDOCUMENTTYPEID as NUMBER(38,0)) as ORIGINALDOCUMENTTYPEID,
        cast(ORIGINALSEQUENCE as NUMBER(38,0)) as ORIGINALSEQUENCE,
        cast(PLANDELIVERY as NUMBER(38,0)) as PLANDELIVERY,
        cast(PLANNEDPURCHASEADVICENUMBER as VARCHAR(9)) as PLANNEDPURCHASEADVICENUMBER,
        cast(POSITIONNUMBER_PONO as NUMBER(38,0)) as POSITIONNUMBER_PONO,
        cast(POSITIONNUMBER_POSI as NUMBER(38,0)) as POSITIONNUMBER_POSI,
        cast(POSITIONNUMBER_PPON as NUMBER(38,0)) as POSITIONNUMBER_PPON,
        cast(POSITIONNUMBER_RETP as NUMBER(38,0)) as POSITIONNUMBER_RETP,
        cast(PURCHASEORDER as VARCHAR(9)) as PURCHASEORDER,
        cast(QUOTATIONNUMBER as VARCHAR(9)) as QUOTATIONNUMBER,
        cast(QUOTATIONPOSITION as NUMBER(38,0)) as QUOTATIONPOSITION,
        cast(READYFORPROCESSINGDESCRIPTION as VARCHAR(16777216)) as READYFORPROCESSINGDESCRIPTION,
        cast(READYFORPROCESSINGID as NUMBER(38,0)) as READYFORPROCESSINGID,
        cast(RECEIPTPRIORITY as NUMBER(38,0)) as RECEIPTPRIORITY,
        cast(RECEIPTQUANTITY as NUMBER(15,2)) as RECEIPTQUANTITY,
        cast(RETURNINVOICECOMPANY as NUMBER(38,0)) as RETURNINVOICECOMPANY,
        cast(RETURNORDER as VARCHAR(9)) as RETURNORDER,
        cast(RETURNTRANSACTIONTYPE as VARCHAR(3)) as RETURNTRANSACTIONTYPE,
        cast(SALESOFFICE as VARCHAR(6)) as SALESOFFICE,
        cast(SALESORDER as VARCHAR(9)) as SALESORDER,
        cast(SCHEDULE as VARCHAR(9)) as SCHEDULE,
        cast(SCHEDULEPOSITION as NUMBER(38,0)) as SCHEDULEPOSITION,
        cast(SCHEDULEREVISION as NUMBER(38,0)) as SCHEDULEREVISION,
        cast(SEQUENCENUMBER_PSEQ as NUMBER(38,0)) as SEQUENCENUMBER_PSEQ,
        cast(SEQUENCENUMBER_RETS as NUMBER(38,0)) as SEQUENCENUMBER_RETS,
        cast(SEQUENCENUMBER_SQNB as NUMBER(38,0)) as SEQUENCENUMBER_SQNB,
        cast(SHIPMENT as VARCHAR(9)) as SHIPMENT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data