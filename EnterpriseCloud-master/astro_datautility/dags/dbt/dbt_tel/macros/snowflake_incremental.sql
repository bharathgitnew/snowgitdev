{% macro dbt_snowflake_get_incremental_sql(strategy, tmp_relation, target_relation, unique_key, dest_columns) %}
  {% if strategy == 'merge' %}
    {% do return(tel_get_merge_sql(target_relation, tmp_relation, unique_key, dest_columns)) %}
  {% elif strategy == 'delete+insert' %}
    {% do return(tel_get_delete_insert_merge_sql(target_relation, tmp_relation, unique_key, dest_columns)) %}
  {% elif strategy == 'insert_overwrite' %}
    {% do return(tel_get_insert_overwrite_merge_sql(target_relation, tmp_relation, unique_key, dest_columns)) %}
  {% else %}
    {% do exceptions.raise_compiler_error('invalid strategy: ' ~ strategy) %}
  {% endif %}
{% endmacro %}


{% macro is_tel_incremental() %}
    {#-- do not run introspective queries in parsing #}
    {% if not execute %}
        {{ return(False) }}
    {% else %}
        {% set relation = adapter.get_relation(this.database, this.schema, this.table) %}
        {{ return(relation is not none
                  and relation.type == 'table'
                  and not should_full_refresh()) }}
                  and (model.config.materialized == 'incremental'
                    or model.config.materialized == 'tel_incremental'
                  )
    {% endif %}
{% endmacro %}