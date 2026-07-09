# Contributing

## Development

Install dependencies:

```bash
uv sync
```

Run checks:

```bash
uv run dbt parse --profiles-dir .
uv run pytest
```

## Adapter Support

New adapter support must include:

- A dispatch implementation.
- Setup validation or a documented reason validation is not possible.
- README compatibility table updates.
- Compile tests for success and missing setup behavior.

Do not add support for an adapter unless the warehouse has a documented HTTP
primitive, UDF mechanism, remote function, or URL table reader.

## Releases

Releases use semantic versioning and `v*` Git tags. Update `CHANGELOG.md`,
`dbt_project.yml`, and `pyproject.toml` together.
