/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='view',
            alias='SUPPL_CHG_REQUEST_COMMENT',
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        DESCR, 
 	 	COMMENT_ID, 
 	 	REQUEST_ID, 
 	 	COMMENT_DT, 
 	 	USERID
        FROM {{ ref('COMMON__SUPPLIER__SUPPL_CHG_REQUEST_COMMENT') }}
        
    ),
    transform_data as (
        SELECT
            *
        FROM source_data
    ),
    type_data as (
        SELECT
            *
        FROM transform_data
    )
    SELECT * FROM type_data