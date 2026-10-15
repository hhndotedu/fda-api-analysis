-- a. Which states and recalling firms contribute the most Class I recalls?
-- Business question: Within each state, find the TOP 3 recalling 
--   firms have the most Class I recalls?
-- Business purpose: Identify firms that contribute substantially 
--   to the serious recall records associated with particular states, 
--   potentially helping a hospital prioritize supplier monitoring.

DROP MATERIALIZED VIEW IF EXISTS analytics.classI_recalls_within_state;
CREATE MATERIALIZED VIEW analytics.classI_recalls_within_state
AS 

WITH state_firm AS 
(SELECT state, 
     recalling_firm,
     COUNT(*) as classification_1
FROM analytics.stg_recalls
WHERE classification = 'Class I'
GROUP BY state, recalling_firm
ORDER BY state, classification_1 ASC), 

rank_firm AS 
(SELECT state,
     recalling_firm,
     classification_1,
     RANK() OVER (PARTITION BY state ORDER BY classification_1 ASC) AS recall_rank
FROM state_firm)

SELECT state, 
    recalling_firm, 
    classification_1,
    recall_rank
FROM rank_firm
WHERE recall_rank <= 3 AND state IS NOT NULL;

-- b. Which states have the highest proportion of Class I recalls?
-- Business question: Among states with at least 20 recall records, 
--   which have the highest percentage of recalls classified as Class I?
-- Business purpose: Compare recall severity across states while 
--   accounting for differences in their total recall counts.

DROP MATERIALIZED VIEW IF EXISTS analytics.classI_percent_per_state;
CREATE MATERIALIZED VIEW analytics.classI_percent_per_state
AS 

SELECT state,
     COUNT(*) as total_recalls,
     COUNT(CASE WHEN classification = 'Class I' THEN 1 END) AS class_I_recalls, 
     ROUND(COUNT(CASE WHEN classification = 'Class I' THEN 1 END) * 100 / COUNT(*),2) AS class_I_percent
FROM analytics.stg_recalls
WHERE state IS NOT NULL
GROUP BY state
HAVING COUNT(*) >= 20 -- avoid states with low recalls 
ORDER BY state; 

-- c. Which recalling firms have the highest proportion of Class I recalls within each state?
-- Business question: Among recalling firms with at least 20 recall records in a state, 
--   which firms have the highest percentage of Class I recalls?
-- Business purpose: Identify firms whose recalls are disproportionately classified 
--   as serious, rather than simply identifying firms with the largest number of recalls. 
--   This could help a hospital prioritize supplier risk reviews alongside overall recall volume.

DROP MATERIALIZED VIEW IF EXISTS analytics.classI_percent_firm_per_state;
CREATE MATERIALIZED VIEW analytics.classI_percent_firm_per_state
AS 

WITH state_firm_classI AS 
(SELECT state,
     recalling_firm,
     COUNT (*) AS total_recalls, 
     COUNT(CASE WHEN classification = 'Class I' THEN 1 END) AS class_I_recalls,
     ROUND(COUNT(CASE WHEN classification = 'Class I' THEN 1 END) * 100.0 / COUNT(*),2) AS class_I_percent
FROM analytics.stg_recalls
WHERE state IS NOT NULL
GROUP BY state, recalling_firm
HAVING COUNT(*) >= 20
ORDER BY class_I_percent DESC), 

rank_firm_classI AS 
(SELECT state,
     recalling_firm,
     total_recalls,
     class_I_recalls, 
     class_I_percent,
     RANK() OVER (PARTITION BY state ORDER BY class_I_percent DESC) AS recall_rank
FROM state_firm_classI)

SELECT state,
     recalling_firm,
     total_recalls,  
     class_I_recalls,
     class_I_percent 
FROM rank_firm_classI
-- Firms that have the highest class I recall percents within each state
WHERE recall_rank <= 1 AND state IS NOT NULL; 


