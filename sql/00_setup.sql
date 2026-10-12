-- SELECT
--     column_name,
--     data_type
-- FROM information_schema.columns
-- WHERE table_name = 'raw_data';


-- create a JSON as a table 
-- SELECT
--     "index",
--     raw_data ->> 'recall_number' AS recall_number,
--     raw_data ->> 'status' AS status,
--     raw_data ->> 'classification' AS classification,
--     raw_data ->> 'recalling_firm' AS recalling_firm,
--     raw_data ->> 'product_description' AS product_description,
--     raw_data ->> 'reason_for_recall' AS reason_for_recall
-- FROM raw_data
-- LIMIT 10;


-- Create a schema, help to organize your table 
DROP SCHEMA IF EXISTS analytics CASCADE;
CREATE SCHEMA analytics;

