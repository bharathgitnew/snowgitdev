/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='view',
            alias='SUPPL_APPLICABLE_CATEGORY_DESCR',
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        APPLICABLE_CATEGORY_ID, 
 	 	DESCR
        FROM {{ ref('COMMON__SUPPLIER__SUPPL_APPLICABLE_CATEGORY_DESCR') }}
        
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