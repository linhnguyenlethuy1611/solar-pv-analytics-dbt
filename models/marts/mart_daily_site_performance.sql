
{{ config(materialized='view') }}

WITH daily_energy AS (
    SELECT
        SiteID,
        `Date` AS production_date,
        SUM(Energy_kWh) AS energy_kwh,
        COUNT(*) AS measurement_count
    FROM {{ source('solar_raw', 'fact_pv_15min_raw') }}
    GROUP BY SiteID, production_date
)

SELECT
    d.SiteID,
    s.SiteName,
    s.Region,
    d.production_date,
    s.Installed_kWp,
    ROUND(d.energy_kwh, 2) AS daily_energy_kwh,
    ROUND(
        SAFE_DIVIDE(d.energy_kwh, s.Installed_kWp),
        2
    ) AS daily_specific_yield,
    d.measurement_count

FROM daily_energy AS d
INNER JOIN {{ source('solar_raw', 'dim_sites') }} AS s
    ON d.SiteID = s.SiteID
