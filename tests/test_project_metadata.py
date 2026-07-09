from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[1]


def test_dbt_project_name_is_http() -> None:
    project = yaml.safe_load((ROOT / "dbt_project.yml").read_text())

    assert project["name"] == "http"
    assert project["version"] == "0.1.0"


def test_readme_documents_every_supported_adapter() -> None:
    readme = (ROOT / "README.md").read_text()

    for heading in [
        "### Databricks",
        "### Snowflake",
        "### BigQuery",
        "### Redshift",
        "### Postgres / Supabase",
        "### ClickHouse",
        "### DuckDB",
    ]:
        assert heading in readme
