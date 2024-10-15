-- Table: public.hurricane_archive_summary_staging

DROP TABLE IF EXISTS public.hurricane_archive_summary_staging;

CREATE TABLE IF NOT EXISTS public.hurricane_archive_summary_staging
(
    year integer,
    storms integer,
    hurricanes integer,
    deaths integer,
    damage_millions_usd integer,
    retired_names character varying(100) 
);