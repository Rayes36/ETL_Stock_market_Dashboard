SELECT '=== Loading balance_sheet_asset_decomposition_mart TABLE ===' AS info;
CREATE TABLE dw_stock_dashboard.financials_schema.balance_sheet_asset_decomposition_mart(
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    current BOOLEAN
);

INSERT INTO dw_stock_dashboard.financials_schema.balance_sheet_asset_decomposition_mart(
    ticker,
    name,
    date,
    value,
    current
)
WITH latest_date AS(
    SELECT
        ticker,
        name,
        date,
        value,
        MAX(date) OVER(PARTITION BY ticker) AS latest_date
    FROM
        dw_stock_dashboard.main.quarterly_balance_sheets_fact
),
-- Current assets
current_assets AS(
    SELECT
        ticker,
        name,
        date,
        value
    FROM
        latest_date
    WHERE
        date = latest_date
        AND name IN(
            'Cash, Cash Equivalents, and Short-term Investments', 'Cash and Cash Equivalents, at Carrying Value',
            'Accounts Receivable, after Allowance for Credit Loss, Current', 'Inventory, Net',
            'Prepaid Expense and Other Assets, Current', 'Assets, Current'
        )
),
calculated_cash AS(
    SELECT
        ticker,
        date,
        'Cash, Cash Equivalents, and Short-term Investments' AS name,
        COALESCE(
            NULLIF(MAX(CASE WHEN name = 'Cash, Cash Equivalents, and Short-term Investments' THEN value END), 0),
            MAX(CASE WHEN name = 'Cash and Cash Equivalents, at Carrying Value' THEN value END)
        ) AS value
    FROM
        current_assets
    GROUP BY
        ticker,
        date
),
other_current_assets AS(
    SELECT
        ca.ticker,
        ca.date,
        'Other Current Assets' AS name,
        GREATEST(
            ca.value
            - c.value
            - COALESCE(r.value, 0)
            - COALESCE(inv.value, 0)
            - COALESCE(prep.value, 0)
        , 0) AS value
    FROM
        current_assets AS ca
    INNER JOIN calculated_cash AS c
        ON ca.ticker = c.ticker
    LEFT JOIN current_assets AS r
        ON ca.ticker = r.ticker
        AND r.name = 'Accounts Receivable, after Allowance for Credit Loss, Current'
    LEFT JOIN current_assets AS inv
        ON ca.ticker = inv.ticker
        AND inv.name = 'Inventory, Net'
    LEFT JOIN current_assets AS prep
        ON ca.ticker = prep.ticker
        AND prep.name = 'Prepaid Expense and Other Assets, Current'
    WHERE
        ca.name = 'Assets, Current'
),
-- Non-current assets
non_current_assets AS(
    SELECT
        ticker,
        name,
        date,
        value
    FROM
        latest_date
    WHERE
        date = latest_date
        AND name IN(
            'Assets', 'Assets, Current', 'Goodwill', 'Intangible Assets, Net(Excluding Goodwill)',
            'Property, Plant and Equipment, Net', 'Operating Lease, Right-of-Use Asset',
            'Other Assets, Noncurrent'
        )
),
other_non_current_assets AS(
    SELECT
        a.ticker,
        a.date,
        'Long-term Investments' AS name,
        GREATEST(
        (a.value - ac.value)
            - COALESCE(gw.value, 0)
            - COALESCE(ia.value, 0)
            - COALESCE(ppe.value, 0)
            - COALESCE(rou.value, 0)
            - COALESCE(ona.value, 0)
        , 0) AS value
    FROM
        non_current_assets AS a
    JOIN non_current_assets AS ac
        ON a.ticker = ac.ticker 
        AND ac.name  = 'Assets, Current'
    LEFT JOIN non_current_assets AS gw
        ON a.ticker = gw.ticker 
        AND gw.name  = 'Goodwill'
    LEFT JOIN non_current_assets AS ia 
        ON a.ticker = ia.ticker 
        AND ia.name  = 'Intangible Assets, Net(Excluding Goodwill)'
    LEFT JOIN non_current_assets AS ppe
        ON a.ticker = ppe.ticker
        AND ppe.name = 'Property, Plant and Equipment, Net'
    LEFT JOIN non_current_assets AS rou
        ON a.ticker = rou.ticker
        AND rou.name = 'Operating Lease, Right-of-Use Asset'
    LEFT JOIN non_current_assets AS ona
        ON a.ticker = ona.ticker
        AND ona.name = 'Other Assets, Noncurrent'
    WHERE
        a.name = 'Assets'
)
-- Current assets output
SELECT
    ticker,
    name,
    date,
    value,
    TRUE AS current
FROM
    calculated_cash
UNION ALL
SELECT
    ticker,
    name,
    date,
    value,
    TRUE
FROM
    current_assets
WHERE
    name IN(
        'Accounts Receivable, after Allowance for Credit Loss, Current', 'Inventory, Net',
        'Prepaid Expense and Other Assets, Current'
    )
UNION ALL
SELECT
    ticker,
    name,
    date,
    value,
    TRUE
FROM
    other_current_assets
-- Non-current assets output
UNION ALL
SELECT
    ticker,
    name,
    date,
    value,
    FALSE
FROM
    non_current_assets
WHERE
    name IN(
        'Goodwill', 'Intangible Assets, Net(Excluding Goodwill)', 'Property, Plant and Equipment, Net',
        'Operating Lease, Right-of-Use Asset', 'Other Assets, Noncurrent'
    )
