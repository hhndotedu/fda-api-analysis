-- Which states and recalling firms contribute the most Class I recalls?
-- Business question: Within each state, find the TOP 3 recalling firms have the most Class I recalls?
-- Business purpose: Identify firms that contribute substantially to the serious recall records associated with particular states, potentially helping a hospital prioritize supplier monitoring.
-- SQL skills: Grouping by multiple columns, conditional counting, sorting, and optionally using ROW_NUMBER() or RANK() to identify the top firms within each state.

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
     RANK() OVER (PARTITION BY state ORDER BY classification_1 ASC) as recall_rank
FROM state_firm)

SELECT state, 
    recalling_firm, 
    classification_1,
    recall_rank
FROM rank_firm
WHERE recall_rank <= 3 AND state IS NOT NULL;

