{% macro duckdb__request(method, url, headers={}, params={}, body=none, connection=none, function_name=none, content_type='application/json') -%}
  {{ exceptions.raise_compiler_error('dbt-http supports `read_url` for DuckDB HTTP(S) files via httpfs, but not generic scalar HTTP `request`. See README.md#duckdb.') }}
{%- endmacro %}

{% macro duckdb__read_url(url, format=none, schema=none, headers={}) -%}
  read_csv_auto({{ http.sql_string(url) }})
{%- endmacro %}

{% macro duckdb__validate_http_setup(feature='request', connection=none, function_name=none) -%}
  {%- if feature != 'read_url' -%}
    {{ exceptions.raise_compiler_error('dbt-http supports `read_url` for DuckDB, not `' ~ feature ~ '`. See README.md#duckdb.') }}
  {%- endif -%}
{%- endmacro %}
