DROP SCHEMA IF EXISTS efficiency_schema CASCADE;
CREATE SCHEMA IF NOT EXISTS efficiency_schema;

SELECT '=== Loading fcf_mart TABLE ===' AS info;
CREATE TABLE dw_stock_dashboard.efficiency_schema.latest_fcf_analysis_mart(
    ticker VARCHAR,
    date DATE,
    free_cash_flow DOUBLE,
    fcf_3_year_avg DOUBLE,
    fcf_margin DOUBLE,
    fcf_conversion_rate DOUBLE
);

INSERT INTO dw_stock_dashboard.efficiency_schema.latest_fcf_analysis_mart(
    ticker,
    date,
    free_cash_flow,
    fcf_3_year_avg,
    fcf_margin,
    fcf_conversion_rate
)
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
fcf_3_year_avg AS(
    SELECT 
        ticker,
        AVG(value) AS fcf_3_year_avg
    FROM(
        SELECT
            ticker,
            value,
            ROW_NUMBER() OVER(PARTITION BY ticker ORDER BY date DESC) as rn
        FROM 
            dw_stock_dashboard.main.yearly_cash_flow_fact
        WHERE 
            name = 'Free Cash Flow'
    )
    WHERE
        rn <= 3
    GROUP BY
        ticker
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
    fcf_avg.fcf_3_year_avg,
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
LEFT JOIN fcf_3_year_avg AS fcf_avg
    ON fcf_avg.ticker = fcf.ticker
WHERE
    fcf.rn = 1
    AND lr.rn = 1
    AND li.rn = 1
ORDER BY
    fcf.ticker;


-- quarterly section ---------------------------------------------------------


CREATE TABLE dw_stock_dashboard.efficiency_schema.fcf_analysis_mart(
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE
);

INSERT INTO dw_stock_dashboard.efficiency_schema.fcf_analysis_mart(
    ticker,
    name,
    date,
    value
)
SELECT
    ticker,
    name,
    date,
    value
FROM
    dw_stock_dashboard.main.ttm_cash_flow_fact
WHERE
    name IN(
        'Free Cash Flow', 'Depreciation And Amortization', 'Capital Expenditure',
        'Stock Based Compensation', 'Change In Working Capital', 'Other Non Cash Items'
    )
UNION ALL
SELECT
    ticker,
    name,
    date,
    value
FROM
    dw_stock_dashboard.main.ttm_income_statements_fact
WHERE
    name = 'Net Income'
ORDER BY
    ticker ASC,
    date ASC,
    name ASC;