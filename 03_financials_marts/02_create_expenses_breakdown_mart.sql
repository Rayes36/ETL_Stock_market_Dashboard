SELECT '=== Loading quarterly_and_yearly_expenses_breakdown_mart TABLE ===' AS info;
CREATE TABLE dw_stock_dashboard.financials_schema.quarterly_expenses_breakdown_mart(
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    percentage_diff DOUBLE
);

INSERT INTO dw_stock_dashboard.financials_schema.quarterly_expenses_breakdown_mart(
    ticker,
    name,
    date,
    value,
    percentage_diff
)
WITH previous_value_ist AS(
    SELECT
        ticker,
        date,
        name,
        value,
        LAST_VALUE(value) OVER(
            PARTITION BY name, ticker
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS latest_value
    FROM
        dw_stock_dashboard.main.quarterly_income_statements_fact
),
calculated_sga AS(
    SELECT
        ticker,
        date,
        name,
        value
    FROM
        dw_stock_dashboard.main.quarterly_income_statements_fact
    WHERE
        name = 'General and Administrative Expense'
    UNION ALL
    SELECT
        ticker,
        date,
        'Selling General And Administration' AS name,
        SUM(CASE WHEN name = 'General and Administrative Expense' THEN COALESCE(value, 0) ELSE 0 END) +
        SUM(CASE WHEN name = 'Selling and Marketing Expense' THEN COALESCE(value, 0) ELSE 0 END) AS value
    FROM
        dw_stock_dashboard.main.quarterly_income_statements_fact
    WHERE
        name IN('General and Administrative Expense', 'Selling and Marketing Expense')
    GROUP BY
        ticker,
        date
),
previous_value_sga AS(
    SELECT
        ticker,
        date,
        name,
        value,
        LAST_VALUE(value) OVER(
            PARTITION BY name, ticker
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS latest_value
    FROM
        calculated_sga
)
SELECT
    ticker,
    name,
    date,
    value,
    CASE
        WHEN latest_value IS NULL THEN NULL
        ELSE ((latest_value - value) / NULLIF(latest_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value_ist
WHERE
    name IN(
        'Total Revenue', 'Gross Profit (Calculated)', 'Cost of Revenue',
        'Net Income (Loss) Attributable to Parent', 'Costs and Expenses',
        'Research and Development Expense'
    )
UNION ALL
SELECT
    ticker,
    name,
    date,
    value,
    CASE
        WHEN latest_value IS NULL THEN NULL
        ELSE ((latest_value - value) / NULLIF(latest_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value_sga
WHERE
    name = 'Selling General And Administration'
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
WITH previous_value_ist AS(
    SELECT
        ticker,
        date,
        name,
        value,
        LAST_VALUE(value) OVER(
            PARTITION BY name, ticker
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS latest_value
    FROM
        dw_stock_dashboard.main.yearly_income_statements_fact
),
calculated_sga AS(
    SELECT
        ticker,
        date,
        name,
        value
    FROM
        dw_stock_dashboard.main.yearly_income_statements_fact
    WHERE
        name = 'General and Administrative Expense'
    UNION ALL
    SELECT
        ticker,
        date,
        'Selling General And Administration' AS name,
        SUM(CASE WHEN name = 'General and Administrative Expense' THEN COALESCE(value, 0) ELSE 0 END) +
        SUM(CASE WHEN name = 'Selling and Marketing Expense' THEN COALESCE(value, 0) ELSE 0 END) AS value
    FROM
        dw_stock_dashboard.main.yearly_income_statements_fact
    WHERE
        name IN('General and Administrative Expense', 'Selling and Marketing Expense')
    GROUP BY
        ticker,
        date
),
previous_value_sga AS(
    SELECT
        ticker,
        date,
        name,
        value,
        LAST_VALUE(value) OVER(
            PARTITION BY name, ticker
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS latest_value
    FROM
        calculated_sga
)
SELECT
    ticker,
    name,
    date,
    value,
    CASE
        WHEN latest_value IS NULL THEN NULL
        ELSE ((latest_value - value) / NULLIF(latest_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value_ist
WHERE
    name IN(
        'Total Revenue', 'Gross Profit (Calculated)', 'Cost of Revenue',
        'Net Income (Loss) Attributable to Parent', 'Costs and Expenses',
        'Research and Development Expense'
    )
UNION ALL
SELECT
    ticker,
    name,
    date,
    value,
    CASE
        WHEN latest_value IS NULL THEN NULL
        ELSE ((latest_value - value) / NULLIF(latest_value, 0)) * 100
    END AS percentage_diff
FROM
    previous_value_sga
WHERE
    name = 'Selling General And Administration'
ORDER BY
    name ASC,
    ticker ASC,
    date ASC;