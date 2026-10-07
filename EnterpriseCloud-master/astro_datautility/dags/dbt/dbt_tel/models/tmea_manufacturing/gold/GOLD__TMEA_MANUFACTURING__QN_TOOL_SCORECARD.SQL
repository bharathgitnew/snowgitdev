{{ config(
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    alias = 'QN_TOOL_SCORECARD',
    transient = false
) }}

WITH ref_cte_CODE_GROUP_TEXTS AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__CODE_GROUP_TEXTS') }}
    WHERE
        language_key = 'E'
        AND client = '300'
),
ref_cte_CODE_TEXTS AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__CODE_TEXTS') }}
    WHERE
        language_key = 'E'
        AND client = '300'
),
ref_cte_INDIVIDUAL_OBJECT_STATUS AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__INDIVIDUAL_OBJECT_STATUS') }}
    WHERE
        client = '300'
),
ref_cte_MATERIAL_DESCRIPTIONS AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__MATERIAL_DESCRIPTIONS') }}
    WHERE
        language_key = 'E'
        AND client = '300'
),
ref_cte_PRIORITY_TEXT AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__PRIORITY_TEXT') }}
    WHERE
        language_key = 'E'
        AND client = '300'
),
ref_cte_QUALITY_NOTIFICATION AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__QUALITY_NOTIFICATION') }}
    WHERE
        primary_language_indicator_for_text_segment = 'E'
        AND notification_type = 'Q3'
        AND client = '300'
),
ref_cte_QUALITY_NOTIFICATION_CAUSES AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__QUALITY_NOTIFICATION_CAUSES') }}
    WHERE
        primary_language_indicator_for_text_segment = 'E'
        AND client = '300'
),
ref_cte_QUALITY_NOTIFICATION_ITEMS AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__QUALITY_NOTIFICATION_ITEMS') }}
    WHERE
        primary_language_indicator_for_text_segment = 'E'
        AND client = '300'
),
ref_cte_SYSTEM_STATUS_TEXTS AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__SYSTEM_STATUS_TEXTS') }}
    WHERE
        language_key = 'E'
),
ref_cte_EQUIPMENT_MASTER_DATA AS (
    SELECT
        material_number,
        CONCAT(LEFT(material_number, 3), RIGHT(material_number, 3)) AS tool_number1,
        sernr_serial_number AS tool_serial_number
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__EQUIPMENT_MASTER_DATA') }}
    WHERE(material_number LIKE ('AV-A%')
        OR material_number LIKE ('AN-A%')
        OR material_number LIKE ('Z2-A%')
        OR material_number LIKE ('Z3-A%')
        OR material_number LIKE ('UT-A%')
        OR material_number LIKE ('FN-A%'))),
