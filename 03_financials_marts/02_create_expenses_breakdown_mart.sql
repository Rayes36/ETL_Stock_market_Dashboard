SELECT '=== Loading ttm_and_yearly_expenses_breakdown_mart TABLE ===' AS info;
CREATE TABLE dw_stock_dashboard.financials_schema.ttm_expenses_breakdown_mart(
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    percentage_diff DOUBLE
);

INSERT INTO dw_stock_dashboard.financials_schema.ttm_expenses_breakdown_mart(
    ticker,
    name,
    date,
    value,
    percentage_diff
)
WITH previous_value AS(
    SELECT
        *,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        dw_stock_dashboard.main.ttm_income_statements_fact
)
SELECT
    ticker,
    name,
    date,
    value,
    CASE
        WHEN previous_value IS NULL THEN 0
        ELSE((value - previous_value) / NULLIF(previous_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value
WHERE
    name IN('Total Revenue', 'Gross Profit', 'Cost Of Revenue', 'Net Income', 
    'Total Expenses', 'Selling General And Administration', 'Research And Development',
    'Other Operating Expenses')
ORDER BY
    name ASC,
    ticker ASC,
    date ASC;


-- yearly section ---------------------------------------------------------


CREATE TABLE dw_stock_dashboard.financials_schema.yearly_expenses_breakdown_mart(
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    percentage_diff DOUBLE
);

INSERT INTO dw_stock_dashboard.financials_schema.yearly_expenses_breakdown_mart(
    ticker,
    name,
    date,
    value,
    percentage_diff
)
WITH previous_value AS(
    SELECT
        *,
        LAG(value) OVER(PARTITION BY name, ticker ORDER BY date) AS previous_value
    FROM
        dw_stock_dashboard.main.yearly_income_statements_fact
)
SELECT
    ticker,
    name,
    date,
    value,
    CASE
        WHEN previous_value IS NULL THEN 0
        ELSE((value - previous_value) / NULLIF(previous_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value
WHERE
    name IN('Total Revenue', 'Gross Profit', 'Cost Of Revenue', 'Net Income', 
    'Total Expenses', 'Selling General And Administration', 'Research And Development',
    'Other Operating Expenses')
ORDER BY
    name ASC,
    ticker ASC,
    date ASC;