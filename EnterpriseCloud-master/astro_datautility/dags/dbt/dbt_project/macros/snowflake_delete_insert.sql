{% macro snowflake__get_delete_insert_merge_sql(target, source, unique_key, dest_columns) %}
    {% set dml = default__get_delete_insert_merge_sql(target, source, unique_key, dest_columns) %}
    {% do return(snowflake_dml_explicit_transaction(dml)) %}
{% endmacro %}
