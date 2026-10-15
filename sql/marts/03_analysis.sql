-- a. Which firms are high contributors to serious recalls and also have a high Class I percentage?
-- Business question: Within each state, which firms rank in the top three by number of 
--     Class I recalls and also have a Class I recall percentage above their state's overall percentage?
-- Business purpose: Distinguish firms that contribute a large number of serious recall records
--     and have a higher serious-recall proportion than the state overall. This could help prioritize which firms warrant further supplier review.

SELECT *
FROM analytics.classI_recalls_within_state
JOIN analytics.classI_percent_per_state 
ON analytics.classI_recalls_within_state.state = analytics.classI_percent_per_state.state; 