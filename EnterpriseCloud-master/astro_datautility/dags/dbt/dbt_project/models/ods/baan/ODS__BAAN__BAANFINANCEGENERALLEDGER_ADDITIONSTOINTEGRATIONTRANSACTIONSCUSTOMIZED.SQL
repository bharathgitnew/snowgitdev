/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_ADDITIONSTOINTEGRATIONTRANSACTIONSCUSTOMIZED.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_ADDITIONSTOINTEGRATIONTRANSACTIONSCUSTOMIZED.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_ADDITIONSTOINTEGRATIONTRANSACTIONSCUSTOMIZED 
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
    alias='BAANFINANCEGENERALLEDGER_ADDITIONSTOINTEGRATIONTRANSACTIONSCUSTOMIZED',
    unique_key = ['FINANCIALTRANSACTIONID',
    'FROMTOID',
    'ORIGINALCOMPANY',
    'SEQUENCENUMBER',
    'TRANSACTIONDATE',
    'TRANSACTIONORIGINID',
    'PROJECTGENERAL',
    'TRANSACTIONORIGINDESCRIPTION',
    'ORDER_NUMBER',
    'POSITION',
    'STATUSID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAM)),'')                                                                                         AS ACQUISITIONMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CACT)),'')                                                                                         AS ACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AGRP)),'')                                                                                         AS AGREEMENTGROUP 
            ,T$AGTY.CONSTANTDESCRIPTION                                                                                                          AS AGREEMENTTYPEDESCRIPTION 
            ,CAST(T$AGTY AS INT)                                                                                                                 AS AGREEMENTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREG)),'')                                                                                         AS AREA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AEXT)),'')                                                                                         AS ASSETEXTENSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$GROU)),'')                                                                                         AS ASSETGROUPCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ANBR)),'')                                                                                         AS ASSETNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BOOK)),'')                                                                                         AS BOOKCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BYFR)),'')                                                                                         AS BUYFROM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COPC)),'')                                                                                         AS CALCULATIONOFFICEPCS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSF)),'')                                                                                         AS CALCULATIONOFFICESFC 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAT)),'')                                                                                         AS CATERY_CCAT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTGY)),'')                                                                                         AS CATERY_CTGY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHNL)),'')                                                                                         AS CHANNEL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RBGP)),'')                                                                                         AS COMMISSIONREBATEGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COTY)),'')                                                                                         AS CONTRACTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                         AS COSTPRICECOMPONENT 
            ,T$COTP.CONSTANTDESCRIPTION                                                                                                          AS COSTTYPEDESCRIPTION 
            ,CAST(T$COTP AS INT)                                                                                                                 AS COSTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$METH)),'')                                                                                         AS DEPRECIATIONCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FREQ)),'')                                                                                         AS DEPRECIATIONFREQUENCY 
            ,T$DTYP.CONSTANTDESCRIPTION                                                                                                          AS DISPOSALTYPEDESCRIPTION 
            ,CAST(T$DTYP AS INT)                                                                                                                 AS DISPOSALTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSPA)),'')                                                                                         AS ELEMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                                                                                         AS EMPLOYEE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EUPC)),'')                                                                                         AS ENTERPRICEUNITCALCOFFICEPCS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EUSF)),'')                                                                                         AS ENTERPRICEUNITCALCOFFICESFC 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EUMW)),'')                                                                                         AS ENTERPRICEUNITMAINWORKCENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EUPR)),'')                                                                                         AS ENTERPRICEUNITPROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EUPU)),'')                                                                                         AS ENTERPRICEUNITPURCHASEOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EUSA)),'')                                                                                         AS ENTERPRICEUNITSALESOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EUSE)),'')                                                                                         AS ENTERPRICEUNITSERVICEOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EUWA)),'')                                                                                         AS ENTERPRICEUNITWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EUWO)),'')                                                                                         AS ENTERPRICEUNITWORKCENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CEQU)),'')                                                                                         AS EQUIPMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FISU)),'')                                                                                         AS FINANCIALBUSINESSPARTNERGROUPPURCHASE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FICU)),'')                                                                                         AS FINANCIALBUSINESSPARTNERGROUPSALES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PROJ)),'')                                                                                         AS FINANCIALCUSTOMERGROUPPCSPROJECT 
            ,T$FITR.CONSTANTDESCRIPTION                                                                                                          AS FINANCIALTRANSACTIONDESCRIPTION 
            ,CAST(T$FITR AS INT)                                                                                                                 AS FINANCIALTRANSACTIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFAC)),'')                                                                                         AS FINANCINGMETHOD 
            ,T$FROT.CONSTANTDESCRIPTION                                                                                                          AS FROMTODESCRIPTION 
            ,CAST(T$FROT AS INT)                                                                                                                 AS FROMTOID 
            ,CAST(T$INST AS BIGINT)                                                                                                              AS INSTALLMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IFBP)),'')                                                                                         AS INVOICEFROMBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICETOBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITG)),'')                                                                                         AS ITEMGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MITG)),'')                                                                                         AS ITEMGROUPMAINITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBRN)),'')                                                                                         AS LINEOFBUSINESS 
            ,CAST(T$LKEY AS BIGINT)                                                                                                              AS LOCATIONKEY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MCNO)),'')                                                                                         AS MACHINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MITM)),'')                                                                                         AS MAINITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MIMA)),'')                                                                                         AS MAINITEMMANUFACTURER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MIPC)),'')                                                                                         AS MAINITEMPRODUCTCLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MIPL)),'')                                                                                         AS MAINITEMPRODUCTLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MNWC)),'')                                                                                         AS MAINWORKCENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'')                                                                                         AS MANUFACTURER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MODE)),'')                                                                                         AS MODEL 
            ,CAST(T$NPER AS TINYINT)                                                                                                             AS NUMBEROFPERIODFORSERVICE 
            ,CAST(T$OBJC AS INT)                                                                                                                 AS OBJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COGR)),'')                                                                                         AS OBJECTGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COEL)),'')                                                                                         AS OBSELEMENT 
            ,CAST(T$OPNO AS INT)                                                                                                                 AS OPERATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COBS)),'')                                                                                         AS ORGANIZATIONBREAKDOWN 
            ,CAST(T$OCOM AS INT)                                                                                                                 AS ORIGINALCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLA)),'')                                                                                         AS PLAN 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCL)),'')                                                                                         AS PRODUCTCLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRLN)),'')                                                                                         AS PRODUCTIONLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLN)),'')                                                                                         AS PRODUCTLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FICP)),'')                                                                                         AS PROJECTGENERAL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PROP)),'')                                                                                         AS PROPERTYTYPECODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PUOF)),'')                                                                                         AS PURCHASEOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$POTY)),'')                                                                                         AS PURCHASEORDERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGP)),'')                                                                                         AS PURCHASESTATISTICSGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDIS)),'')                                                                                         AS REASON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REAS)),'')                                                                                         AS REASONCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFA)),'')                                                                                         AS REFERENCEACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RELN)),'')                                                                                         AS RELATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRV)),'')                                                                                         AS RESULTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRO)),'')                                                                                         AS REVENUECODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SAOF)),'')                                                                                         AS SALESOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORTY)),'')                                                                                         AS SALESORDERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SGPS)),'')                                                                                         AS SALESSTATISTICSGROUP 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,CAST(T$SERN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$GRNO)),'')                                                                                         AS SERIES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SARE)),'')                                                                                         AS SERVICEAREA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SECA)),'')                                                                                         AS SERVICECAR 
            ,T$SECO.CONSTANTDESCRIPTION                                                                                                          AS SERVICECOSTTYPEDESCRIPTION 
            ,CAST(T$SECO AS INT)                                                                                                                 AS SERVICECOSTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEIT)),'')                                                                                         AS SERVICEITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEIG)),'')                                                                                         AS SERVICEITEMGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEKI)),'')                                                                                         AS SERVICEKIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEKT)),'')                                                                                         AS SERVICEKITTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEOF)),'')                                                                                         AS SERVICEOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SETY)),'')                                                                                         AS SERVICETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHFR)),'')                                                                                         AS SHIPFROM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHTO)),'')                                                                                         AS SHIPTO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SLTO)),'')                                                                                         AS SOLDTO 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS STATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SCTG)),'')                                                                                         AS SUBCATERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSUB)),'')                                                                                         AS SUBCONTRACTING 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CICO)),'')                                                                                         AS SUNDRYCOSTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUPE)),'')                                                                                         AS SUPPORTENGINEER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TASK)),'')                                                                                         AS TASK 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRG)),'')                                                                                         AS TRADEGROUP 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,T$TROR.CONSTANTDESCRIPTION                                                                                                          AS TRANSACTIONORIGINDESCRIPTION 
            ,CAST(T$TROR AS INT)                                                                                                                 AS TRANSACTIONORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MCWR)),'')                                                                                         AS WAREHOUSEMAINITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WOTY)),'')                                                                                         AS WAREHOUSINRDERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWTE)),'')                                                                                         AS WARRANTY 
            ,T$WTTP.CONSTANTDESCRIPTION                                                                                                          AS WARRENTYTYPEDESCRIPTION 
            ,CAST(T$WTTP AS INT)                                                                                                                 AS WARRENTYTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS WORKCENTER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD955201") }} AS SOURCETABLE  
            /*AGREEMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$AGTY 
             ON   T$AGTY.TABLENAME  = 'TFGLD955' 
              AND T$AGTY.COLUMNNAME = 'T$AGTY' 
              AND T$AGTY.CONSTANT   = SOURCETABLE.T$AGTY 
            /*COSTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COTP 
             ON   T$COTP.TABLENAME  = 'TFGLD955' 
              AND T$COTP.COLUMNNAME = 'T$COTP' 
              AND T$COTP.CONSTANT   = SOURCETABLE.T$COTP 
            /*DISPOSALTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DTYP 
             ON   T$DTYP.TABLENAME  = 'TFGLD955' 
              AND T$DTYP.COLUMNNAME = 'T$DTYP' 
              AND T$DTYP.CONSTANT   = SOURCETABLE.T$DTYP 
            /*FINANCIALTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FITR 
             ON   T$FITR.TABLENAME  = 'TFGLD955' 
              AND T$FITR.COLUMNNAME = 'T$FITR' 
              AND T$FITR.CONSTANT   = SOURCETABLE.T$FITR 
            /*FROMTO*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FROT 
             ON   T$FROT.TABLENAME  = 'TFGLD955' 
              AND T$FROT.COLUMNNAME = 'T$FROT' 
              AND T$FROT.CONSTANT   = SOURCETABLE.T$FROT 
            /*SERVICECOSTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SECO 
             ON   T$SECO.TABLENAME  = 'TFGLD955' 
              AND T$SECO.COLUMNNAME = 'T$SECO' 
              AND T$SECO.CONSTANT   = SOURCETABLE.T$SECO 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'TFGLD955' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
            /*TRANSACTIONORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TROR 
             ON   T$TROR.TABLENAME  = 'TFGLD955' 
              AND T$TROR.COLUMNNAME = 'T$TROR' 
              AND T$TROR.CONSTANT   = SOURCETABLE.T$TROR 
            /*WARRENTYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$WTTP 
             ON   T$WTTP.TABLENAME  = 'TFGLD955' 
              AND T$WTTP.COLUMNNAME = 'T$WTTP' 
              AND T$WTTP.CONSTANT   = SOURCETABLE.T$WTTP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1970-01-01 00:00:00.000 -0000') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT distinct
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACQUISITIONMETHOD AS ACQUISITIONMETHOD, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.AGREEMENTGROUP AS AGREEMENTGROUP, 
        source_data.AGREEMENTTYPEDESCRIPTION AS AGREEMENTTYPEDESCRIPTION, 
        source_data.AGREEMENTTYPEID AS AGREEMENTTYPEID, 
        source_data.AREA AS AREA, 
        source_data.ASSETEXTENSION AS ASSETEXTENSION, 
        source_data.ASSETGROUPCODE AS ASSETGROUPCODE, 
        source_data.ASSETNUMBER AS ASSETNUMBER, 
        source_data.BOOKCODE AS BOOKCODE, 
        source_data.BUYFROM AS BUYFROM, 
        source_data.CALCULATIONOFFICEPCS AS CALCULATIONOFFICEPCS, 
        source_data.CALCULATIONOFFICESFC AS CALCULATIONOFFICESFC, 
        source_data.CATERY_CCAT AS CATERY_CCAT, 
        source_data.CATERY_CTGY AS CATERY_CTGY, 
        source_data.CHANNEL AS CHANNEL, 
        source_data.COMMISSIONREBATEGROUP AS COMMISSIONREBATEGROUP, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONTRACTTYPE AS CONTRACTTYPE, 
        source_data.COSTPRICECOMPONENT AS COSTPRICECOMPONENT, 
        source_data.COSTTYPEDESCRIPTION AS COSTTYPEDESCRIPTION, 
        source_data.COSTTYPEID AS COSTTYPEID, 
        source_data.COUNTRY AS COUNTRY, 
        source_data.DEPRECIATIONCODE AS DEPRECIATIONCODE, 
        source_data.DEPRECIATIONFREQUENCY AS DEPRECIATIONFREQUENCY, 
        source_data.DISPOSALTYPEDESCRIPTION AS DISPOSALTYPEDESCRIPTION, 
        source_data.DISPOSALTYPEID AS DISPOSALTYPEID, 
        source_data.ELEMENT AS ELEMENT, 
        source_data.EMPLOYEE AS EMPLOYEE, 
        source_data.ENTERPRICEUNITCALCOFFICEPCS AS ENTERPRICEUNITCALCOFFICEPCS, 
        source_data.ENTERPRICEUNITCALCOFFICESFC AS ENTERPRICEUNITCALCOFFICESFC, 
        source_data.ENTERPRICEUNITMAINWORKCENTER AS ENTERPRICEUNITMAINWORKCENTER, 
        source_data.ENTERPRICEUNITPROJECT AS ENTERPRICEUNITPROJECT, 
        source_data.ENTERPRICEUNITPURCHASEOFFICE AS ENTERPRICEUNITPURCHASEOFFICE, 
        source_data.ENTERPRICEUNITSALESOFFICE AS ENTERPRICEUNITSALESOFFICE, 
        source_data.ENTERPRICEUNITSERVICEOFFICE AS ENTERPRICEUNITSERVICEOFFICE, 
        source_data.ENTERPRICEUNITWAREHOUSE AS ENTERPRICEUNITWAREHOUSE, 
        source_data.ENTERPRICEUNITWORKCENTER AS ENTERPRICEUNITWORKCENTER, 
        source_data.EQUIPMENT AS EQUIPMENT, 
        source_data.FINANCIALBUSINESSPARTNERGROUPPURCHASE AS FINANCIALBUSINESSPARTNERGROUPPURCHASE, 
        source_data.FINANCIALBUSINESSPARTNERGROUPSALES AS FINANCIALBUSINESSPARTNERGROUPSALES, 
        source_data.FINANCIALCUSTOMERGROUPPCSPROJECT AS FINANCIALCUSTOMERGROUPPCSPROJECT, 
        source_data.FINANCIALTRANSACTIONDESCRIPTION AS FINANCIALTRANSACTIONDESCRIPTION, 
        source_data.FINANCIALTRANSACTIONID AS FINANCIALTRANSACTIONID, 
        source_data.FINANCINGMETHOD AS FINANCINGMETHOD, 
        source_data.FROMTODESCRIPTION AS FROMTODESCRIPTION, 
        source_data.FROMTOID AS FROMTOID, 
        source_data.INSTALLMENT AS INSTALLMENT, 
        source_data.INVOICEFROMBP AS INVOICEFROMBP, 
        source_data.INVOICETOBP AS INVOICETOBP, 
        source_data.ITEM AS ITEM, 
        source_data.ITEMGROUP AS ITEMGROUP, 
        source_data.ITEMGROUPMAINITEM AS ITEMGROUPMAINITEM, 
        source_data.LINEOFBUSINESS AS LINEOFBUSINESS, 
        source_data.LOCATIONKEY AS LOCATIONKEY, 
        source_data.MACHINE AS MACHINE, 
        source_data.MAINITEM AS MAINITEM, 
        source_data.MAINITEMMANUFACTURER AS MAINITEMMANUFACTURER, 
        source_data.MAINITEMPRODUCTCLASS AS MAINITEMPRODUCTCLASS, 
        source_data.MAINITEMPRODUCTLINE AS MAINITEMPRODUCTLINE, 
        source_data.MAINWORKCENTER AS MAINWORKCENTER, 
        source_data.MANUFACTURER AS MANUFACTURER, 
        source_data.MODEL AS MODEL, 
        source_data.NUMBEROFPERIODFORSERVICE AS NUMBEROFPERIODFORSERVICE, 
        source_data.OBJECT AS OBJECT, 
        source_data.OBJECTGROUP AS OBJECTGROUP, 
        source_data.OBSELEMENT AS OBSELEMENT, 
        source_data.OPERATION AS OPERATION, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER,
        source_data.ORGANIZATIONBREAKDOWN AS ORGANIZATIONBREAKDOWN, 
        source_data.ORIGINALCOMPANY AS ORIGINALCOMPANY, 
        source_data.PLAN AS PLAN, 
        source_data.POSITION AS POSITION,
        source_data.PRODUCTCLASS AS PRODUCTCLASS, 
        source_data.PRODUCTIONLINE AS PRODUCTIONLINE, 
        source_data.PRODUCTLINE AS PRODUCTLINE, 
        source_data.PROJECTGENERAL AS PROJECTGENERAL, 
        source_data.PROPERTYTYPECODE AS PROPERTYTYPECODE, 
        source_data.PURCHASEOFFICE AS PURCHASEOFFICE, 
        source_data.PURCHASEORDERTYPE AS PURCHASEORDERTYPE, 
        source_data.PURCHASESTATISTICSGROUP AS PURCHASESTATISTICSGROUP, 
        source_data.REASON AS REASON, 
        source_data.REASONCODE AS REASONCODE, 
        source_data.REFERENCEACTIVITY AS REFERENCEACTIVITY, 
        source_data.RELATION AS RELATION, 
        source_data.RESULTTYPE AS RESULTTYPE, 
        source_data.REVENUECODE AS REVENUECODE, 
        source_data.SALESOFFICE AS SALESOFFICE, 
        source_data.SALESORDERTYPE AS SALESORDERTYPE, 
        source_data.SALESSTATISTICSGROUP AS SALESSTATISTICSGROUP, 
        source_data.SEQUENCE AS SEQUENCE,
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.SERIES AS SERIES, 
        source_data.SERVICEAREA AS SERVICEAREA, 
        source_data.SERVICECAR AS SERVICECAR, 
        source_data.SERVICECOSTTYPEDESCRIPTION AS SERVICECOSTTYPEDESCRIPTION, 
        source_data.SERVICECOSTTYPEID AS SERVICECOSTTYPEID, 
        source_data.SERVICEITEM AS SERVICEITEM, 
        source_data.SERVICEITEMGROUP AS SERVICEITEMGROUP, 
        source_data.SERVICEKIT AS SERVICEKIT, 
        source_data.SERVICEKITTYPE AS SERVICEKITTYPE, 
        source_data.SERVICEOFFICE AS SERVICEOFFICE, 
        source_data.SERVICETYPE AS SERVICETYPE, 
        source_data.SHIPFROM AS SHIPFROM, 
        source_data.SHIPTO AS SHIPTO, 
        source_data.SOLDTO AS SOLDTO, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION,
        source_data.STATUSID AS STATUSID,
        source_data.SUBCATERY AS SUBCATERY, 
        source_data.SUBCONTRACTING AS SUBCONTRACTING, 
        source_data.SUNDRYCOSTCODE AS SUNDRYCOSTCODE, 
        source_data.SUPPORTENGINEER AS SUPPORTENGINEER, 
        source_data.TASK AS TASK, 
        source_data.TRADEGROUP AS TRADEGROUP, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
        source_data.TRANSACTIONORIGINDESCRIPTION AS TRANSACTIONORIGINDESCRIPTION, 
        source_data.TRANSACTIONORIGINID AS TRANSACTIONORIGINID, 
        source_data.WAREHOUSE AS WAREHOUSE, 
        source_data.WAREHOUSEMAINITEM AS WAREHOUSEMAINITEM, 
        source_data.WAREHOUSINRDERTYPE AS WAREHOUSINRDERTYPE, 
        source_data.WARRANTY AS WARRANTY, 
        source_data.WARRENTYTYPEDESCRIPTION AS WARRENTYTYPEDESCRIPTION, 
        source_data.WARRENTYTYPEID AS WARRENTYTYPEID, 
        source_data.WORKCENTER AS WORKCENTER
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACQUISITIONMETHOD as VARCHAR(3)) as ACQUISITIONMETHOD,
        cast(ACTIVITY as VARCHAR(8)) as ACTIVITY,
        cast(AGREEMENTGROUP as VARCHAR(6)) as AGREEMENTGROUP,
        cast(AGREEMENTTYPEDESCRIPTION as VARCHAR(16777216)) as AGREEMENTTYPEDESCRIPTION,
        cast(AGREEMENTTYPEID as NUMBER(38,0)) as AGREEMENTTYPEID,
        cast(AREA as VARCHAR(3)) as AREA,
        cast(ASSETEXTENSION as VARCHAR(15)) as ASSETEXTENSION,
        cast(ASSETGROUPCODE as VARCHAR(10)) as ASSETGROUPCODE,
        cast(ASSETNUMBER as VARCHAR(15)) as ASSETNUMBER,
        cast(BOOKCODE as VARCHAR(10)) as BOOKCODE,
        cast(BUYFROM as VARCHAR(9)) as BUYFROM,
        cast(CALCULATIONOFFICEPCS as VARCHAR(6)) as CALCULATIONOFFICEPCS,
        cast(CALCULATIONOFFICESFC as VARCHAR(6)) as CALCULATIONOFFICESFC,
        cast(CATERY_CCAT as VARCHAR(3)) as CATERY_CCAT,
        cast(CATERY_CTGY as VARCHAR(10)) as CATERY_CTGY,
        cast(CHANNEL as VARCHAR(3)) as CHANNEL,
        cast(COMMISSIONREBATEGROUP as VARCHAR(6)) as COMMISSIONREBATEGROUP,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONTRACTTYPE as VARCHAR(3)) as CONTRACTTYPE,
        cast(COSTPRICECOMPONENT as VARCHAR(8)) as COSTPRICECOMPONENT,
        cast(COSTTYPEDESCRIPTION as VARCHAR(16777216)) as COSTTYPEDESCRIPTION,
        cast(COSTTYPEID as NUMBER(38,0)) as COSTTYPEID,
        cast(COUNTRY as VARCHAR(3)) as COUNTRY,
        cast(DEPRECIATIONCODE as VARCHAR(20)) as DEPRECIATIONCODE,
        cast(DEPRECIATIONFREQUENCY as VARCHAR(10)) as DEPRECIATIONFREQUENCY,
        cast(DISPOSALTYPEDESCRIPTION as VARCHAR(16777216)) as DISPOSALTYPEDESCRIPTION,
        cast(DISPOSALTYPEID as NUMBER(38,0)) as DISPOSALTYPEID,
        cast(ELEMENT as VARCHAR(8)) as ELEMENT,
        cast(EMPLOYEE as VARCHAR(6)) as EMPLOYEE,
        cast(ENTERPRICEUNITCALCOFFICEPCS as VARCHAR(6)) as ENTERPRICEUNITCALCOFFICEPCS,
        cast(ENTERPRICEUNITCALCOFFICESFC as VARCHAR(6)) as ENTERPRICEUNITCALCOFFICESFC,
        cast(ENTERPRICEUNITMAINWORKCENTER as VARCHAR(6)) as ENTERPRICEUNITMAINWORKCENTER,
        cast(ENTERPRICEUNITPROJECT as VARCHAR(6)) as ENTERPRICEUNITPROJECT,
        cast(ENTERPRICEUNITPURCHASEOFFICE as VARCHAR(6)) as ENTERPRICEUNITPURCHASEOFFICE,
        cast(ENTERPRICEUNITSALESOFFICE as VARCHAR(6)) as ENTERPRICEUNITSALESOFFICE,
        cast(ENTERPRICEUNITSERVICEOFFICE as VARCHAR(6)) as ENTERPRICEUNITSERVICEOFFICE,
        cast(ENTERPRICEUNITWAREHOUSE as VARCHAR(6)) as ENTERPRICEUNITWAREHOUSE,
        cast(ENTERPRICEUNITWORKCENTER as VARCHAR(6)) as ENTERPRICEUNITWORKCENTER,
        cast(EQUIPMENT as VARCHAR(10)) as EQUIPMENT,
        cast(FINANCIALBUSINESSPARTNERGROUPPURCHASE as VARCHAR(3)) as FINANCIALBUSINESSPARTNERGROUPPURCHASE,
        cast(FINANCIALBUSINESSPARTNERGROUPSALES as VARCHAR(3)) as FINANCIALBUSINESSPARTNERGROUPSALES,
        cast(FINANCIALCUSTOMERGROUPPCSPROJECT as VARCHAR(9)) as FINANCIALCUSTOMERGROUPPCSPROJECT,
        cast(FINANCIALTRANSACTIONDESCRIPTION as VARCHAR(16777216)) as FINANCIALTRANSACTIONDESCRIPTION,
        cast(FINANCIALTRANSACTIONID as NUMBER(38,0)) as FINANCIALTRANSACTIONID,
        cast(FINANCINGMETHOD as VARCHAR(3)) as FINANCINGMETHOD,
        cast(FROMTODESCRIPTION as VARCHAR(16777216)) as FROMTODESCRIPTION,
        cast(FROMTOID as NUMBER(38,0)) as FROMTOID,
        cast(INSTALLMENT as NUMBER(38,0)) as INSTALLMENT,
        cast(INVOICEFROMBP as VARCHAR(9)) as INVOICEFROMBP,
        cast(INVOICETOBP as VARCHAR(9)) as INVOICETOBP,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ITEMGROUP as VARCHAR(6)) as ITEMGROUP,
        cast(ITEMGROUPMAINITEM as VARCHAR(6)) as ITEMGROUPMAINITEM,
        cast(LINEOFBUSINESS as VARCHAR(6)) as LINEOFBUSINESS,
        cast(LOCATIONKEY as NUMBER(38,0)) as LOCATIONKEY,
        cast(MACHINE as VARCHAR(6)) as MACHINE,
        cast(MAINITEM as VARCHAR(47)) as MAINITEM,
        cast(MAINITEMMANUFACTURER as VARCHAR(6)) as MAINITEMMANUFACTURER,
        cast(MAINITEMPRODUCTCLASS as VARCHAR(6)) as MAINITEMPRODUCTCLASS,
        cast(MAINITEMPRODUCTLINE as VARCHAR(6)) as MAINITEMPRODUCTLINE,
        cast(MAINWORKCENTER as VARCHAR(6)) as MAINWORKCENTER,
        cast(MANUFACTURER as VARCHAR(6)) as MANUFACTURER,
        cast(MODEL as VARCHAR(47)) as MODEL,
        cast(NUMBEROFPERIODFORSERVICE as NUMBER(38,0)) as NUMBEROFPERIODFORSERVICE,
        cast(OBJECT as NUMBER(38,0)) as OBJECT,
        cast(OBJECTGROUP as VARCHAR(6)) as OBJECTGROUP,
        cast(OBSELEMENT as VARCHAR(8)) as OBSELEMENT,
        cast(OPERATION as NUMBER(38,0)) as OPERATION,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(ORGANIZATIONBREAKDOWN as VARCHAR(9)) as ORGANIZATIONBREAKDOWN,
        cast(ORIGINALCOMPANY as NUMBER(38,0)) as ORIGINALCOMPANY,
        cast(PLAN as VARCHAR(3)) as PLAN,
        cast(POSITION as NUMBER(38,0)) as POSITION,
        cast(PRODUCTCLASS as VARCHAR(6)) as PRODUCTCLASS,
        cast(PRODUCTIONLINE as VARCHAR(6)) as PRODUCTIONLINE,
        cast(PRODUCTLINE as VARCHAR(6)) as PRODUCTLINE,
        cast(PROJECTGENERAL as VARCHAR(9)) as PROJECTGENERAL,
        cast(PROPERTYTYPECODE as VARCHAR(10)) as PROPERTYTYPECODE,
        cast(PURCHASEOFFICE as VARCHAR(6)) as PURCHASEOFFICE,
        cast(PURCHASEORDERTYPE as VARCHAR(3)) as PURCHASEORDERTYPE,
        cast(PURCHASESTATISTICSGROUP as VARCHAR(6)) as PURCHASESTATISTICSGROUP,
        cast(REASON as VARCHAR(6)) as REASON,
        cast(REASONCODE as VARCHAR(10)) as REASONCODE,
        cast(REFERENCEACTIVITY as VARCHAR(8)) as REFERENCEACTIVITY,
        cast(RELATION as VARCHAR(9)) as RELATION,
        cast(RESULTTYPE as VARCHAR(3)) as RESULTTYPE,
        cast(REVENUECODE as VARCHAR(8)) as REVENUECODE,
        cast(SALESOFFICE as VARCHAR(6)) as SALESOFFICE,
        cast(SALESORDERTYPE as VARCHAR(3)) as SALESORDERTYPE,
        cast(SALESSTATISTICSGROUP as VARCHAR(6)) as SALESSTATISTICSGROUP,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SERIES as VARCHAR(8)) as SERIES,
        cast(SERVICEAREA as VARCHAR(3)) as SERVICEAREA,
        cast(SERVICECAR as VARCHAR(10)) as SERVICECAR,
        cast(SERVICECOSTTYPEDESCRIPTION as VARCHAR(16777216)) as SERVICECOSTTYPEDESCRIPTION,
        cast(SERVICECOSTTYPEID as NUMBER(38,0)) as SERVICECOSTTYPEID,
        cast(SERVICEITEM as VARCHAR(47)) as SERVICEITEM,
        cast(SERVICEITEMGROUP as VARCHAR(6)) as SERVICEITEMGROUP,
        cast(SERVICEKIT as VARCHAR(6)) as SERVICEKIT,
        cast(SERVICEKITTYPE as VARCHAR(3)) as SERVICEKITTYPE,
        cast(SERVICEOFFICE as VARCHAR(6)) as SERVICEOFFICE,
        cast(SERVICETYPE as VARCHAR(3)) as SERVICETYPE,
        cast(SHIPFROM as VARCHAR(9)) as SHIPFROM,
        cast(SHIPTO as VARCHAR(9)) as SHIPTO,
        cast(SOLDTO as VARCHAR(9)) as SOLDTO,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(SUBCATERY as VARCHAR(10)) as SUBCATERY,
        cast(SUBCONTRACTING as VARCHAR(8)) as SUBCONTRACTING,
        cast(SUNDRYCOSTCODE as VARCHAR(8)) as SUNDRYCOSTCODE,
        cast(SUPPORTENGINEER as VARCHAR(6)) as SUPPORTENGINEER,
        cast(TASK as VARCHAR(8)) as TASK,
        cast(TRADEGROUP as VARCHAR(3)) as TRADEGROUP,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(TRANSACTIONORIGINDESCRIPTION as VARCHAR(16777216)) as TRANSACTIONORIGINDESCRIPTION,
        cast(TRANSACTIONORIGINID as NUMBER(38,0)) as TRANSACTIONORIGINID,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(WAREHOUSEMAINITEM as VARCHAR(6)) as WAREHOUSEMAINITEM,
        cast(WAREHOUSINRDERTYPE as VARCHAR(3)) as WAREHOUSINRDERTYPE,
        cast(WARRANTY as VARCHAR(16)) as WARRANTY,
        cast(WARRENTYTYPEDESCRIPTION as VARCHAR(16777216)) as WARRENTYTYPEDESCRIPTION,
        cast(WARRENTYTYPEID as NUMBER(38,0)) as WARRENTYTYPEID,
        cast(WORKCENTER as VARCHAR(6)) as WORKCENTER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data