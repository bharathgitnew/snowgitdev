{% macro snowflake_create_table_as(temporary, relation, sql) -%}
  {%- set transient = config.get('transient', default=true) -%}
  {%- set cluster_by_keys = config.get('cluster_by', default=none) -%}
  {%- set enable_automatic_clustering = config.get('automatic_clustering', default=false) -%}
  {%- set copy_grants = config.get('copy_grants', default=false) -%}
  {%- set create_stream = config.get('target_has_stream', default='No') -%}
  {%- set table_name = relation.database + '.' + relation.schema  + '.' + config.get('alias', default='no_alias_config_value') -%}

  {%- if cluster_by_keys is not none and cluster_by_keys is string -%}
    {%- set cluster_by_keys = [cluster_by_keys] -%}
  {%- endif -%}
  {%- if cluster_by_keys is not none -%}
    {%- set cluster_by_string = cluster_by_keys|join(", ")-%}
  {% else %}
    {%- set cluster_by_string = none -%}
  {%- endif -%}
  {%- set sql_header = config.get('sql_header', none) -%}

  {{ sql_header if sql_header is not none }}

      create or replace {% if temporary -%}
        temporary
      {%- elif transient -%}
        transient
      {%- endif %} table {{ relation }} {% if copy_grants and not temporary -%} copy grants {%- endif %} as
      (
        {%- if cluster_by_string is not none -%}
          select * from(
            {{ sql }}
            ) order by ({{ cluster_by_string }})
        {%- else -%}
          {{ sql }}
        {%- endif %}
      );

    {% if cluster_by_string is not none and not temporary -%}
      alter table {{relation}} cluster by ({{cluster_by_string}});
    {%- endif -%}
    {% if enable_automatic_clustering and cluster_by_string is not none and not temporary  -%}
      alter table {{relation}} resume recluster;
    {%- endif -%}
    {% if create_stream == 'Yes' -%}
      create or replace stream {{table_name}}_Stream on table {{table_name}};
    {%- endif -%}

{% endmacro %}
