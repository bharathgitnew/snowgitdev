/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANMANUFACTURINGSHOPFLOORCONTROL_PRODUCTIONORDERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANMANUFACTURINGSHOPFLOORCONTROL_PRODUCTIONORDERS.SQL 
-materialized incremental
-alias BAANMANUFACTURINGSHOPFLOORCONTROL_PRODUCTIONORDERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:54 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANMANUFACTURINGSHOPFLOORCONTROL_PRODUCTIONORDERS',
    unique_key = ['PRODUCTIONORDER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$OPDT<= '1/1/1970' THEN NULL ELSE T$OPDT  END AS DATETIME) AS ACTUALOFF_LINEDATE 
            ,CAST(CASE WHEN T$APDT<= '1/1/1970' THEN NULL ELSE T$APDT  END AS DATETIME) AS ACTUALPRODUCTIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ASLN)),'')                                                                                         AS ASSEMBLYLINE 
            ,T$ASMI.CONSTANTDESCRIPTION                                                                                                          AS ASSEMBLYMATERIALISSUENOTEPRINTEDDESCRIPTION 
            ,CAST(T$ASMI AS INT)                                                                                                                 AS ASSEMBLYMATERIALISSUENOTEPRINTEDID 
            ,T$ASRS.CONSTANTDESCRIPTION                                                                                                          AS ASSEMBLYROUTINGSHEETPRINTEDDESCRIPTION 
            ,CAST(T$ASRS AS INT)                                                                                                                 AS ASSEMBLYROUTINGSHEETPRINTEDID 
            ,T$BFHR.CONSTANTDESCRIPTION                                                                                                          AS BACKFLUSHHOURSDESCRIPTION 
            ,CAST(T$BFHR AS INT)                                                                                                                 AS BACKFLUSHHOURSID 
            ,T$BFEP.CONSTANTDESCRIPTION                                                                                                          AS BACKFLUSHMATERIALSDESCRIPTION 
            ,CAST(T$BFEP AS INT)                                                                                                                 AS BACKFLUSHMATERIALSID 
            ,CAST(CASE WHEN T$CADA<= '1/1/1970' THEN NULL ELSE T$CADA  END AS DATETIME) AS CALCULATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLCO)),'')                                                                                         AS CALCULATIONOFFICE 
            ,T$CHEL.CONSTANTDESCRIPTION                                                                                                          AS CHECKLISTPRINTEDDESCRIPTION 
            ,CAST(T$CHEL AS INT)                                                                                                                 AS CHECKLISTPRINTEDID 
            ,CAST(CASE WHEN T$CLDT<= '1/1/1970' THEN NULL ELSE T$CLDT  END AS DATETIME) AS CLOSINGDATE 
            ,CAST(CASE WHEN T$CMDT<= '1/1/1970' THEN NULL ELSE T$CMDT  END AS DATETIME) AS COMPLETIONDATE 
            ,CAST(CASE WHEN T$EFDT<= '1/1/1970' THEN NULL ELSE T$EFDT  END AS DATETIME) AS CONFIGURATIONDATE 
            ,"T$CRPR$1".CONSTANTDESCRIPTION                                                                                                        AS COSTINGREPORTSPRINTED1DESCRIPTION 
            ,CAST("T$CRPR$1" AS INT)                                                                                                               AS COSTINGREPORTSPRINTED1ID 
            ,"T$CRPR$2".CONSTANTDESCRIPTION                                                                                                        AS COSTINGREPORTSPRINTED2DESCRIPTION 
            ,CAST("T$CRPR$2" AS INT)                                                                                                               AS COSTINGREPORTSPRINTED2ID 
            ,"T$CRPR$3".CONSTANTDESCRIPTION                                                                                                        AS COSTINGREPORTSPRINTED3DESCRIPTION 
            ,CAST("T$CRPR$3" AS INT)                                                                                                               AS COSTINGREPORTSPRINTED3ID 
            ,"T$CRPR$4".CONSTANTDESCRIPTION                                                                                                        AS COSTINGREPORTSPRINTED4DESCRIPTION 
            ,CAST("T$CRPR$4" AS INT)                                                                                                               AS COSTINGREPORTSPRINTED4ID 
            ,T$COVN.CONSTANTDESCRIPTION                                                                                                          AS COVERINGNOTEPRINTEDDESCRIPTION 
            ,CAST(T$COVN AS INT)                                                                                                                 AS COVERINGNOTEPRINTEDID 
            ,T$CUTL.CONSTANTDESCRIPTION                                                                                                          AS CUTTINGLISTPRINTEDDESCRIPTION 
            ,CAST(T$CUTL AS INT)                                                                                                                 AS CUTTINGLISTPRINTEDID 
            ,T$DEFC.CONSTANTDESCRIPTION                                                                                                          AS DEFINITIVECLOSEDDESCRIPTION 
            ,CAST(T$DEFC AS INT)                                                                                                                 AS DEFINITIVECLOSEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS ENGINEERINGITEMREVISION 
            ,T$FRES.CONSTANTDESCRIPTION                                                                                                          AS ESTIMATEDCOSTSAREFROZENDESCRIPTION 
            ,CAST(T$FRES AS INT)                                                                                                                 AS ESTIMATEDCOSTSAREFROZENID 
            ,CAST(T$ELTM AS INT)                                                                                                                 AS EXTRALEADTIME 
            ,T$INSN.CONSTANTDESCRIPTION                                                                                                          AS INSPECTIONNOTEPRINTEDDESCRIPTION 
            ,CAST(T$INSN AS INT)                                                                                                                 AS INSPECTIONNOTEPRINTEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MITM)),'')                                                                                         AS ITEM 
            ,CAST(CASE WHEN T$LMAD<= '1/1/1970' THEN NULL ELSE T$LMAD  END AS DATETIME) AS LASTMATERIALALLOCATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                         AS LOTCODE 
            ,T$MATN.CONSTANTDESCRIPTION                                                                                                          AS MATERIALISSUENOTEPRINTEDDESCRIPTION 
            ,CAST(T$MATN AS INT)                                                                                                                 AS MATERIALISSUENOTEPRINTEDID 
            ,T$MATL.CONSTANTDESCRIPTION                                                                                                          AS MATERIALLISTPRINTEDDESCRIPTION 
            ,CAST(T$MATL AS INT)                                                                                                                 AS MATERIALLISTPRINTEDID 
            ,T$MFRE.CONSTANTDESCRIPTION                                                                                                          AS MOMENTOFFREEZINGESTUNITCOSTSDESCRIPTION 
            ,CAST(T$MFRE AS INT)                                                                                                                 AS MOMENTOFFREEZINGESTUNITCOSTSID 
            ,T$MMNO.CONSTANTDESCRIPTION                                                                                                          AS MOVINGMETHODNEXTOPRDESCRIPTION 
            ,CAST(T$MMNO AS INT)                                                                                                                 AS MOVINGMETHODNEXTOPRID 
            ,T$MMPO.CONSTANTDESCRIPTION                                                                                                          AS MOVINGMETHODPREVOPRDESCRIPTION 
            ,CAST(T$MMPO AS INT)                                                                                                                 AS MOVINGMETHODPREVOPRID 
            ,CAST(T$NNTS AS INT)                                                                                                                 AS NUMBEROFPULLNOTES 
            ,CAST(CASE WHEN T$OLDT<= '1/1/1970' THEN NULL ELSE T$OLDT  END AS DATETIME) AS OFFLINEDATE 
            ,T$OPRN.CONSTANTDESCRIPTION                                                                                                          AS OPERATIONNOTEPRINTEDDESCRIPTION 
            ,CAST(T$OPRN AS INT)                                                                                                                 AS OPERATIONNOTEPRINTEDID 
            ,T$BLOC.CONSTANTDESCRIPTION                                                                                                          AS OPERATIONSBLOCKEDDESCRIPTION 
            ,CAST(T$BLOC AS INT)                                                                                                                 AS OPERATIONSBLOCKEDID 
            ,T$OPRP.CONSTANTDESCRIPTION                                                                                                          AS OPERATIONSPRESENTDESCRIPTION 
            ,CAST(T$OPRP AS INT)                                                                                                                 AS OPERATIONSPRESENTID 
            ,T$OSTA.CONSTANTDESCRIPTION                                                                                                          AS ORDER_STATUSDESCRIPTION 
            ,CAST(T$OSTA AS INT)                                                                                                                 AS ORDER_STATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PLID)),'')                                                                                         AS PLANNER 
            ,T$CPLA.CONSTANTDESCRIPTION                                                                                                          AS PLANNINGMETHODDESCRIPTION 
            ,CAST(T$CPLA AS INT)                                                                                                                 AS PLANNINGMETHODID 
            ,CAST(T$PRCD AS INT)                                                                                                                 AS PRIORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PDNO)),'')                                                                                         AS PRODUCTIONORDER 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS PRODUCTIONORDERTEXT 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PRODUCTIONSTARTDATEANDTIME 
            ,CAST(T$CPVA AS BIGINT)                                                                                                              AS PRODUCTVARIANT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,T$PNPT.CONSTANTDESCRIPTION                                                                                                          AS PULLNOTEDESCRIPTION 
            ,CAST(T$PNPT AS INT)                                                                                                                 AS PULLNOTEID 
            ,CAST(T$QBFD AS NUMERIC(15,2))                                                                                                       AS QUANTITYBACKFLUSHED 
            ,CAST(T$QDLV AS NUMERIC(15,2))                                                                                                       AS QUANTITYDELIVERED 
            ,CAST(T$QNTL AS NUMERIC(15,2))                                                                                                       AS QUANTITYINITIAL 
            ,CAST(T$QOOR AS NUMERIC(15,2))                                                                                                       AS QUANTITYONORDER 
            ,CAST(T$QRDR AS NUMERIC(15,2))                                                                                                       AS QUANTITYORDERED 
            ,CAST(T$QRJC AS NUMERIC(15,2))                                                                                                       AS QUANTITYREJECTED 
            ,CAST(T$QTBF AS NUMERIC(15,2))                                                                                                       AS QUANTITYTOBACKFLUSH 
            ,CAST(T$QTDL AS NUMERIC(15,2))                                                                                                       AS QUANTITYTODELIVER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RANU)),'')                                                                                         AS RA_hash_ 
            ,T$RECN.CONSTANTDESCRIPTION                                                                                                          AS RECEIPTNOTEPRINTEDDESCRIPTION 
            ,CAST(T$RECN AS INT)                                                                                                                 AS RECEIPTNOTEPRINTEDID 
            ,CAST(CASE WHEN T$DLDT<= '1/1/1970' THEN NULL ELSE T$DLDT  END AS DATETIME) AS REPLANNEDDELIVERYDATE 
            ,CAST(CASE WHEN T$RDLD<= '1/1/1970' THEN NULL ELSE T$RDLD  END AS DATETIME) AS REQUESTEDDELIVERYDATE 
            ,T$RWKO.CONSTANTDESCRIPTION                                                                                                          AS REWORKORDERDESCRIPTION 
            ,CAST(T$RWKO AS INT)                                                                                                                 AS REWORKORDERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RMAN)),'')                                                                                         AS RMA_hash_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OPRO)),'')                                                                                         AS ROUTING 
            ,T$ROUL.CONSTANTDESCRIPTION                                                                                                          AS ROUTINGSHEETPRINTEDDESCRIPTION 
            ,CAST(T$ROUL AS INT)                                                                                                                 AS ROUTINGSHEETPRINTEDID 
            ,CAST(T$SFTM AS INT)                                                                                                                 AS SAFETYTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SALO)),'')                                                                                         AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRTO)),'')                                                                                         AS SALESORDERNUMBER 
            ,CAST(T$PRTP AS INT)                                                                                                                 AS SALESORDERPOS 
            ,T$SAWL.CONSTANTDESCRIPTION                                                                                                          AS SAWINGLISTPRINTEDDESCRIPTION 
            ,CAST(T$SAWL AS INT)                                                                                                                 AS SAWINGLISTPRINTEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SERN)),'')                                                                                         AS SERIAL_hash_ 
            ,T$SUBN.CONSTANTDESCRIPTION                                                                                                          AS SUBCONTRACTINGNOTEPRINTEDDESCRIPTION 
            ,CAST(T$SUBN AS INT)                                                                                                                 AS SUBCONTRACTINGNOTEPRINTEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
            ,T$RSWC.CONSTANTDESCRIPTION                                                                                                          AS WIPPERWORKCENTERDESCRIPTION 
            ,CAST(T$RSWC AS INT)                                                                                                                 AS WIPPERWORKCENTERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TRCP)),'')                                                                                         AS WIPTRANSFERCOSTCOMPONENT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTISFC001201") }} AS SOURCETABLE  
            /*ASSEMBLYMATERIALISSUENOTEPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ASMI 
             ON   T$ASMI.TABLENAME  = 'TISFC001' 
              AND T$ASMI.COLUMNNAME = 'T$ASMI' 
              AND T$ASMI.CONSTANT   = SOURCETABLE.T$ASMI 
            /*ASSEMBLYROUTINGSHEETPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ASRS 
             ON   T$ASRS.TABLENAME  = 'TISFC001' 
              AND T$ASRS.COLUMNNAME = 'T$ASRS' 
              AND T$ASRS.CONSTANT   = SOURCETABLE.T$ASRS 
            /*BACKFLUSHHOURS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BFHR 
             ON   T$BFHR.TABLENAME  = 'TISFC001' 
              AND T$BFHR.COLUMNNAME = 'T$BFHR' 
              AND T$BFHR.CONSTANT   = SOURCETABLE.T$BFHR 
            /*BACKFLUSHMATERIALS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BFEP 
             ON   T$BFEP.TABLENAME  = 'TISFC001' 
              AND T$BFEP.COLUMNNAME = 'T$BFEP' 
              AND T$BFEP.CONSTANT   = SOURCETABLE.T$BFEP 
            /*CHECKLISTPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CHEL 
             ON   T$CHEL.TABLENAME  = 'TISFC001' 
              AND T$CHEL.COLUMNNAME = 'T$CHEL' 
              AND T$CHEL.CONSTANT   = SOURCETABLE.T$CHEL 
            /*COSTINGREPORTSPRINTED1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$CRPR$1" 
             ON   "T$CRPR$1".TABLENAME  = 'TISFC001' 
              AND "T$CRPR$1".COLUMNNAME = 'T$CRPR' 
              AND "T$CRPR$1".CONSTANT   = SOURCETABLE."T$CRPR$1" 
            /*COSTINGREPORTSPRINTED2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$CRPR$2" 
             ON   "T$CRPR$2".TABLENAME  = 'TISFC001' 
              AND "T$CRPR$2".COLUMNNAME = 'T$CRPR' 
              AND "T$CRPR$2".CONSTANT   = SOURCETABLE."T$CRPR$2" 
            /*COSTINGREPORTSPRINTED3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$CRPR$3" 
             ON   "T$CRPR$3".TABLENAME  = 'TISFC001' 
              AND "T$CRPR$3".COLUMNNAME = 'T$CRPR' 
              AND "T$CRPR$3".CONSTANT   = SOURCETABLE."T$CRPR$3" 
            /*COSTINGREPORTSPRINTED4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$CRPR$4" 
             ON   "T$CRPR$4".TABLENAME  = 'TISFC001' 
              AND "T$CRPR$4".COLUMNNAME = 'T$CRPR' 
              AND "T$CRPR$4".CONSTANT   = SOURCETABLE."T$CRPR$4" 
            /*COVERINGNOTEPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COVN 
             ON   T$COVN.TABLENAME  = 'TISFC001' 
              AND T$COVN.COLUMNNAME = 'T$COVN' 
              AND T$COVN.CONSTANT   = SOURCETABLE.T$COVN 
            /*CUTTINGLISTPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CUTL 
             ON   T$CUTL.TABLENAME  = 'TISFC001' 
              AND T$CUTL.COLUMNNAME = 'T$CUTL' 
              AND T$CUTL.CONSTANT   = SOURCETABLE.T$CUTL 
            /*DEFINITIVECLOSED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEFC 
             ON   T$DEFC.TABLENAME  = 'TISFC001' 
              AND T$DEFC.COLUMNNAME = 'T$DEFC' 
              AND T$DEFC.CONSTANT   = SOURCETABLE.T$DEFC 
            /*ESTIMATEDCOSTSAREFROZEN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FRES 
             ON   T$FRES.TABLENAME  = 'TISFC001' 
              AND T$FRES.COLUMNNAME = 'T$FRES' 
              AND T$FRES.CONSTANT   = SOURCETABLE.T$FRES 
            /*INSPECTIONNOTEPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INSN 
             ON   T$INSN.TABLENAME  = 'TISFC001' 
              AND T$INSN.COLUMNNAME = 'T$INSN' 
              AND T$INSN.CONSTANT   = SOURCETABLE.T$INSN 
            /*MATERIALISSUENOTEPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MATN 
             ON   T$MATN.TABLENAME  = 'TISFC001' 
              AND T$MATN.COLUMNNAME = 'T$MATN' 
              AND T$MATN.CONSTANT   = SOURCETABLE.T$MATN 
            /*MATERIALLISTPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MATL 
             ON   T$MATL.TABLENAME  = 'TISFC001' 
              AND T$MATL.COLUMNNAME = 'T$MATL' 
              AND T$MATL.CONSTANT   = SOURCETABLE.T$MATL 
            /*MOMENTOFFREEZINGESTUNITCOSTS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MFRE 
             ON   T$MFRE.TABLENAME  = 'TISFC001' 
              AND T$MFRE.COLUMNNAME = 'T$MFRE' 
              AND T$MFRE.CONSTANT   = SOURCETABLE.T$MFRE 
            /*MOVINGMETHODNEXTOPR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MMNO 
             ON   T$MMNO.TABLENAME  = 'TISFC001' 
              AND T$MMNO.COLUMNNAME = 'T$MMNO' 
              AND T$MMNO.CONSTANT   = SOURCETABLE.T$MMNO 
            /*MOVINGMETHODPREVOPR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MMPO 
             ON   T$MMPO.TABLENAME  = 'TISFC001' 
              AND T$MMPO.COLUMNNAME = 'T$MMPO' 
              AND T$MMPO.CONSTANT   = SOURCETABLE.T$MMPO 
            /*OPERATIONNOTEPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPRN 
             ON   T$OPRN.TABLENAME  = 'TISFC001' 
              AND T$OPRN.COLUMNNAME = 'T$OPRN' 
              AND T$OPRN.CONSTANT   = SOURCETABLE.T$OPRN 
            /*OPERATIONSBLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLOC 
             ON   T$BLOC.TABLENAME  = 'TISFC001' 
              AND T$BLOC.COLUMNNAME = 'T$BLOC' 
              AND T$BLOC.CONSTANT   = SOURCETABLE.T$BLOC 
            /*OPERATIONSPRESENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPRP 
             ON   T$OPRP.TABLENAME  = 'TISFC001' 
              AND T$OPRP.COLUMNNAME = 'T$OPRP' 
              AND T$OPRP.CONSTANT   = SOURCETABLE.T$OPRP 
            /*ORDERSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OSTA 
             ON   T$OSTA.TABLENAME  = 'TISFC001' 
              AND T$OSTA.COLUMNNAME = 'T$OSTA' 
              AND T$OSTA.CONSTANT   = SOURCETABLE.T$OSTA 
            /*PLANNINGMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CPLA 
             ON   T$CPLA.TABLENAME  = 'TISFC001' 
              AND T$CPLA.COLUMNNAME = 'T$CPLA' 
              AND T$CPLA.CONSTANT   = SOURCETABLE.T$CPLA 
            /*PULLNOTE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PNPT 
             ON   T$PNPT.TABLENAME  = 'TISFC001' 
              AND T$PNPT.COLUMNNAME = 'T$PNPT' 
              AND T$PNPT.CONSTANT   = SOURCETABLE.T$PNPT 
            /*RECEIPTNOTEPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RECN 
             ON   T$RECN.TABLENAME  = 'TISFC001' 
              AND T$RECN.COLUMNNAME = 'T$RECN' 
              AND T$RECN.CONSTANT   = SOURCETABLE.T$RECN 
            /*REWORKORDER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RWKO 
             ON   T$RWKO.TABLENAME  = 'TISFC001' 
              AND T$RWKO.COLUMNNAME = 'T$RWKO' 
              AND T$RWKO.CONSTANT   = SOURCETABLE.T$RWKO 
            /*ROUTINGSHEETPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ROUL 
             ON   T$ROUL.TABLENAME  = 'TISFC001' 
              AND T$ROUL.COLUMNNAME = 'T$ROUL' 
              AND T$ROUL.CONSTANT   = SOURCETABLE.T$ROUL 
            /*SAWINGLISTPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SAWL 
             ON   T$SAWL.TABLENAME  = 'TISFC001' 
              AND T$SAWL.COLUMNNAME = 'T$SAWL' 
              AND T$SAWL.CONSTANT   = SOURCETABLE.T$SAWL 
            /*SUBCONTRACTINGNOTEPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SUBN 
             ON   T$SUBN.TABLENAME  = 'TISFC001' 
              AND T$SUBN.COLUMNNAME = 'T$SUBN' 
              AND T$SUBN.CONSTANT   = SOURCETABLE.T$SUBN 
            /*WIPPERWORKCENTER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RSWC 
             ON   T$RSWC.TABLENAME  = 'TISFC001' 
              AND T$RSWC.COLUMNNAME = 'T$RSWC' 
              AND T$RSWC.CONSTANT   = SOURCETABLE.T$RSWC 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTUALOFF_LINEDATE AS ACTUALOFF_LINEDATE, 
        source_data.ACTUALPRODUCTIONDATE AS ACTUALPRODUCTIONDATE, 
        source_data.ASSEMBLYLINE AS ASSEMBLYLINE, 
        source_data.ASSEMBLYMATERIALISSUENOTEPRINTEDDESCRIPTION AS ASSEMBLYMATERIALISSUENOTEPRINTEDDESCRIPTION, 
        source_data.ASSEMBLYMATERIALISSUENOTEPRINTEDID AS ASSEMBLYMATERIALISSUENOTEPRINTEDID, 
        source_data.ASSEMBLYROUTINGSHEETPRINTEDDESCRIPTION AS ASSEMBLYROUTINGSHEETPRINTEDDESCRIPTION, 
        source_data.ASSEMBLYROUTINGSHEETPRINTEDID AS ASSEMBLYROUTINGSHEETPRINTEDID, 
        source_data.BACKFLUSHHOURSDESCRIPTION AS BACKFLUSHHOURSDESCRIPTION, 
        source_data.BACKFLUSHHOURSID AS BACKFLUSHHOURSID, 
        source_data.BACKFLUSHMATERIALSDESCRIPTION AS BACKFLUSHMATERIALSDESCRIPTION, 
        source_data.BACKFLUSHMATERIALSID AS BACKFLUSHMATERIALSID, 
        source_data.CALCULATIONDATE AS CALCULATIONDATE, 
        source_data.CALCULATIONOFFICE AS CALCULATIONOFFICE, 
        source_data.CHECKLISTPRINTEDDESCRIPTION AS CHECKLISTPRINTEDDESCRIPTION, 
        source_data.CHECKLISTPRINTEDID AS CHECKLISTPRINTEDID, 
        source_data.CLOSINGDATE AS CLOSINGDATE, 
        source_data.COMPLETIONDATE AS COMPLETIONDATE, 
        source_data.CONFIGURATIONDATE AS CONFIGURATIONDATE, 
        source_data.COSTINGREPORTSPRINTED1DESCRIPTION AS COSTINGREPORTSPRINTED1DESCRIPTION, 
        source_data.COSTINGREPORTSPRINTED1ID AS COSTINGREPORTSPRINTED1ID, 
        source_data.COSTINGREPORTSPRINTED2DESCRIPTION AS COSTINGREPORTSPRINTED2DESCRIPTION, 
        source_data.COSTINGREPORTSPRINTED2ID AS COSTINGREPORTSPRINTED2ID, 
        source_data.COSTINGREPORTSPRINTED3DESCRIPTION AS COSTINGREPORTSPRINTED3DESCRIPTION, 
        source_data.COSTINGREPORTSPRINTED3ID AS COSTINGREPORTSPRINTED3ID, 
        source_data.COSTINGREPORTSPRINTED4DESCRIPTION AS COSTINGREPORTSPRINTED4DESCRIPTION, 
        source_data.COSTINGREPORTSPRINTED4ID AS COSTINGREPORTSPRINTED4ID, 
        source_data.COVERINGNOTEPRINTEDDESCRIPTION AS COVERINGNOTEPRINTEDDESCRIPTION, 
        source_data.COVERINGNOTEPRINTEDID AS COVERINGNOTEPRINTEDID, 
        source_data.CUTTINGLISTPRINTEDDESCRIPTION AS CUTTINGLISTPRINTEDDESCRIPTION, 
        source_data.CUTTINGLISTPRINTEDID AS CUTTINGLISTPRINTEDID, 
        source_data.DEFINITIVECLOSEDDESCRIPTION AS DEFINITIVECLOSEDDESCRIPTION, 
        source_data.DEFINITIVECLOSEDID AS DEFINITIVECLOSEDID, 
        source_data.ENGINEERINGITEMREVISION AS ENGINEERINGITEMREVISION, 
        source_data.ESTIMATEDCOSTSAREFROZENDESCRIPTION AS ESTIMATEDCOSTSAREFROZENDESCRIPTION, 
        source_data.ESTIMATEDCOSTSAREFROZENID AS ESTIMATEDCOSTSAREFROZENID, 
        source_data.EXTRALEADTIME AS EXTRALEADTIME, 
        source_data.INSPECTIONNOTEPRINTEDDESCRIPTION AS INSPECTIONNOTEPRINTEDDESCRIPTION, 
        source_data.INSPECTIONNOTEPRINTEDID AS INSPECTIONNOTEPRINTEDID, 
        source_data.ITEM AS ITEM, 
        source_data.LASTMATERIALALLOCATIONDATE AS LASTMATERIALALLOCATIONDATE, 
        source_data.LOTCODE AS LOTCODE, 
        source_data.MATERIALISSUENOTEPRINTEDDESCRIPTION AS MATERIALISSUENOTEPRINTEDDESCRIPTION, 
        source_data.MATERIALISSUENOTEPRINTEDID AS MATERIALISSUENOTEPRINTEDID, 
        source_data.MATERIALLISTPRINTEDDESCRIPTION AS MATERIALLISTPRINTEDDESCRIPTION, 
        source_data.MATERIALLISTPRINTEDID AS MATERIALLISTPRINTEDID, 
        source_data.MOMENTOFFREEZINGESTUNITCOSTSDESCRIPTION AS MOMENTOFFREEZINGESTUNITCOSTSDESCRIPTION, 
        source_data.MOMENTOFFREEZINGESTUNITCOSTSID AS MOMENTOFFREEZINGESTUNITCOSTSID, 
        source_data.MOVINGMETHODNEXTOPRDESCRIPTION AS MOVINGMETHODNEXTOPRDESCRIPTION, 
        source_data.MOVINGMETHODNEXTOPRID AS MOVINGMETHODNEXTOPRID, 
        source_data.MOVINGMETHODPREVOPRDESCRIPTION AS MOVINGMETHODPREVOPRDESCRIPTION, 
        source_data.MOVINGMETHODPREVOPRID AS MOVINGMETHODPREVOPRID, 
        source_data.NUMBEROFPULLNOTES AS NUMBEROFPULLNOTES, 
        source_data.OFFLINEDATE AS OFFLINEDATE, 
        source_data.OPERATIONNOTEPRINTEDDESCRIPTION AS OPERATIONNOTEPRINTEDDESCRIPTION, 
        source_data.OPERATIONNOTEPRINTEDID AS OPERATIONNOTEPRINTEDID, 
        source_data.OPERATIONSBLOCKEDDESCRIPTION AS OPERATIONSBLOCKEDDESCRIPTION, 
        source_data.OPERATIONSBLOCKEDID AS OPERATIONSBLOCKEDID, 
        source_data.OPERATIONSPRESENTDESCRIPTION AS OPERATIONSPRESENTDESCRIPTION, 
        source_data.OPERATIONSPRESENTID AS OPERATIONSPRESENTID, 
        source_data.ORDER_STATUSDESCRIPTION AS ORDER_STATUSDESCRIPTION, 
        source_data.ORDER_STATUSID AS ORDER_STATUSID, 
        source_data.PLANNER AS PLANNER, 
        source_data.PLANNINGMETHODDESCRIPTION AS PLANNINGMETHODDESCRIPTION, 
        source_data.PLANNINGMETHODID AS PLANNINGMETHODID, 
        source_data.PRIORITY AS PRIORITY, 
        source_data.PRODUCTIONORDER AS PRODUCTIONORDER, 
        source_data.PRODUCTIONORDERTEXT AS PRODUCTIONORDERTEXT, 
        source_data.PRODUCTIONSTARTDATEANDTIME AS PRODUCTIONSTARTDATEANDTIME, 
        source_data.PRODUCTVARIANT AS PRODUCTVARIANT, 
        source_data.PROJECT AS PROJECT, 
        source_data.PULLNOTEDESCRIPTION AS PULLNOTEDESCRIPTION, 
        source_data.PULLNOTEID AS PULLNOTEID, 
        source_data.QUANTITYBACKFLUSHED AS QUANTITYBACKFLUSHED, 
        source_data.QUANTITYDELIVERED AS QUANTITYDELIVERED, 
        source_data.QUANTITYINITIAL AS QUANTITYINITIAL, 
        source_data.QUANTITYONORDER AS QUANTITYONORDER, 
        source_data.QUANTITYORDERED AS QUANTITYORDERED, 
        source_data.QUANTITYREJECTED AS QUANTITYREJECTED, 
        source_data.QUANTITYTOBACKFLUSH AS QUANTITYTOBACKFLUSH, 
        source_data.QUANTITYTODELIVER AS QUANTITYTODELIVER, 
        source_data.RA_HASH_ AS RA_HASH_, 
        source_data.RECEIPTNOTEPRINTEDDESCRIPTION AS RECEIPTNOTEPRINTEDDESCRIPTION, 
        source_data.RECEIPTNOTEPRINTEDID AS RECEIPTNOTEPRINTEDID, 
        source_data.REPLANNEDDELIVERYDATE AS REPLANNEDDELIVERYDATE, 
        source_data.REQUESTEDDELIVERYDATE AS REQUESTEDDELIVERYDATE, 
        source_data.REWORKORDERDESCRIPTION AS REWORKORDERDESCRIPTION, 
        source_data.REWORKORDERID AS REWORKORDERID, 
        source_data.RMA_HASH_ AS RMA_HASH_, 
        source_data.ROUTING AS ROUTING, 
        source_data.ROUTINGSHEETPRINTEDDESCRIPTION AS ROUTINGSHEETPRINTEDDESCRIPTION, 
        source_data.ROUTINGSHEETPRINTEDID AS ROUTINGSHEETPRINTEDID, 
        source_data.SAFETYTIME AS SAFETYTIME, 
        source_data.SALESORDER AS SALESORDER, 
        source_data.SALESORDERNUMBER AS SALESORDERNUMBER, 
        source_data.SALESORDERPOS AS SALESORDERPOS, 
        source_data.SAWINGLISTPRINTEDDESCRIPTION AS SAWINGLISTPRINTEDDESCRIPTION, 
        source_data.SAWINGLISTPRINTEDID AS SAWINGLISTPRINTEDID, 
        source_data.SERIAL_HASH_ AS SERIAL_HASH_, 
        source_data.SUBCONTRACTINGNOTEPRINTEDDESCRIPTION AS SUBCONTRACTINGNOTEPRINTEDDESCRIPTION, 
        source_data.SUBCONTRACTINGNOTEPRINTEDID AS SUBCONTRACTINGNOTEPRINTEDID, 
        source_data.WAREHOUSE AS WAREHOUSE, 
        source_data.WIPPERWORKCENTERDESCRIPTION AS WIPPERWORKCENTERDESCRIPTION, 
        source_data.WIPPERWORKCENTERID AS WIPPERWORKCENTERID, 
        source_data.WIPTRANSFERCOSTCOMPONENT AS WIPTRANSFERCOSTCOMPONENT
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTUALOFF_LINEDATE as TIMESTAMP_NTZ(9)) as ACTUALOFF_LINEDATE,
        cast(ACTUALPRODUCTIONDATE as TIMESTAMP_NTZ(9)) as ACTUALPRODUCTIONDATE,
        cast(ASSEMBLYLINE as VARCHAR(6)) as ASSEMBLYLINE,
        cast(ASSEMBLYMATERIALISSUENOTEPRINTEDDESCRIPTION as VARCHAR(16777216)) as ASSEMBLYMATERIALISSUENOTEPRINTEDDESCRIPTION,
        cast(ASSEMBLYMATERIALISSUENOTEPRINTEDID as NUMBER(38,0)) as ASSEMBLYMATERIALISSUENOTEPRINTEDID,
        cast(ASSEMBLYROUTINGSHEETPRINTEDDESCRIPTION as VARCHAR(16777216)) as ASSEMBLYROUTINGSHEETPRINTEDDESCRIPTION,
        cast(ASSEMBLYROUTINGSHEETPRINTEDID as NUMBER(38,0)) as ASSEMBLYROUTINGSHEETPRINTEDID,
        cast(BACKFLUSHHOURSDESCRIPTION as VARCHAR(16777216)) as BACKFLUSHHOURSDESCRIPTION,
        cast(BACKFLUSHHOURSID as NUMBER(38,0)) as BACKFLUSHHOURSID,
        cast(BACKFLUSHMATERIALSDESCRIPTION as VARCHAR(16777216)) as BACKFLUSHMATERIALSDESCRIPTION,
        cast(BACKFLUSHMATERIALSID as NUMBER(38,0)) as BACKFLUSHMATERIALSID,
        cast(CALCULATIONDATE as TIMESTAMP_NTZ(9)) as CALCULATIONDATE,
        cast(CALCULATIONOFFICE as VARCHAR(6)) as CALCULATIONOFFICE,
        cast(CHECKLISTPRINTEDDESCRIPTION as VARCHAR(16777216)) as CHECKLISTPRINTEDDESCRIPTION,
        cast(CHECKLISTPRINTEDID as NUMBER(38,0)) as CHECKLISTPRINTEDID,
        cast(CLOSINGDATE as TIMESTAMP_NTZ(9)) as CLOSINGDATE,
        cast(COMPLETIONDATE as TIMESTAMP_NTZ(9)) as COMPLETIONDATE,
        cast(CONFIGURATIONDATE as TIMESTAMP_NTZ(9)) as CONFIGURATIONDATE,
        cast(COSTINGREPORTSPRINTED1DESCRIPTION as VARCHAR(16777216)) as COSTINGREPORTSPRINTED1DESCRIPTION,
        cast(COSTINGREPORTSPRINTED1ID as NUMBER(38,0)) as COSTINGREPORTSPRINTED1ID,
        cast(COSTINGREPORTSPRINTED2DESCRIPTION as VARCHAR(16777216)) as COSTINGREPORTSPRINTED2DESCRIPTION,
        cast(COSTINGREPORTSPRINTED2ID as NUMBER(38,0)) as COSTINGREPORTSPRINTED2ID,
        cast(COSTINGREPORTSPRINTED3DESCRIPTION as VARCHAR(16777216)) as COSTINGREPORTSPRINTED3DESCRIPTION,
        cast(COSTINGREPORTSPRINTED3ID as NUMBER(38,0)) as COSTINGREPORTSPRINTED3ID,
        cast(COSTINGREPORTSPRINTED4DESCRIPTION as VARCHAR(16777216)) as COSTINGREPORTSPRINTED4DESCRIPTION,
        cast(COSTINGREPORTSPRINTED4ID as NUMBER(38,0)) as COSTINGREPORTSPRINTED4ID,
        cast(COVERINGNOTEPRINTEDDESCRIPTION as VARCHAR(16777216)) as COVERINGNOTEPRINTEDDESCRIPTION,
        cast(COVERINGNOTEPRINTEDID as NUMBER(38,0)) as COVERINGNOTEPRINTEDID,
        cast(CUTTINGLISTPRINTEDDESCRIPTION as VARCHAR(16777216)) as CUTTINGLISTPRINTEDDESCRIPTION,
        cast(CUTTINGLISTPRINTEDID as NUMBER(38,0)) as CUTTINGLISTPRINTEDID,
        cast(DEFINITIVECLOSEDDESCRIPTION as VARCHAR(16777216)) as DEFINITIVECLOSEDDESCRIPTION,
        cast(DEFINITIVECLOSEDID as NUMBER(38,0)) as DEFINITIVECLOSEDID,
        cast(ENGINEERINGITEMREVISION as VARCHAR(6)) as ENGINEERINGITEMREVISION,
        cast(ESTIMATEDCOSTSAREFROZENDESCRIPTION as VARCHAR(16777216)) as ESTIMATEDCOSTSAREFROZENDESCRIPTION,
        cast(ESTIMATEDCOSTSAREFROZENID as NUMBER(38,0)) as ESTIMATEDCOSTSAREFROZENID,
        cast(EXTRALEADTIME as NUMBER(38,0)) as EXTRALEADTIME,
        cast(INSPECTIONNOTEPRINTEDDESCRIPTION as VARCHAR(16777216)) as INSPECTIONNOTEPRINTEDDESCRIPTION,
        cast(INSPECTIONNOTEPRINTEDID as NUMBER(38,0)) as INSPECTIONNOTEPRINTEDID,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LASTMATERIALALLOCATIONDATE as TIMESTAMP_NTZ(9)) as LASTMATERIALALLOCATIONDATE,
        cast(LOTCODE as VARCHAR(16)) as LOTCODE,
        cast(MATERIALISSUENOTEPRINTEDDESCRIPTION as VARCHAR(16777216)) as MATERIALISSUENOTEPRINTEDDESCRIPTION,
        cast(MATERIALISSUENOTEPRINTEDID as NUMBER(38,0)) as MATERIALISSUENOTEPRINTEDID,
        cast(MATERIALLISTPRINTEDDESCRIPTION as VARCHAR(16777216)) as MATERIALLISTPRINTEDDESCRIPTION,
        cast(MATERIALLISTPRINTEDID as NUMBER(38,0)) as MATERIALLISTPRINTEDID,
        cast(MOMENTOFFREEZINGESTUNITCOSTSDESCRIPTION as VARCHAR(16777216)) as MOMENTOFFREEZINGESTUNITCOSTSDESCRIPTION,
        cast(MOMENTOFFREEZINGESTUNITCOSTSID as NUMBER(38,0)) as MOMENTOFFREEZINGESTUNITCOSTSID,
        cast(MOVINGMETHODNEXTOPRDESCRIPTION as VARCHAR(16777216)) as MOVINGMETHODNEXTOPRDESCRIPTION,
        cast(MOVINGMETHODNEXTOPRID as NUMBER(38,0)) as MOVINGMETHODNEXTOPRID,
        cast(MOVINGMETHODPREVOPRDESCRIPTION as VARCHAR(16777216)) as MOVINGMETHODPREVOPRDESCRIPTION,
        cast(MOVINGMETHODPREVOPRID as NUMBER(38,0)) as MOVINGMETHODPREVOPRID,
        cast(NUMBEROFPULLNOTES as NUMBER(38,0)) as NUMBEROFPULLNOTES,
        cast(OFFLINEDATE as TIMESTAMP_NTZ(9)) as OFFLINEDATE,
        cast(OPERATIONNOTEPRINTEDDESCRIPTION as VARCHAR(16777216)) as OPERATIONNOTEPRINTEDDESCRIPTION,
        cast(OPERATIONNOTEPRINTEDID as NUMBER(38,0)) as OPERATIONNOTEPRINTEDID,
        cast(OPERATIONSBLOCKEDDESCRIPTION as VARCHAR(16777216)) as OPERATIONSBLOCKEDDESCRIPTION,
        cast(OPERATIONSBLOCKEDID as NUMBER(38,0)) as OPERATIONSBLOCKEDID,
        cast(OPERATIONSPRESENTDESCRIPTION as VARCHAR(16777216)) as OPERATIONSPRESENTDESCRIPTION,
        cast(OPERATIONSPRESENTID as NUMBER(38,0)) as OPERATIONSPRESENTID,
        cast(ORDER_STATUSDESCRIPTION as VARCHAR(16777216)) as ORDER_STATUSDESCRIPTION,
        cast(ORDER_STATUSID as NUMBER(38,0)) as ORDER_STATUSID,
        cast(PLANNER as VARCHAR(6)) as PLANNER,
        cast(PLANNINGMETHODDESCRIPTION as VARCHAR(16777216)) as PLANNINGMETHODDESCRIPTION,
        cast(PLANNINGMETHODID as NUMBER(38,0)) as PLANNINGMETHODID,
        cast(PRIORITY as NUMBER(38,0)) as PRIORITY,
        cast(PRODUCTIONORDER as VARCHAR(9)) as PRODUCTIONORDER,
        cast(PRODUCTIONORDERTEXT as NUMBER(38,10)) as PRODUCTIONORDERTEXT,
        cast(PRODUCTIONSTARTDATEANDTIME as TIMESTAMP_NTZ(9)) as PRODUCTIONSTARTDATEANDTIME,
        cast(PRODUCTVARIANT as NUMBER(38,0)) as PRODUCTVARIANT,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(PULLNOTEDESCRIPTION as VARCHAR(16777216)) as PULLNOTEDESCRIPTION,
        cast(PULLNOTEID as NUMBER(38,0)) as PULLNOTEID,
        cast(QUANTITYBACKFLUSHED as NUMBER(15,2)) as QUANTITYBACKFLUSHED,
        cast(QUANTITYDELIVERED as NUMBER(15,2)) as QUANTITYDELIVERED,
        cast(QUANTITYINITIAL as NUMBER(15,2)) as QUANTITYINITIAL,
        cast(QUANTITYONORDER as NUMBER(15,2)) as QUANTITYONORDER,
        cast(QUANTITYORDERED as NUMBER(15,2)) as QUANTITYORDERED,
        cast(QUANTITYREJECTED as NUMBER(15,2)) as QUANTITYREJECTED,
        cast(QUANTITYTOBACKFLUSH as NUMBER(15,2)) as QUANTITYTOBACKFLUSH,
        cast(QUANTITYTODELIVER as NUMBER(15,2)) as QUANTITYTODELIVER,
        cast(RA_HASH_ as VARCHAR(20)) as RA_HASH_,
        cast(RECEIPTNOTEPRINTEDDESCRIPTION as VARCHAR(16777216)) as RECEIPTNOTEPRINTEDDESCRIPTION,
        cast(RECEIPTNOTEPRINTEDID as NUMBER(38,0)) as RECEIPTNOTEPRINTEDID,
        cast(REPLANNEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as REPLANNEDDELIVERYDATE,
        cast(REQUESTEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as REQUESTEDDELIVERYDATE,
        cast(REWORKORDERDESCRIPTION as VARCHAR(16777216)) as REWORKORDERDESCRIPTION,
        cast(REWORKORDERID as NUMBER(38,0)) as REWORKORDERID,
        cast(RMA_HASH_ as VARCHAR(10)) as RMA_HASH_,
        cast(ROUTING as VARCHAR(6)) as ROUTING,
        cast(ROUTINGSHEETPRINTEDDESCRIPTION as VARCHAR(16777216)) as ROUTINGSHEETPRINTEDDESCRIPTION,
        cast(ROUTINGSHEETPRINTEDID as NUMBER(38,0)) as ROUTINGSHEETPRINTEDID,
        cast(SAFETYTIME as NUMBER(38,0)) as SAFETYTIME,
        cast(SALESORDER as VARCHAR(9)) as SALESORDER,
        cast(SALESORDERNUMBER as VARCHAR(9)) as SALESORDERNUMBER,
        cast(SALESORDERPOS as NUMBER(38,0)) as SALESORDERPOS,
        cast(SAWINGLISTPRINTEDDESCRIPTION as VARCHAR(16777216)) as SAWINGLISTPRINTEDDESCRIPTION,
        cast(SAWINGLISTPRINTEDID as NUMBER(38,0)) as SAWINGLISTPRINTEDID,
        cast(SERIAL_HASH_ as VARCHAR(30)) as SERIAL_HASH_,
        cast(SUBCONTRACTINGNOTEPRINTEDDESCRIPTION as VARCHAR(16777216)) as SUBCONTRACTINGNOTEPRINTEDDESCRIPTION,
        cast(SUBCONTRACTINGNOTEPRINTEDID as NUMBER(38,0)) as SUBCONTRACTINGNOTEPRINTEDID,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(WIPPERWORKCENTERDESCRIPTION as VARCHAR(16777216)) as WIPPERWORKCENTERDESCRIPTION,
        cast(WIPPERWORKCENTERID as NUMBER(38,0)) as WIPPERWORKCENTERID,
        cast(WIPTRANSFERCOSTCOMPONENT as VARCHAR(8)) as WIPTRANSFERCOSTCOMPONENT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data