{% macro bigquery__request(method, url, headers={}, params={}, body=none, connection=none, function_name=none, content_type='application/json') -%}
  {{ http.bigquery__validate_http_setup('request', connection, function_name) }}
  {{ function_name }}(
    {{ http.sql_string(method | upper) }},
    {{ http.sql_string(url) }},
    {{ http.json_string(headers) }},
    {{ http.json_string(params) }},
    {{ http.json_string(body) }},
    {{ http.sql_string(content_type) }}
  )
{%- endmacro %}

{% macro bigquery__validate_http_setup(feature='request', connection=none, function_name=none) -%}
  {%- if feature != 'request' -%}
    {{ exceptions.raise_compiler_error(http.unsupported_message(feature)) }}
  {%- endif -%}
  {%- if function_name is none -%}
    {{ http.setup_error('request', '`function_name` for the BigQuery remote function', 'bigquery') }}
  {%- endif -%}
  {%- if execute and http.should_validate_setup() -%}
    {%- set parsed = http.parse_function_name(function_name) -%}
    {%- set sql -%}
      select 1
      from `{{ parsed.database }}.{{ parsed.schema }}.INFORMATION_SCHEMA.ROUTINES`
      where lower(routine_name) = lower({{ http.sql_string(parsed.identifier) }})
      limit 1
    {%- endset -%}
    {{ http.assert_query_has_rows(sql, 'BigQuery remote function `' ~ function_name ~ '`', 'bigquery') }}
  {%- endif -%}
{%- endmacro %}