UNION ALL
SELECT
    ticker,
    name,
    date,
    value,
    FALSE
FROM
    other_non_current_assets
ORDER BY
    current DESC,
    ticker ASC,
    name ASC;


-- Liabilities table -----------------------------------------------------


SELECT '=== Loading balance_sheet_liability_decomposition_mart TABLE ===' AS info;
CREATE TABLE dw_stock_dashboard.financials_schema.balance_sheet_liability_decomposition_mart(
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    current BOOLEAN
);

INSERT INTO dw_stock_dashboard.financials_schema.balance_sheet_liability_decomposition_mart(
    ticker,
    name,
    date,
    value,
    current
)
WITH latest_date AS(
    SELECT
        ticker,
        name,
        date,
        value,
        MAX(date) OVER(PARTITION BY ticker) AS latest_date
    FROM
        dw_stock_dashboard.main.quarterly_balance_sheets_fact
),
-- Current liabilities
current_liabilities AS(
    SELECT
        ticker,
        name,
        date,
        value
    FROM
        latest_date
    WHERE
        date = latest_date
        AND name IN(
            'Accounts Payable, Current',
            'Accrued Liabilities, Current',
            'Operating Lease, Liability, Current',
            'Long-term Debt, Current Maturities',
            'Liabilities, Current'
        )
),
other_current_liabilities AS(
    SELECT
        cl.ticker,
        cl.date,
        'Other Current Liabilities' AS name,
        GREATEST(
            cl.value
            - COALESCE(ap.value, 0)
            - COALESCE(al.value, 0)
            - COALESCE(ol.value, 0)
            - COALESCE(ltd.value, 0)
        , 0) AS value
    FROM
        current_liabilities AS cl
        LEFT JOIN current_liabilities AS ap 
            ON cl.ticker = ap.ticker 
            AND ap.name  = 'Accounts Payable, Current'
        LEFT JOIN current_liabilities AS al 
            ON cl.ticker = al.ticker 
            AND al.name  = 'Accrued Liabilities, Current'
        LEFT JOIN current_liabilities AS ol 
            ON cl.ticker = ol.ticker 
            AND ol.name  = 'Operating Lease, Liability, Current'
        LEFT JOIN current_liabilities AS ltd
            ON cl.ticker = ltd.ticker
            AND ltd.name = 'Long-term Debt, Current Maturities'
    WHERE
        cl.name = 'Liabilities, Current'
),
-- Non-current liabilities
non_current_liabilities AS(
    SELECT
        ticker,
        name,
        date,
        value
    FROM
        latest_date
    WHERE
        date = latest_date
        AND name IN(
            'Liabilities', 'Liabilities, Current', 'Assets', 'Stockholders'' Equity Attributable to Parent',
            'Long-term Debt, Excluding Current Maturities', 'Operating Lease, Liability, Noncurrent',
            'Other Liabilities, Noncurrent'
        )
),
calculated_liabilities_total AS(
    SELECT
        ticker,
        date,
        COALESCE(
            NULLIF(MAX(CASE WHEN name = 'Liabilities' THEN value END), 0),
            MAX(CASE WHEN name = 'Assets' THEN value ELSE 0 END) -
            MAX(CASE WHEN name = 'Stockholders'' Equity Attributable to Parent' THEN value ELSE 0 END)
        ) AS total_liabilities
    FROM
        non_current_liabilities
    GROUP BY
        ticker,
        date
),
other_non_current_liabilities AS(
    SELECT
        lt.ticker,
        lt.date,
        'Other Non-Current Liabilities' AS name,
        GREATEST(
        (lt.total_liabilities - cl.value)
            - COALESCE(ltd.value, 0)
            - COALESCE(ol.value, 0)
            - COALESCE(onl.value, 0)
        , 0) AS value
    FROM
        calculated_liabilities_total AS lt
        JOIN non_current_liabilities AS cl 
            ON lt.ticker = cl.ticker 
            AND cl.name  = 'Liabilities, Current'
        LEFT JOIN non_current_liabilities AS ltd
            ON lt.ticker = ltd.ticker
            AND ltd.name = 'Long-term Debt, Excluding Current Maturities'
        LEFT JOIN non_current_liabilities AS ol 
            ON lt.ticker = ol.ticker 
            AND ol.name  = 'Operating Lease, Liability, Noncurrent'
        LEFT JOIN non_current_liabilities AS onl
            ON lt.ticker = onl.ticker
            AND onl.name = 'Other Liabilities, Noncurrent'
)
-- Current liabilities output
SELECT
    ticker,
    name,
    date,
    value,
    TRUE AS current
FROM
    current_liabilities
WHERE
    name IN(
        'Accounts Payable, Current', 'Accrued Liabilities, Current', 'Operating Lease, Liability, Current',
        'Long-term Debt, Current Maturities'
    )
UNION ALL
SELECT
    ticker,
    name,
    date,
    value,
    TRUE
FROM
    other_current_liabilities
-- Non-current liabilities output
UNION ALL
SELECT
    ticker,
    name,
    date,
    value,
    FALSE
FROM
    non_current_liabilities
WHERE
    name IN(
        'Long-term Debt, Excluding Current Maturities', 'Operating Lease, Liability, Noncurrent',
        'Other Liabilities, Noncurrent'
    )
UNION ALL
SELECT
    ticker,
    name,
    date,
    value,
    FALSE
FROM
    other_non_current_liabilities
ORDER BY
    current DESC,
    ticker ASC,
    name ASC;