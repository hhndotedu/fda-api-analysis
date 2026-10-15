-- 01_overview_stats.sql 
--a. Number of recalls by classification 
REFRESH MATERIALIZED VIEW analytics.recalls_count_by_classification; 
--b.TOP 10 Countries with number of recalls 
REFRESH MATERIALIZED VIEW analytics.recalls_count_by_country; 
--c.Recalling firms and number of each classification recall
REFRESH MATERIALIZED VIEW analytics.classification_count_by_firm; 

-- 02_detail_info.sql 
--a. Which firms contribute the most serious recall records? - TOP 3 of firms with highest class I recalls within each state
REFRESH MATERIALIZED VIEW analytics.classI_recalls_within_state; 
--b. Which states have the highest proportion of serious recalls? - States with highest class I recall percentage
REFRESH MATERIALIZED VIEW analytics.classI_percent_per_state; 
--c. Which firms have the highest proportion of serious recalls? - TOP 1 of firms with highest class I recall percentage within each state
REFRESH MATERIALIZED VIEW analytics.classI_percent_firm_per_state; 