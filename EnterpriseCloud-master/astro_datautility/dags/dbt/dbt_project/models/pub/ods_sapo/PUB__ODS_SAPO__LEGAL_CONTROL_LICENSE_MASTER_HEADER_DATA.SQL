{{ config(
      materialized='view',
      alias='LEGAL_CONTROL_LICENSE_MASTER_HEADER_DATA',
      transient=false
) }}
WITH SOURCE_DATA AS(
    SELECT 
    _CAPTUREDATETIME,
	MANDT,
    GENNR,
    INDEI,
    GEGRU,
    GEART,
    EXGEN,
    GENST,
    ANFDA,
    ANFUZ,
    ABGDA,
    ABGUZ,
    EIGDA,
    EIGUZ,
    VELDA,
    VELUZ,
    REODA,
    REOUZ,
    GST_0,
    GST_A,
    GST_B,
    GST_C,
    GST_D,
    GST_Z,
    GANDA,
    GENDA,
    GMAXW,
    WAERS,
    GMAXQ,
    MEINS,
    ERNAM,
    ERDAT,
    ERZET,
    GENLA,
    EXART,
    GAUFW,
    GLIEW,
    BUKRS,
    ZTERM,
    GMAXA,
    GAUFA,
    GPRZW,
    GAUFQ,
    GLIEQ,
    VBELN,
    VBDFG,
    VBDNR,
    BEHO2,
    BEHOE1,
    BEHOE2
from {{ ref('ODS__SAPO__LEGAL_CONTROL_LICENSE_MASTER_HEADER_DATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data