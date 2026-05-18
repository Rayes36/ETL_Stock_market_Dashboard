SELECT '=== Loading fcf marts ===' AS info;
CREATE OR REPLACE TABLE dw_stock_dashboard.analytic_schema.fcf_analysis_mart AS
SELECT
    ticker,
    name,
    date,
    value,
    AVG(value) OVER(PARTITION BY ticker) AS ttm_fcf_average
FROM
    dw_stock_dashboard.main.ttm_cash_flow_fact
WHERE
    name IN('Free Cash Flow')
ORDER BY
    ticker ASC,
    date ASC,
    name ASC;


CREATE OR REPLACE TABLE dw_stock_dashboard.analytic_schema.latest_fcf_mart AS
WITH latest_fcf AS(
    SELECT
        ticker,
        date,
        value,
        ROW_NUMBER() OVER(PARTITION BY ticker ORDER BY date DESC) as rn
    FROM
        dw_stock_dashboard.main.ttm_cash_flow_fact
    WHERE 
        name = 'Free Cash Flow'
),
latest_revenue AS(
    SELECT
        ticker,
        date,
        value,
        ROW_NUMBER() OVER(PARTITION BY ticker ORDER BY date DESC) as rn
    FROM 
        dw_stock_dashboard.main.ttm_income_statements_fact
    WHERE 
        name = 'Total Revenue'
),
latest_income AS(
    SELECT
        ticker,
        date,
        value,
        ROW_NUMBER() OVER(PARTITION BY ticker ORDER BY date DESC) as rn
    FROM 
        dw_stock_dashboard.main.ttm_income_statements_fact
    WHERE 
        name = 'Net Income'
)
SELECT
    fcf.ticker,
    fcf.date,
    fcf.value AS free_cash_flow,
    (fcf.value / NULLIF(lr.value, 0)) * 100 AS fcf_margin,
    (fcf.value / NULLIF(li.value, 0)) * 100 AS fcf_conversion_rate
FROM 
    latest_fcf AS fcf
INNER JOIN latest_revenue AS lr
    ON lr.ticker = fcf.ticker
    AND lr.date = fcf.date
INNER JOIN latest_income AS li
    ON li.ticker = fcf.ticker
    AND li.date = fcf.date
WHERE
    fcf.rn = 1
    AND lr.rn = 1
    AND li.rn = 1
ORDER BY
    fcf.ticker;