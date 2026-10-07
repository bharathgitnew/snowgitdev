{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='BAAN_INTEGRATIONTRANSACTIONS',
    unique_key = []
) }}


with source_data as 
(
    SELECT  
        A._CAPTUREDATETIME AS _CAPTUREDATETIME,
        b.t$ocom AS Original_Company,
        b.t$tror AS Transaction_Origin,
        b.t$fitr AS Financial_Transaction,
        b.t$trdt AS Log_Date,
        b.t$sern AS Sequence_Number,
        a.t$ttyp AS Transaction_Type,
        a.t$docn AS Document,
        a.t$lino AS Document_Line_Number,
        a.t$fcom AS Finance_Company,
        C.t$ifbp AS Invoice_From_BPID,
        b.t$leac AS Ledger_Acc,
        b.t$dim1 AS Dimension_1,
        b.t$dim2 AS Dimension_2,
        b.t$dim3 AS Dimension_3,
        b.t$dim4 AS Dimension_4,
        b.t$dim5 AS Dimension_5,
        b.t$fyer AS Fiscal_Year,
        b.t$fprd AS Financial_Period,
        e.t$vyer AS Tax_Year,
        e.t$vprd AS Tax_Period,
        b.t$ryer AS Reporting_Year,
        b.t$rprd AS Reporting_Period,
        b.t$ccur AS Currency,
        b."T$RATS$1" AS Currency_Rate,
        b."T$RATF$1" AS Currency_Rate_Factor,
        b.t$amnt AS Amount,
        b.t$dbcr AS DC,
        e.t$refr AS Reference,
        C.t$ccty AS Country,
        e.t$vtyp AS Tax_Type,
        e.t$vamt AS Tax_Amount,
        e.t$qty1 AS Quantity_1,
        e.t$qty2 AS Quantity_2,
        b.t$nuni AS Number_Of_Units,
        b.t$cuni AS Unit,
        a.t$crus AS Created_By,
        a.t$crdt AS Transaction_Date,
        a.t$orno AS Order_No,
        a.t$pono AS Order_Position,
        a.t$sqnb AS Order_Sequence_No,
        b.t$cpcp AS Cost_Price_Component,
        b.t$cwar AS Warehouse,
        trim(SUBSTR(b.t$item,10,LENGTH(b.t$item)-9)) AS Item,
        a.t$cprj AS Project,
        C.t$nper AS Number_Of_Periods,
        a.t$sint AS Transaction_Status,
        a.t$btno AS Batch_Number,
        a.t$pous AS Posted_By,
        a.t$podt AS Posting_Date,
        f.t$cpln AS TEL_BU,
        h.t$teac AS TEA_BU,
        f.t$cpcl AS Product_Class,
        f.t$cpcp AS Cost_Component,
        g.t$dsca AS Cost_Component_Desc,
        f.t$ccfg AS Configuration, 
        f.t$mode AS MODEL,
        j.t$cser AS Serial_Number,
        f.t$cwte AS Warranty,
        f.t$seof AS Service_Office,
        f.t$wttp AS Warranty_Type,
        f.t$coty AS Contract_Type,
        f.t$sety AS Service_Type,
        f.t$seig AS Service_Item_Group,
        case when f.T$SECO = 0
        then NULL
        when f.T$SECO = 5 
        then 'MATERIAL_COSTS'
        else TO_CHAR(f.T$SECO) 
        end AS Service_Cost_type,
        trim(SUBSTR(f.t$seit,10,LENGTH(f.t$seit)-9)) AS Service_Item,
        f.t$inst AS Installment,
        f.t$slto AS Sold_to_BPID,
        UPPER(l.t$nama) AS Sold_To_BP,
        f.t$shfr AS Ship_from_BPID,
        UPPER(m.t$nama) AS Ship_from_BP,
        f.t$shto AS Ship_to_BPID,
        UPPER(n.t$nama) AS Ship_To_BP
    FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD418200") }}  A   /* Integration References */
    INNER JOIN {{ source("BAAN_ORACLE_LIVE", "TTFGLD410200") }}  B      /* Integration Transactions Debit*/
    ON  A.t$ocom = B.t$ocom
    AND A.t$tror = B.t$tror
    AND A.t$fitr = B.t$fitr
    AND A.t$trdt = B.t$trdt
    AND A.t$sern = B.t$sern
    AND A.t$frot = 2 /*To*/
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTFGLD415200") }}  C    /* Additions to Integration Transactions */
    ON  B.t$ocom = C.t$ocom
    AND B.t$tror = C.t$tror
    AND B.t$fitr = C.t$fitr
    AND B.t$trdt = C.t$trdt
    AND B.t$sern = C.t$sern   
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTFGLD106201") }}  e   /* Finalized Transactions */
    ON  A.t$ocom = e.t$ocmp
    AND A.t$ttyp = e.t$otyp
    AND A.t$docn = e.t$odoc
    AND A.t$lino = e.t$olin
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTFGLD955201") }}  f
    ON  A.t$ocom = f.t$ocom
    AND A.t$tror = f.t$tror
    AND A.t$fitr = f.t$fitr
    AND A.t$trdt = f.t$trdt
    AND A.t$sern = f.t$sern
    AND A.t$frot = f.t$frot
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCMCS048200") }}  g  /* Cost Components */
    ON  f.t$cpcp = g.t$cpcp
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCCOM907201") }}  h /* BU Mappings */
    ON f.t$cpln = h.t$telc
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTSCFG200201") }}  j /* Objects */
    ON  f.t$ccfg = j.t$ccfg
    AND f.t$mode = j.t$crob
    AND f.t$objc = j.t$oseq  
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCCOM100200") }}  l     /* Sold To BP */
    ON    f.t$slto = l.t$bpid
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCCOM100200") }}  m     /* Ship_from_BP */
    ON    f.t$shfr = m.t$bpid
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCCOM100200") }}  n     /* Ship To BP */
    ON    f.t$shto = n.t$bpid

    UNION
    
    SELECT  
        A._CAPTUREDATETIME AS _CAPTUREDATETIME,
        b.t$ocom AS Original_Company,
        b.t$tror AS Transaction_Origin,
        b.t$fitr AS Financial_Transaction,
        b.t$trdt AS Log_Date,
        b.t$sern AS Sequence_Number,
        a.t$ttyp AS Transaction_Type,
        a.t$docn AS Document,
        a.t$lino AS Document_Line_Number,
        a.t$fcom AS Finance_Company,
        c.t$ifbp AS Invoice_From_BPID,
        b.t$leac AS Ledger_Acc,
        b.t$dim1 AS Dimension_1,
        b.t$dim2 AS Dimension_2,
        b.t$dim3 AS Dimension_3,
        b.t$dim4 AS Dimension_4,
        b.t$dim5 AS Dimension_5,
        b.t$fyer AS Fiscal_Year,
        b.t$fprd AS Financial_Period,
        e.t$vyer AS Tax_Year,
        e.t$vprd AS Tax_Period,
        b.t$ryer AS Reporting_Year,
        b.t$rprd AS Reporting_Period,
        b.t$ccur AS Currency,
        b."T$RATS$1" AS Currency_Rate,
        b."T$RATF$1" AS Currency_Rate_Factor,
        b.t$amnt AS Amount,
        b.t$dbcr AS DC,
        e.t$refr AS Reference,
        c.t$ccty AS Country,
        e.t$vtyp AS Tax_Type,
        e.t$vamt AS Tax_Amount,
        e.t$qty1 AS Quantity_1,
        e.t$qty2 AS Quantity_2,
        b.t$nuni AS Number_Of_Units,
        b.t$cuni AS Unit,
        a.t$crus AS Created_By,
        a.t$crdt AS Transaction_Date,
        a.t$orno AS Order_No,
        a.t$pono AS Order_Position,
        a.t$sqnb AS Order_Sequence_No,
        b.t$cpcp AS Cost_Price_Component,
        b.t$cwar AS Warehouse,
        trim(SUBSTR(b.t$item,10,LENGTH(b.t$item)-9)) AS Item,
        a.t$cprj AS Project,
        c.t$nper AS Number_Of_Periods,
        a.t$sint AS Transaction_Status,
        a.t$btno AS Batch_Number,
        a.t$pous AS Posted_By,
        a.t$podt AS Posting_Date,
        f.t$cpln AS TEL_BU,
        h.t$teac AS TEA_BU,
        f.t$cpcl AS Product_Class,
        f.t$cpcp AS Cost_Component,
        g.t$dsca AS Cost_Component_Desc,
        f.t$ccfg AS Configuration, 
        f.t$mode AS MODEL,
        j.t$cser AS Serial_Number,
        f.t$cwte AS Warranty,
        f.t$seof AS Service_Office,
        f.t$wttp AS Warranty_Type,
        f.t$coty AS Contract_Type,
        f.t$sety AS Service_Type,
        f.t$seig AS Service_Item_Group,
        case when f.T$SECO = 0
        then NULL
        when f.T$SECO = 5 
        then 'MATERIAL_COSTS'
        else TO_CHAR(f.T$SECO) 
        end AS Service_Cost_type,        
        trim(SUBSTR(f.t$seit,10,LENGTH(f.t$seit)-9)) AS Service_Item,
        f.t$inst AS Installment,
        f.t$slto AS Sold_to_BPID,
        UPPER(l.t$nama) AS Sold_To_BP,
        f.t$shfr AS Ship_from_BPID,
        UPPER(m.t$nama) AS Ship_from_BP,
        f.t$shto AS Ship_to_BPID,
        UPPER(n.t$nama) AS Ship_To_BP
    FROM  {{ source("BAAN_ORACLE_LIVE", "TTFGLD418200") }}  A   /* Integration References */
    INNER JOIN {{ source("BAAN_ORACLE_LIVE", "TTFGLD417200") }}  B      /* Integration Transactions Debit*/
    ON  A.t$ocom = B.t$ocom
    AND A.t$tror = B.t$tror
    AND A.t$fitr = B.t$fitr
    AND A.t$trdt = B.t$trdt
    AND A.t$sern = B.t$sern
    AND A.t$frot = 1 /*from*/
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTFGLD415200") }}  C    /* Additions to Integration Transactions */
    ON  B.t$ocom = C.t$ocom
    AND B.t$tror = C.t$tror
    AND B.t$fitr = C.t$fitr
    AND B.t$trdt = C.t$trdt
    AND B.t$sern = C.t$sern   
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTFGLD106201") }}  e   /* Finalized Transactions */
    ON  A.t$ocom = e.t$ocmp
    AND A.t$ttyp = e.t$otyp
    AND A.t$docn = e.t$odoc
    AND A.t$lino = e.t$olin
    LEFT OUTER JOIN  {{ source("BAAN_ORACLE_LIVE", "TTFGLD955201") }}  f
    ON  A.t$ocom = f.t$ocom
    AND A.t$tror = f.t$tror
    AND A.t$fitr = f.t$fitr
    AND A.t$trdt = f.t$trdt
    AND A.t$sern = f.t$sern
    AND A.t$frot = f.t$frot
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCMCS048200") }}  g  /* Cost Components */
    ON  f.t$cpcp = g.t$cpcp
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCCOM907201") }}  h /* BU Mappings */
    ON f.t$cpln = h.t$telc
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTSCFG200201") }}  j /* Objects */
    ON  f.t$ccfg = j.t$ccfg
    AND f.t$mode = j.t$crob
    AND f.t$objc = j.t$oseq
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCCOM100200") }}  l     /* Sold To BP */
    ON    f.t$slto = l.t$bpid
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCCOM100200") }}  m     /* Ship_from_BP */
    ON    f.t$shfr = m.t$bpid
    LEFT OUTER JOIN {{ source("BAAN_ORACLE_LIVE", "TTCCOM100200") }}  n     /* Ship To BP */
    ON    f.t$shto = n.t$bpid

),

