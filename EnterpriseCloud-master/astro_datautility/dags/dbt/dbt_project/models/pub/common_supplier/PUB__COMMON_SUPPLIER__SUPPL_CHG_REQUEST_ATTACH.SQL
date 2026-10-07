/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='view',
            alias='SUPPL_CHG_REQUEST_ATTACH',
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        REQUEST_ID, 
 	 	ATTACHMENT_ID
        FROM {{ ref('COMMON__SUPPLIER__SUPPL_CHG_REQUEST_ATTACH') }}
        
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