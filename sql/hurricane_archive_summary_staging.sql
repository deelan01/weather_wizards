-- Table: public.hurricane_archive_summary_db

DROP TABLE IF EXISTS public.hurricane_archive_summary_staging;

CREATE TABLE IF NOT EXISTS public.hurricane_archive_summary_staging
(
    "year" integer,
    "storms" integer,
    "hurricanes" integer,
    "deaths" character varying(100),
    "damage_millions_usd" character varying(100),
    "retired_names" character varying(100)
);
