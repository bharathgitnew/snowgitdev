{{ config(
      materialized='view',
      alias='Calendar_Date',
      transient=false
) }}

with Source_Data AS
(
    SELECT
        * exclude(_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__DE_SAP_MASTER_DATA__CALENDAR_DATE') }}
)
,Transform_Data AS
(
	SELECT * from Source_Data
)
SELECT * FROM Transform_Data