{%- test recently_run(model, interval=24, date_or_time_part='hours') -%}
{# warns if there were no runs of the parent model in a given time interval #}
{{- config(severity = 'warn') }}

-- depends_on: {{ ref('dbt_artifacts', 'model_executions') }}

{#- scan through the graph object (manifest.json) to reverse look up the model node -#}
{%- set nodes = graph.get('nodes', {}) -%}
{%- for node_id, node in nodes.items() -%}
    {%- if node.alias == this.identifier -%}
        {%- set parent_model = node.depends_on.nodes[0] -%}

            {#- invert the recent model executions #}
            select 1 where not exists (
                select
                    1,
                from {{ ref('dbt_artifacts', 'model_executions') }}
                where NODE_ID = '{{ parent_model }}'
                    and STATUS = 'success'
                    and datediff('{{ date_or_time_part }}', RUN_STARTED_AT, SYSDATE()) < {{ interval }}
                limit 1
            )

        {%- break -%}
    {%- elif loop.last -%}
        select 1 where 'reached end of loop' = 'did not find test node in manifest.json'
    {%- endif -%}
{%- endfor -%}

{% endtest %}


{%- test has_data(model) -%}
{# raises an error when row count of model equals zero #}

{#- scan through the graph object (manifest.json) to reverse look up the model node -#}
{%- set nodes = graph.get('nodes', {}) -%}
{%- for node_id, node in nodes.items() -%}
    {%- if node.alias == this.identifier -%}
        {%- set parent_model = node.depends_on.nodes[0] -%}
        {%- set model_name = parent_model.split('.')[2] -%}

            {#- look up the row count of the parent table #}
            select 1 where ( select count(*) from {{ ref(model_name) }} ) = 0

        {%- break -%}
    {%- elif loop.last -%}
        select 1 where 'reached end of loop' = 'did not find test node in manifest.json'
    {%- endif -%}
{%- endfor -%}

{% endtest %}

