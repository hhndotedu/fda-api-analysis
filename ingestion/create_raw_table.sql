CREATE TABLE raw_data (
    index       VARCHAR(255) PRIMARY KEY NOT NULL,
    raw_data    JSON NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
)
