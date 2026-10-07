/************
Model file generated from dbtGeneratePubViews: 06.15.2023.05.36.14"
*************/

{{ config(
      materialized='view',
      alias='TTCCOM020200',
      transient=false
) }}

with source_data as (
    SELECT
        T$SUNO,
        T$CTIT,
        T$NAMA,
        T$NAMB,
        T$NAMC,
        T$NAMD,
        T$NAME,
        T$NAMF,
        T$PSTC,
        T$COMP,
        T$CREG,
        T$PSPR,
        T$PSTX,
        T$SNDR,
        T$CCOR,
        T$CWAR,
        T$REFA,
        T$REFS,
        T$OCUS,
        T$TELP,
        T$TELX,
        T$TEFX,
        T$SEAK,
        T$CBRN,
        T$CBAN,
        T$CFCC,
        T$FANO,
        T$CCON,
        T$CPAY,
        T$CCRS,
        T$CDEC,
        T$CCTY,
        T$CLAN,
        T$CCUR,
        T$CVYN,
        T$SCUS,
        T$CPLP,
        T$CFSG,
        T$PAYM,
        T$CUNO,
        T$QUAL,
        T$BUOR,
        T$BUIN,
        T$ODIS,
        T$SUBC,
        T$CRYR,
        T$TOVR_1,
        T$TOVR_2,
        T$TOVR_3,
        T$TOVR_4,
        T$TOVR_5,
        T$SUST,
        T$EDED,
        T$CADR,
        T$FOVN,
        T$INRL,
        T$ISCN,
        T$COTP,
        T$TXTA,
        T$GEOC_L,
        T$MAIL,
        T$BEID,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('ODS__BAAN_TEE__TTCCOM020200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data