qm15 AS (
    SELECT
        qmel.notification_no,
        qmfe.item_number_in_item_record,
        qmfe.notification_item_short_text,
        qmfe.code_group_problem,
        qmfe.problem_or_damage_code,
        qpct.short_text_for_code_up_to_40_characters_in_length AS problem_code_text,
        CASE
            WHEN qmel.material_number LIKE 'AN%' THEN 'ANTARES'
            WHEN qmel.material_number LIKE 'AV%' THEN 'ACREVIA'
            WHEN qmel.material_number LIKE 'UT%' THEN 'ULRTA TRIMMER'
            WHEN qmel.material_number LIKE 'Z2%' THEN 'ZETA 200'
            WHEN qmel.material_number LIKE 'Z3%' THEN 'ZETA 300'
            WHEN qmel.material_number LIKE 'RED%' THEN 'REDLINE'
            WHEN qmel.material_number LIKE 'MP%' THEN 'MERCURY'
            WHEN qmel.material_number LIKE 'FN%' THEN 'FINESTA'
            ELSE 'NOT TOOL SPECIFIC'
        END AS tool_type,
        qmel.material_number,
        RIGHT(
            qmel.material_number,
            4
        ) AS material_last_characters,
        makt.material_description,
        CONCAT(LEFT(qmel.material_number, 3), RIGHT(qmel.material_number, 3)) AS tool_number,
        tool_number1,
        tool_serial_number,
        qmfe.name_of_person_who_created_the_object,
        qmel.date_on_which_record_was_created,
        YEAR(
            qmel.date_on_which_record_was_created
        ) AS year_created_date,
        MONTH(
            qmel.date_on_which_record_was_created
        ) AS month_create_date,
        MONTHNAME(
            qmel.date_on_which_record_was_created
        ) AS month_name_create_date,
        fiscal_year_quarter_text,
        qmfe.name_of_person_who_changed_object,
        qmfe.date_of_last_change,
        qmfe.code_group_object_parts,
        qmfe.part_of_object,
        qpgt.short_description_of_the_code_group AS problem_code_group_text,
        qpct1.short_text_for_code_up_to_40_characters_in_length AS object_part_code_text,
        qpgt1.short_description_of_the_code_group AS object_part_code_group_text,
        qmur.cause_text,
        qmur.code_group_causes,
        qmur.cause_code,
        qpct2.short_text_for_code_up_to_40_characters_in_length AS cause_code_text,
        qpgt2.short_description_of_the_code_group AS cause_code_group_text,
        qmel.notification_type,
        qmel.short_text AS description,
        qmel.priority,
        qmel.date_of_notification AS notification_date,
        qmel.date_for_notification_completion,
        qmel.order_number,
        t356_t.priority_text
    FROM
        ref_cte_QUALITY_NOTIFICATION qmel full
        JOIN ref_cte_QUALITY_NOTIFICATION_ITEMS qmfe
        ON qmel.notification_no = qmfe.notification_no
        LEFT JOIN ref_cte_CODE_TEXTS qpct
        ON qmfe.code_group_problem = qpct.code_group
        AND qpct.code = qmfe.problem_or_damage_code
        LEFT JOIN ref_cte_CODE_GROUP_TEXTS qpgt
        ON qmfe.code_group_problem = qpgt.code_group
        AND qmfe.catalog_type_problemsdefects = qpgt.catalog
        LEFT JOIN ref_cte_MATERIAL_DESCRIPTIONS makt
        ON qmel.material_number = makt.material_number
        LEFT JOIN ref_cte_QUALITY_NOTIFICATION_CAUSES qmur
        ON qmel.notification_no = qmur.notification_no
        LEFT JOIN ref_cte_CODE_TEXTS qpct1
        ON qmfe.catalog_type_object_parts = qpct1.catalog
        AND qmfe.code_group_object_parts = qpct1.code_group
        AND qmfe.part_of_object = qpct1.code
        LEFT JOIN ref_cte_CODE_TEXTS qpct2
        ON qmur.cause_code = qpct2.code
        AND qmur.code_group_causes = qpct2.code_group
        LEFT JOIN ref_cte_PRIORITY_TEXT t356_t
        ON qmel.priority = t356_t.priority
        AND qmel.priority_type = t356_t.priority_type
        LEFT JOIN ref_cte_CODE_GROUP_TEXTS qpgt1
        ON qmfe.catalog_type_object_parts = qpgt1.catalog
        AND qmfe.code_group_object_parts = qpgt1.code_group
        LEFT JOIN ref_cte_CODE_GROUP_TEXTS qpgt2
        ON qmur.catalog_type_causes = qpgt2.catalog
        AND qmur.code_group_causes = qpgt2.code_group
        LEFT JOIN pub.de_operations.calendar_date
        ON calendar_date = qmel.date_on_which_record_was_created
        LEFT JOIN ref_cte_EQUIPMENT_MASTER_DATA
        ON tool_number = tool_number1
),
qm15_notification_status AS(
    SELECT
        qmel.notification_no AS qm15_notification_no,
        LISTAGG(
            tj02t.individual_status_of_an_object_short_form,
            ' | '
        ) AS notification_status,
        LISTAGG(
            tj02t.object_status,
            ' | '
        ) AS notification_status_description
    FROM
        ref_cte_QUALITY_NOTIFICATION qmel
        LEFT JOIN ref_cte_INDIVIDUAL_OBJECT_STATUS jest
        ON qmel.object_number_for_status_management = jest.object_number
        LEFT JOIN ref_cte_SYSTEM_STATUS_TEXTS tj02t
        ON jest.object_status = tj02t.system_status
    WHERE
        jest.indicator_status_is_inactive <> 'X'
        AND tj02t.language_key = 'E'
    GROUP BY
        notification_no
),
zqnext AS(
    SELECT
        qmel.notification_no AS zqnext_notification_no,
        qmel.external_reference_number,
        qpct.short_text_for_code_up_to_40_characters_in_length AS dispo_decision,
        qmel.additional_device_data
    FROM
        ref_cte_QUALITY_NOTIFICATION qmel
        LEFT JOIN ref_cte_CODE_TEXTS qpct
        ON qmel.code_group_coding = qpct.code_group
        AND qpct.code = qmel.coding
),
output AS(
    SELECT
        *
    FROM
        qm15
        LEFT JOIN qm15_notification_status
        ON qm15.notification_no = qm15_notification_status.qm15_notification_no
        LEFT JOIN zqnext
        ON zqnext.zqnext_notification_no = qm15_notification_status.qm15_notification_no
),
source_data AS (
    SELECT
        notification_no,
        item_number_in_item_record,
        notification_item_short_text,
        code_group_problem,
        problem_or_damage_code,
        problem_code_text,
        CASE
            WHEN notification_status_description ILIKE '%completed%' THEN 'Closed'
            ELSE 'Open'
        END AS open_close,
        tool_type,
        CASE
            WHEN tool_type = 'ZETA 200'
            OR tool_type = 'ZETA 300' THEN 'Zeta'
            WHEN tool_type = 'ULRTA TRIMMER' THEN 'UT+'
            WHEN tool_type = 'NOT TOOL SPECIFIC' THEN NULL
            WHEN tool_type = 'REDLINE' THEN NULL
            ELSE INITCAP(tool_type)
        END AS tool,
        tool_number,-- tool_number1,
        CASE
            WHEN material_number ILIKE 'UT-%' THEN 'UT-A' || material_last_characters
            WHEN material_number ILIKE 'Z2-%' THEN 'Z2-A' || material_last_characters
            WHEN material_number ILIKE 'Z3-%' THEN 'Z3-A' || material_last_characters
            WHEN material_number ILIKE 'AV-%' THEN 'AV-A' || material_last_characters
            WHEN material_number ILIKE 'GB-%' THEN 'GB-A' || material_last_characters
            WHEN material_number ILIKE 'FN-%' THEN 'FN-A' || material_last_characters
            WHEN material_number ILIKE 'AN-%' THEN 'AN-A' || material_last_characters
            WHEN material_number ILIKE 'MP-%' THEN 'MP-A' || material_last_characters
            WHEN material_number ILIKE 'B1-%' THEN 'B1-A' || material_last_characters
            WHEN material_number ILIKE 'P2-%' THEN 'P2-A' || material_last_characters
            WHEN material_number ILIKE '%CT CUE%'
            OR material_number ILIKE '%CUE WIP%' THEN 'DSS CUE'
            WHEN material_number ILIKE 'Z2ML%'
            OR material_number ILIKE 'Z3ML%'
            OR material_number ILIKE 'MPML%' THEN 'CSS CUE'
            WHEN material_number ILIKE '0R%' THEN 'OR-A' || material_last_characters
            WHEN material_number ILIKE '%GCIB%' THEN 'Achrevia Alpha'
            WHEN material_number ILIKE 'TC%' THEN 'Yeild Hunter'
            ELSE 'Other'
        END AS tool_number_v2,
        tool_serial_number,
        material_number,
        material_last_characters,
        material_description,
        name_of_person_who_created_the_object,
        date_on_which_record_was_created,
        year_created_date,
        month_create_date,
        month_name_create_date,
        fiscal_year_quarter_text,
        name_of_person_who_changed_object,
        date_of_last_change,
        code_group_object_parts,
        part_of_object,
        problem_code_group_text,
        object_part_code_text,
        object_part_code_group_text,
        cause_text,
        code_group_causes,
        cause_code,
        cause_code_text,
        cause_code_group_text,
        notification_type,
        description,
        priority,
        notification_date,
        date_for_notification_completion,
        order_number,
        priority_text,
        qm15_notification_no,
        notification_status,
        notification_status_description,
        zqnext_notification_no,
        external_reference_number,
        dispo_decision,
        TRY_TO_DECIMAL(
            additional_device_data,
            30,
            2
        ) AS additional_device_data
    FROM
        output
)
  
