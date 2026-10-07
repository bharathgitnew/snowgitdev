/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='view',
            alias='SUPPL_USER_ROLE',
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        USERID, 
 	 	ROLEID
        FROM {{ ref('COMMON__SUPPLIER__SUPPL_USER_ROLE') }}
        
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