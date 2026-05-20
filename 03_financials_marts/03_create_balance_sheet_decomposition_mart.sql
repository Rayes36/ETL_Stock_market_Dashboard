SELECT '=== Loading balance_sheet_decomposition_mart TABLE ===' AS info;
CREATE TABLE dw_stock_dashboard.financials_schema.balance_sheet_decomposition_mart(
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    total_group_value DOUBLE,
    value DOUBLE,
    financial_category VARCHAR
);

INSERT INTO dw_stock_dashboard.financials_schema.balance_sheet_decomposition_mart(
    ticker,
    name,
    date,
    total_group_value,
    value,
    financial_category
)
WITH assets AS(
    SELECT
        ticker,
        name,
        date,
        value,
        SUM(value) OVER(PARTITION BY ticker, date) AS total_group_value
    FROM
        dw_stock_dashboard.main.ttm_balance_sheet_fact
    WHERE
        name IN(
            -- current assets
            'Current Assets', 'Cash Cash Equivalents And Short Term Investments', 
            'Receivables', 'Other Current Assets',
            -- non current assets
            'Total Non Current Assets', 'Net PPE', 'Goodwill And Other Intangible Assets',
            'Other Non Current Assets', 'Other Properties'
        )
),
liabilities AS(
    SELECT
        ticker,
        name,
        date,
        value,
        SUM(value) OVER(PARTITION BY ticker, date) AS total_group_value
    FROM
        dw_stock_dashboard.main.ttm_balance_sheet_fact
    WHERE
        name IN(
            -- current liabilities
            'Current Liabilities', 'Accounts Payable', 'Payables And Accrued Expenses', 'Current Accrued Expenses',
            -- non current liabilities
            'Long Term Debt And Capital Lease Obligations', 'Capital Lease Obligations',
            'Long Term Debt', 'Other Non Current Liabilities'
        )
)
SELECT
    ticker,
    name,
    date,
    total_group_value,
    value,
    'asset' AS financial_category
FROM
    assets
UNION ALL
SELECT
    ticker,
    name,
    date,
    total_group_value,
    value,
    'liability' AS financial_category
FROM
    liabilities
ORDER BY
    ticker ASC,
    date ASC,
    financial_category ASC,
    name ASC;