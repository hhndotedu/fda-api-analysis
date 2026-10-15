-- Scenario: Your hospital's supply chain team wants a high-level overview of recalled 
-- products to understand which classification experience the most recalls.
-- What you would analyze

--a. Number of recalls by classification 
DROP MATERIALIZED VIEW IF EXISTS analytics.recalls_count_by_classification; 
CREATE MATERIALIZED VIEW analytics.recalls_count_by_classification
AS 
SELECT classification, 
      COUNT(*) AS total_recall_count 
FROM analytics.stg_recalls 
GROUP BY classification
ORDER BY classification ASC; 

--b. TOP 10 Countries with the most classification I recalls and number of recalls 
DROP MATERIALIZED VIEW IF EXISTS analytics.recalls_count_by_country;
CREATE MATERIALIZED VIEW analytics.recalls_count_by_country
AS 
SELECT country, 
    COUNT(*) AS total_recall_count
FROM analytics.stg_recalls
WHERE classification = 'Class I'
GROUP BY country
ORDER BY COUNT(*) DESC
LIMIT 10; 

-- c. Recalling firms and count number of each classification
DROP MATERIALIZED VIEW IF EXISTS analytics.classification_count_by_firm;
CREATE MATERIALIZED VIEW analytics.classification_count_by_firm
AS 

SELECT state, 
    recalling_firm,
    COUNT(CASE WHEN classification = 'Class I' THEN 1 END) AS class_1,
    COUNT(CASE WHEN classification = 'Class II' THEN 1 END) AS class_2,
    COUNT(CASE WHEN classification = 'Class III' THEN 1 END) AS class_3    
 FROM analytics.stg_recalls
 GROUP BY state, recalling_firm
 ORDER BY class_1 DESC;

 SELECT * FROM analytics.classification_count_by_firm;

