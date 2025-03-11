{% macro generate_date_dimension(start_date, end_date) %}
    WITH date_series AS (
        SELECT
            DATEADD(day, seq4(), '{{ start_date }}') AS date
        FROM
            TABLE(GENERATOR(ROWCOUNT => 365 * 5 + 120)) -- Adjust ROWCOUNT as needed
    )
    SELECT
        date::DATE        AS date_id,
        date,
        DAYOFWEEK(date)+1 AS day_of_week,
        DAYNAME(date)     AS day_name,
        QUARTER(date)     AS quarter,
        MONTH(date)       AS month,
        YEAR(date)        AS year,
        LAST_DAY(date, 'QUARTER') AS quarter_end_date,
        LAST_DAY(date, 'MONTH') AS month_end_date
    FROM
        date_series
    WHERE
        date BETWEEN '{{ start_date }}' AND '{{ end_date }}'
    ORDER BY
        date
{% endmacro %}