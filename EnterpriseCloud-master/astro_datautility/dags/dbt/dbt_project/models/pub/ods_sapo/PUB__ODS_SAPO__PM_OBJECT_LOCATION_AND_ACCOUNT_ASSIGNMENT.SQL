{{ config(
      materialized='view',
      alias='PM_OBJECT_LOCATION_AND_ACCOUNT_ASSIGNMENT',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
		ILOAN,
		TPLNR,
		ABCKZ,
		ABCKZI,
		EQFNR,
		EQFNRI,
		SWERK,
		SWERKI,
		STORT,
		STORTI,
		MSGRP,
		MSGRPI,
		BEBER,
		BEBERI,
		CR_OBJTY,
		PPSID,
		PPSIDI,
		GSBER,
		GSBERI,
		KOKRS,
		KOKRSI,
		KOSTL,
		KOSTLI,
		PROID,
		PROIDI,
		BUKRS,
		BUKRSI,
		ANLNR,
		ANLNRI,
		ANLUN,
		ANLUNI,
		DAUFN,
		DAUFNI,
		AUFNR,
		AUFNRI,
		TPLNRI,
		VKORG,
		VKORGI,
		VTWEG,
		VTWEGI,
		SPART,
		SPARTI,
		ADRNR,
		ADRNRI,
		OWNER,
		VKBUR,
		VKGRP,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__PM_OBJECT_LOCATION_AND_ACCOUNT_ASSIGNMENT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data