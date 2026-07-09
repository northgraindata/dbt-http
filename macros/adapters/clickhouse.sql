{% macro clickhouse__request(method, url, headers={}, params={}, body=none, connection=none, function_name=none, content_type='application/json') -%}
  {{ exceptions.raise_compiler_error('dbt-http supports `read_url` for ClickHouse via url(...), but not generic scalar HTTP `request`. See README.md#clickhouse.') }}
{%- endmacro %}

{% macro clickhouse__read_url(url, format=none, schema=none, headers={}) -%}
  {%- if format is none or schema is none -%}
    {{ http.setup_error('read_url', '`format` and `schema` arguments for ClickHouse url(...)', 'clickhouse') }}
  {%- endif -%}
  url({{ http.sql_string(url) }}, {{ http.sql_string(format) }}, {{ http.sql_string(schema) }}
    {%- if headers -%}
      , headers(
        {%- for key, value in headers.items() -%}
          {{ http.sql_string(key) }}={{ http.sql_string(value) }}{{ ", " if not loop.last }}
        {%- endfor -%}
      )
    {%- endif -%}
  )
{%- endmacro %}

{% macro clickhouse__validate_http_setup(feature='request', connection=none, function_name=none) -%}
  {%- if feature != 'read_url' -%}
    {{ exceptions.raise_compiler_error('dbt-http supports `read_url` for ClickHouse, not `' ~ feature ~ '`. See README.md#clickhouse.') }}
  {%- endif -%}
{%- endmacro %}
