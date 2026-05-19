SELECT '=== Loading fcf margin mart ===' AS info;
CREATE OR REPLACE TABLE dw_stock_dashboard.analytic_schema.fcf_margin_analysis_mart AS
SELECT
    ist.ticker,
    ist.date,
    
    -- 1. Gross Margin
    MAX(CASE WHEN ist.name = 'Gross Profit' THEN ist.value END) /
    NULLIF(MAX(CASE WHEN ist.name = 'Total Revenue' THEN ist.value END), 0) AS gross_margin,
    
    -- 2. Operating Margin
    MAX(CASE WHEN ist.name = 'Operating Income' THEN ist.value END) /
    NULLIF(MAX(CASE WHEN ist.name = 'Total Revenue' THEN ist.value END), 0) AS operating_margin,

    -- 3. Net Margin
    MAX(CASE WHEN ist.name = 'Net Income' THEN ist.value END) /
    NULLIF(MAX(CASE WHEN ist.name = 'Total Revenue' THEN ist.value END), 0) AS net_margin,
    
    -- 4. FCF Margin
    MAX(CASE WHEN cf.name = 'Free Cash Flow' THEN cf.value END) /
    NULLIF(MAX(CASE WHEN ist.name = 'Total Revenue' THEN ist.value END), 0) AS fcf_margin,
    
    -- 5. ROE
    MAX(CASE WHEN ist.name = 'Net Income' THEN ist.value END) /
    NULLIF(MAX(CASE WHEN bs.name = 'Stockholders Equity' THEN bs.value END), 0) AS roe,
    
    -- 6. ROA
    MAX(CASE WHEN ist.name = 'Net Income' THEN ist.value END) /
    NULLIF(MAX(CASE WHEN bs.name = 'Total Assets' THEN bs.value END), 0) AS roa,
    
    -- 7. ROIC
    MAX(CASE WHEN ist.name = 'EBIT' THEN ist.value END) *
        (1 - COALESCE(
                MAX(CASE WHEN ist.name = 'Tax Rate For Calcs' THEN ist.value END), 
                MAX(CASE WHEN ist.name = 'Tax Provision' THEN ist.value END) / NULLIF(MAX(CASE WHEN ist.name = 'Pretax Income' THEN ist.value END), 0), 
                0
        )) /
    NULLIF(
        COALESCE(MAX(CASE WHEN bs.name = 'Total Debt' THEN bs.value END), 0) +
        COALESCE(MAX(CASE WHEN bs.name = 'Stockholders Equity' THEN bs.value END), 0) -
        COALESCE(MAX(CASE WHEN bs.name = 'Cash And Cash Equivalents' THEN bs.value END), 0), 
    0) AS roic,
    
    -- 8. ROCE
    MAX(CASE WHEN ist.name = 'EBIT' THEN ist.value END) /
    NULLIF(
        COALESCE(MAX(CASE WHEN bs.name = 'Total Assets' THEN bs.value END), 0) - 
        COALESCE(MAX(CASE WHEN bs.name = 'Current Liabilities' THEN bs.value END), 0), 
    0) AS roce
FROM
    dw_stock_dashboard.main.ttm_income_statements_fact AS ist
INNER JOIN dw_stock_dashboard.main.ttm_cash_flow_fact AS cf
    ON cf.ticker = ist.ticker
    AND cf.date = ist.date
INNER JOIN dw_stock_dashboard.main.ttm_balance_sheet_fact AS bs
    ON bs.ticker = ist.ticker
    AND bs.date = ist.date
WHERE
    ist.name IN(
        'Gross Profit',
        'Total Revenue',
        'Operating Income',
        'Net Income',
        'Tax Provision',
        'Pretax Income',
        'Tax Rate For Calcs',
        'EBIT'
    )
    AND cf.name IN(
        'Free Cash Flow'
    )
    AND bs.name IN(
        'Total Assets',
        'Total Debt',
        'Stockholders Equity',
        'Cash And Cash Equivalents',
        'Current Liabilities'
    )
GROUP BY
    ist.ticker,
    ist.date
ORDER BY
    ist.ticker ASC,
    ist.date ASC;