,
transform_data AS (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        notification_no,
        item_number_in_item_record,
        notification_item_short_text,
        code_group_problem,
        problem_or_damage_code,
        problem_code_text,
        tool_type,
        material_number,
        material_last_characters,
        material_description,
        name_of_person_who_created_the_object,
        date_on_which_record_was_created,
        year_created_date,
        month_create_date,
        month_name_create_date,
        fiscal_year_quarter_text,
        name_of_person_who_changed_object,
        date_of_last_change,
        code_group_object_parts,
        part_of_object,
        problem_code_group_text,
        object_part_code_text,
        object_part_code_group_text,
        cause_text,
        code_group_causes,
        cause_code,
        cause_code_text,
        cause_code_group_text,
        notification_type,
        description,
        priority,
        notification_date,
        date_for_notification_completion,
        order_number,
        priority_text,
        qm15_notification_no,
        notification_status,
        notification_status_description,
        zqnext_notification_no,
        external_reference_number,
        dispo_decision,
        additional_device_data
    FROM
        source_data
        WHERE
        date_on_which_record_was_created > '2020-01-01'
),
TYPE_DATA AS (
    SELECT 
    CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
    NOTIFICATION_NO,
    ITEM_NUMBER_IN_ITEM_RECORD,
    NOTIFICATION_ITEM_SHORT_TEXT,
    CODE_GROUP_PROBLEM, 
    PROBLEM_OR_DAMAGE_CODE,
    PROBLEM_CODE_TEXT,
    TOOL_TYPE,
    MATERIAL_NUMBER,
    MATERIAL_LAST_CHARACTERS,
    MATERIAL_DESCRIPTION,
    NAME_OF_PERSON_WHO_CREATED_THE_OBJECT,
    DATE_ON_WHICH_RECORD_WAS_CREATED::DATE AS DATE_ON_WHICH_RECORD_WAS_CREATED,
    YEAR_CREATED_DATE::NUMBER(38,0) AS YEAR_CREATED_DATE,
    MONTH_CREATE_DATE::NUMBER(38,0) AS MONTH_CREATE_DATE,  
    MONTH_NAME_CREATE_DATE,
    FISCAL_YEAR_QUARTER_TEXT,
    NAME_OF_PERSON_WHO_CHANGED_OBJECT,
    DATE_OF_LAST_CHANGE::DATE AS DATE_OF_LAST_CHANGE,
    CODE_GROUP_OBJECT_PARTS,
    PART_OF_OBJECT,
    PROBLEM_CODE_GROUP_TEXT,
    OBJECT_PART_CODE_TEXT,
    OBJECT_PART_CODE_GROUP_TEXT,    
    CAUSE_TEXT,
    CODE_GROUP_CAUSES,
    CAUSE_CODE,
    CAUSE_CODE_TEXT,
    CAUSE_CODE_GROUP_TEXT,
    NOTIFICATION_TYPE,
    DESCRIPTION,
    PRIORITY,
    NOTIFICATION_DATE::DATE AS NOTIFICATION_DATE,
    DATE_FOR_NOTIFICATION_COMPLETION::DATE AS DATE_FOR_NOTIFICATION_COMPLETION,
    ORDER_NUMBER,
    PRIORITY_TEXT,
    QM15_NOTIFICATION_NO,   
    NOTIFICATION_STATUS,
    NOTIFICATION_STATUS_DESCRIPTION,
    ZQNEXT_NOTIFICATION_NO,
    EXTERNAL_REFERENCE_NUMBER,  
    DISPO_DECISION,
    ADDITIONAL_DEVICE_DATA::NUMBER(38,2) AS ADDITIONAL_DEVICE_DATA
FROM transform_data
)
SELECT
    *
FROM
    TYPE_DATA
