{{ config(
      materialized='view',
      alias='SALES_OPTIONSETMETADATA',
      transient=false
) }}

with source_data as (
SELECT
    ENTITYNAME,
    OPTIONSETNAME,
    OPTION,
    ISUSERLOCALIZEDLABEL,
    LOCALIZEDLABELLANGUAGECODE,
    LOCALIZEDLABEL,
    _FILEDATE,
    _FILENAME
from {{ ref('COMMON__CRM__SALES_OPTIONSETMETADATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data