{% macro snowflake__get_insert_overwrite_merge_sql(target, source, dest_columns, predicates, include_sql_header) -%}
    {%- set predicates = [] if predicates is none else [] + predicates -%}
    {%- set source_columns = adapter.get_columns_in_relation(source) -%}
    {%- set target_columns = adapter.get_columns_in_relation(target) -%}
    {%- set source_cols_csv = get_quoted_csv(source_columns | map(attribute="name")) -%}
    {%- set sql_header = config.get('sql_header', none) -%}

    {{ sql_header if sql_header is not none and include_sql_header }}

    insert overwrite into {{ target }}
    select {{ source_cols_csv }}
    from {{ source }};

    INSERT INTO Control.Tel_Audit_Log (Execution_datetime,Execution_Audit_Log_Id,Materialization_Type,Schema_Name,Table_Name,InsertedCount,UpdatedCount,DeletedCount,TotalRowsInTable)
    SELECT CURRENT_TIMESTAMP(),'{{ invocation_id }}','INSERT OVERWRITE', UPPER('{{target.schema}}'), UPPER('{{target.name}}'), $1,  NULL, NULL, $1 FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
{% endmacro %}
