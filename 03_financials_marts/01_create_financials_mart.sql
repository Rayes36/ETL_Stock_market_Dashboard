DROP SCHEMA IF EXISTS financials_schema CASCADE;
CREATE SCHEMA IF NOT EXISTS financials_schema;

SELECT '=== Loading TTM, quarterly, and yearly financials mart TABLE ===' AS info;
CREATE TABLE dw_stock_dashboard.financials_schema.ttm_financials_mart(
    ticker VARCHAR,
    date DATE,
    total_revenue DOUBLE,
    operating_income DOUBLE,
    net_income DOUBLE,
    eps_diluted DOUBLE,
    operating_cash_flow DOUBLE,
    capital_expenditures DOUBLE,
    free_cash_flow DOUBLE
);
INSERT INTO dw_stock_dashboard.financials_schema.ttm_financials_mart(
    ticker,
    date,
    total_revenue,
    operating_income,
    net_income,
    eps_diluted,
    operating_cash_flow,
    capital_expenditures,
    free_cash_flow
)
WITH ttm_value AS(
    SELECT
        ticker,
        name,
        date,
        SUM(value) OVER(
            PARTITION BY ticker
            ORDER BY date
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS ttm_value
    FROM
        dw_stock_dashboard.main.quarterly_income_statements_fact
    WHERE
        name = 'Total Revenue'

    UNION ALL
    SELECT
        ticker,
        name,
        date,
        SUM(value) OVER(
            PARTITION BY ticker 
            ORDER BY date 
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS ttm_value
    FROM
        dw_stock_dashboard.main.quarterly_income_statements_fact
    WHERE
        name = 'Operating Income (Loss)'

    UNION ALL
    SELECT
        ticker,
        name,
        date,
        SUM(value) OVER(
            PARTITION BY ticker 
            ORDER BY date 
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS ttm_value
    FROM
        dw_stock_dashboard.main.quarterly_income_statements_fact
    WHERE
        name = 'Net Income (Loss) Attributable to Parent'

    UNION ALL
    SELECT
        ticker,
        name,
        date,
        ROUND(
            SUM(value) OVER(
                PARTITION BY ticker 
                ORDER BY date 
                ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
            ), 3
        ) AS ttm_value
    FROM
        dw_stock_dashboard.main.quarterly_income_statements_fact
    WHERE
        name = 'Earnings Per Share, Diluted'

    UNION ALL
    SELECT
        ticker,
        name,
        date,
        SUM(value) OVER(
            PARTITION BY ticker 
            ORDER BY date 
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS ttm_value
    FROM
        dw_stock_dashboard.main.quarterly_cash_flows_fact
    WHERE
        name = 'Net Cash Provided by (Used in) Operating Activities'

    UNION ALL
    SELECT
        ticker,
        name,
        date,
        SUM(value) OVER(
            PARTITION BY ticker 
            ORDER BY date 
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS ttm_value
    FROM
        dw_stock_dashboard.main.quarterly_cash_flows_fact
    WHERE
        name = 'Capital Expenditures'
),
long_to_wide AS(
    SELECT
        ticker,
        date,
        MAX(CASE WHEN name = 'Total Revenue' THEN ttm_value END) AS total_revenue,
        MAX(CASE WHEN name = 'Operating Income (Loss)' THEN ttm_value END) AS operating_income,
        MAX(CASE WHEN name = 'Net Income (Loss) Attributable to Parent' THEN ttm_value END) AS net_income,
        MAX(CASE WHEN name = 'Earnings Per Share, Diluted' THEN ttm_value END) AS eps_diluted,
        MAX(CASE WHEN name = 'Net Cash Provided by (Used in) Operating Activities' THEN ttm_value END) AS operating_cash_flow,
        MAX(CASE WHEN name = 'Capital Expenditures' THEN ttm_value END) AS capital_expenditures
    FROM
        ttm_value
    GROUP BY
        ticker,
        date
)
SELECT
    ticker,
    date,
    total_revenue,
    operating_income,
    net_income,
    eps_diluted,
    operating_cash_flow,
    capital_expenditures,
    
    -- addition is used because capex data is negative and OCF is positive
    CASE
        WHEN operating_cash_flow IS NULL OR capital_expenditures IS NULL THEN 0
        ELSE operating_cash_flow + capital_expenditures
    END AS free_cash_flow
FROM
    long_to_wide
ORDER BY
    ticker ASC,
    date DESC;



-- quarterly section ---------------------------------------------------------

CREATE TABLE dw_stock_dashboard.financials_schema.quarterly_financials_mart(
    ticker VARCHAR,
    date DATE,
    total_revenue DOUBLE,
    operating_income DOUBLE,
    net_income DOUBLE,
    eps_diluted DOUBLE,
    operating_cash_flow DOUBLE,
    capital_expenditures DOUBLE,
    free_cash_flow DOUBLE
);
INSERT INTO dw_stock_dashboard.financials_schema.quarterly_financials_mart(
    ticker,
    date,
    total_revenue,
    operating_income,
    net_income,
    eps_diluted,
    operating_cash_flow,
    capital_expenditures,
    free_cash_flow
)
WITH get_value AS(
    SELECT
        ticker,
        name,
        date,
        value
    FROM
        dw_stock_dashboard.main.quarterly_income_statements_fact
    WHERE
        name IN(
            'Total Revenue', 'Operating Income (Loss)', 'Net Income (Loss) Attributable to Parent',
            'Earnings Per Share, Diluted'
        )
    
    UNION ALL
    SELECT
        ticker,
        name,
        date,
        value
    FROM
        dw_stock_dashboard.main.quarterly_cash_flows_fact
    WHERE
        name IN(
            'Net Cash Provided by (Used in) Operating Activities', 'Capital Expenditures'
        )
),
long_to_wide AS(
    SELECT
        ticker,
        date,
        MAX(CASE WHEN name = 'Total Revenue' THEN value END) AS total_revenue,
        MAX(CASE WHEN name = 'Operating Income (Loss)' THEN value END) AS operating_income,
        MAX(CASE WHEN name = 'Net Income (Loss) Attributable to Parent' THEN value END) AS net_income,
        MAX(CASE WHEN name = 'Earnings Per Share, Diluted' THEN value END) AS eps_diluted,
        MAX(CASE WHEN name = 'Net Cash Provided by (Used in) Operating Activities' THEN value END) AS operating_cash_flow,
        MAX(CASE WHEN name = 'Capital Expenditures' THEN value END) AS capital_expenditures
    FROM
        get_value
    GROUP BY
        ticker,
        date
)
SELECT
    ticker,
    date,
    total_revenue,
    operating_income,
    net_income,
    ROUND(eps_diluted, 3) AS eps_diluted,
    operating_cash_flow,
    capital_expenditures,
    
    -- addition is used because capex data is negative and OCF is positive
    CASE 
        WHEN operating_cash_flow IS NULL OR capital_expenditures IS NULL THEN 0
        ELSE operating_cash_flow + capital_expenditures
    END AS free_cash_flow
FROM
    long_to_wide
ORDER BY
    ticker ASC,
    date DESC;



-- yearly section ---------------------------------------------------------

CREATE TABLE dw_stock_dashboard.financials_schema.yearly_financials_mart(
    ticker VARCHAR,
    date DATE,
    total_revenue DOUBLE,
    operating_income DOUBLE,
    net_income DOUBLE,
    eps_diluted DOUBLE,
    operating_cash_flow DOUBLE,
    capital_expenditures DOUBLE,
    free_cash_flow DOUBLE
);
INSERT INTO dw_stock_dashboard.financials_schema.yearly_financials_mart(
    ticker,
    date,
    total_revenue,
    operating_income,
    net_income,
    eps_diluted,
    operating_cash_flow,
    capital_expenditures,
    free_cash_flow
)
WITH get_value AS(
    SELECT
        ticker,
        name,
        date,
        value
    FROM
        dw_stock_dashboard.main.yearly_income_statements_fact
    WHERE
        name IN(
            'Total Revenue', 'Operating Income (Loss)', 'Net Income (Loss) Attributable to Parent',
            'Earnings Per Share, Diluted'
        )
    
    UNION ALL
    SELECT
        ticker,
        name,
        date,
        value
    FROM
        dw_stock_dashboard.main.yearly_cash_flows_fact
    WHERE
        name = 'Net Cash Provided by (Used in) Operating Activities'
),
annual_capex_from_quarters AS (
    SELECT
        ticker,
        YEAR(date) AS capex_year,
        SUM(value) AS capital_expenditures
    FROM
        dw_stock_dashboard.main.quarterly_cash_flows_fact
    WHERE
        name = 'Capital Expenditures'
    GROUP BY
        ticker,
        YEAR(date)
    HAVING
        COUNT(value) = 4
),
long_to_wide AS(
    SELECT
        ticker,
        date,
        MAX(CASE WHEN name = 'Total Revenue' THEN value END) AS total_revenue,
        MAX(CASE WHEN name = 'Operating Income (Loss)' THEN value END) AS operating_income,
        MAX(CASE WHEN name = 'Net Income (Loss) Attributable to Parent' THEN value END) AS net_income,
        MAX(CASE WHEN name = 'Earnings Per Share, Diluted' THEN value END) AS eps_diluted,
        MAX(CASE WHEN name = 'Net Cash Provided by (Used in) Operating Activities' THEN value END) AS operating_cash_flow
    FROM
        get_value
    GROUP BY
        ticker,
        date
)
SELECT
    ltw.ticker,
    ltw.date,
    ltw.total_revenue,
    ltw.operating_income,
    ltw.net_income,
    ltw.eps_diluted,
    ltw.operating_cash_flow,
    ac.capital_expenditures,
    
    -- addition is used because capex data is negative and OCF is positive
    CASE 
        WHEN ltw.operating_cash_flow IS NULL OR ac.capital_expenditures IS NULL THEN NULL
        ELSE ltw.operating_cash_flow + ac.capital_expenditures
    END AS free_cash_flow
FROM
    long_to_wide AS ltw
LEFT JOIN annual_capex_from_quarters AS ac
    ON ltw.ticker = ac.ticker
    AND YEAR(ltw.date) = ac.capex_year
ORDER BY
    ltw.ticker ASC,
    ltw.date DESC;