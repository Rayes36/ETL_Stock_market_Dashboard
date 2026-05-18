DROP SCHEMA IF EXISTS analytic_schema CASCADE;
CREATE SCHEMA IF NOT EXISTS analytic_schema;

SELECT '=== Loading fifty_two_week_dip_mart TABLE ===' AS info;
CREATE OR REPLACE TABLE dw_stock_dashboard.analytic_schema.fifty_two_week_dip_mart AS
WITH ranked_prices AS(
    SELECT
        ticker,
        closing_price,
        highest_price,
        lowest_price,
        date,
        ROW_NUMBER() OVER(PARTITION BY ticker ORDER BY date DESC) as rank,
        MAX(date) OVER(PARTITION BY ticker) as ticker_latest_date 
    FROM 
        dw_stock_dashboard.main.prices_fact
),
get_highest_and_lowest_price_in_52wk AS(
    SELECT 
        ticker,
        MAX(highest_price) AS highest_52wk_price,
        MIN(lowest_price) AS lowest_52wk_price
    FROM 
        ranked_prices
    WHERE 
        date >= ticker_latest_date - INTERVAL '52 WEEK'
    GROUP BY 
        ticker
)
SELECT 
    rp.ticker,
    rp.closing_price AS latest_closing_price,
    hl52.highest_52wk_price,
    hl52.lowest_52wk_price
FROM 
    ranked_prices AS rp
INNER JOIN get_highest_and_lowest_price_in_52wk AS hl52
    ON rp.ticker = hl52.ticker
WHERE 
    rp.rank = 1;