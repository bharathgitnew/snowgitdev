{% macro tel_get_merge_sql(target, source_sql, unique_key, dest_columns, predicates=none) -%}
    {#
       Workaround for Snowflake not being happy with a merge on a constant-false predicate.
       When no unique_key is provided, this macro will do a regular insert. If a unique_key
       is provided, then this macro will do a proper merge instead.
    #}
    {%- set dest_cols_csv = get_quoted_csv(dest_columns | map(attribute='name')) -%}
    {%- set sql_header = config.get('sql_header', none) -%}

    {%- set dml -%}
    {%- if unique_key is none -%}

        {{ sql_header if sql_header is not none }}

        insert into {{ target }} ({{ dest_cols_csv }})
        (
            select {{ dest_cols_csv }}
            from {{ source_sql }}
        )

    {%- elif unique_key is iterable and (unique_key is not string and unique_key is not mapping) -%}

        {%- set predicates = [] if predicates is none else [] + predicates -%}
        {%- set dest_cols_csv = get_quoted_csv(dest_columns | map(attribute="name")) -%}
        {%- set update_columns = config.get('merge_update_columns', default = dest_columns | map(attribute="quoted") | list) -%}
        {%- set sql_header = config.get('sql_header', none) -%}
        {%- set source_row_hash_string = [] -%}
        {%- set lower_unique_keys = [] -%}
        {%- set lower_update_columns = [] -%}

        {%- for update_columns_value in update_columns  -%}
            {%- do lower_update_columns.append( update_columns_value.lower().replace('"','') ) -%}
        {%- endfor -%}

        {%- set source_row_hash -%}

            SHA2({%- for column in dest_columns -%}
                {%- if column.name == '_ROW_HASH' -%}
                    ''
                {%- elif column.name == '_CAPTUREDATETIME' -%}
                    ''
                {%- elif column.name == '_AUDIT_LOG_ID' -%}
                    ''
                {%- elif column.name == 'AUDIT_LOG_ID' -%}
                    ''
                {%- elif column.name in unique_key -%}
                    ''
                {%- elif column.name.lower() not in lower_update_columns -%}
                    ''
                {%- else -%}
                     COALESCE(DBT_INTERNAL_SOURCE.{{ column.name }}::VARIANT, {{ var('NullTypeValues')[ column.data_type.partition('(')[0] | default("this key does not exist in the dict")] | default(column.data_type) }}::VARIANT )
                {%- endif -%}
                {{ '
                || ' if not loop.last }}
            {%- endfor -%})

        {%- endset -%}

        {%- if unique_key -%}

            {%- for unique_key_value in unique_key  -%}
                {%- do lower_unique_keys.append( unique_key_value.lower() ) -%}
                {%- set unique_key_match -%}
                    DBT_INTERNAL_SOURCE.{{ unique_key_value }} = DBT_INTERNAL_DEST.{{ unique_key_value }}
                {%- endset -%}
                {%- do predicates.append(unique_key_match) -%}
            {%- endfor -%}

        {% else %}
            {% do predicates.append('FALSE') %}
        {% endif %}

        {{ sql_header if sql_header is not none }}

        merge into {{ target }} as DBT_INTERNAL_DEST
            using {{ source_sql }} as DBT_INTERNAL_SOURCE
            on {{ predicates | join('
            and ') }}

        {% if unique_key %}
        when matched and IFNULL(DBT_INTERNAL_DEST._row_hash, 'NULLFIELDVALUE') != {{ source_row_hash }}
        then update set

            {% for column_name in update_columns -%}

                {%- if not column_name.lower().replace('"','') in lower_unique_keys -%}
                    {%- if column_name == '"_ROW_HASH"' -%}
                        {{ column_name }} = {{ source_row_hash }}
                    {%- else -%}
                        {{ column_name }} = DBT_INTERNAL_SOURCE.{{ column_name }}
                    {%- endif -%}

                    {%- if not loop.last %}
                    , {%- endif %}
                {%- endif -%}

            {%- endfor %}

        {% endif %}

        when not matched then insert
            ({{ dest_cols_csv.replace(',','
            ,') }})
        values
            ({{ dest_cols_csv.replace(',','
            ,').replace('"_ROW_HASH"', source_row_hash) }})

    {%- else -%}

        {{ default__get_merge_sql(target, source_sql, unique_key, dest_columns, predicates) }}

    {%- endif -%}
    {%- endset -%}

    {% do return(snowflake_dml_explicit_transaction(dml)) %}

{% endmacro %}