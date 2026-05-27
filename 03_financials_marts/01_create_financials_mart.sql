DROP SCHEMA IF EXISTS financials_schema CASCADE;
CREATE SCHEMA IF NOT EXISTS financials_schema;

SELECT '=== Loading quarterly_and_yearly_expenses_breakdown_mart TABLE ===' AS info;
CREATE TABLE dw_stock_dashboard.financials_schema.quarterly_financials_mart(
    ticker VARCHAR,
    date DATE,
    name VARCHAR,
    value DOUBLE,
    percentage_diff DOUBLE
);

INSERT INTO dw_stock_dashboard.financials_schema.quarterly_financials_mart(
    ticker,
    date,
    name,
    value,
    percentage_diff
)
WITH previous_value_ist AS(
    SELECT
        *,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        dw_stock_dashboard.main.quarterly_income_statements_fact
),
calculated_cash_flows AS(
    SELECT
        ticker,
        date,
        name,
        value
    FROM
        dw_stock_dashboard.main.quarterly_cash_flows_fact
    WHERE
        name = 'Net Cash Provided by (Used in) Operating Activities'
        
    UNION ALL
    SELECT
        ticker,
        date,
        'Free Cash Flow' AS name,
        SUM(CASE WHEN name = 'Net Cash Provided by (Used in) Operating Activities' THEN COALESCE(value, 0) ELSE 0 END) -
        SUM(CASE WHEN name = 'Payments to Acquire Property, Plant, and Equipment' THEN COALESCE(value, 0) ELSE 0 END) AS value
    FROM
        dw_stock_dashboard.main.quarterly_cash_flows_fact
    WHERE
        name IN('Net Cash Provided by (Used in) Operating Activities', 'Payments to Acquire Property, Plant, and Equipment')
    GROUP BY
        ticker,
        date
),
previous_value_cfl AS(
    SELECT
        ticker,
        date,
        name,
        value,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        calculated_cash_flows
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
    name IN(
        'Total Revenue', 'Operating Income (Loss)',
        'Net Income (Loss) Attributable to Parent', 'Earnings Per Share, Diluted'
    )
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
    name IN('Net Cash Provided by (Used in) Operating Activities', 'Free Cash Flow')
ORDER BY
    name ASC,
    ticker ASC,
    date ASC;


-- yearly section ---------------------------------------------------------


CREATE TABLE dw_stock_dashboard.financials_schema.yearly_financials_mart(
    ticker VARCHAR,
    date DATE,
    name VARCHAR,
    value DOUBLE,
    percentage_diff DOUBLE
);

INSERT INTO dw_stock_dashboard.financials_schema.yearly_financials_mart(
    ticker,
    date,
    name,
    value,
    percentage_diff
)
WITH previous_value_ist AS(
    SELECT
        *,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        dw_stock_dashboard.main.yearly_income_statements_fact
),
calculated_cash_flows AS(
    SELECT
        ticker,
        date,
        name,
        value
    FROM
        dw_stock_dashboard.main.yearly_cash_flows_fact
    WHERE
        name = 'Operating Cash Flow'
        
    UNION ALL
    SELECT
        ticker,
        date,
        'Free Cash Flow' AS name,
        SUM(CASE WHEN name = 'Operating Cash Flow' THEN COALESCE(value, 0) ELSE 0 END) -
        SUM(CASE WHEN name = 'Payments to Acquire Property, Plant, and Equipment' THEN COALESCE(value, 0) ELSE 0 END) AS value
    FROM
        dw_stock_dashboard.main.yearly_cash_flows_fact
    WHERE
        name IN ('Net Cash Provided by (Used in) Operating Activities', 'Payments to Acquire Property, Plant, and Equipment')
    GROUP BY
        ticker,
        date
),
previous_value_cfl AS(
    SELECT
        ticker,
        date,
        name,
        value,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        calculated_cash_flows
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
    name IN(
        'Total Revenue', 'Operating Income (Loss)',
        'Net Income (Loss) Attributable to Parent', 'Earnings Per Share, Diluted'
    )
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
    name IN('Net Cash Provided by (Used in) Operating Activities', 'Free Cash Flow')
ORDER BY
    name ASC,
    ticker ASC,
    date ASC;