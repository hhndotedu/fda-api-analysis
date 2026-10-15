
DROP VIEW analytics.stg_recalls_quantity;
CREATE OR REPLACE VIEW analytics.stg_recalls_quantity AS
SELECT
    s.source_id,
    s.event_id, 
    s.classification,
    s.product_quantity,

    CASE
        WHEN s.product_quantity IS NOT NULL
         AND TRIM(s.product_quantity) <> ''
         AND UPPER(TRIM(s.product_quantity)) NOT IN ('N/A', 'NA', 'UNKNOWN', 'VARIOUS')
         AND s.product_quantity !~ ';'
         AND s.product_quantity !~* '^[[:space:]]*[a-z][).]'
         AND regexp_match(
                 s.product_quantity,
                 '^[[:space:]]*([0-9][0-9,]*[.]?[0-9]*)[[:space:]]*(.*)$'
             ) IS NOT NULL
        THEN
            REPLACE(
                (regexp_match(
                    s.product_quantity,
                    '^[[:space:]]*([0-9][0-9,]*[.]?[0-9]*)[[:space:]]*(.*)$'
                ))[1],
                ',', ''
            )::NUMERIC
        ELSE NULL
    END AS quantity_numeric,

    CASE
        WHEN s.product_quantity IS NOT NULL
         AND s.product_quantity !~ ';'
         AND s.product_quantity !~* '^[[:space:]]*[a-z][).]'
         AND regexp_match(
                 s.product_quantity,
                 '^[[:space:]]*([0-9][0-9,]*[.]?[0-9]*)[[:space:]]*(.*)$'
             ) IS NOT NULL
        THEN NULLIF(
            REGEXP_REPLACE(
                LOWER(TRIM((regexp_match(
                    s.product_quantity,
                    '^[[:space:]]*([0-9][0-9,]*[.]?[0-9]*)[[:space:]]*(.*)$'
                ))[2])),
                '[.]',
                '',
                'g'     
            ),
            ''
        )
        ELSE NULL
    END AS quantity_unit,

    CASE
        WHEN s.product_quantity IS NULL
          OR TRIM(s.product_quantity) = ''
          OR UPPER(TRIM(s.product_quantity)) IN ('N/A', 'NA', 'UNKNOWN', 'VARIOUS')
            THEN 'missing_or_unknown'

        WHEN s.product_quantity ~ ';'
          OR s.product_quantity ~* '^[[:space:]]*[a-z][).]'
            THEN 'needs_review_multiple_items'

        WHEN regexp_match(
                 s.product_quantity,
                 '^[[:space:]]*([0-9][0-9,]*[.]?[0-9]*)[[:space:]]*(.*)$'
             ) IS NOT NULL
            THEN 'parsed'

        ELSE 'needs_review_unrecognized'
    END AS quantity_parse_status

FROM analytics.stg_recalls AS s;


SELECT *
FROM analytics.stg_recalls;