{% macro request(method, url, headers={}, params={}, body=none, connection=none, function_name=none, content_type='application/json') -%}
  {{ return(adapter.dispatch('request', 'http')(method, url, headers, params, body, connection, function_name, content_type)) }}
{%- endmacro %}

{% macro get(url, headers={}, params={}, connection=none, function_name=none) -%}
  {{ return(http.request('GET', url, headers, params, none, connection, function_name)) }}
{%- endmacro %}

{% macro post(url, body, headers={}, params={}, connection=none, function_name=none, content_type='application/json') -%}
  {{ return(http.request('POST', url, headers, params, body, connection, function_name, content_type)) }}
{%- endmacro %}

{% macro read_url(url, format=none, schema=none, headers={}) -%}
  {{ return(adapter.dispatch('read_url', 'http')(url, format, schema, headers)) }}
{%- endmacro %}

{% macro validate_http_setup(feature='request', connection=none, function_name=none) -%}
  {{ return(adapter.dispatch('validate_http_setup', 'http')(feature, connection, function_name)) }}
{%- endmacro %}

{% macro default__request(method, url, headers={}, params={}, body=none, connection=none, function_name=none, content_type='application/json') -%}
  {{ exceptions.raise_compiler_error(http.unsupported_message('request')) }}
{%- endmacro %}

{% macro default__read_url(url, format=none, schema=none, headers={}) -%}
  {{ exceptions.raise_compiler_error(http.unsupported_message('read_url')) }}
{%- endmacro %}

{% macro default__validate_http_setup(feature='request', connection=none, function_name=none) -%}
  {{ exceptions.raise_compiler_error(http.unsupported_message(feature)) }}
{%- endmacro %}
