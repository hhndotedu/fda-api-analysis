CREATE TABLE raw_data (
    index       BIGSERIAL PRIMARY KEY NOT NULL,
    raw_data    JSON NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
)
