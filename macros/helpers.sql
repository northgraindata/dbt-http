{% macro unsupported_message(feature) -%}
  {%- set adapter_name = target.type if target is defined else 'unknown' -%}
  dbt-http does not support `{{ feature }}` for adapter `{{ adapter_name }}` yet.
  See the compatibility table in README.md and open an adapter request if the warehouse has a safe HTTP primitive.
{%- endmacro %}

{% macro setup_error(feature, missing, docs_anchor) -%}
  {%- set adapter_name = target.type if target is defined else 'unknown' -%}
  {{ exceptions.raise_compiler_error(
      'dbt-http setup validation failed for adapter `' ~ adapter_name ~ '` and feature `' ~ feature ~ '`: missing ' ~ missing ~
      '. See README.md#' ~ docs_anchor ~ ' for setup instructions.'
  ) }}
{%- endmacro %}

{% macro sql_string(value) -%}
  {%- if value is none -%}
    null
  {%- else -%}
    '{{ (value | string).replace("'", "''") }}'
  {%- endif -%}
{%- endmacro %}

{% macro json_string(value) -%}
  {%- if value is none -%}
    null
  {%- elif value is string -%}
    {{ http.sql_string(value) }}
  {%- else -%}
    {{ http.sql_string(tojson(value)) }}
  {%- endif -%}
{%- endmacro %}

{% macro should_validate_setup() -%}
  {{ return(var('http', {}).get('validate_setup', true)) }}
{%- endmacro %}

{% macro relation_exists_sql(database, schema, identifier) -%}
  select 1
  from {{ database }}.information_schema.routines
  where lower(routine_schema) = lower({{ http.sql_string(schema) }})
    and lower(routine_name) = lower({{ http.sql_string(identifier) }})
  limit 1
{%- endmacro %}

{% macro assert_query_has_rows(sql, missing, docs_anchor) -%}
  {%- if execute and http.should_validate_setup() -%}
    {%- set result = run_query(sql) -%}
    {%- if result is none or (result | length) == 0 -%}
      {{ http.setup_error('request', missing, docs_anchor) }}
    {%- endif -%}
  {%- endif -%}
{%- endmacro %}

{% macro parse_function_name(function_name, default_schema=none) -%}
  {%- set parts = (function_name | string).replace('`', '').replace('"', '').split('.') -%}
  {%- if parts | length == 1 -%}
    {{ return({'database': target.database, 'schema': default_schema or target.schema, 'identifier': parts[0]}) }}
  {%- elif parts | length == 2 -%}
    {{ return({'database': target.database, 'schema': parts[0], 'identifier': parts[1]}) }}
  {%- else -%}
    {{ return({'database': parts[-3], 'schema': parts[-2], 'identifier': parts[-1]}) }}
  {%- endif -%}
{%- endmacro %}
