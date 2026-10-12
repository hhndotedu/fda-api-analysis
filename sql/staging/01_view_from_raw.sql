-- Create a view to stage the recall data and ready for mart 
-- Trim the value/text to remove space
-- Input NULL for missing values 

CREATE OR REPLACE VIEW analytics.stg_recalls AS

SELECT
    "index" AS source_id,

    -- Identification
    NULLIF(TRIM(raw_data ->> 'event_id'), '') AS event_id,
    NULLIF(TRIM(raw_data ->> 'recall_number'), '') AS recall_number,

    -- Recall status and classification
    NULLIF(TRIM(raw_data ->> 'status'), '') AS status,
    NULLIF(TRIM(raw_data ->> 'classification'), '') AS classification,
    NULLIF(TRIM(raw_data ->> 'product_type'), '') AS product_type,

    -- Company and location
    NULLIF(TRIM(raw_data ->> 'recalling_firm'), '') AS recalling_firm,
    NULLIF(TRIM(raw_data ->> 'address_1'), '') AS address_1,
    NULLIF(TRIM(raw_data ->> 'address_2'), '') AS address_2,
    NULLIF(TRIM(raw_data ->> 'city'), '') AS city,
    NULLIF(TRIM(raw_data ->> 'state'), '') AS state,
    NULLIF(TRIM(raw_data ->> 'country'), '') AS country,
    NULLIF(TRIM(raw_data ->> 'postal_code'), '') AS postal_code,

    -- Product information
    NULLIF(TRIM(raw_data ->> 'product_description'), '')
        AS product_description,
    NULLIF(TRIM(raw_data ->> 'product_quantity'), '')
        AS product_quantity,
    NULLIF(TRIM(raw_data ->> 'code_info'), '') AS code_info,

    -- Recall details
    NULLIF(TRIM(raw_data ->> 'reason_for_recall'), '')
        AS reason_for_recall,
    NULLIF(TRIM(raw_data ->> 'voluntary_mandated'), '')
        AS voluntary_mandated,
    NULLIF(TRIM(raw_data ->> 'initial_firm_notification'), '')
        AS initial_firm_notification,
    NULLIF(TRIM(raw_data ->> 'distribution_pattern'), '')
        AS distribution_pattern,

    -- Dates: retain text initially
    NULLIF(TRIM(raw_data ->> 'recall_initiation_date'), '')
        AS recall_initiation_date_raw,
    NULLIF(TRIM(raw_data ->> 'center_classification_date'), '')
        AS center_classification_date_raw,
    NULLIF(TRIM(raw_data ->> 'termination_date'), '')
        AS termination_date_raw,
    NULLIF(TRIM(raw_data ->> 'report_date'), '')
        AS report_date_raw,

    -- Additional source information
    raw_data -> 'openfda' AS openfda,
    created_at AS ingested_at

FROM raw_data;

SELECT *
FROM analytics.stg_recalls;

