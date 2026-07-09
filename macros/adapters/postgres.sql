{% macro postgres__request(method, url, headers={}, params={}, body=none, connection=none, function_name=none, content_type='application/json') -%}
  {{ http.postgres__validate_http_setup('request', connection, function_name) }}
  {%- set upper_method = method | upper -%}
  {%- if upper_method == 'GET' and not headers and not params -%}
    (select content from http_get({{ http.sql_string(url) }}))
  {%- elif upper_method == 'POST' and not headers and not params -%}
    (select content from http_post({{ http.sql_string(url) }}, {{ http.json_string(body) }}, {{ http.sql_string(content_type) }}))
  {%- else -%}
    (select content from http((
      {{ http.sql_string(upper_method) }},
      {{ http.sql_string(url) }},
      {{ http.postgres_headers(headers) }},
      {{ http.sql_string(content_type) }},
      {{ http.json_string(body) }}
    )::http_request))
  {%- endif -%}
{%- endmacro %}

{% macro postgres__validate_http_setup(feature='request', connection=none, function_name=none) -%}
  {%- if feature != 'request' -%}
    {{ exceptions.raise_compiler_error(http.unsupported_message(feature)) }}
  {%- endif -%}
  {%- set sql -%}
    select 1
    from pg_extension
    where extname = 'http'
    limit 1
  {%- endset -%}
  {{ http.assert_query_has_rows(sql, 'Postgres `http` extension from pgsql-http', 'postgres--supabase') }}
{%- endmacro %}

{% macro postgres_headers(headers) -%}
  {%- if not headers -%}
    null
  {%- else -%}
    http_headers(
      {%- for key, value in headers.items() -%}
        {{ http.sql_string(key) }}, {{ http.sql_string(value) }}{{ ", " if not loop.last }}
      {%- endfor -%}
    )
  {%- endif -%}
{%- endmacro %}
