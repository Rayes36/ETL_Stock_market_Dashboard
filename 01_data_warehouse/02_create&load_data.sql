CREATE TABLE IF NOT EXISTS company_dim(
    company_id INTEGER PRIMARY KEY,
    company_name VARCHAR,
    ticker VARCHAR,
    type VARCHAR,
    country VARCHAR,
    region VARCHAR,
    exchange VARCHAR,
    currency VARCHAR,
    industry VARCHAR,
    sector VARCHAR,
    outstanding_shares INTEGER
);

CREATE TABLE IF NOT EXISTS prices_fact(
    company_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    date TIMESTAMP,
    closing_price DOUBLE,
    opening_price DOUBLE,
    highest_price DOUBLE,
    lowest_price DOUBLE,
    opening_price DOUBLE,
    volume INTEGER,
    FOREIGN KEY(company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE IF NOT EXISTS wall_street_estimate_fact(
    company_id INTEGER PRIMARY KEY
    ticker VARCHAR,
    current_price DOUBLE,
    highest_forecast DOUBLE,
    average_forecast DOUBLE,
    lowest_forecast DOUBLE,
    median_forecast DOUBLE,
    FOREIGN KEY(company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE IF NOT EXISTS ttm_income_statements_fact(
    company_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date TIMESTAMP,
    value DOUBLE,
    FOREIGN KEY(company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE IF NOT EXISTS ttm_cash_flow_fact(
    company_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date TIMESTAMP,
    value DOUBLE,
    FOREIGN KEY(company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE IF NOT EXISTS ttm_balance_sheet_fact(
    company_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date TIMESTAMP,
    value DOUBLE,
    FOREIGN KEY(company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE IF NOT EXISTS yearly_income_statements_fact(
    company_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date TIMESTAMP,
    value DOUBLE,
    FOREIGN KEY(company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE IF NOT EXISTS yearly_cash_flow_fact(
    company_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date TIMESTAMP,
    value DOUBLE,
    FOREIGN KEY(company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE IF NOT EXISTS yearly_balance_sheet_fact(
    company_id INTEGER PRIMARY KEY,
    ticker VARCHAR,
    name VARCHAR,
    date TIMESTAMP,
    value DOUBLE,
    FOREIGN KEY(company_id) REFERENCES company_dim(company_id)
);