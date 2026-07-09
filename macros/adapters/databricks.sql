{% macro databricks__request(method, url, headers={}, params={}, body=none, connection=none, function_name=none, content_type='application/json') -%}
  {{ http.databricks__validate_http_setup('request', connection, function_name) }}
  http_request(
    CONN => {{ http.sql_string(connection) }},
    METHOD => {{ http.sql_string(method | upper) }},
    PATH => {{ http.sql_string(url) }}
    {%- if headers %}
    , HEADERS => {{ http.databricks_map(headers) }}
    {%- endif %}
    {%- if params %}
    , PARAMS => {{ http.databricks_map(params) }}
    {%- endif %}
    {%- if body is not none %}
    , JSON => {{ http.json_string(body) }}
    {%- endif %}
  )
{%- endmacro %}

{% macro databricks__validate_http_setup(feature='request', connection=none, function_name=none) -%}
  {%- if feature != 'request' -%}
    {{ exceptions.raise_compiler_error(http.unsupported_message(feature)) }}
  {%- endif -%}
  {%- if connection is none -%}
    {{ http.setup_error('request', '`connection` argument or configured Unity Catalog HTTP connection name', 'databricks') }}
  {%- endif -%}
  {%- if execute and http.should_validate_setup() -%}
    {%- set sql -%}
      describe connection {{ connection }}
    {%- endset -%}
    {%- set result = run_query(sql) -%}
    {%- if result is none -%}
      {{ http.setup_error('request', 'Databricks HTTP connection `' ~ connection ~ '`', 'databricks') }}
    {%- endif -%}
  {%- endif -%}
{%- endmacro %}

{% macro databricks_map(values) -%}
  {%- set pairs = [] -%}
  {%- for key, value in values.items() -%}
    {%- do pairs.append(http.sql_string(key)) -%}
    {%- do pairs.append(http.sql_string(value)) -%}
  {%- endfor -%}
  map({{ pairs | join(', ') }})
{%- endmacro %}
