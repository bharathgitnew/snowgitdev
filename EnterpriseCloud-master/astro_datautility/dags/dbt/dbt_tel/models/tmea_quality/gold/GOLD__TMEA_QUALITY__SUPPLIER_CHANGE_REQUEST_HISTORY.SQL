{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SUPPLIER_CHANGE_REQUEST_HISTORY',
    	transient=false
) }}

WITH ONE AS(
    select
        issue_nbr,
        REQUEST_ID AS R_ID,
        -- REQUESTER_ID,
        -- A.USERID,
        A.BUSINESS_PARTNER_ID,
        B.NAME
    from
        {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHANGE_REQUEST') }} AS SCR
        LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_USER_INFO') }} AS A ON SCR.REQUESTER_ID = USERID
        LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_BUSINESS_PARTNER') }} AS B ON A.BUSINESS_PARTNER_ID = B.BUSINESS_PARTNER_ID
),
TWO AS(
    select
        SUPPL_CHG_REQUEST_TRACKER_ID,
        SCRT.REQUEST_ID,
        //SCRT.ACTION_ID AS EVENT_ID,
        DESCR AS EVENT,
        //SCRT.USERID AS EVENT_BY_ID,
        CONCAT(FIRST_NAME, ' ', LAST_NAME) AS EVENT_BY,
        ACTION_DT AS EVENT_DATE_TIME
    from
        {{ ref('SILVER__TMEA_QUALITY__SUPPL_CHG_REQUEST_TRACKER') }} SCRT
        LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_ACTION_DESCR') }} SAD ON SCRT.ACTION_ID = SAD.ACTION_ID
        LEFT JOIN {{ ref('SILVER__TMEA_QUALITY__SUPPL_USER_INFO') }} SUI ON SCRT.USERID = SUI.USERID
),
MAIN AS (
    SELECT
        *
    FROM
        ONE
        LEFT JOIN TWO ON R_ID = TWO.REQUEST_ID
),
source_data as (
select
    REQUEST_ID,
    ISSUE_NBR,
    EVENT,
    EVENT_BY,
    BUSINESS_PARTNER_ID,
    NAME AS SUPPLIER_NAME,
    EVENT_DATE_TIME
from
    MAIN
ORDER BY
    ISSUE_NBR,
    EVENT_DATE_TIME
),
transform_data as (
select
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	REQUEST_ID,
	ISSUE_NBR,
	EVENT,
	EVENT_BY,
	BUSINESS_PARTNER_ID,
	SUPPLIER_NAME,
	EVENT_DATE_TIME
from 
	source_data
),
type_data as (
select
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	REQUEST_ID,
	ISSUE_NBR,
	EVENT,
	EVENT_BY,
	BUSINESS_PARTNER_ID,
	SUPPLIER_NAME,
	EVENT_DATE_TIME
from transform_data
)
SELECT * from type_data