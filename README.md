# Solar PV Analytics — BigQuery & dbt

## Project Overview

This project demonstrates an analytics engineering workflow for monitoring solar photovoltaic (PV) electricity production using **Python, Google BigQuery, SQL, and dbt Core**.

It uses a synthetic dataset of 15-minute inverter-level measurements to build a daily performance model, validate data quality, and document data dependencies.

The objective is to transform detailed PV measurements into reliable, analysis-ready data that can support reporting and performance monitoring.

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Synthetic data generation and initial processing |
| Google BigQuery | Cloud data warehouse and SQL execution |
| SQL | Data aggregation, joins, and KPI calculations |
| dbt Core | Data transformation, testing, and documentation |
| Git | Version control |

## Dataset

The analysis covers June 2025.

| Metric | Value |
|---|---:|
| PV sites | 25 |
| Inverters | 102 |
| Measurement interval | 15 minutes |
| Analysis period | 30 days |
| Raw measurement records | 293,760 |
| Daily site-level records | 750 |

The source data is stored in the BigQuery dataset `analytics_lab`.

**Source tables:**

- `dim_sites`: Site identifiers, names, regions, installed capacities, and other site metadata.
- `dim_inverters`: Inverter identifiers, site associations, and inverter metadata.
- `fact_pv_15min_raw`: 15-minute electricity production and environmental measurements.

**Note:** The dataset is synthetic and is intended for learning and demonstrating data engineering and analytical methods. It does not represent actual operational PV measurements.

## Data Transformation

The dbt model `mart_daily_site_performance` transforms inverter-level measurements into daily site-level performance indicators.

The model:

1. Aggregates 15-minute energy measurements by site and production date.
2. Joins the aggregated data with site metadata.
3. Calculates daily production and specific yield.
4. Exposes the result as a BigQuery View.

**Output grain:** One row per PV site and production date.

**Main analytical metrics:**

| Metric | Definition |
|---|---|
| `daily_energy_kwh` | Total electricity produced by a site during one day (kWh) |
| `daily_specific_yield` | Daily energy divided by installed capacity (kWh/kWp) |
| `measurement_count` | Number of inverter-level records included in the daily aggregation |

Specific Yield allows production to be compared across PV sites of different installed capacities.

The resulting View contains **750 site-day records** covering 25 sites and 30 production dates.

## Data Quality Tests

Data quality checks are implemented using dbt generic tests and a custom generic test.

| Validation | Test |
|---|---|
| Site identifier must not be NULL | `not_null` |
| Production date must not be NULL | `not_null` |
| Installed capacity must not be NULL | `not_null` |
| Daily energy must not be NULL | `not_null` |
| Site and production date must form a unique combination | Custom `unique_site_date_pair` |
| Source measurement SiteIDs must exist in the site dimension | `relationships` |

**Validation result: 6 tests passed, 0 test failures.**

The relationship test is applied to the raw measurement source, helping detect invalid site references before aggregation.

## Documentation and Data Lineage

dbt Documentation provides metadata, model descriptions, column definitions, and a dependency graph.

The daily performance model depends on two BigQuery source tables:

- `solar_raw.fact_pv_15min_raw`
- `solar_raw.dim_sites`

Both feed the `mart_daily_site_performance` model.

The `dim_inverters` table is declared as a source but is not directly used in this model.

## Project Structure

- `models/sources.yml` — BigQuery source definitions and source tests.
- `models/marts/mart_daily_site_performance.sql` — Daily PV performance transformation.
- `models/marts/schema.yml` — Model descriptions and column tests.
- `tests/generic/unique_site_date_pair.sql` — Custom composite-key uniqueness test.
- `dbt_project.yml` — dbt project configuration.
- `README.md` — Project documentation.

## Running the Project

**Prerequisites:**

- A Python environment with dbt Core and the BigQuery adapter installed.
- Google Cloud Application Default Credentials configured.
- Access to the BigQuery project and source datasets.
- A valid local dbt profile (`profiles.yml`).

The project uses the BigQuery dataset `analytics_lab` for source data and `analytics_dbt` for transformed models. Both are configured in the EU location.

**Verify the connection:**

`dbt debug`

**Build the daily performance View:**

`dbt run --select mart_daily_site_performance`

**Run the model data quality tests:**

`dbt test --select mart_daily_site_performance`

**Run the source relationship test:**

`dbt test --select "source:solar_raw.fact_pv_15min_raw"`

**Generate documentation:**

`dbt docs generate`

**Serve documentation locally:**

`dbt docs serve --port 8080`

The source BigQuery tables must exist before running the model. Source CSV ingestion is performed separately from this dbt project.

## Project Scope and Limitations

- This is a portfolio and learning project based on synthetic PV data.
- The current implementation focuses on daily energy production and specific yield.
- The model is materialized as a BigQuery View.
- The project does not currently include automated scheduling or a production deployment.
- BigQuery Sandbox imposes data retention and other operational limitations.

## Key Learnings

This project demonstrates practical experience with:

- Cloud SQL analytics using BigQuery.
- Data modeling at a defined analytical grain.
- SQL transformations managed with dbt Core.
- Generic and custom data quality tests.
- Referential integrity validation.
- Data documentation and lineage.
- Organizing analytical transformations as a reproducible, version-controlled project.
