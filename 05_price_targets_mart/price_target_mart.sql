DROP SCHEMA IF EXISTS price_target_schema CASCADE;
CREATE SCHEMA IF NOT EXISTS price_target_schema;

SELECT '=== Loading price_target_mart TABLE ===' AS info;
CREATE VIEW dw_stock_dashboard.price_target_schema.price_target_mart AS 
SELECT 
    * 
FROM 
    dw_stock_dashboard.main.wall_street_estimate_fact;