import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def run_dbt(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["uv", "run", "dbt", *args],
        cwd=ROOT,
        check=False,
        text=True,
        capture_output=True,
    )


def test_dbt_parse_succeeds() -> None:
    result = run_dbt("parse", "--profiles-dir", ".")

    assert result.returncode == 0, result.stdout + result.stderr


def test_duckdb_read_url_operation_succeeds() -> None:
    result = run_dbt(
        "run-operation",
        "read_url",
        "--profiles-dir",
        ".",
        "--args",
        '{url: "https://example.com/data.csv"}',
    )

    assert result.returncode == 0, result.stdout + result.stderr


def test_duckdb_request_operation_fails_with_supported_message() -> None:
    result = run_dbt(
        "run-operation",
        "request",
        "--profiles-dir",
        ".",
        "--args",
        '{method: "GET", url: "https://example.com"}',
    )

    output = result.stdout + result.stderr
    assert result.returncode != 0
    assert "supports `read_url` for DuckDB" in output
    assert "not generic scalar HTTP `request`" in output
