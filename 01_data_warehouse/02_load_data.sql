SELECT '=== Dropping Tables ===' AS info;
DROP TABLE IF EXISTS prices_fact;
DROP TABLE IF EXISTS wall_street_estimate_fact;
DROP TABLE IF EXISTS quarterly_income_statements_fact;
DROP TABLE IF EXISTS quarterly_cash_flows_fact;
DROP TABLE IF EXISTS quarterly_balance_sheets_fact;
DROP TABLE IF EXISTS yearly_income_statements_fact;
DROP TABLE IF EXISTS yearly_cash_flows_fact;
DROP TABLE IF EXISTS yearly_balance_sheets_fact;
DROP TABLE IF EXISTS company_dim;

CREATE TABLE IF NOT EXISTS company_dim(
    ticker VARCHAR PRIMARY KEY,
    company_name VARCHAR,
    type VARCHAR,
    country VARCHAR,
    region VARCHAR,
    exchange VARCHAR,
    currency VARCHAR,
    industry VARCHAR,
    sector VARCHAR,
    outstanding_shares BIGINT
);
SELECT '=== Loading company_dim TABLE ===' AS info;
INSERT INTO company_dim(
    ticker,
    company_name,
    type,
    country,
    region,
    exchange,
    currency,
    industry,
    sector,
    outstanding_shares
)
SELECT
    ticker,
    company_name,
    type,
    country,
    region,
    exchange,
    currency,
    industry,
    sector,
    outstanding_shares
FROM
    read_csv('datasets/company_dim.csv', AUTO_DETECT=TRUE);


CREATE TABLE IF NOT EXISTS prices_fact(
    price_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    date DATE,
    closing_price DOUBLE,
    opening_price DOUBLE,
    highest_price DOUBLE,
    lowest_price DOUBLE,
    volume BIGINT,
    FOREIGN KEY(ticker) REFERENCES company_dim(ticker)
);
SELECT '=== Loading prices_fact TABLE ===' AS info;
INSERT INTO prices_fact(
    price_id,
    ticker,
    date,
    closing_price,
    opening_price,
    highest_price,
    lowest_price,
    volume
)
SELECT
    ROW_NUMBER() OVER (ORDER BY date ASC) AS price_id,
    Ticker,
    Date,
    Close,  
    High,
    Low,
    Open,
    Volume
FROM
    read_csv('datasets/prices_fact.csv', AUTO_DETECT=TRUE);


CREATE TABLE IF NOT EXISTS wall_street_estimate_fact(
    estimate_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    current_price DOUBLE,
    highest_forecast DOUBLE,
    average_forecast DOUBLE,
    lowest_forecast DOUBLE,
    median_forecast DOUBLE,
    FOREIGN KEY(ticker) REFERENCES company_dim(ticker)
);
SELECT '=== Loading wall_street_estimate_fact TABLE ===' AS info;
INSERT INTO wall_street_estimate_fact(
    estimate_id,
    ticker,
    current_price,
    highest_forecast,
    average_forecast,
    lowest_forecast,
    median_forecast
)
SELECT
    ROW_NUMBER() OVER (ORDER BY ticker ASC) AS price_id,
    ticker,
    current,
    high,
    low,
    mean,
    median,
FROM
    read_csv('datasets/wall_street_estimate_fact.csv', AUTO_DETECT=TRUE);


CREATE TABLE IF NOT EXISTS quarterly_income_statements_fact(
    financials_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    FOREIGN KEY(ticker) REFERENCES company_dim(ticker)
);
SELECT '=== Loading quarterly_income_statements_fact TABLE ===' AS info;
INSERT INTO quarterly_income_statements_fact(
    financials_id,
    ticker,
    name,
    date,
    value
)
SELECT
    ROW_NUMBER() OVER (ORDER BY date, ticker ASC) AS price_id,
    ticker,
    name,
    date,
    value
FROM
    read_csv('datasets/quarterly/quarterly_income_statements_fact.csv', AUTO_DETECT=TRUE);


CREATE TABLE IF NOT EXISTS quarterly_cash_flows_fact(
    financials_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    FOREIGN KEY(ticker) REFERENCES company_dim(ticker)
);
SELECT '=== Loading quarterly_cash_flows_fact TABLE ===' AS info;
INSERT INTO quarterly_cash_flows_fact(
    financials_id,
    ticker,
    name,
    date,
    value
)
SELECT
    ROW_NUMBER() OVER (ORDER BY date, ticker ASC) AS price_id,
    ticker,
    name,
    date,
    value
FROM
    read_csv('datasets/quarterly/quarterly_cash_flows_fact.csv', AUTO_DETECT=TRUE);


CREATE TABLE IF NOT EXISTS quarterly_balance_sheets_fact(
    financials_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    FOREIGN KEY(ticker) REFERENCES company_dim(ticker)
);
SELECT '=== Loading quarterly_balance_sheets_fact TABLE ===' AS info;
INSERT INTO quarterly_balance_sheets_fact(
    financials_id,
    ticker,
    name,
    date,
    value
)
SELECT
    ROW_NUMBER() OVER (ORDER BY date, ticker ASC) AS price_id,
    ticker,
    name,
    date,
    value
FROM
    read_csv('datasets/quarterly/quarterly_balance_sheets_fact.csv', AUTO_DETECT=TRUE);


CREATE TABLE IF NOT EXISTS yearly_income_statements_fact(
    financials_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    FOREIGN KEY(ticker) REFERENCES company_dim(ticker)
);
SELECT '=== Loading yearly_income_statements_fact TABLE ===' AS info;
INSERT INTO yearly_income_statements_fact(
    financials_id,
    ticker,
    name,
    date,
    value
)
SELECT
    ROW_NUMBER() OVER (ORDER BY date, ticker ASC) AS price_id,
    ticker,
    name,
    date,
    value
FROM
    read_csv('datasets/yearly/yearly_income_statements_fact.csv', AUTO_DETECT=TRUE);


CREATE TABLE IF NOT EXISTS yearly_cash_flows_fact(
    financials_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    FOREIGN KEY(ticker) REFERENCES company_dim(ticker)
);
SELECT '=== Loading yearly_cash_flows_fact TABLE ===' AS info;
INSERT INTO yearly_cash_flows_fact(
    financials_id,
    ticker,
    name,
    date,
    value
)
SELECT
    ROW_NUMBER() OVER (ORDER BY date, ticker ASC) AS price_id,
    ticker,
    name,
    date,
    value
FROM
    read_csv('datasets/yearly/yearly_cash_flows_fact.csv', AUTO_DETECT=TRUE);


CREATE TABLE IF NOT EXISTS yearly_balance_sheets_fact(
    financials_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date DATE,
    value DOUBLE,
    FOREIGN KEY(ticker) REFERENCES company_dim(ticker)
);
SELECT '=== Loading yearly_balance_sheets_fact TABLE ===' AS info;
INSERT INTO yearly_balance_sheets_fact(
    financials_id,
    ticker,
    name,
    date,
    value
)
SELECT
    ROW_NUMBER() OVER (ORDER BY date, ticker ASC) AS price_id,
    ticker,
    name,
    date,
    value
FROM
    read_csv('datasets/yearly/yearly_balance_sheets_fact.csv', AUTO_DETECT=TRUE);