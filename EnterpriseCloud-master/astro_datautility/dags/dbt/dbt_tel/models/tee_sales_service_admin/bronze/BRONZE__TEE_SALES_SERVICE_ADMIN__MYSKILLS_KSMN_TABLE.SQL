/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Repository\EnterpriseCloud\Snowflake\LZ_2_ODS-MySkills\KSMN_Table__MySkills_KSMNTable.SQL 
-newFile C:\Repository\EnterpriseCloud\dbt\lz_to_ods\models\myskills\KSMNTable.SQL 
-materialized incremental
-alias KSMNTable 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MYSKILLS
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/12/2022 6:09:19 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MYSKILLS_KSMN_TABLE',
    unique_key = ['TELKAICD']
) }}


with source_data as 
(
    SELECT  
         _Filename as _Filename 
        ,_Filedate as _Filedate 
        ,JSonField:GYOMUYMD::STRING AS GYOMUYMD 
        ,JSonField:TELKAICD::STRING AS TELKAICD 
        ,JSonField:SEISNM::STRING AS SEISNM 
        ,JSonField:SEISNE::STRING AS SEISNE 
        ,JSonField:SSRYNM::STRING AS SSRYNM 
        ,JSonField:SSRYNE::STRING AS SSRYNE 
        ,JSonField:FKINM::STRING AS FKINM 
        ,JSonField:FKINE::STRING AS FKINE 
        ,JSonField:KKBASCD::STRING AS KKBASCD 
        ,JSonField:KUNICD::STRING AS KUNICD 
        ,JSonField:KSTUKACD::STRING AS KSTUKACD 
        ,JSonField:SOSIKKBN::STRING AS SOSIKKBN 
        ,JSonField:TELSYMD::STRING AS TELSYMD 
        ,JSonField:TACSYMD::STRING AS TACSYMD 
        ,JSonField:ZSBSYMD::STRING AS ZSBSYMD 
        ,JSonField:ZSKSYMD::STRING AS ZSKSYMD 
        ,JSonField:ZSKSSYMD::STRING AS ZSKSSYMD 
        ,JSonField:ZSKESYMD::STRING AS ZSKESYMD 
        ,JSonField:ZSK1YMD::STRING AS ZSK1YMD 
        ,JSonField:ZSK2YMD::STRING AS ZSK2YMD 
        ,JSonField:ZSNBYMD::STRING AS ZSNBYMD 
        ,JSonField:ZSYSYMD::STRING AS ZSYSYMD 
        ,JSonField:ZSTACYMD::STRING AS ZSTACYMD 
        ,JSonField:ZSSIZYMD::STRING AS ZSSIZYMD 
        ,JSonField:ZSSPYMD::STRING AS ZSSPYMD 
        ,JSonField:ZSGSYMD::STRING AS ZSGSYMD 
        ,JSonField:ZSNPYMD::STRING AS ZSNPYMD 
        ,JSonField:ZSTKYMD::STRING AS ZSTKYMD 
        ,JSonField:ZSKKYMD::STRING AS ZSKKYMD 
        ,JSonField:ZSKTYMD::STRING AS ZSKTYMD 
        ,JSonField:ZSKHYMD::STRING AS ZSKHYMD 
        ,JSonField:ZSNHYMD::STRING AS ZSNHYMD 
        ,JSonField:ZSNSYMD::STRING AS ZSNSYMD 
        ,JSonField:TSBSYMD::STRING AS TSBSYMD 
        ,JSonField:TSKSYMD::STRING AS TSKSYMD 
        ,JSonField:TSKSSYMD::STRING AS TSKSSYMD 
        ,JSonField:TSKESYMD::STRING AS TSKESYMD 
        ,JSonField:TSK1YMD::STRING AS TSK1YMD 
        ,JSonField:TSK2YMD::STRING AS TSK2YMD 
        ,JSonField:TSNBYMD::STRING AS TSNBYMD 
        ,JSonField:TSYSYMD::STRING AS TSYSYMD 
        ,JSonField:TSTACYMD::STRING AS TSTACYMD 
        ,JSonField:TSSITYMD::STRING AS TSSITYMD 
        ,JSonField:TSSPYMD::STRING AS TSSPYMD 
        ,JSonField:TSGSYMD::STRING AS TSGSYMD 
        ,JSonField:TSNPYMD::STRING AS TSNPYMD 
        ,JSonField:TSTKYMD::STRING AS TSTKYMD 
        ,JSonField:TSKKYMD::STRING AS TSKKYMD 
        ,JSonField:TSKTYMD::STRING AS TSKTYMD 
        ,JSonField:TSKHYMD::STRING AS TSKHYMD 
        ,JSonField:TSNHYMD::STRING AS TSNHYMD 
        ,JSonField:TSNSYMD::STRING AS TSNSYMD 
        ,JSonField:NODSKBN::STRING AS NODSKBN 
        ,JSonField:KKKSSYMD::STRING AS KKKSSYMD 
        ,JSonField:KKMSTYMD::STRING AS KKMSTYMD 
        ,JSonField:KKKTIYMD::STRING AS KKKTIYMD 
        ,JSonField:KNMHTYMD::STRING AS KNMHTYMD 
        ,JSonField:KGMKTYMD::STRING AS KGMKTYMD 
        ,JSonField:KOGMKYMD::STRING AS KOGMKYMD 
        ,JSonField:KNAMTYMD::STRING AS KNAMTYMD 
        ,JSonField:KAGMKYMD::STRING AS KAGMKYMD 
        ,JSonField:KGTMYMD::STRING AS KGTMYMD 
        ,JSonField:KKMSKYMD::STRING AS KKMSKYMD 
        ,JSonField:JKMSKYMD::STRING AS JKMSKYMD 
        ,JSonField:SCHEHYMD::STRING AS SCHEHYMD 
        ,JSonField:SOHAYMD::STRING AS SOHAYMD 
        ,JSonField:BATSYMD::STRING AS BATSYMD 
        ,JSonField:BATSFLG::STRING AS BATSFLG 
        ,JSonField:OLRIFLG::STRING AS OLRIFLG 
        ,JSonField:JYDHKBN::STRING AS JYDHKBN 
        ,JSonField:GBRKKBN::STRING AS GBRKKBN 
        ,JSonField:SKSDSKS::INTEGER AS SKSDSKS 
        ,JSonField:SKSDSYKS::INTEGER AS SKSDSYKS 
        ,JSonField:GYMHDK::STRING AS GYMHDK 
        ,JSonField:TORIYMD::STRING AS TORIYMD 
        ,JSonField:HUKSKNS::INTEGER AS HUKSKNS 
        ,JSonField:OLRKYMD::STRING AS OLRKYMD 
        ,JSonField:BTRKYMD::STRING AS BTRKYMD 
        ,JSonField:HMAKKBN::STRING AS HMAKKBN 
        ,JSonField:TIMESP::STRING AS TIMESP 
        FROM {{ source("MYSKILLS", "KSMN_TABLE") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MYSKILLS", "KSMN_TABLE") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.GYOMUYMD AS GYOMUYMD, 
        source_data.TELKAICD AS TELKAICD, 
        source_data.SEISNM AS SEISNM, 
        source_data.SEISNE AS SEISNE, 
        source_data.SSRYNM AS SSRYNM, 
        source_data.SSRYNE AS SSRYNE, 
        source_data.FKINM AS FKINM, 
        source_data.FKINE AS FKINE, 
        source_data.KKBASCD AS KKBASCD, 
        source_data.KUNICD AS KUNICD, 
        source_data.KSTUKACD AS KSTUKACD, 
        source_data.SOSIKKBN AS SOSIKKBN, 
        source_data.TELSYMD AS TELSYMD, 
        source_data.TACSYMD AS TACSYMD, 
        source_data.ZSBSYMD AS ZSBSYMD, 
        source_data.ZSKSYMD AS ZSKSYMD, 
        source_data.ZSKSSYMD AS ZSKSSYMD, 
        source_data.ZSKESYMD AS ZSKESYMD, 
        source_data.ZSK1YMD AS ZSK1YMD, 
        source_data.ZSK2YMD AS ZSK2YMD, 
        source_data.ZSNBYMD AS ZSNBYMD, 
        source_data.ZSYSYMD AS ZSYSYMD, 
        source_data.ZSTACYMD AS ZSTACYMD, 
        source_data.ZSSIZYMD AS ZSSIZYMD, 
        source_data.ZSSPYMD AS ZSSPYMD, 
        source_data.ZSGSYMD AS ZSGSYMD, 
        source_data.ZSNPYMD AS ZSNPYMD, 
        source_data.ZSTKYMD AS ZSTKYMD, 
        source_data.ZSKKYMD AS ZSKKYMD, 
        source_data.ZSKTYMD AS ZSKTYMD, 
        source_data.ZSKHYMD AS ZSKHYMD, 
        source_data.ZSNHYMD AS ZSNHYMD, 
        source_data.ZSNSYMD AS ZSNSYMD, 
        source_data.TSBSYMD AS TSBSYMD, 
        source_data.TSKSYMD AS TSKSYMD, 
        source_data.TSKSSYMD AS TSKSSYMD, 
        source_data.TSKESYMD AS TSKESYMD, 
        source_data.TSK1YMD AS TSK1YMD, 
        source_data.TSK2YMD AS TSK2YMD, 
        source_data.TSNBYMD AS TSNBYMD, 
        source_data.TSYSYMD AS TSYSYMD, 
        source_data.TSTACYMD AS TSTACYMD, 
        source_data.TSSITYMD AS TSSITYMD, 
        source_data.TSSPYMD AS TSSPYMD, 
        source_data.TSGSYMD AS TSGSYMD, 
        source_data.TSNPYMD AS TSNPYMD, 
        source_data.TSTKYMD AS TSTKYMD, 
        source_data.TSKKYMD AS TSKKYMD, 
        source_data.TSKTYMD AS TSKTYMD, 
        source_data.TSKHYMD AS TSKHYMD, 
        source_data.TSNHYMD AS TSNHYMD, 
        source_data.TSNSYMD AS TSNSYMD, 
        source_data.NODSKBN AS NODSKBN, 
        source_data.KKKSSYMD AS KKKSSYMD, 
        source_data.KKMSTYMD AS KKMSTYMD, 
        source_data.KKKTIYMD AS KKKTIYMD, 
        source_data.KNMHTYMD AS KNMHTYMD, 
        source_data.KGMKTYMD AS KGMKTYMD, 
        source_data.KOGMKYMD AS KOGMKYMD, 
        source_data.KNAMTYMD AS KNAMTYMD, 
        source_data.KAGMKYMD AS KAGMKYMD, 
        source_data.KGTMYMD AS KGTMYMD, 
        source_data.KKMSKYMD AS KKMSKYMD, 
        source_data.JKMSKYMD AS JKMSKYMD, 
        source_data.SCHEHYMD AS SCHEHYMD, 
        source_data.SOHAYMD AS SOHAYMD, 
        source_data.BATSYMD AS BATSYMD, 
        source_data.BATSFLG AS BATSFLG, 
        source_data.OLRIFLG AS OLRIFLG, 
        source_data.JYDHKBN AS JYDHKBN, 
        source_data.GBRKKBN AS GBRKKBN, 
        source_data.SKSDSKS AS SKSDSKS, 
        source_data.SKSDSYKS AS SKSDSYKS, 
        source_data.GYMHDK AS GYMHDK, 
        source_data.TORIYMD AS TORIYMD, 
        source_data.HUKSKNS AS HUKSKNS, 
        source_data.OLRKYMD AS OLRKYMD, 
        source_data.BTRKYMD AS BTRKYMD, 
        source_data.HMAKKBN AS HMAKKBN, 
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.TIMESP , '/Date(' , '' ) , ')/' , '' ) ) ) AS TIMESP, 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        _FILEDATE,
        _FILENAME
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(GYOMUYMD as VARCHAR(16777216)) as GYOMUYMD,
        cast(TELKAICD as VARCHAR(16777216)) as TELKAICD,
        cast(SEISNM as VARCHAR(16777216)) as SEISNM,
        cast(SEISNE as VARCHAR(16777216)) as SEISNE,
        cast(SSRYNM as VARCHAR(16777216)) as SSRYNM,
        cast(SSRYNE as VARCHAR(16777216)) as SSRYNE,
        cast(FKINM as VARCHAR(16777216)) as FKINM,
        cast(FKINE as VARCHAR(16777216)) as FKINE,
        cast(KKBASCD as VARCHAR(16777216)) as KKBASCD,
        cast(KUNICD as VARCHAR(16777216)) as KUNICD,
        cast(KSTUKACD as VARCHAR(16777216)) as KSTUKACD,
        cast(SOSIKKBN as VARCHAR(16777216)) as SOSIKKBN,
        cast(TELSYMD as VARCHAR(16777216)) as TELSYMD,
        cast(TACSYMD as VARCHAR(16777216)) as TACSYMD,
        cast(ZSBSYMD as VARCHAR(16777216)) as ZSBSYMD,
        cast(ZSKSYMD as VARCHAR(16777216)) as ZSKSYMD,
        cast(ZSKSSYMD as VARCHAR(16777216)) as ZSKSSYMD,
        cast(ZSKESYMD as VARCHAR(16777216)) as ZSKESYMD,
        cast(ZSK1YMD as VARCHAR(16777216)) as ZSK1YMD,
        cast(ZSK2YMD as VARCHAR(16777216)) as ZSK2YMD,
        cast(ZSNBYMD as VARCHAR(16777216)) as ZSNBYMD,
        cast(ZSYSYMD as VARCHAR(16777216)) as ZSYSYMD,
        cast(ZSTACYMD as VARCHAR(16777216)) as ZSTACYMD,
        cast(ZSSIZYMD as VARCHAR(16777216)) as ZSSIZYMD,
        cast(ZSSPYMD as VARCHAR(16777216)) as ZSSPYMD,
        cast(ZSGSYMD as VARCHAR(16777216)) as ZSGSYMD,
        cast(ZSNPYMD as VARCHAR(16777216)) as ZSNPYMD,
        cast(ZSTKYMD as VARCHAR(16777216)) as ZSTKYMD,
        cast(ZSKKYMD as VARCHAR(16777216)) as ZSKKYMD,
        cast(ZSKTYMD as VARCHAR(16777216)) as ZSKTYMD,
        cast(ZSKHYMD as VARCHAR(16777216)) as ZSKHYMD,
        cast(ZSNHYMD as VARCHAR(16777216)) as ZSNHYMD,
        cast(ZSNSYMD as VARCHAR(16777216)) as ZSNSYMD,
        cast(TSBSYMD as VARCHAR(16777216)) as TSBSYMD,
        cast(TSKSYMD as VARCHAR(16777216)) as TSKSYMD,
        cast(TSKSSYMD as VARCHAR(16777216)) as TSKSSYMD,
        cast(TSKESYMD as VARCHAR(16777216)) as TSKESYMD,
        cast(TSK1YMD as VARCHAR(16777216)) as TSK1YMD,
        cast(TSK2YMD as VARCHAR(16777216)) as TSK2YMD,
        cast(TSNBYMD as VARCHAR(16777216)) as TSNBYMD,
        cast(TSYSYMD as VARCHAR(16777216)) as TSYSYMD,
        cast(TSTACYMD as VARCHAR(16777216)) as TSTACYMD,
        cast(TSSITYMD as VARCHAR(16777216)) as TSSITYMD,
        cast(TSSPYMD as VARCHAR(16777216)) as TSSPYMD,
        cast(TSGSYMD as VARCHAR(16777216)) as TSGSYMD,
        cast(TSNPYMD as VARCHAR(16777216)) as TSNPYMD,
        cast(TSTKYMD as VARCHAR(16777216)) as TSTKYMD,
        cast(TSKKYMD as VARCHAR(16777216)) as TSKKYMD,
        cast(TSKTYMD as VARCHAR(16777216)) as TSKTYMD,
        cast(TSKHYMD as VARCHAR(16777216)) as TSKHYMD,
        cast(TSNHYMD as VARCHAR(16777216)) as TSNHYMD,
        cast(TSNSYMD as VARCHAR(16777216)) as TSNSYMD,
        cast(NODSKBN as VARCHAR(16777216)) as NODSKBN,
        cast(KKKSSYMD as VARCHAR(16777216)) as KKKSSYMD,
        cast(KKMSTYMD as VARCHAR(16777216)) as KKMSTYMD,
        cast(KKKTIYMD as VARCHAR(16777216)) as KKKTIYMD,
        cast(KNMHTYMD as VARCHAR(16777216)) as KNMHTYMD,
        cast(KGMKTYMD as VARCHAR(16777216)) as KGMKTYMD,
        cast(KOGMKYMD as VARCHAR(16777216)) as KOGMKYMD,
        cast(KNAMTYMD as VARCHAR(16777216)) as KNAMTYMD,
        cast(KAGMKYMD as VARCHAR(16777216)) as KAGMKYMD,
        cast(KGTMYMD as VARCHAR(16777216)) as KGTMYMD,
        cast(KKMSKYMD as VARCHAR(16777216)) as KKMSKYMD,
        cast(JKMSKYMD as VARCHAR(16777216)) as JKMSKYMD,
        cast(SCHEHYMD as VARCHAR(16777216)) as SCHEHYMD,
        cast(SOHAYMD as VARCHAR(16777216)) as SOHAYMD,
        cast(BATSYMD as VARCHAR(16777216)) as BATSYMD,
        cast(BATSFLG as VARCHAR(16777216)) as BATSFLG,
        cast(OLRIFLG as VARCHAR(16777216)) as OLRIFLG,
        cast(JYDHKBN as VARCHAR(16777216)) as JYDHKBN,
        cast(GBRKKBN as VARCHAR(16777216)) as GBRKKBN,
        cast(SKSDSKS as NUMBER(38,0)) as SKSDSKS,
        cast(SKSDSYKS as NUMBER(38,0)) as SKSDSYKS,
        cast(GYMHDK as VARCHAR(16777216)) as GYMHDK,
        cast(TORIYMD as VARCHAR(16777216)) as TORIYMD,
        cast(HUKSKNS as NUMBER(38,0)) as HUKSKNS,
        cast(OLRKYMD as VARCHAR(16777216)) as OLRKYMD,
        cast(BTRKYMD as VARCHAR(16777216)) as BTRKYMD,
        cast(HMAKKBN as VARCHAR(16777216)) as HMAKKBN,
        cast(TIMESP as TIMESTAMP_NTZ(9)) as TIMESP
    from transform_data
    )
select * from type_data