transform_data as
(
    SELECT *,
       '{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
    FROM source_data
), 

type_data as 
(
    SELECT
        cast(ORIGINAL_COMPANY as NUMBER(38,0)) as ORIGINAL_COMPANY,
        cast(TRANSACTION_ORIGIN as NUMBER(38,0)) as TRANSACTION_ORIGIN,
        cast(FINANCIAL_TRANSACTION as NUMBER(38,0)) as FINANCIAL_TRANSACTION,
        cast(LOG_DATE as TIMESTAMP_NTZ(9)) as LOG_DATE,
        cast(SEQUENCE_NUMBER as NUMBER(38,0)) as SEQUENCE_NUMBER,
        cast(TRANSACTION_TYPE as VARCHAR(3)) as TRANSACTION_TYPE,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(DOCUMENT_LINE_NUMBER as NUMBER(38,0)) as DOCUMENT_LINE_NUMBER,
        cast(FINANCE_COMPANY as NUMBER(38,0)) as FINANCE_COMPANY,
        cast(INVOICE_FROM_BPID as VARCHAR(9)) as INVOICE_FROM_BPID,
        cast(LEDGER_ACC as VARCHAR(12)) as LEDGER_ACC,
        cast(DIMENSION_1 as VARCHAR(6)) as DIMENSION_1,
        cast(DIMENSION_2 as VARCHAR(6)) as DIMENSION_2,
        cast(DIMENSION_3 as VARCHAR(6)) as DIMENSION_3,
        cast(DIMENSION_4 as VARCHAR(6)) as DIMENSION_4,
        cast(DIMENSION_5 as VARCHAR(6)) as DIMENSION_5,
        cast(FISCAL_YEAR as NUMBER(38,10)) as FISCAL_YEAR,
        cast(FINANCIAL_PERIOD as NUMBER(38,0)) as FINANCIAL_PERIOD,
        cast(TAX_YEAR as NUMBER(38,0)) as TAX_YEAR,
        cast(TAX_PERIOD as NUMBER(38,0)) as TAX_PERIOD,
        cast(REPORTING_YEAR as NUMBER(38,0)) as REPORTING_YEAR,
        cast(REPORTING_PERIOD as NUMBER(38,0)) as REPORTING_PERIOD,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(CURRENCY_RATE as NUMBER(38,10)) as CURRENCY_RATE,
        cast(CURRENCY_RATE_FACTOR as NUMBER(38,10)) as CURRENCY_RATE_FACTOR,
        cast(AMOUNT as NUMBER(38,10)) as AMOUNT,
        cast(DC as NUMBER(38,0)) as DC,
        cast(REFERENCE as VARCHAR(32)) as REFERENCE,
        cast(COUNTRY as VARCHAR(3)) as COUNTRY,
        cast(TAX_TYPE as NUMBER(38,0)) as TAX_TYPE,
        cast(TAX_AMOUNT as NUMBER(38,10)) as TAX_AMOUNT,
        cast(QUANTITY_1 as NUMBER(38,0)) as QUANTITY_1,
        cast(QUANTITY_2 as NUMBER(38,0)) as QUANTITY_2,
        cast(NUMBER_OF_UNITS as NUMBER(38,0)) as NUMBER_OF_UNITS,
        cast(UNIT as VARCHAR(3)) as UNIT,
        cast(CREATED_BY as VARCHAR(16)) as CREATED_BY,
        cast(TRANSACTION_DATE as TIMESTAMP_NTZ(9)) as TRANSACTION_DATE,
        cast(ORDER_NO as VARCHAR(9)) as ORDER_NO,
        cast(ORDER_POSITION as NUMBER(38,0)) as ORDER_POSITION,
        cast(ORDER_SEQUENCE_NO as NUMBER(38,0)) as ORDER_SEQUENCE_NO,
        cast(COST_PRICE_COMPONENT as VARCHAR(8)) as COST_PRICE_COMPONENT,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(NUMBER_OF_PERIODS as NUMBER(38,0)) as NUMBER_OF_PERIODS,
        cast(TRANSACTION_STATUS as NUMBER(38,0)) as TRANSACTION_STATUS,
        cast(BATCH_NUMBER as NUMBER(38,0)) as BATCH_NUMBER,
        cast(POSTED_BY as VARCHAR(16)) as POSTED_BY,
        cast(POSTING_DATE as TIMESTAMP_NTZ(9)) as POSTING_DATE,
        cast(TEL_BU as VARCHAR(6)) as TEL_BU,
        cast(TEA_BU as VARCHAR(6)) as TEA_BU,
        cast(PRODUCT_CLASS as VARCHAR(6)) as PRODUCT_CLASS,
        cast(COST_COMPONENT as VARCHAR(8)) as COST_COMPONENT,
        cast(COST_COMPONENT_DESC as VARCHAR(30)) as COST_COMPONENT_DESC,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(MODEL as VARCHAR(47)) as MODEL,
        cast(SERIAL_NUMBER as VARCHAR(20)) as SERIAL_NUMBER,
        cast(WARRANTY as VARCHAR(16)) as WARRANTY,
        cast(SERVICE_OFFICE as VARCHAR(6)) as SERVICE_OFFICE,
        cast(WARRANTY_TYPE as NUMBER(38,0)) as WARRANTY_TYPE,
        cast(CONTRACT_TYPE as VARCHAR(3)) as CONTRACT_TYPE,
        cast(SERVICE_TYPE as VARCHAR(3)) as SERVICE_TYPE,
        cast(SERVICE_ITEM_GROUP as VARCHAR(6)) as SERVICE_ITEM_GROUP,
        cast(SERVICE_COST_TYPE as VARCHAR(16777216)) as SERVICE_COST_TYPE,
        cast(SERVICE_ITEM as VARCHAR(47)) as SERVICE_ITEM,
        cast(INSTALLMENT as NUMBER(38,0)) as INSTALLMENT,
        cast(SOLD_TO_BPID as VARCHAR(9)) as SOLD_TO_BPID,
        cast(SOLD_TO_BP as VARCHAR(105)) as SOLD_TO_BP,
        cast(SHIP_FROM_BPID as VARCHAR(9)) as SHIP_FROM_BPID,
        cast(SHIP_FROM_BP as VARCHAR(105)) as SHIP_FROM_BP,
        cast(SHIP_TO_BPID as VARCHAR(9)) as SHIP_TO_BPID,
        cast(SHIP_TO_BP as VARCHAR(105)) as SHIP_TO_BP,
        cast(AUDIT_LOG_ID as VARCHAR(36)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME
    FROM transform_data

)

select * from type_data