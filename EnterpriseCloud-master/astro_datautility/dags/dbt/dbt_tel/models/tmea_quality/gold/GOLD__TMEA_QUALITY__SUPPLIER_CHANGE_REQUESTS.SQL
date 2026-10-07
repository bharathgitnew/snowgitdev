{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='SUPPLIER_CHANGE_REQUESTS',
        transient=false
) }}

WITH 
CTE_SUPPL_CHANGE_REQUEST AS (
        SELECT
            ISSUE_NBR,
            SSD.DESCR AS SCR_STATUS,
            REQUESTER_ID,
            REQUEST_ID,
            REQUEST_ID AS REQUEST_ID_URL
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHANGE_REQUEST') }} SCR
            JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_STATUS_DESCR') }} SSD ON SCR.STATUS = SSD.STATUS
        ORDER BY
            ISSUE_NBR DESC
    ),
    CTE_REQUESTOR AS (
        SELECT
            USERID,
            CONCAT (FIRST_NAME, ' ', LAST_NAME) AS REQUESTOR
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_USER_INFO') }}
    ),
    CTE_SUPPLIER AS (
        SELECT
            A.USERID,
            A.BUSINESS_PARTNER_ID,
            B.NAME
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_USER_INFO') }} AS A
            LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_BUSINESS_PARTNER') }} AS B ON A.BUSINESS_PARTNER_ID = B.BUSINESS_PARTNER_ID
    ),
    CTE_FACTORY AS (
        SELECT
            SCRF.REQUEST_ID,
            SF.DESCR AS TEL_FACTORY
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHG_REQUEST_FACTORY') }} SCRF
            JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_FACTORY') }} SF ON SCRF.ID = SF.ID
    ),
    CTE_TECHNICAL_OWNER AS (
        SELECT
            REQUEST_ID,
            LISTAGG(CONCAT (FIRST_NAME, ' ', LAST_NAME), ', ') AS TECHNICAL_OWNER
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHG_REQUEST_APPROVER') }} SCRA
            LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_USER_INFO') }} SUI ON SCRA.USERID = SUI.USERID
            LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_ROLE_DESCR') }} SRD ON SCRA.ROLEID = SRD.ROLEID
        WHERE
            DESCR = 'TECHNICAL'
        GROUP BY
            REQUEST_ID
    ),
    CTE_TECH_END_DATE AS (
        SELECT
            DESCR,
            REQUEST_ID,
            TO_DATE(A.ACTION_DT) AS TECH_END_DATE
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHG_REQUEST_TRACKER') }} AS A
            LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_ACTION_DESCR') }} AS B ON A.ACTION_ID = B.ACTION_ID
        WHERE
            A.ACTION_ID = '21' --Approve (technical) 	aka tech end date
    ),
    CTE_SCS_END_DATE AS (
        SELECT
            DESCR,
            REQUEST_ID,
            TO_DATE(A.ACTION_DT) AS SCS_END_DATE
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHG_REQUEST_TRACKER') }} AS A
            LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_ACTION_DESCR') }} AS B ON A.ACTION_ID = B.ACTION_ID
        WHERE
            A.ACTION_ID = '31'
    ),
    CTE_END_DATE AS (
        SELECT
            DESCR,
            REQUEST_ID,
            TO_DATE(A.ACTION_DT) AS END_DATE
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHG_REQUEST_TRACKER') }} AS A
            LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_ACTION_DESCR') }} AS B ON A.ACTION_ID = B.ACTION_ID
        WHERE
            A.ACTION_ID = '41'
    ),
    CTE_SCS_OWNER AS (
        SELECT
            REQUEST_ID,
            LISTAGG(CONCAT (FIRST_NAME, ' ', LAST_NAME), ', ') AS SCS_OWNER
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHG_REQUEST_APPROVER') }}  SCRA
            LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_USER_INFO') }} SUI ON SCRA.USERID = SUI.USERID
            LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_ROLE_DESCR') }} SRD ON SCRA.ROLEID = SRD.ROLEID
        WHERE
            DESCR = 'SCS'
        GROUP BY
            REQUEST_ID
    ),
    CTE_SUPPLIER_SUBMIT_DATE AS (
        SELECT
            REQUEST_ID,
            MIN(TO_DATE(ACTION_DT)) AS SUPPLIER_SUBMIT_DATE
        FROM
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHG_REQUEST_TRACKER') }}
        WHERE
            ACTION_ID = '2'
        GROUP BY
            REQUEST_ID
    ),
    CTE_SUPPL_CHG_REQUEST_APPROVAL AS (
        select
            REQUEST_ID,
            EAR_NBR AS SCR_EAR_NBR
        from
            {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHG_REQUEST_APPROVAL') }}
    ),
    CTE_EAR AS (
        SELECT
            ESARID AS EAR_ID,
            URL_LINK AS EAR_URL_LINK,
            STATUS AS EAR_STATUS,
            DUEDATE AS EAR_ORIG_EST_COMP_DATE,
            ESTCOMPLETIONDATE AS EAR_CURRENT_EST_COMP_DATE,
            STARTDATE AS EAR_START_WORK_DATE,
            COMPLETEDATE AS EAR_ACTUAL_COMPLETION_DATE,
            ECNNUMBER AS EAR_ECN_NUMBER,
            NEEDDATE AS EAR_REQUESTED_ECN_RESOLUTION_DATE,
            CREATED AS EAR_CREATED,
            AUTHOR AS EAR_AUTHOR
        FROM
            {{ ref('SILVER__TMEA_QUALITY__ENGINEERING_ACTION_REQUEST') }}
    ),
    SOURCE_DATA AS (
        SELECT
            DISTINCT REQUEST_ID_URL,
            ISSUE_NBR AS ISSUE_NUMBER,
            SUPPLIER_SUBMIT_DATE,
            SCR_STATUS,
            REQUESTOR,
            NAME AS SUPPLIER_NAME,
            TEL_FACTORY,
            TECHNICAL_OWNER,
            TECH_END_DATE,
            SCS_OWNER,
            SCS_END_DATE,
            END_DATE,
            CONCAT (
                'http://tehaus0124.us.tel.com:8065/SupplierChangeRequest/admin/approveForm?requestId=',
                REQUEST_ID_URL
            ) AS SCR_URL_TEXT,
            SCR_EAR_NBR,
            EAR_ID,
            CONCAT(
                'https://sharepoint.us.tel.com/sites/TMEAENG/_layouts/15/NintexForms/Modern/DisplayForm.aspx?List=d0799c7a%2D06a8%2D46bc%2Db10a%2D5dbc6de1816a&ID=',
                LTRIM(EAR_ID, 'EAR'),
                '&Source=https%3A%2F%2Fsharepoint%2Eus%2Etel%2Ecom%2Fsites%2FTMEAENG%2FLists%2FEAR%2FAllItems%2Easpx%3Fweb%3D1%26useFiltersInViewXml%3D1&ContentTypeId=0x01005C20E25F54532149B121859FA8C1C4FB&RootFolder=%2Fsites%2FTMEAENG%2FLists%2FEAR'
            ) AS EAR_URL_LINK,
            EAR_STATUS,
            EAR_ORIG_EST_COMP_DATE,
            EAR_CURRENT_EST_COMP_DATE,
            EAR_START_WORK_DATE,
            EAR_ACTUAL_COMPLETION_DATE,
            EAR_ECN_NUMBER,
            EAR_REQUESTED_ECN_RESOLUTION_DATE,
            EAR_CREATED,
            EAR_AUTHOR
        FROM
            CTE_SUPPL_CHANGE_REQUEST
            LEFT JOIN CTE_REQUESTOR ON CTE_SUPPL_CHANGE_REQUEST.REQUESTER_ID = CTE_REQUESTOR.USERID
            LEFT JOIN CTE_SUPPLIER ON CTE_SUPPL_CHANGE_REQUEST.REQUESTER_ID = CTE_SUPPLIER.USERID
            LEFT JOIN CTE_FACTORY ON CTE_FACTORY.REQUEST_ID = CTE_SUPPL_CHANGE_REQUEST.REQUEST_ID
            LEFT JOIN CTE_TECHNICAL_OWNER ON CTE_SUPPL_CHANGE_REQUEST.REQUEST_ID = CTE_TECHNICAL_OWNER.REQUEST_ID
            LEFT JOIN CTE_TECH_END_DATE ON CTE_TECH_END_DATE.REQUEST_ID = CTE_SUPPL_CHANGE_REQUEST.REQUEST_ID
            LEFT JOIN CTE_SCS_END_DATE ON CTE_SCS_END_DATE.REQUEST_ID = CTE_SUPPL_CHANGE_REQUEST.REQUEST_ID
            LEFT JOIN CTE_END_DATE ON CTE_END_DATE.REQUEST_ID = CTE_SUPPL_CHANGE_REQUEST.REQUEST_ID
            LEFT JOIN CTE_SCS_OWNER ON CTE_SCS_OWNER.REQUEST_ID = CTE_SUPPL_CHANGE_REQUEST.REQUEST_ID
            LEFT JOIN CTE_SUPPLIER_SUBMIT_DATE ON CTE_SUPPL_CHANGE_REQUEST.REQUEST_ID = CTE_SUPPLIER_SUBMIT_DATE.REQUEST_ID
            LEFT JOIN CTE_SUPPL_CHG_REQUEST_APPROVAL ON CTE_SUPPL_CHG_REQUEST_APPROVAL.REQUEST_ID = CTE_SUPPL_CHANGE_REQUEST.REQUEST_ID
            LEFT JOIN CTE_EAR ON CTE_EAR.EAR_ID = CTE_SUPPL_CHG_REQUEST_APPROVAL.SCR_EAR_NBR
    ),
    transform_data as (
        select
            '{{ invocation_id }}' AS _AUDIT_LOG_ID,
            SHA2('hash_me') AS _ROW_HASH,
            REQUEST_ID_URL,
            ISSUE_NUMBER,
            SUPPLIER_SUBMIT_DATE,
            SCR_STATUS,
            REQUESTOR,
            SUPPLIER_NAME,
            TEL_FACTORY,
            TECHNICAL_OWNER,
            TECH_END_DATE,
            SCS_OWNER,
            SCS_END_DATE,
            END_DATE,
            SCR_URL_TEXT,
            SCR_EAR_NBR,
            EAR_ID,
            EAR_URL_LINK,
            EAR_STATUS,
            EAR_ORIG_EST_COMP_DATE,
            EAR_CURRENT_EST_COMP_DATE,
            EAR_START_WORK_DATE,
            EAR_ACTUAL_COMPLETION_DATE,
            EAR_ECN_NUMBER,
            EAR_REQUESTED_ECN_RESOLUTION_DATE,
            EAR_CREATED,
            EAR_AUTHOR
        from
            source_data
    ),
type_data as(
	select 
			CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
            REQUEST_ID_URL,
            ISSUE_NUMBER,
            SUPPLIER_SUBMIT_DATE,
            SCR_STATUS,
            REQUESTOR,
            SUPPLIER_NAME,
            TEL_FACTORY,
            TECHNICAL_OWNER,
            TECH_END_DATE,
            SCS_OWNER,
            SCS_END_DATE,
            END_DATE,
            SCR_URL_TEXT,
            SCR_EAR_NBR,
            EAR_ID,
            EAR_URL_LINK,
            EAR_STATUS,
            EAR_ORIG_EST_COMP_DATE,
            EAR_CURRENT_EST_COMP_DATE,
            EAR_START_WORK_DATE,
            EAR_ACTUAL_COMPLETION_DATE,
            EAR_ECN_NUMBER,
            EAR_REQUESTED_ECN_RESOLUTION_DATE,
            EAR_CREATED,
            EAR_AUTHOR
    from transform_data
)
select
    *
from
    type_data