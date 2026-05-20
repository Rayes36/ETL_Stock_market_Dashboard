SELECT '=== Loading earnings waterfall mart ===' AS info;
CREATE TABLE dw_stock_dashboard.efficiency_schema.earnings_waterfall_mart(
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE
);

INSERT INTO dw_stock_dashboard.efficiency_schema.earnings_waterfall_mart(
    ticker,
    name,
    date,
    value
)
WITH latest_date AS(
    SELECT
        ticker,
        name,
        date,
        value,
        MAX(date) OVER(PARTITION BY ticker) AS latest_date 
    FROM
        dw_stock_dashboard.main.ttm_income_statements_fact
    WHERE
        name IN(
            'Total Revenue', 'Cost Of Revenue', 'Gross Profit', 'Operating Expense',
            'Operating Income', 'Other Non Operating Income Expenses'
        )
)
SELECT
    ticker,
    name,
    date,
    value
FROM
    latest_date
WHERE
    date = latest_date
ORDER BY
    ticker DESC,
    name DESC;