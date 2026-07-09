# dbt-http

`dbt-http` is a dbt package for explicit, edge-case HTTP access from warehouse SQL.
The dbt package name is `http`.

This package does not make dbt perform HTTP requests during compilation. It generates
adapter-specific SQL around warehouse-native HTTP primitives, UDFs, remote functions,
or URL table readers. If required warehouse setup is missing, macros fail with a clear
message and a link to the relevant setup section.

## Compatibility

| Adapter | `http.request` | `http.read_url` | Setup required | Validation |
| --- | --- | --- | --- | --- |
| Databricks | Supported with `http_request` | Not supported | Unity Catalog HTTP connection | Requires `connection`; validates with `DESCRIBE CONNECTION` when executing |
| Snowflake | Supported through configured UDF | Not supported | External access integration, network rule, secret, Python UDF | Requires `function_name`; checks information schema when executing |
| BigQuery | Supported through configured remote function | Not supported | Cloud Run/HTTP endpoint, BigQuery connection, remote function | Requires `function_name`; checks routines when executing |
| Redshift | Supported through configured Lambda UDF | Not supported | Lambda function, IAM role, external function | Requires `function_name`; checks routines when executing |
| Postgres / Supabase | Supported with `pgsql-http` | Not supported | `http` extension installed | Checks `pg_extension` when executing |
| ClickHouse | Not supported | Supported with `url(...)` | URL table function available | Requires `format` and `schema` |
| DuckDB | Not supported | Supported for HTTP(S) files | `httpfs` behavior available through DuckDB | Compile-time only |
| Other adapters | Not supported | Not supported | N/A | Fails fast |

## Installation

Install from GitHub:

```yaml
packages:
  - git: "https://github.com/northgraindata/dbt-http.git"
    revision: v0.1.0
```

Install locally during development:

```yaml
packages:
  - local: ../dbt-http
```

## Usage

Databricks:

```sql
select
  {{ http.get(
    url='/v1/status',
    connection='my_catalog.my_schema.my_http_connection',
    headers={'Accept': 'application/json'}
  ) }} as response
```

Snowflake, BigQuery, and Redshift use configured functions with a common signature:

```sql
select
  {{ http.post(
    url='https://example.com/events',
    body={'event': 'dbt_run'},
    function_name='analytics.http_request'
  ) }} as response
```

Postgres with `pgsql-http`:

```sql
select
  {{ http.get('https://example.com/status') }} as response
```

ClickHouse:

```sql
select *
from {{ http.read_url(
  url='https://example.com/data.csv',
  format='CSV',
  schema='id UInt64, name String',
  headers={'Accept': 'text/csv'}
) }}
```

DuckDB:

```sql
select *
from {{ http.read_url('https://example.com/data.csv') }}
```

## Validation

Validation is enabled by default during executing dbt commands, such as `dbt run`,
`dbt build`, and `dbt run-operation`. During parse-only compilation, macros avoid
database introspection.

To disable setup validation:

```yaml
vars:
  http:
    validate_setup: false
```

Disabling validation only skips preflight checks. The warehouse can still fail when
the generated SQL runs.

## Adapter Setup

### Databricks

`http.request` uses Databricks `http_request`, which requires a Unity Catalog HTTP
connection and `USE CONNECTION` permission. Pass the connection name with the
`connection` argument.

Docs:
- https://docs.databricks.com/aws/en/sql/language-manual/functions/http_request
- https://docs.databricks.com/aws/en/query-federation/http

Databricks documents rate limits and recommends avoiding high-volume batch usage.

### Snowflake

`http.request` calls a configured Snowflake UDF. The expected UDF signature is:

```sql
http_request(
  method string,
  url string,
  headers_json string,
  params_json string,
  body_json string,
  content_type string
)
```

The UDF must be configured with Snowflake external network access, including network
rules, secrets, and an external access integration.

Docs:
- https://docs.snowflake.com/en/developer-guide/external-network-access/creating-using-external-network-access
- https://docs.snowflake.com/en/sql-reference/sql/create-external-access-integration

### BigQuery

`http.request` calls a configured BigQuery remote function. The expected remote
function signature matches the Snowflake signature above. The Cloud Run endpoint
must implement the BigQuery remote function request/response contract.

Docs:
- https://docs.cloud.google.com/bigquery/docs/remote-functions

Pay attention to BigQuery connection permissions and region constraints.

### Redshift

`http.request` calls a configured Redshift Lambda UDF / external function. The
expected function signature matches the Snowflake signature above.

Docs:
- https://docs.aws.amazon.com/redshift/latest/dg/udf-creating-a-lambda-sql-udf.html
- https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_EXTERNAL_FUNCTION.html

### Postgres / Supabase

`http.request` uses the `http` extension from `pgsql-http`.

Docs:
- https://github.com/pramsey/pgsql-http
- https://supabase.com/docs/guides/database/extensions/http

### ClickHouse

`http.read_url` uses the ClickHouse `url` table function. It supports reading data
from HTTP(S) endpoints, not arbitrary scalar `curl`-style requests.

Docs:
- https://clickhouse.com/docs/sql-reference/table-functions/url

### DuckDB

`http.read_url` currently emits `read_csv_auto('https://...')`, relying on DuckDB
HTTP(S) file access. It is for reading remote files, not arbitrary API calls.

Docs:
- https://duckdb.org/docs/current/core_extensions/httpfs/overview

## Security And Cost

HTTP calls inside warehouse SQL are non-deterministic and can be expensive. Avoid
per-row requests over large datasets. Prefer allowlisted hosts, warehouse-managed
secrets, short timeouts, and auditable connections. Never inline tokens in dbt
models or committed YAML files.

## Development

This repo uses uv:

```bash
uv sync --locked
uv run dbt parse --profiles-dir .
```

Run local checks:

```bash
uv run dbt parse --profiles-dir .
uv run pytest
```
