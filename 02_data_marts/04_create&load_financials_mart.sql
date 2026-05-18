SELECT '=== Loading ttm&yearly_financials_mart TABLE ===' AS info;
CREATE OR REPLACE TABLE dw_stock_dashboard.analytic_schema.ttm_financials_mart AS
WITH previous_value_ist AS(
    SELECT
        *,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        dw_stock_dashboard.main.ttm_income_statements_fact
),
previous_value_cfl AS(
    SELECT
        *,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        dw_stock_dashboard.main.ttm_cash_flow_fact
)
SELECT
    ticker,
    date,
    name,
    value,
    CASE
        WHEN previous_value IS NULL THEN 0
        ELSE((value - previous_value) / NULLIF(previous_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value_ist
WHERE
    name IN('Total Revenue', 'Operating Income', 'Net Income', 'Diluted EPS')
UNION ALL
SELECT
    ticker,
    date,
    name,
    value,
    CASE
        WHEN previous_value IS NULL THEN 0
        ELSE((value - previous_value) / NULLIF(previous_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value_cfl
WHERE
    name IN('Operating Cash Flow', 'Free Cash Flow')
ORDER BY
    name ASC,
    ticker ASC,
    date ASC;


CREATE OR REPLACE TABLE dw_stock_dashboard.analytic_schema.yearly_financials_mart AS
WITH previous_value_ist AS(
    SELECT
        *,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        dw_stock_dashboard.main.yearly_income_statements_fact
),
previous_value_cfl AS(
    SELECT
        *,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        dw_stock_dashboard.main.yearly_cash_flow_fact
)
SELECT
    ticker,
    date,
    name,
    value,
    CASE
        WHEN previous_value IS NULL THEN 0
        ELSE((value - previous_value) / NULLIF(previous_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value_ist
WHERE
    name IN('Total Revenue', 'Operating Income', 'Net Income', 'Diluted EPS')
UNION ALL
SELECT
    ticker,
    date,
    name,
    value,
    CASE
        WHEN previous_value IS NULL THEN 0
        ELSE((value - previous_value) / NULLIF(previous_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value_cfl
WHERE
    name IN('Operating Cash Flow', 'Free Cash Flow')
ORDER BY
    name ASC,
    ticker ASC,
    date ASC;