
{% test unique_site_date_pair(model) %}

SELECT
    SiteID,
    production_date,
    COUNT(*) AS row_count

FROM {{ model }}

GROUP BY
    SiteID,
    production_date

HAVING COUNT(*) > 1

{% endtest %}
