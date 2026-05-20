-- .read build_dw&mart.sql

-- =============================================================================
-- SECTION 1: DATA WAREHOUSE LAYER (Ingestion)
-- Purpose: Ingest, clean, and structure raw data into core warehouse tables.
-- =============================================================================

-- Extract and load raw source data
.read 01_data_warehouse/02_load_data.sql


-- =============================================================================
-- SECTION 2: DATA MARTS LAYER (Analytics & Reporting)
-- Purpose: Transform core warehouse data into business-facing star schemas 
--          and aggregated views for specific business domains.
-- =============================================================================

-- 02. Pricing & Market Trend Marts
-- Generates moving averages and market dip analytics
.read 02_prices_marts/01_create_five_year_moving_average_mart.sql
.read 02_prices_marts/02_create_dip_mart.sql

-- 03. Financial Reporting Marts
-- Consolidates core financial statements, expenses, and balance sheets
.read 03_financials_marts/01_create_financials_mart.sql
.read 03_financials_marts/02_create_expenses_breakdown_mart.sql
.read 03_financials_marts/03_create_balance_sheet_decomposition_mart.sql

-- 04. Operational Efficiency & Cash Flow Marts
-- Tracks Free Cash Flow (FCF) metrics, margins, and earnings drivers
.read 04_efficiency_marts/01_create_fcf_analysis_mart.sql
.read 04_efficiency_marts/02_create_fcf_margin_analysis_mart.sql
.read 04_efficiency_marts/03_create_earnings_waterfall.sql


-- =============================================================================
-- SECTION 3: PRICE TARGET MARTS
-- Purpose: Create price target schema and view to wallstreet analyst estimates.
-- =============================================================================

-- 05. Create schema and analyst price target mart view
.read 05_price_targets_mart/price_target_mart.sql