-- Table: public.hurricane_archive_summary_staging

DROP TABLE IF EXISTS public.hurricane_archive_summary_staging;

CREATE TABLE IF NOT EXISTS public.hurricane_archive_summary_staging
(
    year integer,
    storms integer,
    hurricanes integer,
    deaths varchar(25),
    damage_millions_usd varchar(25),
    retired_names character varying(100) 
);
