/************
Model file generated from dbtGeneratePubViews: 09.07.2022.09.55.14"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_SKB1',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        SAKNR,
        BEGRU,
        BUSAB,
        ERDAT,
        ERNAM,
        MITKZ,
        WMETH,
        XINTB,
        XKRES,
        XLOEB,
        XNKON,
        XOPVW,
        XSPEB,
        XMITK,
        WAERS,
        XSALH,
        MWSKZ,
        XMWNO,
        ZUAWA,
        FSTAG,
        ALTKT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_SKB1') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data