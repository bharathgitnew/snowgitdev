/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='view',
            alias='SUPPL_REASON',
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        REQUEST_ID, 
 	 	REASON_ID
        FROM {{ ref('COMMON__SUPPLIER__SUPPL_REASON') }}
        
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