LS @GMX_STG;

SELECT DISTINCT REPLACE(REPLACE(REPLACE(TRIM(REGEXP_REPLACE(split_part(split_part(metadata$filename,'/',2),'.',0), '[^a-zA-Z, _]+', ''),'_'),'SAP_US_','SAP_'),'SAP_EU','SAP_'),'__','_') FILENAME_HEADER, 

 'DROP EXTERNAL TABLE IF EXISTS '||REPLACE(REPLACE(FILENAME_HEADER,'SAP_US_','SAP_'),'SAP_EU','SAP_') || ';' As DropStmt, 
  'CREATE EXTERNAL TABLE IF NOT EXISTS ' || 
  REPLACE(REPLACE('SAP_US_','SAP_'),'SAP_EU','SAP_') || '\n' ||   ' WITH LOCATION = @GMX_STG/ AUTO_REFRESH = TRUE \n FILE_FORMAT = ''GMX_FILEFORMAT_SOH''
  pattern= ''^us/|eu/|common/|.*'	|| REPLACE(REPLACE(REPLACE(FILENAME_HEADER,'SAP_US_',''),'SAP_EU',''),'SAP_','') || '.*'';' CREATESCRIPT,

 'ALTER EXTERNAL TABLE IF EXISTS '||REPLACE(REPLACE(FILENAME_HEADER,'SAP_US_','SAP_'),'SAP_EU','SAP_') || ' REFRESH;' AS REFRESH_SCRIPT

FROM @GMX_STG  t inner join
table(result_scan(last_query_id()))
on upper(TRIM(REGEXP_REPLACE(split_part(split_part(metadata$filename,'/',2),'.',0), '[^a-zA-Z, _]+', ''),'_')) = upper(TRIM(REGEXP_REPLACE(split_part(split_part("name",'/',6),'.',0), '[^a-zA-Z, _]+', ''),'_'));