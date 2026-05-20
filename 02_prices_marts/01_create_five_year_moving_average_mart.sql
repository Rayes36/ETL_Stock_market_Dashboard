DROP SCHEMA IF EXISTS prices_schema CASCADE;
CREATE SCHEMA IF NOT EXISTS prices_schema;

SELECT '=== Loading five_year_moving_average_price TABLE ===' AS info;
CREATE TABLE dw_stock_dashboard.prices_schema.five_year_moving_average_price_mart(
    ticker VARCHAR,
    date DATE,
    closing_price DOUBLE,
    ma_5_year DOUBLE
);

INSERT INTO dw_stock_dashboard.prices_schema.five_year_moving_average_price_mart(
    ticker,
    date,
    closing_price,
    ma_5_year
)
SELECT
    ticker,
    date,
    closing_price,
    AVG(closing_price) OVER(
        PARTITION BY ticker
        ORDER BY date
        RANGE BETWEEN INTERVAL '5 YEAR' PRECEDING AND CURRENT ROW
    ) AS ma_5_year
FROM
    dw_stock_dashboard.main.prices_fact
ORDER BY
    date DESC,
    ticker ASC;